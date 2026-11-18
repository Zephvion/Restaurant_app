const { initializeApp, getApps } = require("firebase-admin/app");

const firebaseApp = getApps().length
  ? getApps()[0]
  : initializeApp();

module.exports = { firebaseApp };