const test = require("node:test");
const assert = require("node:assert/strict");

const { HttpsError } = require("firebase-functions/v2/https");

const {
  ROLES,
  requireAuthentication,
  getUserRole,
  requireRole,
  requireBranchAccess,
  requireKitchenAccess,
  requireOwnership,
} = require("../src/admin/rbac");

test("unauthenticated requests are rejected", () => {
  assert.throws(
    () => requireAuthentication({}),
    (error) => error instanceof HttpsError &&
      error.code === "unauthenticated"
  );
});

test("users default to customer role", () => {
  assert.equal(
    getUserRole({ token: {} }),
    ROLES.CUSTOMER
  );
});

test("legacy admin claim maps to admin role", () => {
  assert.equal(
    getUserRole({ token: { admin: true } }),
    ROLES.ADMIN
  );
});

test("unknown roles default to customer", () => {
  assert.equal(
    getUserRole({ token: { role: "superuser" } }),
    ROLES.CUSTOMER
  );
});

test("admin role is accepted by requireRole", () => {
  const user = requireRole(
    { auth: { uid: "admin-1", token: { admin: true } } },
    [ROLES.ADMIN]
  );

  assert.equal(user.role, ROLES.ADMIN);
});

test("customer cannot access admin-only operations", () => {
  assert.throws(
    () => requireRole(
      { auth: { uid: "user-1", token: {} } },
      [ROLES.ADMIN]
    ),
    (error) => error instanceof HttpsError &&
      error.code === "permission-denied"
  );
});

test("branch manager can access assigned branch", () => {
  const user = {
    role: ROLES.BRANCH_MANAGER,
    branchIds: ["branch-1"],
  };

  assert.equal(
    requireBranchAccess(user, "branch-1"),
    true
  );
});

test("branch manager cannot access unassigned branch", () => {
  const user = {
    role: ROLES.BRANCH_MANAGER,
    branchIds: ["branch-1"],
  };

  assert.throws(
    () => requireBranchAccess(user, "branch-2"),
    (error) => error instanceof HttpsError &&
      error.code === "permission-denied"
  );
});

test("kitchen staff can access assigned kitchen", () => {
  const user = {
    role: ROLES.KITCHEN_STAFF,
    kitchenIds: ["kitchen-1"],
  };

  assert.equal(
    requireKitchenAccess(user, "kitchen-1"),
    true
  );
});

test("kitchen staff cannot access unassigned kitchen", () => {
  const user = {
    role: ROLES.KITCHEN_STAFF,
    kitchenIds: ["kitchen-1"],
  };

  assert.throws(
    () => requireKitchenAccess(user, "kitchen-2"),
    (error) => error instanceof HttpsError &&
      error.code === "permission-denied"
  );
});

test("customers can access their own resources", () => {
  assert.equal(
    requireOwnership(
      { uid: "user-1", role: ROLES.CUSTOMER },
      "user-1"
    ),
    true
  );
});

test("customers cannot access another user's resources", () => {
  assert.throws(
    () => requireOwnership(
      { uid: "user-1", role: ROLES.CUSTOMER },
      "user-2"
    ),
    (error) => error instanceof HttpsError &&
      error.code === "permission-denied"
  );
});

test("admins can access resources across users", () => {
  assert.equal(
    requireOwnership(
      { uid: "admin-1", role: ROLES.ADMIN },
      "user-2"
    ),
    true
  );
});