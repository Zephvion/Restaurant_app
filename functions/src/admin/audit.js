
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { HttpsError } = require("firebase-functions/v2/https");
const { validateDocument } = require("../../firestore-schema");
const { ROLES, requireRole } = require("./rbac");

const AUDIT_COLLECTION = "adminAuditLogs";

const AUDIT_ACTIONS = Object.freeze([
  "pricing.updated",
  "inventory.updated",
  "catalog.created",
  "catalog.updated",
  "catalog.deleted",
  "plan.created",
  "plan.updated",
  "plan.deleted",
  "reservation.updated",
  "content.created",
  "content.updated",
  "content.deleted",
]);

async function writeAdminAudit({
  db,
  auth,
  action,
  resourceType,
  resourceId,
  before = null,
  after = null,
  metadata = {},
  serverTimestamp = FieldValue.serverTimestamp,
}) {
  if (!auth || !auth.uid) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }

  requireRole({ auth }, [ROLES.ADMIN]);

  if (!AUDIT_ACTIONS.includes(action)) {
    throw new HttpsError("invalid-argument", "Unsupported audit action.");
  }

  if (
    typeof resourceType !== "string" || !resourceType.trim() ||
    typeof resourceId !== "string" || !resourceId.trim()
  ) {
    throw new HttpsError("invalid-argument", "Resource type and ID are required.");
  }

  if (!metadata || typeof metadata !== "object" || Array.isArray(metadata)) {
    throw new HttpsError("invalid-argument", "Metadata must be an object.");
  }

  const entry = {
    actorUid: auth.uid,
    actorRole: auth.token?.role || ROLES.ADMIN,
    action,
    resourceType: resourceType.trim(),
    resourceId: resourceId.trim(),
    before,
    after,
    metadata,
    createdAt: serverTimestamp(),
  };

  const document = await db.collection(AUDIT_COLLECTION).add(entry);

  return { success: true, auditId: document.id };
}

async function performAuditedMutation({
  db = getFirestore(),
  auth,
  collection,
  resourceType,
  resourceId,
  operation,
  action,
  data = {},
  metadata = {},
}) {
  if (!auth || !auth.uid) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }

  requireRole({ auth }, [ROLES.ADMIN]);

  if (!AUDIT_ACTIONS.includes(action)) {
    throw new HttpsError("invalid-argument", "Unsupported audit action.");
  }

  if (
    typeof collection !== "string" || !collection.trim() ||
    typeof resourceType !== "string" || !resourceType.trim() ||
    typeof resourceId !== "string" || !resourceId.trim()
  ) {
    throw new HttpsError("invalid-argument", "Resource information is required.");
  }

  if (!["create", "update", "delete"].includes(operation)) {
    throw new HttpsError("invalid-argument", "Unsupported mutation operation.");
  }

  if (!data || typeof data !== "object" || Array.isArray(data)) {
    throw new HttpsError("invalid-argument", "Data must be an object.");
  }

  if (!metadata || typeof metadata !== "object" || Array.isArray(metadata)) {
    throw new HttpsError("invalid-argument", "Metadata must be an object.");
  }

  const resourceRef = db.collection(collection).doc(resourceId);
  const auditRef = db.collection(AUDIT_COLLECTION).doc();

  return db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(resourceRef);
    const exists = snapshot.exists;

    if (operation === "create" && exists) {
      throw new HttpsError("already-exists", "Resource already exists.");
    }

    if (operation !== "create" && !exists) {
      throw new HttpsError("not-found", "Resource not found.");
    }

    const before = exists ? snapshot.data() : null;
    const after = operation === "delete"
      ? null
      : operation === "create"
        ? data
        : { ...before, ...data };

    if (after !== null) {
      validateDocument(collection, after);
    }

    if (operation === "create") {
      transaction.create(resourceRef, after);
    } else if (operation === "update") {
      transaction.set(resourceRef, data, { merge: true });
    } else {
      transaction.delete(resourceRef);
    }

    transaction.create(auditRef, {
      actorUid: auth.uid,
      actorRole: auth.token?.role || ROLES.ADMIN,
      action,
      resourceType: resourceType.trim(),
      resourceId: resourceId.trim(),
      before,
      after,
      metadata,
      createdAt: FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      resourceId,
      auditId: auditRef.id,
      operation,
    };
  });
}

async function recordAdminAudit(options) {
  return writeAdminAudit({
    ...options,
    db: getFirestore(),
  });
}

module.exports = {
  AUDIT_COLLECTION,
  AUDIT_ACTIONS,
  recordAdminAudit,
  writeAdminAudit,
  performAuditedMutation,
};
