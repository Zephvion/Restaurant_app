"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");

const {
  COLLECTIONS,
  USER_SUBCOLLECTIONS,
  ENUMS,
  validateDocument,
} = require("../firestore-schema");

test("canonical collection names are defined", () => {
  assert.equal(COLLECTIONS.RESTAURANTS, "restaurants");
  assert.equal(COLLECTIONS.DISHES, "dishes");
  assert.equal(COLLECTIONS.MENU_CATEGORIES, "menuCategories");
  assert.equal(COLLECTIONS.ONBOARDING_ITEMS, "onboardingItems");
  assert.equal(COLLECTIONS.SERVICE_ITEMS, "serviceItems");
  assert.equal(COLLECTIONS.PROMO_BANNERS, "promoBanners");
  assert.equal(COLLECTIONS.USERS, "users");
  assert.equal(COLLECTIONS.RESERVATIONS, "reservations");
  assert.equal(COLLECTIONS.TAKEAWAY_ORDERS, "takeawayOrders");
  assert.equal(COLLECTIONS.CATERING_ORDERS, "cateringOrders");
  assert.equal(COLLECTIONS.PLANNER_ORDERS, "plannerOrders");

  assert.equal(COLLECTIONS.BRANCHES, "branches");
  assert.equal(COLLECTIONS.KITCHENS, "kitchens");
  assert.equal(COLLECTIONS.PRODUCTS, "products");
  assert.equal(COLLECTIONS.INVENTORY, "inventory");
  assert.equal(COLLECTIONS.ORDERS, "orders");
  assert.equal(COLLECTIONS.SUBSCRIPTIONS, "subscriptions");
  assert.equal(COLLECTIONS.PAYMENTS, "payments");
});

test("user subcollections are defined", () => {
  assert.equal(USER_SUBCOLLECTIONS.ADDRESSES, "addresses");
  assert.equal(USER_SUBCOLLECTIONS.PAYMENT_METHODS, "paymentMethods");
  assert.equal(USER_SUBCOLLECTIONS.NOTIFICATIONS, "notifications");
  assert.equal(USER_SUBCOLLECTIONS.CART, "cart");
  assert.equal(USER_SUBCOLLECTIONS.MEAL_PLANS, "mealPlans");
  assert.equal(USER_SUBCOLLECTIONS.CALORIE_STATS, "calorieStats");
});

test("valid restaurant passes", () => {
  assert.equal(
    validateDocument("restaurants", {
      name: "Paragon",
      address: "MG Road",
      city: "Kochi",
    }),
    true
  );
});

test("restaurant missing required field fails", () => {
  assert.throws(
    () =>
      validateDocument("restaurants", {
        name: "Paragon",
        city: "Kochi",
      }),
    /address/
  );
});

test("valid dish passes", () => {
  assert.equal(
    validateDocument("dishes", {
      name: "Chicken Biryani",
      price: 180,
      imageUrl: "https://example.com/biryani.jpg",
      kcal: 520,
      grams: 300,
      isVeg: false,
      rating: 4.7,
      category: "Biryani",
      description: "Aromatic chicken biryani",
      ingredients: ["rice", "chicken", "spices"],
      carbs: 45,
      fat: 12,
      protein: 28,
    }),
    true
  );
});

test("negative dish price fails", () => {
  assert.throws(
    () =>
      validateDocument("dishes", {
        name: "Biryani",
        price: -10,
        imageUrl: "image.jpg",
        kcal: 520,
        grams: 300,
        isVeg: false,
        rating: 4.7,
        category: "Biryani",
        description: "Test",
        ingredients: ["rice"],
        carbs: 45,
        fat: 12,
        protein: 28,
      }),
    /price/
  );
});

test("invalid dish rating fails", () => {
  assert.throws(
    () =>
      validateDocument("dishes", {
        name: "Biryani",
        price: 180,
        imageUrl: "image.jpg",
        kcal: 520,
        grams: 300,
        isVeg: false,
        rating: 6,
        category: "Biryani",
        description: "Test",
        ingredients: ["rice"],
        carbs: 45,
        fat: 12,
        protein: 28,
      }),
    /rating/
  );
});

test("valid menu category passes", () => {
  assert.equal(
    validateDocument("menuCategories", {
      name: "Biryani",
      imageUrl: "https://example.com/category.jpg",
    }),
    true
  );
});

test("valid onboarding item passes", () => {
  assert.equal(
    validateDocument("onboardingItems", {
      title: "Welcome",
      subtitle: "Discover delicious food",
      frontImage: "front.jpg",
      backImage: "back.jpg",
    }),
    true
  );
});

test("valid service item passes", () => {
  assert.equal(
    validateDocument("serviceItems", {
      title: "Delivery",
      imageUrl: "delivery.jpg",
      route: "/delivery",
      badgeCount: 2,
    }),
    true
  );
});

test("negative service badge count fails", () => {
  assert.throws(
    () =>
      validateDocument("serviceItems", {
        title: "Delivery",
        imageUrl: "delivery.jpg",
        badgeCount: -1,
      }),
    /badgeCount/
  );
});

test("valid promo banner passes", () => {
  assert.equal(
    validateDocument("promoBanners", {
      headline: "Special offer",
      code: "SAVE20",
      imageUrl: "offer.jpg",
    }),
    true
  );
});

test("valid user passes", () => {
  assert.equal(
    validateDocument("users", {
      name: "Test User",
      phone: "9999999999",
      email: "test@example.com",
      avatarUrl: "avatar.jpg",
    }),
    true
  );
});

test("valid address passes", () => {
  assert.equal(
    validateDocument("addresses", {
      label: "Home",
      details: "MG Road, Kochi",
      isDefault: true,
    }),
    true
  );
});

test("valid payment method passes", () => {
  assert.equal(
    validateDocument("paymentMethods", {
      title: "UPI",
      kind: "upi",
      subtitle: "Pay using UPI",
      assetKind: "upi",
    }),
    true
  );
});

test("invalid payment method kind fails", () => {
  assert.throws(
    () =>
      validateDocument("paymentMethods", {
        title: "Unknown",
        kind: "bitcoin",
      }),
    /kind/
  );
});

test("valid notification passes", () => {
  assert.equal(
    validateDocument("notifications", {
      title: "Order update",
      isPlaced: true,
      isPromo: false,
      orderId: "ORDER001",
    }),
    true
  );
});

test("valid cart item passes", () => {
  assert.equal(
    validateDocument("cart", {
      dishId: "DISH001",
      quantity: 2,
    }),
    true
  );
});

test("zero cart quantity fails", () => {
  assert.throws(
    () =>
      validateDocument("cart", {
        dishId: "DISH001",
        quantity: 0,
      }),
    /quantity/
  );
});

test("valid reservation passes", () => {
  assert.equal(
    validateDocument("reservations", {
      userId: "USER001",
      restaurantId: "REST001",
      date: new Date(),
      timeSlot: "19:00",
      seats: 4,
      tableNumber: 12,
    }),
    true
  );
});

test("reservation with zero seats fails", () => {
  assert.throws(
    () =>
      validateDocument("reservations", {
        userId: "USER001",
        restaurantId: "REST001",
        date: new Date(),
        timeSlot: "19:00",
        seats: 0,
        tableNumber: 12,
      }),
    /seats/
  );
});

// ARCH-006: Reservation status contract tests

test("valid reservation status passes", () => {
  for (const status of ENUMS.reservationStatus) {
    assert.equal(
      validateDocument("reservations", {
        userId: "USER001",
        restaurantId: "REST001",
        date: new Date(),
        timeSlot: "19:00",
        seats: 4,
        tableNumber: 12,
        status,
      }),
      true
    );
  }
});

test("invalid reservation status fails", () => {
  assert.throws(
    () =>
      validateDocument("reservations", {
        userId: "USER001",
        restaurantId: "REST001",
        date: new Date(),
        timeSlot: "19:00",
        seats: 4,
        tableNumber: 12,
        status: "unknown",
      }),
    /status/
  );
});

test("reservation status is optional for legacy records", () => {
  assert.equal(
    validateDocument("reservations", {
      userId: "USER001",
      restaurantId: "REST001",
      date: new Date(),
      timeSlot: "19:00",
      seats: 4,
      tableNumber: 12,
    }),
    true
  );
});

test("valid takeaway order passes", () => {
  assert.equal(
    validateDocument("takeawayOrders", {
      userId: "USER001",
      restaurantId: "REST001",
      items: [
        {
          dishId: "DISH001",
          quantity: 2,
          unitPrice: 180,
        },
      ],
      status: "preparing",
      createdAt: new Date(),
    }),
    true
  );
});

test("takeaway order with invalid status fails", () => {
  assert.throws(
    () =>
      validateDocument("takeawayOrders", {
        userId: "USER001",
        restaurantId: "REST001",
        items: [
          {
            dishId: "DISH001",
            quantity: 2,
            unitPrice: 180,
          },
        ],
        status: "cancelled",
        createdAt: new Date(),
      }),
    /status/
  );
});

test("valid catering order passes", () => {
  assert.equal(
    validateDocument("cateringOrders", {
      userId: "USER001",
      date: new Date(),
      guestRange: "50-100",
      status: "notifiedParagon",
      createdAt: new Date(),
    }),
    true
  );
});

test("invalid catering status fails", () => {
  assert.throws(
    () =>
      validateDocument("cateringOrders", {
        userId: "USER001",
        date: new Date(),
        guestRange: "50-100",
        status: "unknown",
        createdAt: new Date(),
      }),
    /status/
  );
});

test("valid planner order passes", () => {
  assert.equal(
    validateDocument("plannerOrders", {
      userId: "USER001",
      etaMins: 30,
      status: "orderAccepted",
      driverName: "Driver",
      driverPhone: "9999999999",
      paymentLabel: "Paid",
      deliveryTimeWindow: "7:00 PM - 7:30 PM",
      items: [
        {
          name: "Chicken Biryani",
          quantity: 2,
          price: 180,
        },
      ],
      subtotal: 360,
      deliveryFee: 30,
    }),
    true
  );
});

test("valid meal plan passes", () => {
  assert.equal(
    validateDocument("mealPlans", {
      dayOffset: 1,
      mealType: "lunch",
      timeSlot: "13:00",
      location: "OFFICE",
      dishName: "Chicken Biryani",
      imageUrl: "biryani.jpg",
      calories: 520,
      weightGm: 300,
      price: 180,
      protein: 28,
      carbs: 45,
      fat: 12,
    }),
    true
  );
});

test("invalid meal type fails", () => {
  assert.throws(
    () =>
      validateDocument("mealPlans", {
        dayOffset: 1,
        mealType: "brunch",
        timeSlot: "13:00",
        location: "OFFICE",
        dishName: "Biryani",
        imageUrl: "biryani.jpg",
        calories: 520,
        weightGm: 300,
        price: 180,
        protein: 28,
        carbs: 45,
        fat: 12,
      }),
    /mealType/
  );
});

test("invalid meal plan location fails", () => {
  assert.throws(
    () =>
      validateDocument("mealPlans", {
        dayOffset: 1,
        mealType: "lunch",
        timeSlot: "13:00",
        location: "Home",
        dishName: "Biryani",
        imageUrl: "biryani.jpg",
        calories: 520,
        weightGm: 300,
        price: 180,
        protein: 28,
        carbs: 45,
        fat: 12,
      }),
    /location/
  );
});

test("valid calorie stats pass", () => {
  assert.equal(
    validateDocument("calorieStats", {
      targetKcal: 2000,
      remainingKcal: 1200,
      proteinG: 80,
      carbsG: 200,
      fatG: 60,
    }),
    true
  );
});

// New canonical shared collections

test("valid branch passes", () => {
  assert.equal(
    validateDocument("branches", {
      restaurantId: "REST001",
      name: "Kochi Main Branch",
      address: "MG Road",
      city: "Kochi",
      status: "active",
    }),
    true
  );
});

test("branch missing required field fails", () => {
  assert.throws(
    () =>
      validateDocument("branches", {
        restaurantId: "REST001",
        name: "Kochi Main Branch",
        city: "Kochi",
      }),
    /address/
  );
});

test("valid kitchen passes", () => {
  assert.equal(
    validateDocument("kitchens", {
      branchId: "BRANCH001",
      name: "Main Kitchen",
      status: "active",
      createdAt: new Date(),
    }),
    true
  );
});

test("kitchen missing branch ID fails", () => {
  assert.throws(
    () =>
      validateDocument("kitchens", {
        name: "Main Kitchen",
      }),
    /branchId/
  );
});

test("valid product passes", () => {
  assert.equal(
    validateDocument("products", {
      name: "Chicken Biryani",
      price: 180,
      description: "Aromatic biryani",
      imageUrl: "biryani.jpg",
      category: "Biryani",
      sku: "BIRYANI001",
      restaurantId: "REST001",
      branchId: "BRANCH001",
      isAvailable: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    }),
    true
  );
});

test("product with negative price fails", () => {
  assert.throws(
    () =>
      validateDocument("products", {
        name: "Chicken Biryani",
        price: -1,
      }),
    /price/
  );
});

test("valid inventory passes", () => {
  assert.equal(
    validateDocument("inventory", {
      branchId: "BRANCH001",
      productId: "PRODUCT001",
      kitchenId: "KITCHEN001",
      quantity: 100,
      unit: "kg",
      reorderLevel: 10,
      updatedAt: new Date(),
    }),
    true
  );
});

test("inventory with negative quantity fails", () => {
  assert.throws(
    () =>
      validateDocument("inventory", {
        branchId: "BRANCH001",
        productId: "PRODUCT001",
        quantity: -1,
        unit: "kg",
      }),
    /quantity/
  );
});

test("valid shared order passes", () => {
  assert.equal(
    validateDocument("orders", {
      userId: "USER001",
      branchId: "BRANCH001",
      type: "delivery",
      status: "pending",
      items: [
        {
          dishId: "DISH001",
          quantity: 2,
          unitPrice: 180,
        },
      ],
      subtotal: 360,
      total: 390,
      createdAt: new Date(),
    }),
    true
  );
});

test("shared order with invalid item fails", () => {
  assert.throws(
    () =>
      validateDocument("orders", {
        userId: "USER001",
        branchId: "BRANCH001",
        type: "delivery",
        status: "pending",
        items: [
          {
            dishId: "DISH001",
            quantity: 0,
            unitPrice: 180,
          },
        ],
        subtotal: 360,
        total: 390,
        createdAt: new Date(),
      }),
    /quantity/
  );
});

test("valid subscription passes", () => {
  assert.equal(
    validateDocument("subscriptions", {
      ownerId: "USER001",
      planId: "PLAN001",
      status: "active",
      startAt: new Date(),
      endAt: new Date(),
      amount: 999,
      currency: "INR",
      billingInterval: "monthly",
      providerSubscriptionId: "SUB001",
      createdAt: new Date(),
      updatedAt: new Date(),
    }),
    true
  );
});

test("subscription missing plan ID fails", () => {
  assert.throws(
    () =>
      validateDocument("subscriptions", {
        ownerId: "USER001",
        status: "active",
        startAt: new Date(),
        createdAt: new Date(),
      }),
    /planId/
  );
});

test("valid payment transaction passes", () => {
  assert.equal(
    validateDocument("payments", {
      orderId: "ORDER001",
      userId: "USER001",
      amount: 390,
      currency: "INR",
      provider: "cashfree",
      status: "pending",
      createdAt: new Date(),
      providerPaymentId: "PAY001",
      subscriptionId: "SUB001",
      updatedAt: new Date(),
    }),
    true
  );
});

test("payment with negative amount fails", () => {
  assert.throws(
    () =>
      validateDocument("payments", {
        orderId: "ORDER001",
        userId: "USER001",
        amount: -10,
        currency: "INR",
        provider: "cashfree",
        status: "pending",
        createdAt: new Date(),
      }),
    /amount/
  );
});

test("unknown collection fails", () => {
  assert.throws(
    () => validateDocument("unknownCollection", {}),
    /Unknown collection/
  );
});

test("non-object document fails", () => {
  assert.throws(
    () => validateDocument("restaurants", null),
    /object/
  );
});

test("enum values match canonical schema", () => {
  assert.deepEqual(ENUMS.paymentKind, [
    "card",
    "upi",
    "wallet",
    "netBanking",
    "cash",
  ]);

  assert.deepEqual(ENUMS.takeawayStatus, [
    "preparing",
    "packing",
    "readyForTakeaway",
    "taken",
  ]);

  assert.deepEqual(ENUMS.cateringStatus, [
    "notifiedParagon",
    "call",
    "bookingConfirmed",
  ]);

  assert.deepEqual(ENUMS.mealType, [
    "breakfast",
    "lunch",
    "dinner",
  ]);

  assert.deepEqual(ENUMS.plannerOrderStatus, [
    "orderAccepted",
    "taken",
    "done",
  ]);

  assert.deepEqual(ENUMS.branchStatus, [
    "active",
    "inactive",
  ]);

  assert.deepEqual(ENUMS.kitchenStatus, [
    "active",
    "inactive",
  ]);

  assert.deepEqual(ENUMS.reservationStatus, [
    "pending",
    "confirmed",
    "cancelled",
    "completed",
  ]);

  assert.deepEqual(ENUMS.orderType, [
    "takeaway",
    "delivery",
    "dineIn",
    "catering",
  ]);

  assert.deepEqual(ENUMS.orderStatus, [
    "pending",
    "confirmed",
    "preparing",
    "ready",
    "completed",
    "cancelled",
  ]);

  assert.deepEqual(ENUMS.subscriptionStatus, [
    "trialing",
    "active",
    "pastDue",
    "cancelled",
    "expired",
  ]);

  assert.deepEqual(ENUMS.paymentStatus, [
    "pending",
    "authorized",
    "captured",
    "failed",
    "refunded",
  ]);
});