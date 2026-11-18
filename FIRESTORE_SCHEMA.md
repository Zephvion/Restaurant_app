\# Canonical Firestore Schema



\*\*Project:\*\* Restaurant App  

\*\*Status:\*\* Proposed canonical schema  

\*\*Source:\*\* Existing Flutter models in `lib/models/` and mock data in `lib/data/mock\_data.dart`



\## 1. Purpose



This document defines the proposed canonical Firestore collection structure for the Restaurant App.



The current Flutter application uses frontend mock data. These collections and fields are a proposed backend design; they are not confirmation that Firestore integration has been implemented.



\## 2. Schema conventions



\- Use Firestore document IDs as the canonical record IDs.

\- Store dates and timestamps as Firestore `Timestamp` values.

\- Store monetary values as numeric values. Use a consistent currency (INR) across the application.

\- Store enum values as strings matching the Dart enum names.

\- Use `userId` to identify ownership of user-specific records.

\- Store references as document ID strings unless a Firestore `DocumentReference` is explicitly required.

\- Do not store calculated display values when they can be derived reliably.



\## 3. Collection structure



| Collection path | Purpose |

|---|---|

| `restaurants/{restaurantId}` | Restaurant branches |

| `dishes/{dishId}` | Menu dishes |

| `menuCategories/{categoryId}` | Menu category information |

| `onboardingItems/{itemId}` | Onboarding slides |

| `serviceItems/{serviceId}` | Home screen service tiles |

| `promoBanners/{bannerId}` | Promotional banners |

| `users/{userId}` | User profile |

| `users/{userId}/addresses/{addressId}` | Saved addresses |

| `users/{userId}/paymentMethods/{paymentMethodId}` | Payment method display metadata |

| `users/{userId}/notifications/{notificationId}` | User notifications |

| `users/{userId}/cart/{dishId}` | User cart items |

| `reservations/{reservationId}` | Table reservations |

| `takeawayOrders/{orderId}` | Takeaway orders |

| `cateringOrders/{orderId}` | Catering requests |

| `users/{userId}/mealPlans/{mealId}` | Planned meals |

| `plannerOrders/{orderId}` | Food planner orders |

| `users/{userId}/calorieStats/{dateId}` | Daily calorie statistics |



\## 4. Collection field definitions



\### 4.1 restaurants



\*\*Path:\*\* `restaurants/{restaurantId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `name` | String | Yes | Restaurant name |

| `address` | String | Yes | Branch address |

| `city` | String | Yes | Branch city |

| `logoUrl` | String | No | Restaurant logo URL |



The document ID represents the restaurant ID.



\### 4.2 dishes



\*\*Path:\*\* `dishes/{dishId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `name` | String | Yes | Dish name |

| `subtitle` | String | No | Short description |

| `price` | Number | Yes | Current price |

| `oldPrice` | Number | No | Previous price |

| `imageUrl` | String | Yes | Dish image URL or asset reference |

| `kcal` | Integer | Yes | Calories |

| `grams` | Integer | Yes | Serving weight |

| `isVeg` | Boolean | Yes | Vegetarian indicator |

| `rating` | Number | Yes | Dish rating |

| `category` | String | Yes | Dish category |

| `description` | String | Yes | Dish description |

| `ingredients` | Array<String> | Yes | Ingredient list |

| `carbs` | Integer | Yes | Carbohydrates |

| `fat` | Integer | Yes | Fat |

| `protein` | Integer | Yes | Protein |



`hasDiscount` is derived from `oldPrice` and `price`; it is not stored as an authoritative field.



\### 4.3 menuCategories



\*\*Path:\*\* `menuCategories/{categoryId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `name` | String | Yes | Category name |

| `imageUrl` | String | Yes | Category image |



\### 4.4 onboardingItems



\*\*Path:\*\* `onboardingItems/{itemId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `title` | String | Yes | Slide title |

| `subtitle` | String | Yes | Slide subtitle |

| `frontImage` | String | Yes | Front collage image |

| `backImage` | String | Yes | Rear collage image |



\### 4.5 serviceItems



\*\*Path:\*\* `serviceItems/{serviceId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `title` | String | Yes | Service title |

| `imageUrl` | String | Yes | Service image |

| `route` | String | No | Application route |

| `badgeCount` | Integer | No | UI badge count; preferably calculated dynamically |



\### 4.6 promoBanners



\*\*Path:\*\* `promoBanners/{bannerId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `headline` | String | Yes | Promotional headline |

| `code` | String | Yes | Promotion code |

| `imageUrl` | String | Yes | Banner image URL or asset reference |



\### 4.7 users



\*\*Path:\*\* `users/{userId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `name` | String | No | User display name |

| `phone` | String | No | User phone number |

| `email` | String | No | User email |

| `avatarUrl` | String | No | Profile image URL |

| `createdAt` | Timestamp | No | Account creation time |

| `updatedAt` | Timestamp | No | Last profile update |



The document ID should correspond to the authenticated Firebase UID. Profile fields are proposed from the existing mock profile data.



\### 4.8 addresses



\*\*Path:\*\* `users/{userId}/addresses/{addressId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `label` | String | Yes | Address label |

| `details` | String | Yes | Full address |

| `isDefault` | Boolean | Yes | Default address indicator |



\### 4.9 paymentMethods



\*\*Path:\*\* `users/{userId}/paymentMethods/{paymentMethodId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `title` | String | Yes | Display title |

| `subtitle` | String | No | Provider or bank name |

| `kind` | String | Yes | `card`, `upi`, `wallet`, `netBanking`, or `cash` |

| `assetKind` | String | No | UI payment icon identifier |



Only safe payment display metadata belongs here. Never store CVV, card PIN, UPI PIN, passwords, or banking credentials in Firestore.



\### 4.10 notifications



\*\*Path:\*\* `users/{userId}/notifications/{notificationId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `title` | String | Yes | Notification title |

| `orderId` | String | No | Related order ID |

| `imageUrl` | String | No | Notification image |

| `isPlaced` | Boolean | Yes | Order notification indicator |

| `isPromo` | Boolean | Yes | Promotional notification indicator |

| `promoText` | String | No | Promotional message |

| `createdAt` | Timestamp | No | Notification creation time |



\### 4.11 cart



\*\*Path:\*\* `users/{userId}/cart/{dishId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `dishId` | String | Yes | Referenced dish ID |

| `quantity` | Integer | Yes | Selected quantity |

| `updatedAt` | Timestamp | No | Last cart update |



The dish document supplies current menu information. The cart line total is calculated from price and quantity. At checkout, the order must preserve the price charged at that time.



\### 4.12 reservations



\*\*Path:\*\* `reservations/{reservationId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `userId` | String | Yes | Owner's Firebase UID |

| `restaurantId` | String | Yes | Selected restaurant ID |

| `date` | Timestamp | Yes | Reservation date and time |

| `timeSlot` | String | Yes | Selected time slot |

| `seats` | Integer | Yes | Number of seats |

| `tableNumber` | Integer | Yes | Assigned table number |

| `createdAt` | Timestamp | No | Creation time |



`userId` is a proposed ownership field; it is not currently present in the Dart `Reservation` model. `restaurantId` represents the existing nested `Restaurant` relationship.



\### 4.13 takeawayOrders



\*\*Path:\*\* `takeawayOrders/{orderId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `userId` | String | Yes | Owner's Firebase UID |

| `restaurantId` | String | Yes | Selected restaurant ID |

| `items` | Array<Map> | Yes | Order line items |

| `status` | String | Yes | Takeaway status |

| `createdAt` | Timestamp | Yes | Order creation time |



Each `items` entry contains:



| Nested field | Firestore type | Description |

|---|---|---|

| `dishId` | String | Referenced dish |

| `quantity` | Integer | Ordered quantity |

| `unitPrice` | Number | Price snapshot at order time |



Allowed status values: `preparing`, `packing`, `readyForTakeaway`, `taken`.



`totalQuantity` and `grandTotal` are derived from the order items. The stored unit price preserves the checkout price.



\### 4.14 cateringOrders



\*\*Path:\*\* `cateringOrders/{orderId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `userId` | String | Yes | Owner's Firebase UID |

| `date` | Timestamp | Yes | Catering date |

| `guestRange` | String | Yes | Selected guest range |

| `status` | String | Yes | Catering request status |

| `createdAt` | Timestamp | Yes | Request creation time |



Allowed status values: `notifiedParagon`, `call`, `bookingConfirmed`.



`userId` is a proposed ownership field; it is not present in the current Dart `CateringOrder` model.



\### 4.15 mealPlans



\*\*Path:\*\* `users/{userId}/mealPlans/{mealId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `dayOffset` | Integer | Yes | Day offset |

| `mealType` | String | Yes | `breakfast`, `lunch`, or `dinner` |

| `timeSlot` | String | Yes | Planned meal time |

| `location` | String | Yes | Meal location |

| `dishName` | String | Yes | Planned dish name |

| `imageUrl` | String | Yes | Dish image |

| `calories` | Integer | Yes | Calories |

| `weightGm` | Integer | Yes | Meal weight |

| `price` | Number | Yes | Meal price |

| `protein` | Integer | Yes | Protein |

| `carbs` | Integer | Yes | Carbohydrates |

| `fat` | Integer | Yes | Fat |



\### 4.16 plannerOrders



\*\*Path:\*\* `plannerOrders/{orderId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `userId` | String | Yes | Owner's Firebase UID |

| `etaMins` | Integer | Yes | Estimated arrival minutes |

| `status` | String | Yes | `orderAccepted`, `taken`, or `done` |

| `driverName` | String | Yes | Delivery partner name |

| `driverPhone` | String | Yes | Delivery partner phone |

| `driverPhotoUrl` | String | No | Delivery partner photo |

| `paymentLabel` | String | Yes | Payment display label |

| `deliveryTimeWindow` | String | Yes | Delivery time window |

| `items` | Array<Map> | Yes | Planner order items |

| `subtotal` | Number | Yes | Item subtotal |

| `deliveryFee` | Number | Yes | Delivery fee |



Each item contains `name` (String), `quantity` (Integer), and `price` (Number).



`grandTotal` is derived from `subtotal` and `deliveryFee`.



\### 4.17 calorieStats



\*\*Path:\*\* `users/{userId}/calorieStats/{dateId}`



| Field | Firestore type | Required | Description |

|---|---|---|---|

| `targetKcal` | Integer | Yes | Daily calorie target |

| `remainingKcal` | Integer | Yes | Remaining calories |

| `proteinG` | Integer | Yes | Protein total |

| `carbsG` | Integer | Yes | Carbohydrate total |

| `fatG` | Integer | Yes | Fat total |



Use a consistent date ID format such as `YYYY-MM-DD`.



\## 5. Relationships



\- A restaurant can have multiple reservations and takeaway orders.

\- A dish can appear in multiple cart entries and order items.

\- A user can own multiple addresses, payment method display records, notifications, cart entries, reservations, and orders.

\- A reservation references one restaurant through `restaurantId`.

\- A takeaway order references one restaurant and contains multiple dish line items.

\- A planner order contains multiple order items.

\- User-owned subcollections should be scoped to the authenticated user's UID.



\## 6. Data modelling rules



1\. Use stable document IDs; avoid generating a new document for the same logical record on every read.

2\. Store enum values as their exact Dart enum names.

3\. Use Firestore `Timestamp` for dates, not formatted date strings.

4\. Store order item price snapshots so historical orders are not changed when menu prices change.

5\. Calculate totals such as cart line totals and order grand totals consistently. Validate all financial totals on trusted backend code before accepting payment or finalizing orders.

6\. Keep UI-only values, such as formatted labels and derived status text, out of the canonical stored data unless there is a clear backend requirement.

7\. Use Firebase Authentication UID for user ownership.

8\. Validate required fields and data types in Firestore Security Rules and trusted backend code.

9\. Do not expose private user records to other users.

10\. Treat payment-provider credentials and sensitive payment information as external-provider data, not Firestore profile fields.



\## 7. Security considerations



\- Require authentication for user-specific operations.

\- Enforce ownership checks using the authenticated UID.

\- Restrict public reads to explicitly approved catalogue and content collections.

\- Prevent clients from changing protected order fields or assigning themselves privileged roles.

\- Validate field types, required fields, allowed enum values, and numeric ranges.

\- Use trusted Cloud Functions or another trusted backend for sensitive order and payment operations.

\- Review and test Firestore Security Rules before enabling application access.



\## 8. Implementation status and assumptions



\- Existing Dart models and `mock\_data.dart` are the source for the current application data fields.

\- This document proposes a Firestore structure; it does not implement Firestore repositories, serialization, or security rules.

\- `userId`, `createdAt`, `updatedAt`, and certain order snapshot fields are proposed additions where the current models do not define them.

\- Some models, such as meal planning and catering, may require further review against actual application workflows before production implementation.

\- Existing mock data includes local asset paths as well as remote image URLs. Local asset paths must not be treated as publicly accessible URLs without an asset migration strategy.



\## 9. Related source files



\- `lib/models/restaurant.dart`

\- `lib/models/dish.dart`

\- `lib/models/cart\_item.dart`

\- `lib/models/address.dart`

\- `lib/models/payment\_method.dart`

\- `lib/models/app\_notification.dart`

\- `lib/models/menu\_category.dart`

\- `lib/models/promo\_banner.dart`

\- `lib/models/onboarding\_item.dart`

\- `lib/models/service\_item.dart`

\- `lib/models/reservation.dart`

\- `lib/models/takeaway\_order.dart`

\- `lib/models/catering\_order.dart`

\- `lib/models/meal\_plan.dart`

\- `lib/data/mock\_data.dart`

---

## 10. Shared canonical business collections

The following collections extend the existing application model to provide shared records for the restaurant's operational domains. They are proposed additions and require confirmation against the company's business workflows before production use.

### 10.1 branches

**Path:** `branches/{branchId}`

| Field | Firestore type | Required | Description |
|---|---|---|---|
| `restaurantId` | String | Yes | Parent restaurant ID |
| `name` | String | Yes | Branch name |
| `address` | String | Yes | Branch address |
| `city` | String | Yes | Branch city |
| `phone` | String | No | Branch contact number |
| `timezone` | String | No | Branch timezone |
| `status` | String | No | Branch operational status |

Allowed `status` values must match the `branchStatus` enum in `functions/firestore-schema.js`.

### 10.2 kitchens

**Path:** `kitchens/{kitchenId}`

| Field | Firestore type | Required | Description |
|---|---|---|---|
| `branchId` | String | Yes | Parent branch ID |
| `name` | String | Yes | Kitchen name |
| `status` | String | No | Kitchen operational status |
| `createdAt` | Timestamp | No | Creation time |

Allowed `status` values must match the `kitchenStatus` enum in the schema validator.

### 10.3 products

**Path:** `products/{productId}`

| Field | Firestore type | Required | Description |
|---|---|---|---|
| `name` | String | Yes | Product name |
| `price` | Number | Yes | Product price |
| `description` | String | No | Product description |
| `imageUrl` | String | No | Product image |
| `category` | String | No | Product category |
| `sku` | String | No | Stock keeping unit |
| `restaurantId` | String | No | Parent restaurant ID |
| `branchId` | String | No | Associated branch ID |
| `isAvailable` | Boolean | No | Product availability |
| `createdAt` | Timestamp | No | Creation time |
| `updatedAt` | Timestamp | No | Last update time |

### 10.4 inventory

**Path:** `inventory/{inventoryId}`

| Field | Firestore type | Required | Description |
|---|---|---|---|
| `branchId` | String | Yes | Branch holding the inventory |
| `productId` | String | Yes | Referenced product ID |
| `quantity` | Number | Yes | Available quantity |
| `unit` | String | Yes | Inventory measurement unit |
| `kitchenId` | String | No | Associated kitchen ID |
| `reorderLevel` | Number | No | Reorder threshold |
| `updatedAt` | Timestamp | No | Last inventory update |

Inventory changes should be validated by trusted backend operations to prevent inconsistent stock levels.

### 10.5 orders

**Path:** `orders/{orderId}`

| Field | Firestore type | Required | Description |
|---|---|---|---|
| `userId` | String | Yes | Customer Firebase UID |
| `branchId` | String | Yes | Fulfilling branch ID |
| `type` | String | Yes | Order type |
| `status` | String | Yes | Order status |
| `items` | Array<Map> | Yes | Order line items |
| `subtotal` | Number | Yes | Items subtotal |
| `total` | Number | Yes | Final order total |
| `createdAt` | Timestamp | Yes | Order creation time |
| `restaurantId` | String | No | Parent restaurant ID |
| `reservationId` | String | No | Related reservation ID |
| `notes` | String | No | Additional order notes |
| `updatedAt` | Timestamp | No | Last update time |

Each `items` entry contains:

| Nested field | Firestore type | Required | Description |
|---|---|---|---|
| `dishId` | String | Yes | Referenced dish ID |
| `quantity` | Integer | Yes | Ordered quantity |
| `unitPrice` | Number | Yes | Price snapshot at order time |

Allowed `type` and `status` values must match the `orderType` and `orderStatus` enums in the schema validator.

### 10.6 subscriptions

**Path:** `subscriptions/{subscriptionId}`

| Field | Firestore type | Required | Description |
|---|---|---|---|
| `ownerId` | String | Yes | Subscription owner ID |
| `planId` | String | Yes | Subscription plan ID |
| `status` | String | Yes | Subscription status |
| `startAt` | Timestamp | Yes | Subscription start time |
| `createdAt` | Timestamp | Yes | Record creation time |
| `endAt` | Timestamp | No | Subscription end time |
| `amount` | Number | No | Subscription amount |
| `currency` | String | No | Currency code |
| `billingInterval` | String | No | Billing frequency |
| `providerSubscriptionId` | String | No | External provider subscription ID |
| `updatedAt` | Timestamp | No | Last update time |

Allowed `status` values must match the `subscriptionStatus` enum in the schema validator.

### 10.7 payments

**Path:** `payments/{paymentId}`

| Field | Firestore type | Required | Description |
|---|---|---|---|
| `orderId` | String | Yes | Related order ID |
| `userId` | String | Yes | Customer Firebase UID |
| `amount` | Number | Yes | Payment amount |
| `currency` | String | Yes | Currency code |
| `provider` | String | Yes | Payment provider |
| `status` | String | Yes | Payment transaction status |
| `createdAt` | Timestamp | Yes | Payment creation time |
| `providerPaymentId` | String | No | External provider payment ID |
| `subscriptionId` | String | No | Related subscription ID |
| `updatedAt` | Timestamp | No | Last update time |

Allowed `status` values must match the `paymentStatus` enum in the schema validator.

Never store card numbers, CVV, PINs, passwords, or payment-provider secrets in these documents.

## 11. Shared schema relationships

- A restaurant can contain multiple branches.
- A branch can contain multiple kitchens.
- Products can be associated with restaurants and branches.
- Inventory records connect products to branches and optionally kitchens.
- Orders belong to users and are fulfilled by branches.
- Order items preserve product or dish identifiers, quantities, and checkout-time prices.
- Payments reference their associated orders and may reference subscriptions.
- Subscriptions belong to an owner and reference a subscription plan.

## 12. Compatibility and migration notes

- The existing collections such as `restaurants`, `dishes`, `takeawayOrders`, `cateringOrders`, and `plannerOrders` are retained for compatibility with the current Flutter models.
- The new `branches`, `products`, and `orders` collections introduce shared operational concepts. Their relationship to the existing collections must be confirmed before migration.
- `paymentMethods` stores user payment display metadata; `payments` stores transaction records. They serve different purposes.
- Do not delete, rename, or migrate existing collections until the company approves the canonical mapping and migration plan.
- The new validators in `functions/firestore-schema.js` validate document shapes. They do not create collections, connect Flutter repositories, or deploy Firestore rules.
- These proposed fields and enum values require business-owner review before production adoption.

