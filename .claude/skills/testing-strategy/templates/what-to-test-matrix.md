# What-to-Test Decision Matrix

A risk-based framework for deciding what to test and at which layer.

## Step 1: Classify Code by Category

| Category | Examples | Default Layer |
|---|---|---|
| **Pure logic** | Calculations, transforms, validators, formatters | Unit |
| **State management** | Stores, reducers, state machines | Unit |
| **UI components** | Buttons, forms, modals, lists | Unit (Testing Library) |
| **Hooks / composables** | Custom React hooks, Vue composables | Unit (renderHook) |
| **API routes** | REST endpoints, GraphQL resolvers | Integration |
| **Database operations** | Repositories, migrations, queries | Integration |
| **Third-party integrations** | Payment, email, auth providers | Integration (mocked) |
| **User workflows** | Signup, checkout, search, navigation | E2E |
| **Cross-page interactions** | Deep links, redirects, auth flows | E2E |
| **Visual appearance** | Layouts, responsive design, themes | Visual regression |

## Step 2: Apply the Risk Matrix

Cross-reference **business impact** with **change frequency**:

```
                    CHANGE FREQUENCY
                    Low              High
                +-----------------+-----------------+
    High        | GUARD           | FORTRESS        |
    BUSINESS    | Integration     | Unit + Int + E2E|
    IMPACT      | tests + alerts  | Full coverage   |
                +-----------------+-----------------+
    Low         | IGNORE          | SHIELD          |
                | Smoke test only | Unit tests      |
                | or skip         | Cover logic     |
                +-----------------+-----------------+
```

### FORTRESS (High Impact + High Change)
- Payment processing, authentication, core business rules
- **Action**: Unit + Integration + E2E tests. Coverage > 90%.
- **Monitoring**: Alerts on any failure. Block deploy on regression.

### GUARD (High Impact + Low Change)
- Database schemas, auth middleware, encryption, config
- **Action**: Integration tests. Snapshot critical configs.
- **Monitoring**: Alert on any change. Manual review required.

### SHIELD (Low Impact + High Change)
- UI styling, copy text, feature flags, A/B experiments
- **Action**: Unit tests for logic. Visual regression for UI.
- **Monitoring**: Standard CI. No deploy blocking.

### IGNORE (Low Impact + Low Change)
- Internal admin tools, rarely used utilities, legacy code
- **Action**: Smoke test at most. Skip if time-constrained.
- **Monitoring**: None. Fix on report.

## Step 3: Prioritize Within Categories

When time is limited, test in this order:

1. **Revenue-affecting paths** -- checkout, subscriptions, billing
2. **Security boundaries** -- authentication, authorization, input validation
3. **Data integrity** -- writes, migrations, imports/exports
4. **User-facing workflows** -- signup, core features, search
5. **Edge cases in (1-4)** -- nulls, empty states, concurrent access
6. **Error handling** -- API failures, network timeouts, validation errors
7. **Performance-sensitive code** -- hot loops, large datasets, caching
8. **Everything else** -- utilities, formatting, internal tools

## Step 4: Define Test Types per Feature

For any new feature, fill in this table:

```markdown
| Component | Layer | Priority | What to Assert |
|---|---|---|---|
| calculatePrice() | Unit | P0 | Correct totals, discount application, rounding |
| PriceDisplay | Unit | P1 | Renders formatted price, handles zero/negative |
| POST /api/orders | Integration | P0 | 201 on success, 400 on invalid, idempotency |
| OrderRepository.create | Integration | P0 | Persists correctly, handles duplicates |
| Full checkout flow | E2E | P0 | Complete happy path, payment failure recovery |
| Cart badge count | Unit | P2 | Updates on add/remove, shows 99+ |
```

Priority key:
- **P0**: Must have before merge. Blocks release.
- **P1**: Should have before release. Best-effort before merge.
- **P2**: Nice to have. Add in follow-up.

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Better Approach |
|---|---|---|
| Testing implementation details | Brittle; breaks on refactor | Test behavior and outputs |
| 100% coverage as a goal | Diminishing returns past ~85% | Focus on risk-based coverage |
| E2E for everything | Slow, flaky, expensive | Push tests down the pyramid |
| No tests on happy path | Misses basic regressions | Always test the golden path first |
| Only happy path tests | Misses real-world failures | Add error + edge case tests |
| Mocking everything | Tests prove nothing | Mock only at boundaries |
| Shared mutable test state | Flaky, order-dependent | Reset state in beforeEach |
| Testing third-party code | Wasted effort | Test your wrapper/adapter only |
