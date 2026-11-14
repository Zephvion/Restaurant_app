const { HttpsError } = require("firebase-functions/v2/https");

const ROLES = Object.freeze({
  CUSTOMER: "customer",
  ADMIN: "admin",
  BRANCH_MANAGER: "branch_manager",
  KITCHEN_STAFF: "kitchen_staff",
  OPERATIONAL_STAFF: "operational_staff",
});

function requireAuthentication(request) {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Authentication is required."
    );
  }

  return request.auth;
}

function getUserRole(auth) {
  if (auth.token.admin === true) {
    return ROLES.ADMIN;
  }

  const role = auth.token.role;

  return Object.values(ROLES).includes(role)
    ? role
    : ROLES.CUSTOMER;
}

function requireRole(request, allowedRoles) {
  const auth = requireAuthentication(request);
  const role = getUserRole(auth);

  if (!allowedRoles.includes(role)) {
    throw new HttpsError(
      "permission-denied",
      "You do not have permission to perform this operation."
    );
  }

  return {
    uid: auth.uid,
    role,
    branchIds: Array.isArray(auth.token.branchIds)
      ? auth.token.branchIds
      : [],
    kitchenIds: Array.isArray(auth.token.kitchenIds)
      ? auth.token.kitchenIds
      : [],
  };
}

function requireBranchAccess(user, branchId) {
  if (user.role === ROLES.ADMIN) return true;

  if (
    !branchId ||
    !user.branchIds.includes(branchId)
  ) {
    throw new HttpsError(
      "permission-denied",
      "Access to this branch is not permitted."
    );
  }

  return true;
}

function requireKitchenAccess(user, kitchenId) {
  if (user.role === ROLES.ADMIN) return true;

  if (
    !kitchenId ||
    !user.kitchenIds.includes(kitchenId)
  ) {
    throw new HttpsError(
      "permission-denied",
      "Access to this kitchen is not permitted."
    );
  }

  return true;
}

function requireOwnership(user, resourceUserId) {
  if (
    user.role !== ROLES.ADMIN &&
    user.uid !== resourceUserId
  ) {
    throw new HttpsError(
      "permission-denied",
      "You cannot access another user's resource."
    );
  }

  return true;
}

module.exports = {
  ROLES,
  requireAuthentication,
  getUserRole,
  requireRole,
  requireBranchAccess,
  requireKitchenAccess,
  requireOwnership,
};