
const {
  Cashfree,
  CFEnvironment,
} = require("cashfree-pg");

const { defineSecret } = require("firebase-functions/params");

const cashfreeSandboxAppId = defineSecret("CASHFREE_SANDBOX_APP_ID");
const cashfreeSandboxSecret = defineSecret("CASHFREE_SANDBOX_SECRET");

const cashfreeProductionAppId = defineSecret("CASHFREE_PRODUCTION_APP_ID");
const cashfreeProductionSecret = defineSecret("CASHFREE_PRODUCTION_SECRET");

function getCashfreeClient() {
  const environment = process.env.APP_ENV || "development";
  const isProduction = environment === "production";

  const appId = isProduction
    ? cashfreeProductionAppId.value()
    : cashfreeSandboxAppId.value();

  const secret = isProduction
    ? cashfreeProductionSecret.value()
    : cashfreeSandboxSecret.value();

  if (!appId || !secret) {
    throw new Error("Cashfree credentials are not configured.");
  }

  return new Cashfree(
    isProduction ? CFEnvironment.PRODUCTION : CFEnvironment.SANDBOX,
    appId,
    secret
  );
}

module.exports = {
  getCashfreeClient,
  cashfreeSandboxAppId,
  cashfreeSandboxSecret,
  cashfreeProductionAppId,
  cashfreeProductionSecret,
};
