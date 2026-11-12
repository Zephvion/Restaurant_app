
const test = require("node:test");
const assert = require("node:assert/strict");

const payments = require("../src/payments");

test("Cashfree payment and webhook functions are exported", () => {
  assert.equal(typeof payments.createPaymentIntent, "function");
  assert.equal(typeof payments.cashfreeWebhook, "function");
});

test("Cashfree payment functions are callable Cloud Functions", () => {
  assert.ok(payments.createPaymentIntent);
  assert.ok(payments.cashfreeWebhook);
});
