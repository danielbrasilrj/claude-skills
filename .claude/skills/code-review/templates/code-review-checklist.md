# Code Review Checklist

**PR Number**: _____________  
**Author**: _____________  
**Reviewer**: _____________  
**Date**: _____________

---

## Pre-Review

- [ ] PR has clear title and description
- [ ] Linked to issue/ticket (if applicable)
- [ ] PR size is reasonable (< 400 lines changed preferred)
- [ ] CI checks are passing

---

## Pillar 1: Correctness

### Logic & Edge Cases
- [ ] Handles null/undefined values safely
- [ ] Handles empty arrays/objects/strings
- [ ] Boundary values tested (min, max, zero, negative)
- [ ] Off-by-one errors checked in loops/arrays
- [ ] Type coercion is intentional (no implicit `==`)

### Error Handling
- [ ] Try/catch blocks around risky operations
- [ ] Async operations handle errors (`.catch()` or try/catch with await)
- [ ] Error boundaries in React components (if applicable)
- [ ] User-facing error messages are clear and actionable

### State Management
- [ ] Loading states handled
- [ ] Success states handled
- [ ] Error states handled
- [ ] Empty/no-data states handled

---

## Pillar 2: Code Style

### Naming
- [ ] Variables use descriptive names (no single letters except loops)
- [ ] Functions/methods clearly describe their purpose
- [ ] Classes/components use PascalCase
- [ ] Constants use UPPER_SNAKE_CASE
- [ ] Boolean variables use is/has/should prefix

### Structure
- [ ] Functions are single-purpose and < 50 lines
- [ ] No nested ternaries
- [ ] Nesting depth ≤ 3 levels
- [ ] No commented-out code (remove or add TODO with ticket)
- [ ] Imports organized (standard lib → third-party → local)

### Consistency
- [ ] Follows existing project conventions
- [ ] Linter warnings addressed
- [ ] Consistent formatting (run formatter)

---

## Pillar 3: Security

### Authentication & Authorization
- [ ] Protected routes require authentication
- [ ] Authorization checked for sensitive operations
- [ ] Session management is secure (httpOnly cookies, CSRF protection)

### Input Validation
- [ ] All user input validated on server side
- [ ] SQL/NoSQL queries use parameterized inputs (no string concatenation)
- [ ] File uploads validated (type, size, content)
- [ ] URL inputs validated (no SSRF)

### Data Protection
- [ ] No hardcoded secrets, API keys, or credentials
- [ ] Sensitive data not logged (passwords, tokens, PII)
- [ ] Secrets loaded from environment variables or secret manager
- [ ] No sensitive data in error messages

### XSS & Injection
- [ ] User input escaped when rendered (use textContent, not innerHTML)
- [ ] Or sanitized with library (DOMPurify) if HTML is needed
- [ ] No `eval()` or `Function()` with user input
- [ ] Command injection prevented (use parameterized commands)

---

## Pillar 4: Performance

### Database Queries
- [ ] No N+1 query patterns (use eager loading/joins)
- [ ] Appropriate indexes on queried fields
- [ ] Pagination used for large datasets
- [ ] Query only necessary fields (avoid SELECT *)

### Frontend Performance
- [ ] Images optimized (WebP, AVIF) and lazy-loaded
- [ ] Large lists use virtualization or pagination
- [ ] No unnecessary re-renders (React: memo, useMemo, useCallback)
- [ ] Heavy computations memoized or moved to web worker

### API & Network
- [ ] API responses use compression (gzip, brotli)
- [ ] Responses cached when appropriate (ETags, Cache-Control)
- [ ] No blocking network calls on main thread

### Algorithms
- [ ] Time complexity is reasonable (no O(n²) when O(n) is possible)
- [ ] Space complexity is reasonable (no loading entire dataset into memory)

---

## Pillar 5: Accessibility (WCAG 2.1 AA)

### Semantic HTML
- [ ] Interactive elements use correct tags (`<button>`, `<a>`, `<input>`)
- [ ] Heading hierarchy is logical (h1 → h2 → h3, no skips)
- [ ] Landmark regions used (nav, main, article, section, aside)

### Keyboard Navigation
- [ ] All interactive elements keyboard-accessible (tab/enter/space)
- [ ] Focus indicators visible
- [ ] No keyboard traps
- [ ] Skip links provided for repetitive content

### Visual Accessibility
- [ ] Color contrast ≥ 4.5:1 for text (3:1 for large text 18pt+)
- [ ] Color is not sole means of conveying information
- [ ] Images have meaningful alt text (or alt="" if decorative)
- [ ] Touch targets ≥ 24x24px (mobile)

### ARIA
- [ ] ARIA labels on complex components
- [ ] ARIA live regions for dynamic content
- [ ] ARIA attributes used correctly (no invalid combinations)

---

## Pillar 6: Maintainability

### Readability
- [ ] Code is self-documenting (clear names, simple logic)
- [ ] Complex logic has explanatory comments (why, not what)
- [ ] Public APIs have JSDoc/docstrings
- [ ] No magic numbers (use named constants)

### Structure
- [ ] Single Responsibility Principle followed
- [ ] No duplicate code (DRY)
- [ ] Related code is grouped together
- [ ] Dependencies are minimal and justified

### Documentation
- [ ] README updated (if public API changed)
- [ ] Migration guide provided (if breaking change)
- [ ] TODO comments include ticket reference
- [ ] Deprecation warnings added (if applicable)

---

## Pillar 7: Testing

### Test Coverage
- [ ] New logic has corresponding tests
- [ ] Tests cover happy path
- [ ] Tests cover error cases
- [ ] Tests cover edge cases
- [ ] Integration tests for critical paths (if applicable)

### Test Quality
- [ ] Test names clearly describe what is tested
- [ ] Tests are isolated (no shared state)
- [ ] Mocks are minimal and realistic
- [ ] No flaky test patterns (timing, random data, order-dependent)
- [ ] Tests run in CI and must pass before merge

### Test Types
- [ ] Unit tests for business logic
- [ ] Component tests for UI (if applicable)
- [ ] Integration tests for API endpoints (if applicable)
- [ ] E2E tests for user flows (if critical feature)

---

## Pillar 8: Architecture

### Design Patterns
- [ ] Follows existing patterns in codebase
- [ ] Proper separation of concerns (UI, business logic, data access)
- [ ] No circular dependencies
- [ ] Dependencies flow in one direction

### Domain Alignment
- [ ] Aligns with `domain-intelligence` constraints (if configured)
- [ ] Feature is in correct module/package
- [ ] Naming follows domain language (ubiquitous language)

### Extensibility
- [ ] New abstractions are justified (not premature)
- [ ] Code is open for extension, closed for modification
- [ ] Avoids tight coupling

---

## Feedback Summary

### Blockers (Must Fix Before Merge)
<!-- Security issues, critical bugs, circular dependencies -->


### Critical (Should Fix Before Merge)
<!-- Missing tests, architectural violations, edge cases not handled -->


### Suggestions (Nice to Have, Can Defer)
<!-- Performance optimizations, refactoring opportunities, style improvements -->


### Questions (Need Clarification)
<!-- Unclear intent, potential issues, missing context -->


### Praise (Good Patterns to Highlight)
<!-- Elegant solutions, thorough tests, clear code -->


---

## Approval

- [ ] **APPROVED** - Ready to merge
- [ ] **APPROVED WITH COMMENTS** - Merge after addressing non-blocking items
- [ ] **REQUEST CHANGES** - Do not merge until blockers resolved

**Reviewer Signature**: _____________  
**Date**: _____________
