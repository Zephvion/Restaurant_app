
"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");

const {
  validatePolygon,
  validateServiceArea,
  pointInPolygon,
} = require("../src/service-areas");

const polygon = {
  type: "Polygon",
  coordinates: [[
    [76.0, 9.0],
    [77.0, 9.0],
    [77.0, 10.0],
    [76.0, 10.0],
    [76.0, 9.0],
  ]],
};

const validServiceArea = {
  branchId: "BRANCH001",
  restaurantId: "REST001",
  name: "Kochi Delivery Zone",
  polygon,
  deliveryFee: 30,
  minimumOrderValue: 100,
  maxDeliveryDistanceKm: 10,
  estimatedDeliveryMinutes: 40,
  status: "active",
};

test("valid GeoJSON polygon passes validation", () => {
  assert.equal(validatePolygon(polygon), true);
});

test("polygon with an unclosed ring is rejected", () => {
  const invalid = {
    type: "Polygon",
    coordinates: [[
      [76, 9],
      [77, 9],
      [77, 10],
      [76, 10],
    ]],
  };

  assert.throws(() => validatePolygon(invalid), /closed/);
});

test("polygon with invalid coordinates is rejected", () => {
  const invalid = {
    type: "Polygon",
    coordinates: [[
      [200, 9],
      [77, 9],
      [77, 10],
      [200, 9],
    ]],
  };

  assert.throws(() => validatePolygon(invalid), /coordinate/i);
});

test("valid service area passes validation", () => {
  assert.equal(validateServiceArea(validServiceArea), undefined);
});

test("service area with negative delivery fee is rejected", () => {
  assert.throws(
    () => validateServiceArea({
      ...validServiceArea,
      deliveryFee: -1,
    }),
    /non-negative/
  );
});

test("service area with invalid status is rejected", () => {
  assert.throws(
    () => validateServiceArea({
      ...validServiceArea,
      status: "pending",
    }),
    /status/
  );
});

test("point inside polygon is serviceable", () => {
  assert.equal(pointInPolygon(76.5, 9.5, polygon), true);
});

test("point outside polygon is not serviceable", () => {
  assert.equal(pointInPolygon(78, 11, polygon), false);
});
