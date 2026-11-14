\# ARCH-014: Roles and Permission Matrix



\## 1. Purpose



Define role-based access control (RBAC) for the Restaurant App.

All permissions must be enforced by trusted backend services and

Firestore Security Rules, not by Flutter UI visibility alone.



\## 2. Roles



| Role | Description |

|---|---|

| customer | Registered application customer |

| admin | Authorized platform administrator |

| branch\_manager | Manager assigned to a specific branch |

| kitchen\_staff | Staff assigned to a specific kitchen |

| operational\_staff | Authorized staff with limited operational access |



\## 3. Permission Matrix



Legend:

\- R = Read

\- C = Create

\- U = Update

\- D = Delete

\- A = Administrative control

\- — = No access



| Resource | Customer | Admin | Branch Manager | Kitchen Staff | Operational Staff |

|---|---|---|---|---|---|

| Own user profile | R/U | A | — | — | — |

| Other user profiles | — | R/U | — | — | — |

| Restaurants | R | A | R | R | R |

| Branches | R | A | R/U assigned | R assigned | R assigned |

| Kitchens | — | A | R/U assigned | R/U assigned | R assigned |

| Dishes and products | R | A | R/C/U assigned | R | R |

| Inventory | — | A | R/C/U assigned | R | R assigned |

| Own cart | R/C/U/D | A | — | — | — |

| Own reservations | R/C/U | A | R assigned | R assigned | R assigned |

| Own takeaway orders | R/C | A | R/U assigned | R/U assigned | R assigned |

| Own catering orders | R/C | A | R/U assigned | R assigned | R assigned |

| Own planner orders | R/C | A | R/U assigned | R assigned | R assigned |

| Own meal plans | R/C/U/D | A | — | — | — |

| Payments | R own | A | R assigned | — | R assigned |

| Subscriptions | R own | A | — | — | — |

| Notifications | R own | A | — | — | — |

| Role assignments | — | A | — | — | — |

| Audit records | — | A | R assigned | — | — |



Operational permissions are restricted to the assigned branch or kitchen.

The exact permitted status transitions must follow approved business rules.



\## 4. Authorization Rules



1\. Every authenticated user receives the customer role by default.

2\. Privileged roles are assigned only by trusted administrative tooling.

3\. Clients cannot grant or modify their own roles.

4\. Admin access requires a trusted Firebase custom claim.

5\. Branch managers are restricted to assigned branches.

6\. Kitchen staff are restricted to assigned kitchens.

7\. Operational staff can access only explicitly assigned resources.

8\. User-owned documents must be checked against Firebase Auth UID.

9\. Payment and other privileged operations must execute on trusted backend code.

10\. Deny access by default when a role or permission is missing.

11\. Never trust role values supplied in request data.

12\. Role changes must be audited.



\## 5. Role Claim Structure



Proposed Firebase custom claims:



&#x20;   {

&#x20;     "role": "branch\_manager",

&#x20;     "branchIds": \["branch\_001"]

&#x20;   }



Kitchen staff example:



&#x20;   {

&#x20;     "role": "kitchen\_staff",

&#x20;     "branchIds": \["branch\_001"],

&#x20;     "kitchenIds": \["kitchen\_001"]

&#x20;   }



Admin example:



&#x20;   {

&#x20;     "role": "admin",

&#x20;     "admin": true

&#x20;   }



These claims must be assigned by trusted Admin SDK code.

They must never be accepted directly from a client request.



\## 6. Backend Enforcement



\- Validate Firebase authentication before authorization.

\- Resolve permissions from trusted token claims.

\- Check resource ownership and branch/kitchen scope.

\- Reject unauthorized operations with permission-denied.

\- Validate requested status transitions on the backend.

\- Never execute arbitrary client-supplied administrative operations.



\## 7. Implementation Boundaries



This matrix defines the proposed authorization contract.

It does not itself deploy Firestore Security Rules or assign user roles.



Role names, operational permissions and status transitions require

business-owner approval before production enforcement.



\## 8. Acceptance Checklist



\- \[x] Customer, Admin and operational roles defined.

\- \[x] Resource permission matrix documented.

\- \[x] Ownership and organizational scope documented.

\- \[x] Trusted role assignment requirements documented.

\- \[ ] Backend authorization helpers implemented and tested.

\- \[ ] Firestore Security Rules reviewed and tested.

\- \[ ] Business-owner approval obtained.

