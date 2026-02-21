# Testing Strategy -- Reference

Extended reference material for the testing-strategy skill. Consult SKILL.md for primary procedures.

## Framework Comparison Deep Dive

### Vitest vs Jest

| Feature | Vitest | Jest |
|---|---|---|
| Speed (Vite projects) | ~4x faster (native ESM, no transform) | Slower (Babel transform required) |
| Config | Extends `vite.config.ts` | Separate `jest.config.ts` |
| ESM support | Native | Experimental (`--experimental-vm-modules`) |
| Watch mode | Instant (HMR-based) | Full re-run or `--onlyChanged` |
| Snapshot testing | Yes (compatible format) | Yes (original) |
| Module mocking | `vi.mock()` with hoisting | `jest.mock()` with hoisting |
| Coverage | `c8` or `istanbul` built-in | `istanbul` built-in |
| Concurrent tests | `it.concurrent` built-in | `--maxWorkers` only |
| UI | `@vitest/ui` browser dashboard | N/A |
| React Native | Not supported | Built-in support |
| Community size | Growing fast | Largest ecosystem |

**Migration path**: Vitest is mostly Jest-compatible. Replace `jest.fn()` with `vi.fn()`, `jest.mock()` with `vi.mock()`, and update config. Run `npx vitest --reporter=verbose` to validate.

### Playwright vs Cypress

| Feature | Playwright | Cypress |
|---|---|---|
| Multi-browser | Chromium, Firefox, WebKit | Chromium (+ Firefox/WebKit experimental) |
| Multi-tab/origin | Full support | Limited |
| Auto-wait | Built-in for all actions | Built-in but less granular |
| Trace viewer | Included (screenshots, DOM, network) | Dashboard (paid) |
| Parallelism | Built-in sharding | Paid parallelization |
| Mobile emulation | Device presets | Viewport only |
| API testing | `request` context built-in | `cy.request()` |
| Component testing | Experimental | Stable |
| iframes | Full support | Limited |
| Speed | Faster (WebSocket protocol) | Slower (proxy-based) |

### Maestro for Mobile E2E

Maestro uses YAML flows, making mobile E2E accessible without complex setup:

```yaml
appId: com.example.app
---
- launchApp
- tapOn: "Sign In"
- inputText:
    id: "email"
    text: "test@example.com"
- inputText:
    id: "password"
    text: "password123"
- tapOn: "Submit"
- assertVisible: "Welcome"
- takeScreenshot: "login-success"
```

**Key capabilities**:
- Runs on real devices and emulators
- Visual element selection (no XPath fragility)
- Built-in retry and wait logic
- CI integration via `maestro cloud`
- Screenshot comparison for visual regression

## MSW (Mock Service Worker) Patterns

### Request handler patterns

```typescript
import { http, HttpResponse, delay } from 'msw';

// Successful response
http.get('/api/users', () => {
  return HttpResponse.json([
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' },
  ]);
});

// Error response
http.get('/api/users/:id', ({ params }) => {
  if (params.id === '999') {
    return new HttpResponse(null, { status: 404 });
  }
  return HttpResponse.json({ id: params.id, name: 'Alice' });
});

// Slow response (test loading states)
http.get('/api/slow', async () => {
  await delay(3000);
  return HttpResponse.json({ data: 'finally' });
});

// Network error (test error boundaries)
http.get('/api/unstable', () => {
  return HttpResponse.error();
});

// One-time override in a specific test
server.use(
  http.get('/api/users', () => {
    return new HttpResponse(null, { status: 500 });
  })
);
```

### Browser integration (for component/E2E tests)

```typescript
// src/mocks/browser.ts
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);

// Start in development or test
if (process.env.NODE_ENV === 'development') {
  worker.start({ onUnhandledRequest: 'bypass' });
}
```

## Testing Patterns by Layer

### Unit Test Patterns

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

### Integration Test Patterns

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

### E2E Test Patterns

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

## Test Data Management

### Factories (preferred over fixtures)

```typescript
// test/factories/user.ts
import { faker } from '@faker-js/faker';

export function buildUser(overrides: Partial<User> = {}): User {
  return {
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName(),
    role: 'user',
    createdAt: new Date(),
    ...overrides,
  };
}

// Usage
const admin = buildUser({ role: 'admin' });
const users = Array.from({ length: 5 }, () => buildUser());
```

### Seed scripts for E2E

```typescript
// test/seed.ts
export async function seedTestData(db: Database) {
  const user = await db.users.create(buildUser({ email: 'e2e@test.com' }));
  const product = await db.products.create(buildProduct({ price: 29.99 }));
  return { user, product };
}
```

## Coverage Analysis Tips

- **Ignore generated code**: Add `/* istanbul ignore next */` or configure `coveragePathIgnorePatterns`
- **Focus on branch coverage**: Statement coverage can be misleading; a function with 5 branches might show 80% statement coverage but only 20% branch coverage
- **Untested files**: Use `--coverage.all=true` to include files with zero imports in the report
- **Coverage ratchet**: Store current coverage in CI and fail if any metric decreases

## Performance Testing Integration

When tests reveal performance issues, chain to the **performance-optimization** skill:

- Add `performance.mark()` and `performance.measure()` in critical paths
- Use Playwright's `page.metrics()` to capture runtime performance in E2E
- Set Lighthouse CI budgets as part of the E2E test suite
