const { onRequest } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const { initializeApp } = require("firebase-admin/app");

initializeApp();

setGlobalOptions({
  region: "asia-south1",
  maxInstances: 10,
});

exports.health = onRequest((request, response) => {
  response.status(200).json({
    status: "healthy",
    service: "restaurant-api",
  });
});