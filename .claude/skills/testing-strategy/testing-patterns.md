# Testing Patterns by Layer

## Unit Test Patterns

**Pure function tests**: Easiest to test, highest ROI.

```typescript
describe('calculateDiscount', () => {
  it.each([
    { subtotal: 100, code: 'SAVE10', expected: 90 },
    { subtotal: 50, code: 'SAVE10', expected: 45 },
    { subtotal: 100, code: 'INVALID', expected: 100 },
    { subtotal: 0, code: 'SAVE10', expected: 0 },
  ])('returns $expected for subtotal=$subtotal code=$code', ({ subtotal, code, expected }) => {
    expect(calculateDiscount(subtotal, code)).toBe(expected);
  });
});
```

**React component tests** (Testing Library):

```typescript
import { render, screen, userEvent } from '@testing-library/react';

describe('SearchBar', () => {
  it('calls onSearch with debounced input', async () => {
    const onSearch = vi.fn();
    const user = userEvent.setup();
    render(<SearchBar onSearch={onSearch} debounceMs={100} />);

    await user.type(screen.getByRole('searchbox'), 'react');

    // Wait for debounce
    await waitFor(() => {
      expect(onSearch).toHaveBeenCalledWith('react');
    });
    expect(onSearch).toHaveBeenCalledTimes(1);
  });
});
```

**Custom hook tests**:

```typescript
import { renderHook, act } from '@testing-library/react';

describe('useCounter', () => {
  it('increments and decrements', () => {
    const { result } = renderHook(() => useCounter(0));

    act(() => result.current.increment());
    expect(result.current.count).toBe(1);

    act(() => result.current.decrement());
    expect(result.current.count).toBe(0);
  });
});
```

## Integration Test Patterns

**API route tests** (supertest + Express):

```typescript
import request from 'supertest';
import { app } from '../app';
import { db } from '../db';

describe('POST /api/orders', () => {
  beforeEach(() => db.migrate.latest());
  afterEach(() => db.migrate.rollback());

  it('creates order and returns 201', async () => {
    const res = await request(app)
      .post('/api/orders')
      .send({ productId: '1', quantity: 2 })
      .expect(201);

    expect(res.body).toMatchObject({
      id: expect.any(String),
      status: 'pending',
    });
  });
});
```

**Database integration tests**:

```typescript
describe('UserRepository', () => {
  let repo: UserRepository;

  beforeAll(async () => {
    await testDb.connect();
    repo = new UserRepository(testDb);
  });

  afterEach(async () => {
    await testDb.query('DELETE FROM users');
  });

  afterAll(async () => {
    await testDb.disconnect();
  });

  it('finds user by email', async () => {
    await repo.create({ email: 'a@b.com', name: 'Alice' });
    const user = await repo.findByEmail('a@b.com');
    expect(user?.name).toBe('Alice');
  });
});
```

## E2E Test Patterns

**Page Object Model** (Playwright):

```typescript
class CheckoutPage {
  constructor(private page: Page) {}

  async fillShipping(address: ShippingAddress) {
    await this.page.getByLabel('Street').fill(address.street);
    await this.page.getByLabel('City').fill(address.city);
    await this.page.getByLabel('ZIP').fill(address.zip);
  }

  async submitOrder() {
    await this.page.getByRole('button', { name: 'Place order' }).click();
    await this.page.waitForURL('**/confirmation');
  }

  async getConfirmationNumber() {
    return this.page.getByTestId('confirmation-number').textContent();
  }
}
```
