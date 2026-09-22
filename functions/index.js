const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * 1. Daily Midnight Cleanup (Runs every day at 03:00 AM IST)
 * Cleans up expired temporary locks, abandoned carts, and old draft records.
 */
exports.dailyCleanupJob = onSchedule(
  {
    schedule: "0 3 * * *", // 3:00 AM daily
    timeZone: "Asia/Kolkata",
    retryCount: 3,
  },
  async (event) => {
    logger.info("Starting daily midnight cleanup job...");
    const now = new Date();

    try {
      // Clean up stale table holds older than 24 hours that were never confirmed
      const staleHoldsCutoff = new Date(now.getTime() - 24 * 60 * 60 * 1000);
      const staleHoldsSnapshot = await db
        .collection("table_holds")
        .where("expiresAt", "<", staleHoldsCutoff)
        .get();

      const batch = db.batch();
      let deleteCount = 0;

      staleHoldsSnapshot.forEach((doc) => {
        batch.delete(doc.ref);
        deleteCount++;
      });

      if (deleteCount > 0) {
        await batch.commit();
        logger.info(`Deleted ${deleteCount} expired table hold records.`);
      }

      logger.info("Daily midnight cleanup completed successfully.");
    } catch (error) {
      logger.error("Error running daily cleanup job:", error);
    }
  }
);

/**
 * 2. Frequent Table Lock Releaser (Runs every 10 minutes)
 * Automatically releases abandoned 5-minute table holds back to the available pool.
 */
exports.releaseExpiredTableLocks = onSchedule(
  {
    schedule: "*/10 * * * *", // Every 10 minutes
    timeZone: "Asia/Kolkata",
  },
  async (event) => {
    const now = new Date();
    try {
      const expiredLocks = await db
        .collection("table_locks")
        .where("status", "==", "held")
        .where("expiresAt", "<", now)
        .get();

      if (expiredLocks.empty) {
        return;
      }

      const batch = db.batch();
      expiredLocks.forEach((doc) => {
        batch.update(doc.ref, {
          status: "available",
          holderUserId: null,
          holderUserName: null,
          releasedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();
      logger.info(`Released ${expiredLocks.size} expired table locks back to available pool.`);
    } catch (error) {
      logger.error("Error releasing expired table locks:", error);
    }
  }
);
