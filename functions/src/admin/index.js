const { onCall } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");

const {
  ROLES,
  requireRole,
} = require("./rbac");

exports.runAdminOperation = onCall(async (request) => {
  const user = requireRole(request, [ROLES.ADMIN]);

  const { operation } = request.data || {};

  if (typeof operation !== "string" || !operation.trim()) {
    const { HttpsError } = require("firebase-functions/v2/https");

    throw new HttpsError(
      "invalid-argument",
      "A valid operation is required."
    );
  }

  logger.info("Authorized admin operation requested", {
    operation,
    adminUid: user.uid,
    role: user.role,
  });

  return {
    success: true,
    status: "pending_implementation",
    message: "The requested admin operation is not implemented yet.",
  };
});