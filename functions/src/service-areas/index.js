
"use strict";

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const {
  ROLES,
  requireRole,
  requireBranchAccess,
} = require("../admin/rbac");

const COLLECTION = "serviceAreas";
const EARTH_RADIUS_KM = 6371;

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
  if (
    !polygon ||
    polygon.type !== "Polygon" ||
    !Array.isArray(polygon.coordinates) ||
    polygon.coordinates.length === 0
  ) {
    return false;
  }

  const rings = polygon.coordinates;

  if (!pointInRing(longitude, latitude, rings[0])) {
    return false;
  }

  return !rings.slice(1).some((hole) =>
    pointInRing(longitude, latitude, hole)
  );
}

function haversineDistanceKm(lat1, lon1, lat2, lon2) {
  const toRadians = (degrees) => (degrees * Math.PI) / 180;

  const latitudeDifference = toRadians(lat2 - lat1);
  const longitudeDifference = toRadians(lon2 - lon1);

  const a =
    Math.sin(latitudeDifference / 2) ** 2 +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(longitudeDifference / 2) ** 2;

  const centralAngle = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return EARTH_RADIUS_KM * centralAngle;
}

function selectNearestBranch(candidates) {
  if (!Array.isArray(candidates) || candidates.length === 0) {
    return null;
  }

  return [...candidates].sort((a, b) => {
    if (a.distanceKm !== b.distanceKm) {
      return a.distanceKm - b.distanceKm;
    }

    return String(a.branchId).localeCompare(String(b.branchId));
  })[0];
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

  if (
    !serviceAreaId ||
    !updates ||
    typeof updates !== "object" ||
    Array.isArray(updates)
  ) {
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
    return {
      serviceable: false,
      message: "Delivery is not available at this location.",
    };
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

exports.resolveNearestBranch = onCall(async (request) => {
  const {
    latitude,
    longitude,
    orderValue = 0,
    restaurantId,
  } = request.data || {};

  if (
    !Number.isFinite(latitude) ||
    !Number.isFinite(longitude) ||
    latitude < -90 ||
    latitude > 90 ||
    longitude < -180 ||
    longitude > 180 ||
    !Number.isFinite(orderValue) ||
    orderValue < 0 ||
    (restaurantId !== undefined &&
      (typeof restaurantId !== "string" || !restaurantId.trim()))
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Valid customer coordinates and order value are required."
    );
  }

  const db = getFirestore();

  const areasSnapshot = await db
    .collection(COLLECTION)
    .where("status", "==", "active")
    .get();

  const branchCache = new Map();
  const candidates = [];

  for (const areaDocument of areasSnapshot.docs) {
    const area = areaDocument.data();

    if (
      !area.branchId ||
      !area.restaurantId ||
      (restaurantId && area.restaurantId !== restaurantId)
    ) {
      continue;
    }

    if (!pointInPolygon(longitude, latitude, area.polygon)) {
      continue;
    }

    let branch = branchCache.get(area.branchId);

    if (branch === undefined) {
      const branchSnapshot = await db
        .collection("branches")
        .doc(area.branchId)
        .get();

      branch = branchSnapshot.exists ? branchSnapshot.data() : null;
      branchCache.set(area.branchId, branch);
    }

    if (!branch || branch.status === "inactive") {
      continue;
    }

    if (branch.restaurantId !== area.restaurantId) {
      continue;
    }

    if (
      !Number.isFinite(branch.latitude) ||
      !Number.isFinite(branch.longitude) ||
      branch.latitude < -90 ||
      branch.latitude > 90 ||
      branch.longitude < -180 ||
      branch.longitude > 180
    ) {
      continue;
    }

    const distanceKm = haversineDistanceKm(
      latitude,
      longitude,
      branch.latitude,
      branch.longitude
    );

    if (
      !Number.isFinite(area.maxDeliveryDistanceKm) ||
      area.maxDeliveryDistanceKm < 0 ||
      distanceKm > area.maxDeliveryDistanceKm
    ) {
      continue;
    }

    candidates.push({
      branchId: area.branchId,
      restaurantId: area.restaurantId,
      serviceAreaId: areaDocument.id,
      distanceKm,
      deliveryFee: area.deliveryFee,
      minimumOrderValue: area.minimumOrderValue,
      minimumOrderMet: orderValue >= area.minimumOrderValue,
      estimatedDeliveryMinutes: area.estimatedDeliveryMinutes,
    });
  }

  const nearest = selectNearestBranch(candidates);

  if (!nearest) {
    return {
      serviceable: false,
      message: "No eligible branch delivers to this location.",
      reason: "NO_MATCHING_BRANCH",
    };
  }

  return {
    serviceable: true,
    ...nearest,
    distanceKm: Number(nearest.distanceKm.toFixed(2)),
  };
});

module.exports.validatePolygon = validatePolygon;
module.exports.validateServiceArea = validateServiceArea;
module.exports.pointInPolygon = pointInPolygon;
module.exports.haversineDistanceKm = haversineDistanceKm;
module.exports.selectNearestBranch = selectNearestBranch;
