# Example: Feature Testing Plan -- Checkout Flow

A complete testing plan for an e-commerce checkout feature covering all layers of the testing pyramid.

## Feature Overview

Users can add items to their cart, proceed to checkout, enter shipping and payment information, and place an order. The system processes payment via Stripe, sends a confirmation email, and updates inventory.

## Risk Assessment

| Component | Impact | Change Freq | Category | Priority |
|---|---|---|---|---|
| Payment processing | Critical | Low | GUARD | P0 |
| Order creation | Critical | Medium | FORTRESS | P0 |
| Price calculation | Critical | Medium | FORTRESS | P0 |
| Inventory update | High | Low | GUARD | P0 |
| Email confirmation | Medium | Low | GUARD | P1 |
| Cart UI | Medium | High | SHIELD | P1 |
| Address validation | Medium | Medium | SHIELD | P1 |
| Promo code application | Medium | High | SHIELD | P1 |

## Unit Tests (17 tests)

### Price Calculation (`calculateOrderTotal.test.ts`)
```typescript
describe('calculateOrderTotal', () => {
  it('sums item prices * quantities');
  it('applies percentage discount code');
  it('applies fixed-amount discount code');
  it('does not allow negative totals');
  it('rounds to 2 decimal places');
  it('handles empty cart returning zero');
  it('applies tax based on shipping state');
  it('caps discount at order subtotal');
});
```

### Cart Store (`cartStore.test.ts`)
```typescript
describe('CartStore', () => {
  it('adds item to empty cart');
  it('increments quantity for existing item');
  it('removes item from cart');
  it('clears entire cart');
  it('calculates item count badge');
  it('persists to localStorage on change');
  it('restores from localStorage on init');
});
```

### Address Validator (`validateAddress.test.ts`)
```typescript
describe('validateAddress', () => {
  it('accepts valid US address');
  it('rejects missing required fields');
});
```

## Integration Tests (8 tests)

### Order API (`POST /api/orders`)
```typescript
describe('POST /api/orders', () => {
  it('creates order and returns 201 with order ID');
  it('returns 400 for missing required fields');
  it('returns 409 for duplicate idempotency key');
  it('deducts inventory on success');
  it('rolls back inventory on payment failure');
});
```

### Stripe Payment Integration
```typescript
describe('PaymentService (with MSW)', () => {
  it('processes payment and returns charge ID');
  it('handles card_declined error gracefully');
  it('retries on rate_limit error');
});
```

## E2E Tests (4 tests)

### Happy Path (`checkout.spec.ts`)
```typescript
test('complete checkout with valid card', async ({ page }) => {
  // Seed: user logged in, 2 items in cart
  await page.goto('/cart');
  await page.getByRole('button', { name: 'Checkout' }).click();

  // Shipping
  await page.getByLabel('Street').fill('123 Main St');
  await page.getByLabel('City').fill('Austin');
  await page.getByLabel('State').selectOption('TX');
  await page.getByLabel('ZIP').fill('78701');
  await page.getByRole('button', { name: 'Continue' }).click();

  // Payment (Stripe test card)
  const stripeFrame = page.frameLocator('iframe[name*="stripe"]');
  await stripeFrame.getByPlaceholder('Card number').fill('4242424242424242');
  await stripeFrame.getByPlaceholder('MM / YY').fill('12/30');
  await stripeFrame.getByPlaceholder('CVC').fill('123');

  await page.getByRole('button', { name: 'Place order' }).click();

  // Confirmation
  await expect(page).toHaveURL(/\/confirmation/);
  await expect(page.getByText('Order confirmed')).toBeVisible();
  await expect(page.getByTestId('order-number')).not.toBeEmpty();
});
```

### Error Recovery
```typescript
test('shows error and allows retry on payment failure', async ({ page }) => {
  await page.goto('/cart');
  await page.getByRole('button', { name: 'Checkout' }).click();
  // ... fill shipping ...

  // Use Stripe test card for decline
  const stripeFrame = page.frameLocator('iframe[name*="stripe"]');
  await stripeFrame.getByPlaceholder('Card number').fill('4000000000000002');
  // ... fill rest ...

  await page.getByRole('button', { name: 'Place order' }).click();
  await expect(page.getByText('Payment declined')).toBeVisible();

  // Retry with valid card
  await stripeFrame.getByPlaceholder('Card number').clear();
  await stripeFrame.getByPlaceholder('Card number').fill('4242424242424242');
  await page.getByRole('button', { name: 'Try again' }).click();

  await expect(page.getByText('Order confirmed')).toBeVisible();
});
```

### Empty Cart Guard
```typescript
test('redirects to cart if cart is empty', async ({ page }) => {
  await page.goto('/checkout');
  await expect(page).toHaveURL('/cart');
  await expect(page.getByText('Your cart is empty')).toBeVisible();
});
```

### Promo Code
```typescript
test('applies promo code and reflects in total', async ({ page }) => {
  await page.goto('/cart');
  await page.getByPlaceholder('Promo code').fill('SAVE20');
  await page.getByRole('button', { name: 'Apply' }).click();

  await expect(page.getByText('20% off')).toBeVisible();
  // Verify discounted total
  const total = await page.getByTestId('order-total').textContent();
  expect(parseFloat(total!.replace('$', ''))).toBeLessThan(100);
});
```

## Coverage Targets

| Scope | Statements | Branches | Functions |
|---|---|---|---|
| `src/services/pricing/` | 95% | 90% | 95% |
| `src/services/payment/` | 90% | 85% | 90% |
| `src/stores/cart/` | 85% | 80% | 85% |
| `src/components/checkout/` | 75% | 70% | 75% |
| **Overall feature** | **85%** | **80%** | **85%** |

## CI Pipeline

```
Unit tests (17) -----> ~5s
Integration tests (8) -> ~15s (parallel)
E2E tests (4) -------> ~45s (parallel, 2 workers)
Total ----------------> ~1 min with parallelism
```

All tests must pass before merge. Coverage must not decrease.
