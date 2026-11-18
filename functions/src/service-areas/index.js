"use strict";

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const {
  ROLES,
  requireRole,
  requireBranchAccess,
} = require("../admin/rbac");

const COLLECTION = "serviceAreas";

function validatePolygon(polygon) {
  if (
    !polygon ||
    polygon.type !== "Polygon" ||
    !Array.isArray(polygon.coordinates) ||
    polygon.coordinates.length === 0
  ) {
    throw new HttpsError("invalid-argument", "A valid GeoJSON Polygon is required.");
  }

  polygon.coordinates.forEach((ring) => {
    if (!Array.isArray(ring) || ring.length < 4) {
      throw new HttpsError("invalid-argument", "Polygon rings need at least four positions.");
    }

    ring.forEach((position) => {
      if (
        !Array.isArray(position) ||
        position.length < 2 ||
        !Number.isFinite(position[0]) ||
        !Number.isFinite(position[1]) ||
        position[0] < -180 ||
        position[0] > 180 ||
        position[1] < -90 ||
        position[1] > 90
      ) {
        throw new HttpsError("invalid-argument", "Invalid longitude/latitude coordinate.");
      }
    });

    const first = ring[0];
    const last = ring[ring.length - 1];

    if (first[0] !== last[0] || first[1] !== last[1]) {
      throw new HttpsError("invalid-argument", "Polygon rings must be closed.");
    }
  });

  return true;
}

function validateServiceArea(data) {
  if (!data || typeof data !== "object") {
    throw new HttpsError("invalid-argument", "Service-area data is required.");
  }

  for (const field of ["branchId", "restaurantId", "name"]) {
    if (typeof data[field] !== "string" || !data[field].trim()) {
      throw new HttpsError("invalid-argument", `${field} is required.`);
    }
  }

  validatePolygon(data.polygon);

  for (const field of [
    "deliveryFee",
    "minimumOrderValue",
    "maxDeliveryDistanceKm",
    "estimatedDeliveryMinutes",
  ]) {
    if (!Number.isFinite(data[field]) || data[field] < 0) {
      throw new HttpsError("invalid-argument", `${field} must be non-negative.`);
    }
  }

  if (data.estimatedDeliveryMinutes <= 0) {
    throw new HttpsError("invalid-argument", "Estimated delivery time must be positive.");
  }

  if (!["active", "inactive"].includes(data.status || "active")) {
    throw new HttpsError("invalid-argument", "Invalid service-area status.");
  }
}

function pointInRing(longitude, latitude, ring) {
  let inside = false;

  for (let i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    const [xi, yi] = ring[i];
    const [xj, yj] = ring[j];

    const intersects =
      yi > latitude !== yj > latitude &&
      longitude < ((xj - xi) * (latitude - yi)) / (yj - yi) + xi;

    if (intersects) inside = !inside;
  }

  return inside;
}

function pointInPolygon(longitude, latitude, polygon) {
  const rings = polygon.coordinates;

  if (!pointInRing(longitude, latitude, rings[0])) {
    return false;
  }

  return !rings.slice(1).some((hole) =>
    pointInRing(longitude, latitude, hole)
  );
}

async function verifyBranch(db, user, branchId) {
  requireBranchAccess(user, branchId);

  const branchSnapshot = await db.collection("branches").doc(branchId).get();

  if (!branchSnapshot.exists) {
    throw new HttpsError("not-found", "Branch not found.");
  }

  return branchSnapshot.data();
}

exports.createServiceArea = onCall(async (request) => {
  const user = requireRole(request, [ROLES.ADMIN, ROLES.BRANCH_MANAGER]);
  const db = getFirestore();
  const data = request.data || {};

  validateServiceArea(data);
  const branch = await verifyBranch(db, user, data.branchId);

  if (branch.restaurantId !== data.restaurantId) {
    throw new HttpsError("invalid-argument", "Restaurant does not own this branch.");
  }

  const ref = db.collection(COLLECTION).doc();

  await ref.set({
    ...data,
    status: data.status || "active",
    createdBy: user.uid,
    updatedBy: user.uid,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { success: true, serviceAreaId: ref.id };
});

exports.updateServiceArea = onCall(async (request) => {
  const user = requireRole(request, [ROLES.ADMIN, ROLES.BRANCH_MANAGER]);
  const db = getFirestore();
  const { serviceAreaId, updates } = request.data || {};

  if (!serviceAreaId || !updates || typeof updates !== "object") {
    throw new HttpsError("invalid-argument", "Service area ID and updates are required.");
  }

  const ref = db.collection(COLLECTION).doc(serviceAreaId);
  const snapshot = await ref.get();

  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Service area not found.");
  }

  const existing = snapshot.data();
  requireBranchAccess(user, existing.branchId);

  const updated = { ...existing, ...updates };

  if (
    updated.branchId !== existing.branchId ||
    updated.restaurantId !== existing.restaurantId
  ) {
    throw new HttpsError("invalid-argument", "Branch ownership cannot be changed.");
  }

  validateServiceArea(updated);

  await ref.update({
    ...updates,
    updatedBy: user.uid,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { success: true, serviceAreaId };
});

exports.listServiceAreas = onCall(async (request) => {
  const user = requireRole(request, [ROLES.ADMIN, ROLES.BRANCH_MANAGER]);
  const { branchId } = request.data || {};

  requireBranchAccess(user, branchId);

  const snapshot = await getFirestore()
    .collection(COLLECTION)
    .where("branchId", "==", branchId)
    .get();

  return {
    serviceAreas: snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    })),
  };
});

exports.checkDeliveryServiceability = onCall(async (request) => {
  const { branchId, longitude, latitude, orderValue } = request.data || {};

  if (
    typeof branchId !== "string" ||
    !Number.isFinite(longitude) ||
    !Number.isFinite(latitude) ||
    longitude < -180 ||
    longitude > 180 ||
    latitude < -90 ||
    latitude > 90 ||
    !Number.isFinite(orderValue) ||
    orderValue < 0
  ) {
    throw new HttpsError("invalid-argument", "Valid branch, coordinates and order value are required.");
  }

  const snapshot = await getFirestore()
    .collection(COLLECTION)
    .where("branchId", "==", branchId)
    .where("status", "==", "active")
    .get();

  const matching = snapshot.docs.find((doc) =>
    pointInPolygon(longitude, latitude, doc.data().polygon)
  );

  if (!matching) {
    return { serviceable: false, message: "Delivery is not available at this location." };
  }

  const area = matching.data();

  return {
    serviceable: true,
    serviceAreaId: matching.id,
    deliveryFee: area.deliveryFee,
    minimumOrderValue: area.minimumOrderValue,
    minimumOrderMet: orderValue >= area.minimumOrderValue,
    estimatedDeliveryMinutes: area.estimatedDeliveryMinutes,
  };
});

module.exports.validatePolygon = validatePolygon;
module.exports.validateServiceArea = validateServiceArea;
module.exports.pointInPolygon = pointInPolygon;