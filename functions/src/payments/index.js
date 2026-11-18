
const { onCall, HttpsError, onRequest } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");

const { initializeApp, getApps } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const crypto = require("node:crypto");

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();

const {
  getCashfreeClient,
  cashfreeSandboxAppId,
  cashfreeSandboxSecret,
  cashfreeProductionAppId,
  cashfreeProductionSecret,
} = require("./cashfree");

const PAYMENT_SECRETS = [
  cashfreeSandboxAppId,
  cashfreeSandboxSecret,
  cashfreeProductionAppId,
  cashfreeProductionSecret,
];

function calculateOrderAmount(items) {
  if (!Array.isArray(items) || items.length === 0) {
    throw new HttpsError("failed-precondition", "Order has no items.");
  }

  let totalPaise = 0;

  for (const item of items) {
    const price = Number(item.unitPrice);
    const quantity = Number(item.quantity);

    if (
      !Number.isFinite(price) ||
      price <= 0 ||
      !Number.isSafeInteger(quantity) ||
      quantity <= 0
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Order contains invalid item pricing."
      );
    }

    const unitPaise = Math.round(price * 100);
    const lineTotal = unitPaise * quantity;

    if (!Number.isSafeInteger(lineTotal)) {
      throw new HttpsError("failed-precondition", "Invalid order total.");
    }

    totalPaise += lineTotal;
  }

  if (!Number.isSafeInteger(totalPaise) || totalPaise <= 0) {
    throw new HttpsError("failed-precondition", "Invalid payment amount.");
  }

  return totalPaise / 100;
}

function makeCashfreeOrderId() {
  return `rest_${crypto.randomUUID().replace(/-/g, "")}`;
}

exports.createPaymentIntent = onCall(
  { secrets: PAYMENT_SECRETS },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in to pay.");
    }

    const orderId = request.data?.orderId;

    if (
      typeof orderId !== "string" ||
      !/^[a-zA-Z0-9_-]{1,128}$/.test(orderId)
    ) {
      throw new HttpsError("invalid-argument", "Invalid order ID.");
    }

    const orderRef = db.collection("takeawayOrders").doc(orderId);
    const paymentRef = db.collection("payments").doc();

    try {
      const orderSnapshot = await orderRef.get();

      if (!orderSnapshot.exists) {
        throw new HttpsError("not-found", "Order not found.");
      }

      const order = orderSnapshot.data();

      if (order.userId !== request.auth.uid) {
        throw new HttpsError(
          "permission-denied",
          "This order does not belong to you."
        );
      }

      if (order.status !== "pending") {
        throw new HttpsError(
          "failed-precondition",
          "Only pending orders can be paid."
        );
      }

      const amount = calculateOrderAmount(order.items);

      const userSnapshot = await db
        .collection("users")
        .doc(request.auth.uid)
        .get();

      const user = userSnapshot.data() || {};
      const phone = String(
        user.phoneNumber || user.phone || ""
      ).replace(/\s/g, "");

      if (!/^\+?[0-9]{10,15}$/.test(phone)) {
        throw new HttpsError(
          "failed-precondition",
          "Add a valid phone number to your account."
        );
      }

      const cashfreeOrderId = makeCashfreeOrderId();
      const cashfree = getCashfreeClient();

      const cashfreeResponse = await cashfree.PGCreateOrder({
        order_id: cashfreeOrderId,
        order_amount: amount,
        order_currency: "INR",
        customer_details: {
          customer_id: request.auth.uid
            .replace(/[^a-zA-Z0-9]/g, "")
            .slice(0, 50),
          customer_phone: phone,
          ...(user.email ? { customer_email: user.email } : {}),
          ...(user.displayName
            ? { customer_name: user.displayName }
            : {}),
        },
      });

      const cashfreeData = cashfreeResponse.data;

      if (!cashfreeData?.payment_session_id) {
        throw new Error("Cashfree did not return a payment session.");
      }

      await paymentRef.create({
        orderId,
        userId: request.auth.uid,
        amount,
        currency: "INR",
        provider: "cashfree",
        status: "pending",
        providerPaymentId: cashfreeOrderId,
        paymentSessionId: cashfreeData.payment_session_id,
        createdAt: FieldValue.serverTimestamp(),
      });

      logger.info("Cashfree order created", {
        orderId,
        cashfreeOrderId,
      });

      return {
        orderId,
        cashfreeOrderId,
        paymentSessionId: cashfreeData.payment_session_id,
        amount,
        currency: "INR",
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("Cashfree payment creation failed", {
        orderId,
        message: error.message,
      });

      throw new HttpsError("internal", "Unable to create payment.");
    }
  }
);

exports.cashfreeWebhook = onRequest(
  { secrets: PAYMENT_SECRETS },
  async (request, response) => {
    if (request.method !== "POST") {
      response.status(405).send("Method not allowed");
      return;
    }

    try {
      const signature = request.get("x-webhook-signature");
      const timestamp = request.get("x-webhook-timestamp");

      if (!signature || !timestamp || !request.rawBody) {
        response.status(400).send("Missing webhook signature.");
        return;
      }

      const cashfree = getCashfreeClient();
      const rawBody = request.rawBody.toString("utf8");

      cashfree.PGVerifyWebhookSignature(
        signature,
        rawBody,
        timestamp
      );

      const event = JSON.parse(rawBody);
      const data = event.data || {};

      const cashfreeOrderId = data.order?.order_id;
      const paymentStatus = data.payment?.payment_status;
      const webhookAmount = Number(data.payment?.payment_amount);
      const webhookCurrency = data.order?.order_currency;

      if (
        !cashfreeOrderId ||
        !paymentStatus ||
        !Number.isFinite(webhookAmount) ||
        webhookCurrency !== "INR"
      ) {
        response.status(400).send("Invalid webhook payment details.");
        return;
      }

      const statusMap = {
        SUCCESS: "captured",
        FAILED: "failed",
        USER_DROPPED: "failed",
      };

      const newStatus = statusMap[paymentStatus];

      if (!newStatus) {
        response.status(200).send("Event acknowledged.");
        return;
      }

      const query = await db
        .collection("payments")
        .where("providerPaymentId", "==", cashfreeOrderId)
        .limit(1)
        .get();

      if (query.empty) {
        response.status(404).send("Payment not found.");
        return;
      }

      const paymentRef = query.docs[0].ref;

      await db.runTransaction(async (transaction) => {
        const snapshot = await transaction.get(paymentRef);

        if (!snapshot.exists) {
          return;
        }

        const current = snapshot.data();

        if (
          current.status !== "pending" ||
          current.currency !== "INR" ||
          Math.abs(Number(current.amount) - webhookAmount) > 0.001
        ) {
          return;
        }

        transaction.update(paymentRef, {
          status: newStatus,
          updatedAt: FieldValue.serverTimestamp(),
        });
      });

      response.status(200).send("Webhook processed.");
    } catch (error) {
      logger.error("Cashfree webhook processing failed", {
        message: error.message,
      });

      response.status(400).send("Webhook verification failed.");
    }
  }
);
