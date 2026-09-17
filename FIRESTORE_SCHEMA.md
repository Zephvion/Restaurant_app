# Cloud Firestore Database Schema & Data Models

Because **Cloud Firestore** is a NoSQL document database, schemas are structured as **Collections** of JSON-like **Documents**. The models and serialization logic are defined in Dart under [`lib/models/`](file:///Users/mohanamahadevaiah/Restaurant_app/lib/models/).

Below is the complete reference schema for all 10 collections.

---

## 1. `users` Collection
**Document Path**: `/users/{userId}`  
**Description**: Stores user profile, contact details, and saved delivery addresses.

```json
{
  "uid": "usr_abc123",
  "name": "Arti Abraham",
  "email": "artiabraham123@gmail.com",
  "phone": "+91 9874563210",
  "avatarUrl": "https://images.unsplash.com/photo-1544005313-94ddf0286df2",
  "addresses": [
    {
      "label": "Home",
      "details": "Flat no 9B, Landmark World, Palazhi, Calicut, 673014",
      "latitude": 11.2588,
      "longitude": 75.7804,
      "isDefault": true
    }
  ],
  "createdAt": "2026-09-16T10:30:00Z"
}
```
*Model File*: [`lib/models/user_profile.dart`](file:///Users/mohanamahadevaiah/Restaurant_app/lib/models/user_profile.dart)

---

## 2. `dishes` Collection
**Document Path**: `/dishes/{dishId}`  
**Description**: Food catalog with pricing, nutritional values, tags, and ingredients.

```json
{
  "id": "plain_dosa",
  "name": "Plain Dosa",
  "subtitle": "2 nos",
  "price": 80.0,
  "imageUrl": "assets/images/order/extracted/dosa.png",
  "rating": 4.8,
  "kcal": 210,
  "grams": 180,
  "carbs": 35,
  "fat": 6,
  "protein": 5,
  "isVeg": true,
  "category": "Breakfast",
  "description": "Crisp golden fermented rice crepe served with coconut chutney & piping hot sambar.",
  "ingredients": [
    "Fermented rice and urad dal batter",
    "Cold-pressed sesame oil",
    "Salt"
  ]
}
```
*Model File*: [`lib/models/dish.dart`](file:///Users/mohanamahadevaiah/Restaurant_app/lib/models/dish.dart)

---

## 3. `categories` Collection
**Document Path**: `/categories/{categoryId}`  
**Description**: Food menu category chips & icons.

```json
{
  "id": "breakfast",
  "name": "Breakfast",
  "imageUrl": "assets/images/order/extracted/cat_breakfast.png"
}
```
*Model File*: [`lib/models/menu_category.dart`](file:///Users/mohanamahadevaiah/Restaurant_app/lib/models/menu_category.dart)

---

## 4. `restaurants` Collection
**Document Path**: `/restaurants/{restaurantId}`  
**Description**: Restaurant branches, geo-locations, contact, and operational hours.

```json
{
  "id": "rest_calicut_beach",
  "name": "PARAGON Restaurant - Beach Road",
  "location": "Beach Road, Kozhikode, Kerala 673032",
  "rating": 4.9,
  "reviewCount": 12500,
  "imageUrl": "https://images.unsplash.com/photo-1552566626-52f8b828add9",
  "timings": "07:00 AM - 11:30 PM",
  "contactPhone": "+91 495 276 7020",
  "latitude": 11.2590,
  "longitude": 75.7725
}
```
*Model File*: [`lib/models/restaurant.dart`](file:///Users/mohanamahadevaiah/Restaurant_app/lib/models/restaurant.dart)

---

## 5. `promos` Collection
**Document Path**: `/promos/{promoId}`  
**Description**: Carousel promotional banners and coupon codes.

```json
{
  "headline": "GET 10% OFF",
  "code": "WELCOMEBACK",
  "imageUrl": "assets/images/order/extracted/promo_banner_1.png"
}
```
*Model File*: [`lib/models/promo_banner.dart`](file:///Users/mohanamahadevaiah/Restaurant_app/lib/models/promo_banner.dart)

---

## 6. `orders` Collection
**Document Path**: `/orders/{orderId}`  
**Description**: Real-time customer food delivery orders.

```json
{
  "id": "PO84729103",
  "userId": "usr_abc123",
  "items": [
    {
      "dishId": "plain_dosa",
      "name": "Plain Dosa",
      "price": 80.0,
      "quantity": 2,
      "imageUrl": "assets/images/order/extracted/dosa.png"
    }
  ],
  "subtotal": 160.0,
  "gst": 8.0,
  "deliveryFee": 30.0,
  "discount": 16.0,
  "grandTotal": 182.0,
  "appliedCoupon": "WELCOMEBACK",
  "deliveryAddress": {
    "label": "Home",
    "details": "Flat no 9B, Landmark World, Palazhi, Calicut, 673014",
    "latitude": 11.2588,
    "longitude": 75.7804
  },
  "paymentMethodLabel": "Google Pay (UPI)",
  "status": "onTheWay",
  "estimatedDeliveryMinutes": 18,
  "deliveryPartnerName": "John Doe",
  "deliveryPartnerPhone": "+91 9876543210",
  "deliveryPartnerLat": 11.2580,
  "deliveryPartnerLng": 75.7790,
  "createdAt": "2026-09-16T11:00:00Z"
}
```
*Model File*: [`lib/models/order_model.dart`](file:///Users/mohanamahadevaiah/Restaurant_app/lib/models/order_model.dart)

---

## 7. `reservations` Collection
**Document Path**: `/reservations/{reservationId}`  
**Description**: Dine-in table reservations.

```json
{
  "id": "res_98124",
  "userId": "usr_abc123",
  "restaurant": {
    "id": "rest_calicut_beach",
    "name": "PARAGON Restaurant - Beach Road"
  },
  "date": "2026-09-20",
  "timeSlot": "07:30 PM",
  "seats": 4,
  "tableNumber": 8,
  "status": "confirmed",
  "createdAt": "2026-09-16T11:15:00Z"
}
```
*Model File*: [`lib/models/reservation.dart`](file:///Users/mohanamahadevaiah/Restaurant_app/lib/models/reservation.dart)

---

## 8. `takeaway_orders` Collection
**Document Path**: `/takeaway_orders/{takeawayId}`  
**Description**: Self-pickup takeaway orders.

```json
{
  "id": "tk_54210",
  "userId": "usr_abc123",
  "restaurant": {
    "id": "rest_calicut_beach",
    "name": "PARAGON Restaurant - Beach Road"
  },
  "pickupTime": "2026-09-16T19:00:00Z",
  "items": [
    {
      "dishId": "appam_stew",
      "name": "Appam & Stew",
      "price": 180.0,
      "quantity": 2
    }
  ],
  "totalAmount": 360.0,
  "status": "preparing",
  "createdAt": "2026-09-16T11:20:00Z"
}
```
*Model File*: [`lib/models/takeaway_order.dart`](file:///Users/mohanamahadevaiah/Restaurant_app/lib/models/takeaway_order.dart)

---

## 9. `catering_orders` Collection
**Document Path**: `/catering_orders/{cateringId}`  
**Description**: Bulk catering orders for events/functions.

```json
{
  "id": "cat_31094",
  "userId": "usr_abc123",
  "eventType": "Wedding Reception",
  "eventDate": "2026-10-15",
  "timeSlot": "12:30 PM",
  "guestCount": 250,
  "venueAddress": "Grand Auditorium, Calicut",
  "specialInstructions": "Traditional Kerala Sadhya with vegetarian & non-veg options.",
  "status": "underReview",
  "createdAt": "2026-09-16T11:25:00Z"
}
```
*Model File*: [`lib/models/catering_order.dart`](file:///Users/mohanamahadevaiah/Restaurant_app/lib/models/catering_order.dart)

---

## 10. `meal_plans` Collection
**Document Path**: `/meal_plans/{userId}`  
**Description**: Customized weekly meal planning and daily caloric intake goals.

```json
{
  "userId": "usr_abc123",
  "dailyCalorieTarget": 2200,
  "weeklyPlan": {
    "Monday": {
      "breakfast": "Appam & Stew",
      "lunch": "Special Meals",
      "dinner": "Plain Dosa"
    }
  },
  "updatedAt": "2026-09-16T11:30:00Z"
}
```
*Model File*: [`lib/models/meal_plan.dart`](file:///Users/mohanamahadevaiah/Restaurant_app/lib/models/meal_plan.dart)

