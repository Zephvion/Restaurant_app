
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");
const { getFirestore } = require("firebase-admin/firestore");

const { ROLES, requireRole } = require("./rbac");
const {
  AUDIT_COLLECTION,
  performAuditedMutation,
} = require("./audit");

const MUTABLE_RESOURCES = Object.freeze({
  products: ["create", "update", "delete"],
  dishes: ["create", "update", "delete"],
  menuCategories: ["create", "update", "delete"],
  inventory: ["update"],
  reservations: ["update"],
  onboardingItems: ["create", "update", "delete"],
  serviceItems: ["create", "update", "delete"],
  promoBanners: ["create", "update", "delete"],
});

function getAuditAction(collection, operation, data) {
  if (collection === "inventory") {
    return "inventory.updated";
  }

  if (collection === "reservations") {
    return "reservation.updated";
  }

  if (
    ["onboardingItems", "serviceItems", "promoBanners"].includes(collection)
  ) {
    return `content.${operation === "create" ? "created" : operation === "delete" ? "deleted" : "updated"}`;
  }

  if (
    operation === "update" &&
    ["products", "dishes"].includes(collection) &&
    (Object.hasOwn(data, "price") || Object.hasOwn(data, "oldPrice"))
  ) {
    return "pricing.updated";
  }

  return `catalog.${operation === "create" ? "created" : operation === "delete" ? "deleted" : "updated"}`;
}

exports.runAdminOperation = onCall(async (request) => {
  const user = requireRole(request, [ROLES.ADMIN]);
  const { operation } = request.data || {};

  if (typeof operation !== "string" || !operation.trim()) {
    throw new HttpsError("invalid-argument", "A valid operation is required.");
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

exports.adminMutateResource = onCall(async (request) => {
  requireRole(request, [ROLES.ADMIN]);

  const {
    collection,
    resourceId,
    operation,
    data = {},
    metadata = {},
  } = request.data || {};

  if (
    typeof collection !== "string" ||
    !Object.hasOwn(MUTABLE_RESOURCES, collection)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "This resource collection cannot be modified through this endpoint."
    );
  }

  if (!MUTABLE_RESOURCES[collection].includes(operation)) {
    throw new HttpsError(
      "invalid-argument",
      "This operation is not allowed for the selected resource."
    );
  }

  if (typeof resourceId !== "string" || !resourceId.trim()) {
    throw new HttpsError("invalid-argument", "A resource ID is required.");
  }

  if (!data || typeof data !== "object" || Array.isArray(data)) {
    throw new HttpsError("invalid-argument", "Data must be an object.");
  }

  const action = getAuditAction(collection, operation, data);

  return performAuditedMutation({
    db: getFirestore(),
    auth: request.auth,
    collection,
    resourceType: collection,
    resourceId: resourceId.trim(),
    operation,
    action,
    data,
    metadata,
  });
});

exports.getAdminAuditLogs = onCall(async (request) => {
  requireRole(request, [ROLES.ADMIN]);

  const limit = Number(request.data?.limit ?? 50);

  if (!Number.isInteger(limit) || limit < 1 || limit > 100) {
    throw new HttpsError(
      "invalid-argument",
      "Limit must be an integer between 1 and 100."
    );
  }

  const db = getFirestore();
  let query = db
    .collection(AUDIT_COLLECTION)
    .orderBy("createdAt", "desc")
    .limit(limit);

  const cursorId = request.data?.cursor;

  if (cursorId !== undefined) {
    if (typeof cursorId !== "string" || !cursorId.trim()) {
      throw new HttpsError("invalid-argument", "Invalid audit cursor.");
    }

    const cursor = await db.collection(AUDIT_COLLECTION).doc(cursorId).get();

    if (!cursor.exists) {
      throw new HttpsError("invalid-argument", "Audit cursor not found.");
    }

    query = query.startAfter(cursor);
  }

  const snapshot = await query.get();

  return {
    logs: snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    })),
    nextCursor:
      snapshot.docs.length === limit
        ? snapshot.docs[snapshot.docs.length - 1].id
        : null,
  };
});
