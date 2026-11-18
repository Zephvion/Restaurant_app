const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");
const { getFirestore } = require("firebase-admin/firestore");

exports.cleanupExpiredReservations = onSchedule(
  {
    schedule: "every 24 hours",
    timeZone: "Asia/Kolkata",
    region: "asia-south1",
  },
  async () => {
    const db = getFirestore();

    const snapshot = await db
      .collection("reservations")
      .where("status", "==", "pending")
      .get();

    const now = new Date();

    const pastReservations = snapshot.docs.filter((doc) => {
      const data = doc.data();
      const reservationDate = data.date?.toDate
        ? data.date.toDate()
        : new Date(data.date);

      return (
        !Number.isNaN(reservationDate.getTime()) &&
        reservationDate < now
      );
    });

    logger.info("Past pending reservations identified", {
      count: pastReservations.length,
      action: "review_only",
    });
  }
);