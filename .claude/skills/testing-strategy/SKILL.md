---
name: testing-strategy
description: >
  Design and implement comprehensive testing strategies across unit, integration,
  and E2E layers. Framework-agnostic guidance with coverage thresholds, risk-based
  prioritization, and tooling recommendations for web and mobile projects.
---

# Testing Strategy

## Purpose

Provide a structured, repeatable approach to testing that balances coverage, speed, and maintainability. This skill helps you decide what to test, at which layer, with which tool, and to what threshold -- eliminating guesswork and reducing regressions.

## When to Use

- Starting a new project and need a testing architecture
- Adding tests to an untested or under-tested codebase
- Choosing between testing frameworks (Vitest vs Jest vs Playwright vs Maestro)
- Setting coverage thresholds for CI gates
- Prioritizing which code paths to test first (risk-based)
- Reviewing a PR and assessing test adequacy
- Migrating from one test runner to another

## Prerequisites

- Node.js >= 18 (for modern test runners)
- Package manager: npm, pnpm, or yarn
- For E2E web: Playwright (`@playwright/test`)
- For E2E mobile: Maestro CLI
- For API mocking: MSW (`msw`)
- For coverage: built-in (Vitest/Jest) or `c8`/`istanbul`

## Procedures

### 1. Assess the Testing Pyramid

Apply the testing pyramid to distribute effort:

```
        /  E2E  \        ~10% of tests | Slow, brittle, high confidence
       / Integration \    ~20% of tests | Moderate speed, real boundaries
      /    Unit Tests   \  ~70% of tests | Fast, isolated, high volume
```

**Key principle**: Push tests down the pyramid. If a unit test can catch it, do not write an E2E test for it.

### 2. Select the Right Framework

| Scenario | Recommended | Why |
|---|---|---|
| Vite-based project | **Vitest** | 4x faster, native ESM, shared Vite config |
| React Native | **Jest** | Built-in RN support, mature ecosystem |
| Web E2E | **Playwright** | Multi-browser, auto-wait, trace viewer |
| Mobile E2E | **Maestro** | YAML-based, visual assertions, CI-friendly |
| API mocking | **MSW** | Network-level interception, works in browser + Node |
| Legacy CJS project | **Jest** | Broadest CJS compatibility |

### 3. Apply the Risk-Based Decision Matrix

Prioritize testing by combining **impact** and **change frequency**:

| | Low Change Frequency | High Change Frequency |
|---|---|---|
| **High Impact** | Integration tests | Unit + Integration + E2E |
| **Low Impact** | Minimal / smoke tests | Unit tests |

See `templates/what-to-test-matrix.md` for the full decision framework.

### 4. Set Coverage Thresholds

Recommended minimums (adjust per project maturity):

| Metric | New Project | Mature Project | Critical Path |
|---|---|---|---|
| Statements | 70% | 80% | 95% |
| Branches | 65% | 75% | 90% |
| Functions | 70% | 80% | 95% |
| Lines | 70% | 80% | 95% |

**CI gate rule**: Coverage must not decrease on any PR. Use `--coverage.thresholds` flags. See `templates/coverage-config.md` for ready-to-use configs.

### 5. Structure Test Files

Follow the Arrange-Act-Assert (AAA) pattern:

```typescript
describe('CartService', () => {
  describe('addItem', () => {
    it('should add item and update total', () => {
      // Arrange
      const cart = new CartService();
      const item = { id: '1', price: 29.99, qty: 2 };

      // Act
      cart.addItem(item);

      // Assert
      expect(cart.items).toHaveLength(1);
      expect(cart.total).toBe(59.98);
    });
  });
});
```

See `templates/test-file-template.md` for the full template with setup/teardown patterns.

### 6. Mock External Dependencies

Use MSW for network mocking (preferred over manual mocks):

```typescript
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'Test User' });
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

**Rules for mocking**:
- Mock at boundaries (network, filesystem, time), not internal modules
- Never mock what you do not own unless wrapping it first
- Prefer dependency injection over module mocking
- Reset mocks between tests to avoid state leaks

### 7. Write E2E Tests

**Playwright (web)**:
```typescript
test('user can complete checkout', async ({ page }) => {
  await page.goto('/products');
  await page.getByRole('button', { name: 'Add to cart' }).first().click();
  await page.getByRole('link', { name: 'Cart' }).click();
  await page.getByRole('button', { name: 'Checkout' }).click();
  await expect(page.getByText('Order confirmed')).toBeVisible();
});
```

**Maestro (mobile)**:
```yaml
appId: com.example.app
---
- launchApp
- tapOn: "Add to cart"
- tapOn: "Cart"
- tapOn: "Checkout"
- assertVisible: "Order confirmed"
```

### 8. Integrate into CI

```yaml
# GitHub Actions example
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with: { node-version: 20 }
    - run: npm ci
    - run: npm run test:unit -- --coverage
    - run: npm run test:integration
    - run: npx playwright install --with-deps
    - run: npm run test:e2e
```

Run unit tests first (fast feedback), then integration, then E2E.

## Templates

- `templates/test-file-template.md` -- Starter test file with AAA pattern and lifecycle hooks
- `templates/coverage-config.md` -- Coverage configurations for Vitest, Jest, and CI
- `templates/what-to-test-matrix.md` -- Risk-based decision matrix for test prioritization

## Examples

- `examples/feature-testing-plan.md` -- Complete testing plan for a checkout feature

## Chaining

- Use after **prd-driven-development** to derive test cases from requirements
- Pair with **code-review** to validate test adequacy in PRs
- Follow with **ci-cd-pipeline** to wire tests into automated pipelines
- Combine with **accessibility-audit** to add a11y assertions in E2E tests
- Feed results into **performance-optimization** when tests reveal perf regressions

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| Tests pass locally, fail in CI | Env differences (timezone, locale, deps) | Pin Node version, use `--forceExit`, check env vars |
| Flaky E2E tests | Race conditions, animations | Use Playwright auto-wait, add `waitFor`, disable animations in test mode |
| Coverage not increasing | Testing implementation, not behavior | Rewrite tests to cover branches and edge cases |
| MSW not intercepting | Handler not matching request URL | Log unhandled requests with `onUnhandledRequest: 'warn'` |
| Vitest slow on large project | Not using workspace mode | Split into Vitest workspaces, run in parallel |
| Jest ESM errors | CJS/ESM mismatch | Add `transformIgnorePatterns`, or migrate to Vitest |
| Maestro flaky on CI | Emulator boot timing | Add `- waitForAnimationToEnd` and increase timeouts |
