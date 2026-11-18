\# ARCH-006: Domain Enums and Status Contracts



\## 1. Purpose



Define shared status values for orders, reservations, subscriptions,

catering, and payment transactions.



The goal is to keep status names consistent across application

modules and backend validation.



\## 2. Order Status



\### Shared Order



Collection: `orders`



| Status | Meaning |

|---|---|

| `pending` | Order has been created and is awaiting confirmation |

| `confirmed` | Order has been confirmed |

| `preparing` | Order preparation is in progress |

| `ready` | Order is ready |

| `completed` | Order is completed |

| `cancelled` | Order has been cancelled |



\### Takeaway Order



Collection: `takeawayOrders`



| Status | Meaning |

|---|---|

| `preparing` | Order is being prepared |

| `packing` | Order is being packed |

| `readyForTakeaway` | Order is ready for collection |

| `taken` | Order has been collected |



\## 3. Reservation Status



Collection: `reservations`



| Status | Meaning |

|---|---|

| `pending` | Reservation is awaiting confirmation |

| `confirmed` | Reservation is confirmed |

| `cancelled` | Reservation is cancelled |

| `completed` | Reservation is completed |



The reservation status field is optional for legacy records.



\## 4. Subscription Status



Collection: `subscriptions`



| Status | Meaning |

|---|---|

| `trialing` | Subscription is in its trial period |

| `active` | Subscription is active |

| `pastDue` | Payment is overdue |

| `cancelled` | Subscription is cancelled |

| `expired` | Subscription has expired |



\## 5. Catering Status



Collection: `cateringOrders`



| Status | Meaning |

|---|---|

| `notifiedParagon` | Paragon has been notified |

| `call` | A call is required or in progress |

| `bookingConfirmed` | Catering booking is confirmed |



These values preserve the existing application enum.



\## 6. Planner Order Status



Collection: `plannerOrders`



| Status | Meaning |

|---|---|

| `orderAccepted` | Order has been accepted |

| `taken` | Order has been taken |

| `done` | Order is completed |



These values preserve the existing application enum.



\## 7. Payment Transaction Status



Collection: `payments`



| Status | Meaning |

|---|---|

| `pending` | Payment is awaiting processing |

| `authorized` | Payment has been authorized |

| `captured` | Payment has been captured |

| `failed` | Payment has failed |

| `refunded` | Payment has been refunded |



Payment method types are separate from payment transaction statuses.



Existing payment methods:

\- `card`

\- `upi`

\- `wallet`

\- `netBanking`

\- `cash`



\## 8. Order Types



| Value | Meaning |

|---|---|

| `takeaway` | Customer collects the order |

| `delivery` | Order is delivered |

| `dineIn` | Customer eats at the restaurant |

| `catering` | Catering order |



\## 9. Contract Rules



1\. Status values must match the canonical backend enums.

2\. Do not introduce alternative spellings for existing status values.

3\. Payment methods must not be treated as payment transaction statuses.

4\. Legacy reservation records may omit the status field.

5\. New status values require coordinated updates to backend validation,

&#x20;  application models, tests, and documentation.

6\. Status transition rules must be confirmed by the business before

&#x20;  implementation.

7\. Existing status values must not be changed without migration planning.



\## 10. Validation



Backend enum definitions are maintained in:



`functions/firestore-schema.js`



Automated validation tests are maintained in:



`functions/test/firestore-schema.test.js`



Run tests using:



```bash

npm test --prefix functions

