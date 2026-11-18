
const test = require("node:test");
const assert = require("node:assert/strict");

const { initializeApp, getApps } = require("firebase-admin/app");

if (getApps().length === 0) {
  initializeApp({ projectId: "restaurant-app-test" });
}

const notifications = require("../src/notifications");

test("FCM token registration function is exported", () => {
  assert.equal(typeof notifications.registerFcmToken, "function");
});

test("FCM token removal function is exported", () => {
  assert.equal(typeof notifications.removeFcmToken, "function");
});

test("Admin push notification function is exported", () => {
  assert.equal(typeof notifications.sendPushNotification, "function");
});

test("All notification functions are callable Cloud Functions", () => {
  for (const name of [
    "registerFcmToken",
    "removeFcmToken",
    "sendPushNotification",
  ]) {
    assert.equal(typeof notifications[name], "function");
  }
});
