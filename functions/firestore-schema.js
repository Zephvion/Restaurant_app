
"use strict";

const COLLECTIONS = Object.freeze({
  // Existing application collections
  RESTAURANTS: "restaurants",
  DISHES: "dishes",
  MENU_CATEGORIES: "menuCategories",
  ONBOARDING_ITEMS: "onboardingItems",
  SERVICE_ITEMS: "serviceItems",
  PROMO_BANNERS: "promoBanners",
  USERS: "users",
  RESERVATIONS: "reservations",
  TAKEAWAY_ORDERS: "takeawayOrders",
  CATERING_ORDERS: "cateringOrders",
  PLANNER_ORDERS: "plannerOrders",

  // Shared business collections
  BRANCHES: "branches",
  KITCHENS: "kitchens",
  PRODUCTS: "products",
  INVENTORY: "inventory",
  ORDERS: "orders",
  SUBSCRIPTIONS: "subscriptions",
  PAYMENTS: "payments",
});

const USER_SUBCOLLECTIONS = Object.freeze({
  ADDRESSES: "addresses",
  PAYMENT_METHODS: "paymentMethods",
  NOTIFICATIONS: "notifications",
  CART: "cart",
  MEAL_PLANS: "mealPlans",
  CALORIE_STATS: "calorieStats",
});

const ENUMS = Object.freeze({
  paymentKind: ["card", "upi", "wallet", "netBanking", "cash"],
  takeawayStatus: ["preparing", "packing", "readyForTakeaway", "taken"],
  cateringStatus: ["notifiedParagon", "call", "bookingConfirmed"],
  mealType: ["breakfast", "lunch", "dinner"],
  plannerOrderStatus: ["orderAccepted", "taken", "done"],

  branchStatus: ["active", "inactive"],
  kitchenStatus: ["active", "inactive"],
  orderStatus: [
    "pending",
    "confirmed",
    "preparing",
    "ready",
    "completed",
    "cancelled",
  ],
  orderType: ["takeaway", "delivery", "dineIn", "catering"],
  subscriptionStatus: [
    "trialing",
    "active",
    "pastDue",
    "cancelled",
    "expired",
  ],
  paymentStatus: [
    "pending",
    "authorized",
    "captured",
    "failed",
    "refunded",
  ],
});

function isObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function isDateOrTimestamp(value) {
  return (
    value instanceof Date ||
    (isObject(value) && typeof value.toDate === "function")
  );
}

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

function isNonEmptyString(value) {
  return typeof value === "string" && value.trim().length > 0;
}

function required(data, fields) {
  for (const field of fields) {
    if (data[field] === undefined || data[field] === null) {
      throw new Error(`Missing required field: ${field}`);
    }
  }
}

function stringField(data, field) {
  if (!isNonEmptyString(data[field])) {
    throw new Error(`${field} must be a non-empty string`);
  }
}

function optionalStringField(data, field) {
  if (
    data[field] !== undefined &&
    data[field] !== null &&
    typeof data[field] !== "string"
  ) {
    throw new Error(`${field} must be a string when provided`);
  }
}

function numberField(data, field) {
  if (!isFiniteNumber(data[field]) || data[field] < 0) {
    throw new Error(`${field} must be a finite non-negative number`);
  }
}

function integerField(data, field) {
  if (!Number.isInteger(data[field]) || data[field] < 0) {
    throw new Error(`${field} must be a non-negative integer`);
  }
}

function positiveIntegerField(data, field) {
  if (!Number.isInteger(data[field]) || data[field] <= 0) {
    throw new Error(`${field} must be a positive integer`);
  }
}

function dateField(data, field) {
  if (!isDateOrTimestamp(data[field])) {
    throw new Error(`${field} must be a Date or Firestore Timestamp`);
  }
}

function enumField(data, field, allowedValues) {
  if (!allowedValues.includes(data[field])) {
    throw new Error(
      `${field} must be one of: ${allowedValues.join(", ")}`
    );
  }
}

function stringArrayField(data, field) {
  if (
    !Array.isArray(data[field]) ||
    !data[field].every(isNonEmptyString)
  ) {
    throw new Error(`${field} must be an array of non-empty strings`);
  }
}

function orderItemsField(
  items,
  { requireDishId = false, priceField = "price", nameField = null } = {}
) {
  if (!Array.isArray(items) || items.length === 0) {
    throw new Error("items must be a non-empty array");
  }

  items.forEach((item, index) => {
    if (!isObject(item)) {
      throw new Error(`items[${index}] must be an object`);
    }

    if (requireDishId && !isNonEmptyString(item.dishId)) {
      throw new Error(`items[${index}].dishId is required`);
    }

    if (nameField && !isNonEmptyString(item[nameField])) {
      throw new Error(`items[${index}].${nameField} is required`);
    }

    if (!Number.isInteger(item.quantity) || item.quantity <= 0) {
      throw new Error(
        `items[${index}].quantity must be a positive integer`
      );
    }

    if (!isFiniteNumber(item[priceField]) || item[priceField] < 0) {
      throw new Error(
        `items[${index}].${priceField} must be non-negative`
      );
    }
  });
}

// Existing application validators

function validateRestaurant(data) {
  required(data, ["name", "address", "city"]);
  for (const field of ["name", "address", "city"]) {
    stringField(data, field);
  }
  optionalStringField(data, "logoUrl");
}

function validateDish(data) {
  required(data, [
    "name", "price", "imageUrl", "kcal", "grams", "isVeg",
    "rating", "category", "description", "ingredients",
    "carbs", "fat", "protein",
  ]);

  for (const field of [
    "name", "imageUrl", "category", "description",
  ]) {
    stringField(data, field);
  }

  numberField(data, "price");

  if (data.oldPrice !== undefined && data.oldPrice !== null) {
    numberField(data, "oldPrice");
  }

  if (
    !isFiniteNumber(data.rating) ||
    data.rating < 0 ||
    data.rating > 5
  ) {
    throw new Error("rating must be between 0 and 5");
  }

  for (const field of ["kcal", "grams", "carbs", "fat", "protein"]) {
    integerField(data, field);
  }

  if (typeof data.isVeg !== "boolean") {
    throw new Error("isVeg must be a boolean");
  }

  stringArrayField(data, "ingredients");
  optionalStringField(data, "subtitle");
}

function validateMenuCategory(data) {
  required(data, ["name", "imageUrl"]);
  stringField(data, "name");
  stringField(data, "imageUrl");
}

function validateOnboardingItem(data) {
  required(data, ["title", "subtitle", "frontImage", "backImage"]);
  for (const field of ["title", "subtitle", "frontImage", "backImage"]) {
    stringField(data, field);
  }
}

function validateServiceItem(data) {
  required(data, ["title", "imageUrl"]);
  stringField(data, "title");
  stringField(data, "imageUrl");

  if (data.badgeCount !== undefined) {
    integerField(data, "badgeCount");
  }

  optionalStringField(data, "route");
}

function validatePromoBanner(data) {
  required(data, ["headline", "code", "imageUrl"]);
  for (const field of ["headline", "code", "imageUrl"]) {
    stringField(data, field);
  }
}

function validateUser(data) {
  for (const field of ["name", "phone", "email", "avatarUrl"]) {
    optionalStringField(data, field);
  }

  for (const field of ["createdAt", "updatedAt"]) {
    if (data[field] !== undefined) {
      dateField(data, field);
    }
  }
}

function validateAddress(data) {
  required(data, ["label", "details", "isDefault"]);
  stringField(data, "label");
  stringField(data, "details");

  if (typeof data.isDefault !== "boolean") {
    throw new Error("isDefault must be a boolean");
  }
}

function validatePaymentMethod(data) {
  required(data, ["title", "kind"]);
  stringField(data, "title");
  enumField(data, "kind", ENUMS.paymentKind);
  optionalStringField(data, "subtitle");
  optionalStringField(data, "assetKind");
}

function validateNotification(data) {
  required(data, ["title", "isPlaced", "isPromo"]);
  stringField(data, "title");

  for (const field of ["isPlaced", "isPromo"]) {
    if (typeof data[field] !== "boolean") {
      throw new Error(`${field} must be a boolean`);
    }
  }

  optionalStringField(data, "orderId");
  optionalStringField(data, "imageUrl");
  optionalStringField(data, "promoText");

  if (data.createdAt !== undefined) {
    dateField(data, "createdAt");
  }
}

function validateCartItem(data) {
  required(data, ["dishId", "quantity"]);
  stringField(data, "dishId");
  positiveIntegerField(data, "quantity");

  if (data.updatedAt !== undefined) {
    dateField(data, "updatedAt");
  }
}

function validateReservation(data) {
  required(data, [
    "userId", "restaurantId", "date",
    "timeSlot", "seats", "tableNumber",
  ]);

  stringField(data, "userId");
  stringField(data, "restaurantId");
  stringField(data, "timeSlot");
  dateField(data, "date");
  positiveIntegerField(data, "seats");
  positiveIntegerField(data, "tableNumber");

  if (data.createdAt !== undefined) {
    dateField(data, "createdAt");
  }
}

function validateTakeawayOrder(data) {
  required(data, [
    "userId", "restaurantId", "items", "status", "createdAt",
  ]);

  stringField(data, "userId");
  stringField(data, "restaurantId");
  enumField(data, "status", ENUMS.takeawayStatus);
  dateField(data, "createdAt");

  orderItemsField(data.items, {
    requireDishId: true,
    priceField: "unitPrice",
  });
}

function validateCateringOrder(data) {
  required(data, [
    "userId", "date", "guestRange", "status", "createdAt",
  ]);

  stringField(data, "userId");
  stringField(data, "guestRange");
  enumField(data, "status", ENUMS.cateringStatus);
  dateField(data, "date");
  dateField(data, "createdAt");
}

function validateMealPlan(data) {
  required(data, [
    "dayOffset", "mealType", "timeSlot", "location",
    "dishName", "imageUrl", "calories", "weightGm",
    "price", "protein", "carbs", "fat",
  ]);

  enumField(data, "mealType", ENUMS.mealType);

  for (const field of ["timeSlot", "dishName", "imageUrl"]) {
    stringField(data, field);
  }

  if (
    !Number.isInteger(data.dayOffset) ||
    data.dayOffset < 0 ||
    data.dayOffset > 6
  ) {
    throw new Error("dayOffset must be an integer from 0 to 6");
  }

  if (!["HOME", "OFFICE"].includes(data.location)) {
    throw new Error("location must be HOME or OFFICE");
  }

  for (const field of ["calories", "weightGm", "protein", "carbs", "fat"]) {
    integerField(data, field);
  }

  numberField(data, "price");
}

function validatePlannerOrder(data) {
  required(data, [
    "userId", "etaMins", "status", "driverName", "driverPhone",
    "paymentLabel", "deliveryTimeWindow", "items", "subtotal",
    "deliveryFee",
  ]);

  for (const field of [
    "userId", "driverName", "driverPhone",
    "paymentLabel", "deliveryTimeWindow",
  ]) {
    stringField(data, field);
  }

  optionalStringField(data, "driverPhotoUrl");
  enumField(data, "status", ENUMS.plannerOrderStatus);
  integerField(data, "etaMins");

  orderItemsField(data.items, {
    priceField: "price",
    nameField: "name",
  });

  numberField(data, "subtotal");
  numberField(data, "deliveryFee");
}

function validateCalorieStats(data) {
  required(data, [
    "targetKcal", "remainingKcal", "proteinG", "carbsG", "fatG",
  ]);

  for (const field of [
    "targetKcal", "remainingKcal", "proteinG", "carbsG", "fatG",
  ]) {
    integerField(data, field);
  }
}

// New shared business validators

function validateBranch(data) {
  required(data, ["restaurantId", "name", "address", "city"]);

  for (const field of ["restaurantId", "name", "address", "city"]) {
    stringField(data, field);
  }

  optionalStringField(data, "phone");
  optionalStringField(data, "timezone");

  if (data.status !== undefined) {
    enumField(data, "status", ENUMS.branchStatus);
  }
}

function validateKitchen(data) {
  required(data, ["branchId", "name"]);

  stringField(data, "branchId");
  stringField(data, "name");

  if (data.status !== undefined) {
    enumField(data, "status", ENUMS.kitchenStatus);
  }

  if (data.createdAt !== undefined) {
    dateField(data, "createdAt");
  }
}

function validateProduct(data) {
  required(data, ["name", "price"]);

  stringField(data, "name");
  numberField(data, "price");

  optionalStringField(data, "description");
  optionalStringField(data, "imageUrl");
  optionalStringField(data, "category");
  optionalStringField(data, "sku");
  optionalStringField(data, "restaurantId");
  optionalStringField(data, "branchId");

  if (data.isAvailable !== undefined &&
      typeof data.isAvailable !== "boolean") {
    throw new Error("isAvailable must be a boolean");
  }

  if (data.createdAt !== undefined) {
    dateField(data, "createdAt");
  }

  if (data.updatedAt !== undefined) {
    dateField(data, "updatedAt");
  }
}

function validateInventory(data) {
  required(data, [
    "branchId", "productId", "quantity", "unit",
  ]);

  stringField(data, "branchId");
  stringField(data, "productId");
  stringField(data, "unit");
  numberField(data, "quantity");

  optionalStringField(data, "kitchenId");

  if (data.reorderLevel !== undefined) {
    numberField(data, "reorderLevel");
  }

  if (data.updatedAt !== undefined) {
    dateField(data, "updatedAt");
  }
}

function validateSharedOrder(data) {
  required(data, [
    "userId", "branchId", "type", "status",
    "items", "subtotal", "total", "createdAt",
  ]);

  stringField(data, "userId");
  stringField(data, "branchId");

  enumField(data, "type", ENUMS.orderType);
  enumField(data, "status", ENUMS.orderStatus);

  orderItemsField(data.items, {
    requireDishId: true,
    priceField: "unitPrice",
  });

  numberField(data, "subtotal");
  numberField(data, "total");
  dateField(data, "createdAt");

  optionalStringField(data, "restaurantId");
  optionalStringField(data, "reservationId");
  optionalStringField(data, "notes");

  if (data.updatedAt !== undefined) {
    dateField(data, "updatedAt");
  }
}

function validateSubscription(data) {
  required(data, [
    "ownerId", "planId", "status",
    "startAt", "createdAt",
  ]);

  stringField(data, "ownerId");
  stringField(data, "planId");

  enumField(data, "status", ENUMS.subscriptionStatus);

  dateField(data, "startAt");
  dateField(data, "createdAt");

  if (data.endAt !== undefined) {
    dateField(data, "endAt");
  }

  if (data.amount !== undefined) {
    numberField(data, "amount");
  }

  optionalStringField(data, "currency");
  optionalStringField(data, "billingInterval");
  optionalStringField(data, "providerSubscriptionId");

  if (data.updatedAt !== undefined) {
    dateField(data, "updatedAt");
  }
}

function validatePayment(data) {
  required(data, [
    "orderId", "userId", "amount",
    "currency", "provider", "status", "createdAt",
  ]);

  stringField(data, "orderId");
  stringField(data, "userId");
  stringField(data, "currency");
  stringField(data, "provider");

  numberField(data, "amount");
  enumField(data, "status", ENUMS.paymentStatus);
  dateField(data, "createdAt");

  optionalStringField(data, "providerPaymentId");
  optionalStringField(data, "subscriptionId");

  if (data.updatedAt !== undefined) {
    dateField(data, "updatedAt");
  }
}

// Collection-to-validator mapping

const VALIDATORS = Object.freeze({
  [COLLECTIONS.RESTAURANTS]: validateRestaurant,
  [COLLECTIONS.DISHES]: validateDish,
  [COLLECTIONS.MENU_CATEGORIES]: validateMenuCategory,
  [COLLECTIONS.ONBOARDING_ITEMS]: validateOnboardingItem,
  [COLLECTIONS.SERVICE_ITEMS]: validateServiceItem,
  [COLLECTIONS.PROMO_BANNERS]: validatePromoBanner,
  [COLLECTIONS.USERS]: validateUser,

  [USER_SUBCOLLECTIONS.ADDRESSES]: validateAddress,
  [USER_SUBCOLLECTIONS.PAYMENT_METHODS]: validatePaymentMethod,
  [USER_SUBCOLLECTIONS.NOTIFICATIONS]: validateNotification,
  [USER_SUBCOLLECTIONS.CART]: validateCartItem,
  [USER_SUBCOLLECTIONS.MEAL_PLANS]: validateMealPlan,
  [USER_SUBCOLLECTIONS.CALORIE_STATS]: validateCalorieStats,

  [COLLECTIONS.RESERVATIONS]: validateReservation,
  [COLLECTIONS.TAKEAWAY_ORDERS]: validateTakeawayOrder,
  [COLLECTIONS.CATERING_ORDERS]: validateCateringOrder,
  [COLLECTIONS.PLANNER_ORDERS]: validatePlannerOrder,

  [COLLECTIONS.BRANCHES]: validateBranch,
  [COLLECTIONS.KITCHENS]: validateKitchen,
  [COLLECTIONS.PRODUCTS]: validateProduct,
  [COLLECTIONS.INVENTORY]: validateInventory,
  [COLLECTIONS.ORDERS]: validateSharedOrder,
  [COLLECTIONS.SUBSCRIPTIONS]: validateSubscription,
  [COLLECTIONS.PAYMENTS]: validatePayment,
});

function validateDocument(collection, data) {
  if (!isObject(data)) {
    throw new Error("Document data must be an object");
  }

  const validator = VALIDATORS[collection];

  if (!validator) {
    throw new Error(`Unknown collection: ${collection}`);
  }

  validator(data);
  return true;
}

module.exports = {
  COLLECTIONS,
  USER_SUBCOLLECTIONS,
  ENUMS,
  validateDocument,
};
