
const crypto = require("node:crypto");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

const db = getFirestore();

function tokenId(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

function requireAuth(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }
}

exports.registerFcmToken = onCall(async (request) => {
  requireAuth(request);

  const { token, platform = "unknown" } = request.data || {};

  if (typeof token !== "string" || token.length < 20 || token.length > 4096) {
    throw new HttpsError("invalid-argument", "Invalid FCM token.");
  }

  if (!["android", "ios", "web", "unknown"].includes(platform)) {
    throw new HttpsError("invalid-argument", "Invalid platform.");
  }

  await db.collection("users").doc(request.auth.uid)
    .collection("fcmTokens").doc(tokenId(token))
    .set({
      token,
      platform,
      updatedAt: FieldValue.serverTimestamp(),
    });

  return { success: true };
});

exports.removeFcmToken = onCall(async (request) => {
  requireAuth(request);

  const { token } = request.data || {};

  if (typeof token !== "string" || token.length < 20 || token.length > 4096) {
    throw new HttpsError("invalid-argument", "Invalid FCM token.");
  }

  await db.collection("users").doc(request.auth.uid)
    .collection("fcmTokens").doc(tokenId(token)).delete();

  return { success: true };
});

exports.sendPushNotification = onCall(async (request) => {
  requireAuth(request);

  if (request.auth.token.admin !== true) {
    throw new HttpsError("permission-denied", "Admin access required.");
  }

  const { uid, title, body, data = {} } = request.data || {};

  if (
    typeof uid !== "string" ||
    typeof title !== "string" ||
    typeof body !== "string" ||
    !uid.trim() ||
    !title.trim() ||
    !body.trim() ||
    title.length > 200 ||
    body.length > 2000
  ) {
    throw new HttpsError("invalid-argument", "Invalid notification details.");
  }

  if (
    !data ||
    typeof data !== "object" ||
    Array.isArray(data) ||
    Object.keys(data).length > 20 ||
    Object.values(data).some(
      (value) => typeof value !== "string" || value.length > 1000
    )
  ) {
    throw new HttpsError("invalid-argument", "Invalid notification data.");
  }

  const snapshot = await db.collection("users").doc(uid)
    .collection("fcmTokens").get();

  if (snapshot.empty) {
    return { success: true, sent: 0, failed: 0 };
  }

  const validDocs = snapshot.docs.filter(
    (doc) => typeof doc.data().token === "string" && doc.data().token.length > 0
  );

  let sent = 0;
  let failed = 0;

  for (let i = 0; i < validDocs.length; i += 500) {
    const docs = validDocs.slice(i, i + 500);
    const tokens = docs.map((doc) => doc.data().token);

    const result = await getMessaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data,
    });

    sent += result.successCount;
    failed += result.failureCount;

    const batch = db.batch();

    result.responses.forEach((response, index) => {
      if (
        !response.success &&
        [
          "messaging/invalid-registration-token",
          "messaging/registration-token-not-registered",
        ].includes(response.error?.code)
      ) {
        batch.delete(docs[index].ref);
      }
    });

    await batch.commit();
  }

  return { success: true, sent, failed };
});
