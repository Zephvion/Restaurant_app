
const test = require("node:test");
const assert = require("node:assert/strict");

const functions = require("../index");

test("health function is exported", () => {
  assert.equal(typeof functions.health, "function");
});

test("payment function is exported", () => {
  assert.equal(typeof functions.createPaymentIntent, "function");
});

test("scheduled cleanup job is exported", () => {
  assert.equal(typeof functions.cleanupExpiredReservations, "function");
});

test("admin operation is exported", () => {
  assert.equal(typeof functions.runAdminOperation, "function");
});

test("admin audit log reader is exported", () => {
  assert.equal(typeof functions.getAdminAuditLogs, "function");
});

test("admin resource mutation endpoint is exported", () => {
  assert.equal(typeof functions.adminMutateResource, "function");
});
