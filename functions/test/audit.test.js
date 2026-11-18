
const test = require("node:test");
const assert = require("node:assert/strict");

const {
  AUDIT_COLLECTION,
  AUDIT_ACTIONS,
  writeAdminAudit,
  performAuditedMutation,
} = require("../src/admin/audit");

const adminAuth = {
  uid: "admin-001",
  token: {
    admin: true,
    role: "admin",
  },
};

function createFakeDb(initialResources = {}) {
  const resources = new Map(Object.entries(initialResources));
  const auditLogs = new Map();
  let auditCounter = 0;

  const db = {
    collection(name) {
      return {
        doc(id) {
          const documentId = id || `audit-${++auditCounter}`;
          return { collection: name, id: documentId };
        },
        async add(entry) {
          const id = `audit-${++auditCounter}`;
          auditLogs.set(id, entry);
          return { id };
        },
      };
    },

    async runTransaction(callback) {
      const pendingWrites = [];

      const transaction = {
        async get(ref) {
          const value = resources.get(`${ref.collection}/${ref.id}`);

          return {
            exists: value !== undefined,
            data: () => value ? { ...value } : undefined,
          };
        },

        create(ref, data) {
          pendingWrites.push({ type: "create", ref, data });
        },

        set(ref, data, options) {
          pendingWrites.push({ type: "set", ref, data, options });
        },

        delete(ref) {
          pendingWrites.push({ type: "delete", ref });
        },
      };

      const result = await callback(transaction);

      for (const write of pendingWrites) {
        const key = `${write.ref.collection}/${write.ref.id}`;

        if (write.type === "create" || write.type === "set") {
          const previous = resources.get(key) || {};
          resources.set(key, { ...previous, ...write.data });

          if (write.ref.collection === AUDIT_COLLECTION) {
            auditLogs.set(write.ref.id, write.data);
          }
        }

        if (write.type === "delete") {
          resources.delete(key);

          if (write.ref.collection === AUDIT_COLLECTION) {
            auditLogs.delete(write.ref.id);
          }
        }
      }

      return result;
    },
  };

  return {
    db,
    resources,
    auditLogs,
  };
}

test("audit actions are defined", () => {
  assert.ok(AUDIT_ACTIONS.includes("pricing.updated"));
  assert.ok(AUDIT_ACTIONS.includes("inventory.updated"));
  assert.ok(AUDIT_ACTIONS.includes("reservation.updated"));
});

test("admin audit entry is saved", async () => {
  const fake = createFakeDb();

  const result = await writeAdminAudit({
    db: fake.db,
    auth: adminAuth,
    action: "pricing.updated",
    resourceType: "product",
    resourceId: "product-001",
    after: { price: 250 },
    serverTimestamp: () => "test-timestamp",
  });

  assert.deepEqual(result, {
    success: true,
    auditId: "audit-1",
  });

  const entry = fake.auditLogs.get("audit-1");

  assert.equal(entry.actorUid, "admin-001");
  assert.equal(entry.action, "pricing.updated");
  assert.equal(entry.resourceId, "product-001");
  assert.equal(entry.createdAt, "test-timestamp");
});

test("unauthenticated audit requests are rejected", async () => {
  const fake = createFakeDb();

  await assert.rejects(
    writeAdminAudit({
      db: fake.db,
      auth: null,
      action: "pricing.updated",
      resourceType: "product",
      resourceId: "product-001",
    }),
    { code: "unauthenticated" }
  );
});

test("non-admin audit requests are rejected", async () => {
  const fake = createFakeDb();

  await assert.rejects(
    writeAdminAudit({
      db: fake.db,
      auth: {
        uid: "customer-001",
        token: { role: "customer" },
      },
      action: "pricing.updated",
      resourceType: "product",
      resourceId: "product-001",
    }),
    { code: "permission-denied" }
  );
});

test("unsupported audit actions are rejected", async () => {
  const fake = createFakeDb();

  await assert.rejects(
    writeAdminAudit({
      db: fake.db,
      auth: adminAuth,
      action: "unknown.action",
      resourceType: "product",
      resourceId: "product-001",
    }),
    { code: "invalid-argument" }
  );
});

test("missing resource information is rejected", async () => {
  const fake = createFakeDb();

  await assert.rejects(
    writeAdminAudit({
      db: fake.db,
      auth: adminAuth,
      action: "pricing.updated",
      resourceType: "",
      resourceId: "product-001",
    }),
    { code: "invalid-argument" }
  );
});

test("admin product update and audit log are saved together", async () => {
  const fake = createFakeDb({
    "products/product-001": {
      name: "Test Product",
      price: 100,
    },
  });

  const result = await performAuditedMutation({
    db: fake.db,
    auth: adminAuth,
    collection: "products",
    resourceType: "products",
    resourceId: "product-001",
    operation: "update",
    action: "pricing.updated",
    data: { price: 250 },
  });

  assert.equal(result.success, true);
  assert.equal(fake.resources.get("products/product-001").price, 250);
  assert.equal(fake.auditLogs.size, 1);

  const audit = [...fake.auditLogs.values()][0];

  assert.equal(audit.actorUid, "admin-001");
  assert.equal(audit.action, "pricing.updated");
  assert.equal(audit.before.price, 100);
  assert.equal(audit.after.price, 250);
});

test("customer cannot perform an audited mutation", async () => {
  const fake = createFakeDb({
    "products/product-001": {
      name: "Test Product",
      price: 100,
    },
  });

  await assert.rejects(
    performAuditedMutation({
      db: fake.db,
      auth: {
        uid: "customer-001",
        token: { role: "customer" },
      },
      collection: "products",
      resourceType: "products",
      resourceId: "product-001",
      operation: "update",
      action: "pricing.updated",
      data: { price: 250 },
    }),
    { code: "permission-denied" }
  );

  assert.equal(fake.resources.get("products/product-001").price, 100);
  assert.equal(fake.auditLogs.size, 0);
});

test("missing resource cannot be updated", async () => {
  const fake = createFakeDb();

  await assert.rejects(
    performAuditedMutation({
      db: fake.db,
      auth: adminAuth,
      collection: "products",
      resourceType: "products",
      resourceId: "missing-product",
      operation: "update",
      action: "catalog.updated",
      data: { price: 200 },
    }),
    { code: "not-found" }
  );

  assert.equal(fake.auditLogs.size, 0);
});

test("invalid product update creates no audit entry", async () => {
  const fake = createFakeDb({
    "products/product-001": {
      name: "Test Product",
      price: 100,
    },
  });

  await assert.rejects(
    performAuditedMutation({
      db: fake.db,
      auth: adminAuth,
      collection: "products",
      resourceType: "products",
      resourceId: "product-001",
      operation: "update",
      action: "pricing.updated",
      data: { price: -50 },
    })
  );

  assert.equal(fake.resources.get("products/product-001").price, 100);
  assert.equal(fake.auditLogs.size, 0);
});
