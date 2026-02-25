# 8-Pillar Review — Detailed Criteria & Anti-Patterns

## Pillar 1: Correctness

### Definition

The code behaves as intended under all conditions, including edge cases and error scenarios.

### Severity Levels

| Level        | Criteria                                          | Example                              |
| ------------ | ------------------------------------------------- | ------------------------------------ |
| **BLOCKER**  | Logic error causing incorrect results or crashes  | Off-by-one error in array iteration  |
| **CRITICAL** | Edge case not handled, could cause runtime errors | No null check before property access |
| **MAJOR**    | Missing error handling in async operations        | Unhandled promise rejection          |
| **MINOR**    | Incomplete state handling                         | Missing loading state in UI          |

### Checklist

- [ ] All edge cases handled (null, undefined, empty arrays, boundary values)
- [ ] Error paths explicitly handled (try/catch, error boundaries, Result types)
- [ ] Off-by-one errors checked in loops, array slicing, pagination
- [ ] Async operations handle all states: loading, success, error, timeout
- [ ] Type coercion is intentional and safe (no implicit `==` comparisons)
- [ ] Division by zero protected
- [ ] Date/time calculations account for timezones and DST
- [ ] Floating-point arithmetic uses appropriate precision

### Common Anti-Patterns by Language

**JavaScript/TypeScript**

```javascript
// ❌ BAD: No null check
function getUserName(user) {
  return user.profile.name; // Crashes if user or profile is null
}

// ✅ GOOD: Explicit null handling
function getUserName(user) {
  return user?.profile?.name ?? 'Anonymous';
}
```

**Python**

```python
# ❌ BAD: Mutable default argument
def append_to_list(item, lst=[]):
    lst.append(item)
    return lst

# ✅ GOOD: Immutable default
def append_to_list(item, lst=None):
    if lst is None:
        lst = []
    lst.append(item)
    return lst
```

**Go**

```go
// ❌ BAD: Ignoring error
result, _ := someOperation()

// ✅ GOOD: Explicit error handling
result, err := someOperation()
if err != nil {
    return fmt.Errorf("operation failed: %w", err)
}
```

---

## Pillar 2: Code Style

### Definition

Code follows project conventions for naming, formatting, and structure, making it predictable and easy to navigate.

### Severity Levels

| Level          | Criteria                             | Example                                       |
| -------------- | ------------------------------------ | --------------------------------------------- |
| **BLOCKER**    | Never block on style—defer to linter | N/A                                           |
| **SUGGESTION** | Deviates from project conventions    | Inconsistent naming (camelCase vs snake_case) |
| **NITPICK**    | Personal preference with no impact   | Extra blank line                              |

### Checklist

- [ ] Naming follows project conventions (camelCase, PascalCase, snake_case, kebab-case)
- [ ] No commented-out code (remove or add TODO with ticket reference)
- [ ] Consistent formatting (spaces vs tabs, line length—defer to linter)
- [ ] Functions are single-purpose and under 50 lines
- [ ] No nested ternaries or deeply nested conditionals (> 3 levels)
- [ ] Imports organized (standard library → third-party → local)
- [ ] Consistent file naming across codebase

### Language-Specific Conventions

**JavaScript/TypeScript**

- Variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- Classes/Components: `PascalCase`
- Files: `kebab-case.ts` or `PascalCase.tsx` for components

**Python**

- Variables/functions: `snake_case`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Modules: `snake_case.py`

**Go**

- Exported: `PascalCase`
- Unexported: `camelCase`
- No snake_case

---

## Pillar 3: Security

### Definition

Code protects against common vulnerabilities and follows security best practices.

### Severity Levels

| Level        | Criteria                                 | Example                                             |
| ------------ | ---------------------------------------- | --------------------------------------------------- |
| **BLOCKER**  | Exploitable vulnerability (OWASP Top 10) | SQL injection, XSS, hardcoded credentials           |
| **CRITICAL** | Missing security control                 | No authentication on protected route                |
| **MAJOR**    | Insecure configuration                   | Secrets in environment variables without encryption |
| **MINOR**    | Defense-in-depth improvement             | Missing rate limiting on API endpoint               |

### Checklist (OWASP Top 10 2021)

- [ ] **A01 - Broken Access Control**: Authorization checked on every protected resource
- [ ] **A02 - Cryptographic Failures**: No hardcoded secrets, keys, or credentials
- [ ] **A03 - Injection**: All user input validated and sanitized
- [ ] **A04 - Insecure Design**: Security controls designed in, not bolted on
- [ ] **A05 - Security Misconfiguration**: No default passwords, unnecessary features disabled
- [ ] **A06 - Vulnerable Components**: Dependencies up-to-date, no known CVEs
- [ ] **A07 - Authentication Failures**: Secure session management, no weak passwords
- [ ] **A08 - Software Integrity Failures**: Dependencies verified (checksums, SRI)
- [ ] **A09 - Logging Failures**: Sensitive data not logged, audit trail maintained
- [ ] **A10 - SSRF**: Server-side requests validated and restricted

### Common Vulnerabilities by Language

**JavaScript/TypeScript**

```javascript
// ❌ BAD: XSS vulnerability
element.innerHTML = userInput;

// ✅ GOOD: Use safe methods
element.textContent = userInput;
// Or sanitize with DOMPurify
element.innerHTML = DOMPurify.sanitize(userInput);
```

**SQL (Any Language)**

```javascript
// ❌ BAD: SQL injection
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ GOOD: Parameterized query
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);
```

**Python**

```python
# ❌ BAD: Command injection
os.system(f"ping {user_input}")

# ✅ GOOD: Use subprocess with list
subprocess.run(["ping", user_input], check=True)
```

---

## Pillar 4: Performance

### Definition

Code executes efficiently without unnecessary resource consumption.

### Severity Levels

| Level        | Criteria                               | Example                               |
| ------------ | -------------------------------------- | ------------------------------------- |
| **BLOCKER**  | Performance regression > 50%           | Introduced N+1 query on critical path |
| **CRITICAL** | Unbounded resource consumption         | Loading entire dataset into memory    |
| **MAJOR**    | Noticeable user impact (> 100ms delay) | Missing database index on query       |
| **MINOR**    | Optimization opportunity               | Unnecessary re-render in React        |

### Checklist

- [ ] No N+1 query patterns (use eager loading or batch queries)
- [ ] Large lists use pagination, virtualization, or infinite scroll
- [ ] Images optimized (WebP, AVIF) and lazy-loaded
- [ ] No unnecessary re-renders (React: `memo`, `useMemo`, `useCallback`)
- [ ] Database queries use appropriate indexes
- [ ] API responses use compression (gzip, brotli)
- [ ] Heavy computations memoized or cached
- [ ] No blocking operations on main thread (use workers)

### Common Anti-Patterns

**N+1 Query (SQL)**

```javascript
// ❌ BAD: N+1 query
const users = await db.query('SELECT * FROM users');
for (const user of users) {
  user.posts = await db.query('SELECT * FROM posts WHERE user_id = ?', [user.id]);
}

// ✅ GOOD: Single query with JOIN
const users = await db.query(`
  SELECT u.*, p.*
  FROM users u
  LEFT JOIN posts p ON u.id = p.user_id
`);
```

**React Re-renders**

```javascript
// ❌ BAD: Creates new function on every render
function MyComponent() {
  const handleClick = () => console.log('clicked');
  return <Button onClick={handleClick} />;
}

// ✅ GOOD: Memoized callback
function MyComponent() {
  const handleClick = useCallback(() => console.log('clicked'), []);
  return <Button onClick={handleClick} />;
}
```

**Unbounded Lists**

```javascript
// ❌ BAD: Rendering 10,000 items
{
  items.map((item) => <ListItem key={item.id} {...item} />);
}

// ✅ GOOD: Virtualized list
<VirtualList items={items} rowHeight={50} height={600} />;
```

---

## Pillar 5: Accessibility

### Definition

Code is usable by everyone, including people with disabilities (WCAG 2.1 Level AA compliance).

### Severity Levels

| Level        | Criteria                      | Example                                |
| ------------ | ----------------------------- | -------------------------------------- |
| **BLOCKER**  | Violates WCAG Level A         | No keyboard access to critical feature |
| **CRITICAL** | Violates WCAG Level AA        | Insufficient color contrast (< 4.5:1)  |
| **MAJOR**    | Missing semantic HTML or ARIA | Div instead of button                  |
| **MINOR**    | Improvement opportunity       | Missing skip link                      |

### Checklist (WCAG 2.1 Level AA)

- [ ] **1.1 Text Alternatives**: All images have meaningful `alt` text
- [ ] **1.3 Adaptable**: Semantic HTML used (nav, main, article, section)
- [ ] **1.4 Distinguishable**: Color contrast ≥ 4.5:1 (text), ≥ 3:1 (large text)
- [ ] **2.1 Keyboard Accessible**: All interactive elements keyboard-navigable
- [ ] **2.4 Navigable**: Focus indicators visible, heading hierarchy logical
- [ ] **2.5 Input Modalities**: Touch targets ≥ 24x24px (mobile)
- [ ] **3.1 Readable**: Language attribute set (`<html lang="en">`)
- [ ] **3.2 Predictable**: Consistent navigation, no focus changes on input
- [ ] **3.3 Input Assistance**: Form labels and error messages clear
- [ ] **4.1 Compatible**: Valid ARIA attributes, no duplicate IDs

### Common Issues

**Missing Alt Text**

```html
<!-- ❌ BAD -->
<img src="chart.png" />

<!-- ✅ GOOD -->
<img src="chart.png" alt="Sales trend showing 20% growth in Q4" />
```

**Non-Semantic Elements**

```html
<!-- ❌ BAD -->
<div onClick="{handleClick}">Click me</div>

<!-- ✅ GOOD -->
<button onClick="{handleClick}">Click me</button>
```

**Color-Only Information**

```html
<!-- ❌ BAD: Color is sole indicator -->
<span style="color: red;">Error</span>

<!-- ✅ GOOD: Icon + text + color -->
<span style="color: red;"> <AlertIcon aria-hidden="true" /> Error </span>
```

**Low Contrast**

```css
/* ❌ BAD: 2.5:1 contrast */
color: #999;
background: #fff;

/* ✅ GOOD: 7:1 contrast */
color: #555;
background: #fff;
```

---

## Pillar 6: Maintainability

### Definition

Code is easy to understand, modify, and extend without introducing bugs.

### Severity Levels

| Level        | Criteria                       | Example                             |
| ------------ | ------------------------------ | ----------------------------------- |
| **BLOCKER**  | Code is incomprehensible       | 500-line function with no structure |
| **CRITICAL** | Missing critical documentation | Complex algorithm with no comments  |
| **MAJOR**    | Poor naming or structure       | Single-letter variables             |
| **MINOR**    | Could be clearer               | Magic number instead of constant    |

### Checklist

- [ ] Code is self-documenting (clear, descriptive names)
- [ ] Complex logic has explanatory comments (why, not what)
- [ ] No magic numbers—use named constants
- [ ] Dependencies are justified and minimal
- [ ] Functions have single responsibility
- [ ] No deep nesting (> 3 levels)
- [ ] TODO comments include ticket reference
- [ ] Public APIs have JSDoc/docstrings

### Examples

**Magic Numbers**

```javascript
// ❌ BAD: What is 86400000?
const expiryTime = Date.now() + 86400000;

// ✅ GOOD: Named constant
const MS_PER_DAY = 24 * 60 * 60 * 1000;
const expiryTime = Date.now() + MS_PER_DAY;
```

**Poor Naming**

```javascript
// ❌ BAD: Single-letter variables
function f(x, y) {
  const z = x * y;
  return z > 100 ? z : 0;
}

// ✅ GOOD: Descriptive names
function calculateDiscountedPrice(price, discountPercent) {
  const discountedPrice = price * (1 - discountPercent / 100);
  const MINIMUM_DISCOUNT_THRESHOLD = 100;
  return discountedPrice > MINIMUM_DISCOUNT_THRESHOLD ? discountedPrice : 0;
}
```

**Complex Logic Without Comments**

```javascript
// ❌ BAD: No explanation
const result = items.reduce((acc, item) => {
  if (!acc[item.category]) acc[item.category] = [];
  acc[item.category].push(item);
  return acc;
}, {});

// ✅ GOOD: Explanatory comment
// Group items by category for rendering in separate sections
const result = items.reduce((acc, item) => {
  if (!acc[item.category]) acc[item.category] = [];
  acc[item.category].push(item);
  return acc;
}, {});
```

---

## Pillar 7: Testing

### Definition

Code is covered by automated tests that verify correctness and prevent regressions.

### Severity Levels

| Level        | Criteria                             | Example                       |
| ------------ | ------------------------------------ | ----------------------------- |
| **BLOCKER**  | No tests for critical business logic | Payment processing untested   |
| **CRITICAL** | Missing tests for new feature        | New API endpoint has no tests |
| **MAJOR**    | Tests don't cover error cases        | Only happy path tested        |
| **MINOR**    | Test could be more thorough          | Edge case not covered         |

### Checklist

- [ ] New logic has corresponding tests
- [ ] Tests cover happy path, error cases, and edge cases
- [ ] Mocks are minimal and realistic (avoid over-mocking)
- [ ] No flaky test patterns (timing, order-dependent, random data)
- [ ] Test names clearly describe what is tested
- [ ] Integration tests for critical paths
- [ ] E2E tests for user-facing flows
- [ ] Tests run in CI and must pass before merge

### Test Coverage by Layer

| Layer             | Coverage Target | Test Type          |
| ----------------- | --------------- | ------------------ |
| Utility functions | 100%            | Unit               |
| Business logic    | 90%+            | Unit + Integration |
| API endpoints     | 80%+            | Integration        |
| UI components     | 70%+            | Component          |
| User flows        | Critical paths  | E2E                |

### Anti-Patterns

**Over-Mocking**

```javascript
// ❌ BAD: Mocking everything, testing nothing
test('fetchUser returns user', () => {
  const mockFetch = jest.fn().mockResolvedValue({ id: 1, name: 'John' });
  const result = await fetchUser(1);
  expect(result).toEqual({ id: 1, name: 'John' });
});

// ✅ GOOD: Test actual behavior with real dependencies when possible
test('fetchUser returns user from API', async () => {
  const result = await fetchUser(1);
  expect(result).toHaveProperty('id');
  expect(result).toHaveProperty('name');
});
```

**Flaky Tests (Timing)**

```javascript
// ❌ BAD: Race condition
test('animation completes', async () => {
  startAnimation();
  await new Promise((resolve) => setTimeout(resolve, 500)); // Arbitrary delay
  expect(element).toHaveClass('animated');
});

// ✅ GOOD: Wait for actual condition
test('animation completes', async () => {
  startAnimation();
  await waitFor(() => expect(element).toHaveClass('animated'));
});
```

---

## Pillar 8: Architecture

### Definition

Code aligns with the project's architectural patterns and design principles.

### Severity Levels

| Level        | Criteria                              | Example                        |
| ------------ | ------------------------------------- | ------------------------------ |
| **BLOCKER**  | Introduces circular dependency        | Module A imports B imports A   |
| **CRITICAL** | Violates core architectural principle | Business logic in UI component |
| **MAJOR**    | Deviates from established patterns    | REST endpoint uses RPC style   |
| **MINOR**    | Could better align with patterns      | Inconsistent error handling    |

### Checklist

- [ ] Changes follow existing patterns in codebase
- [ ] No circular dependencies introduced
- [ ] Proper separation of concerns (UI, business logic, data access)
- [ ] Aligns with `domain-intelligence` constraints
- [ ] New abstractions are justified (not premature)
- [ ] Dependencies flow in one direction (dependency inversion)
- [ ] Feature is placed in correct module/package

### Common Patterns to Verify

**Layered Architecture**

```
UI Layer → Business Logic Layer → Data Access Layer
(Components)  (Services/Use Cases)  (Repositories)
```

**Dependency Inversion**

```javascript
// ❌ BAD: High-level module depends on low-level module
class OrderService {
  constructor() {
    this.db = new MySQLDatabase(); // Concrete dependency
  }
}

// ✅ GOOD: Depend on abstraction
class OrderService {
  constructor(database: IDatabase) { // Interface/abstraction
    this.db = database;
  }
}
```

**Separation of Concerns**

```javascript
// ❌ BAD: Business logic in UI component
function CheckoutButton() {
  const handleClick = async () => {
    const total = cart.items.reduce((sum, item) => sum + item.price, 0);
    const tax = total * 0.08;
    await fetch('/api/orders', { method: 'POST', body: JSON.stringify({ total: total + tax }) });
  };
  return <button onClick={handleClick}>Checkout</button>;
}

// ✅ GOOD: Business logic in service layer
function CheckoutButton() {
  const { checkout } = useCheckoutService();
  return <button onClick={checkout}>Checkout</button>;
}

// In service layer
class CheckoutService {
  async checkout(cart) {
    const order = this.calculateOrder(cart);
    return this.orderRepository.create(order);
  }
}
```
