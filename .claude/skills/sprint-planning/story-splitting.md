# Story Splitting Patterns

When a user story is too large (13+ points) or violates INVEST, apply one of these splitting strategies:

## 1. Workflow Steps

Split by sequential steps in a user flow.

- **Before:** "As a user, I want to purchase a product"
- **After:**
  - "As a user, I want to add items to my cart"
  - "As a user, I want to enter shipping details"
  - "As a user, I want to complete payment"

## 2. Business Rule Variations

Split by different rules or conditions.

- **Before:** "As a user, I want to apply a discount code"
- **After:**
  - "As a user, I want to apply a percentage discount"
  - "As a user, I want to apply a fixed-amount discount"
  - "As a user, I want to see an error for expired codes"

## 3. Data Variations

Split by different data types or input formats.

- **Before:** "As a user, I want to import my data"
- **After:**
  - "As a user, I want to import from CSV"
  - "As a user, I want to import from JSON"

## 4. Interface Variations

Split by platform or device.

- **Before:** "As a user, I want a responsive dashboard"
- **After:**
  - "As a user, I want to view the dashboard on desktop"
  - "As a user, I want to view the dashboard on mobile"

## 5. CRUD Operations

Split create, read, update, delete into separate stories.

## 6. Performance / Optimization

Deliver functionality first, then optimize.

- Story 1: "Basic search returns results"
- Story 2: "Search results load within 200ms"

## 7. Spike + Implementation

When uncertainty is high, split research from implementation.

- Spike: "Investigate payment gateway API capabilities" (time-boxed, 1-2 days)
- Story: "Integrate Stripe payment processing" (follows spike)
