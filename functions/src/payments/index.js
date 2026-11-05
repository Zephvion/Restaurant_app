const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");

const SUPPORTED_CURRENCIES = ["INR"];

exports.createPaymentIntent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be signed in to create a payment."
    );
  }

  const data = request.data || {};
  const { orderId, amount, currency = "INR" } = data;

  if (
    typeof orderId !== "string" ||
    orderId.trim().length === 0 ||
    orderId.length > 128
  ) {
    throw new HttpsError(
      "invalid-argument",
      "A valid order ID is required."
    );
  }

  if (
    typeof amount !== "number" ||
    !Number.isSafeInteger(amount) ||
    amount <= 0
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Amount must be a positive integer in the smallest currency unit."
    );
  }

  if (!SUPPORTED_CURRENCIES.includes(currency)) {
    throw new HttpsError(
      "invalid-argument",
      "Unsupported payment currency."
    );
  }

  logger.info("Payment request validated", {
    orderId: orderId.trim(),
    userId: request.auth.uid,
    currency,
  });

  return {
    status: "pending_integration",
    orderId: orderId.trim(),
    amount,
    currency,
    message: "Payment provider integration is not configured.",
  };
});