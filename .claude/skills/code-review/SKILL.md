---
name: code-review
description: 8-pillar code review checklist (correctness, style, security, performance, a11y, maintainability, tests, architecture). Use for PR reviews and pre-merge checks.
---

## Purpose

Code Review provides a structured, repeatable code review process covering eight critical dimensions. It ensures consistency across reviews by following checklists grounded in industry standards (OWASP for security, WCAG for accessibility) and prevents common issues from reaching production.

## When to Use

- Reviewing a pull request before merge
- Auditing existing code for quality issues
- Setting up automated review checks in CI
- Training team members on review standards
- Pre-launch code quality gate

## Prerequisites

- Access to the code changes (PR diff or file contents)
- Project's `domain-intelligence` config for stack-specific rules
- Optional: ESLint, Biome, or equivalent linter configured

## Procedures

### 1. Scope the Review

- Read the PR description and linked issue/ticket
- Understand the intent of the change
- Note the size (< 400 lines ideal; flag if larger)

### 2. Apply the 8-Pillar Checklist

Run through each pillar's quick checklist below. For detailed severity levels, expanded checklists, and language-specific anti-patterns, see [pillar-details.md](pillar-details.md).

**Pillar 1: Correctness**

- [ ] Logic handles edge cases (null, empty, boundary values)
- [ ] Error paths are handled (try/catch, error boundaries)
- [ ] No off-by-one errors in loops/pagination
- [ ] Async operations handle loading, success, and error states

**Pillar 2: Code Style**

- [ ] Follows project naming conventions
- [ ] No commented-out code (remove or add TODO with ticket)
- [ ] Consistent formatting (defer to linter)
- [ ] Functions are single-purpose and reasonably sized

**Pillar 3: Security**

- [ ] No hardcoded secrets, API keys, or credentials
- [ ] User input is validated and sanitized
- [ ] SQL/NoSQL queries use parameterized inputs
- [ ] Authentication/authorization checked on protected routes
- [ ] No sensitive data in logs or error messages

**Pillar 4: Performance**

- [ ] No N+1 query patterns
- [ ] Large lists use pagination or virtualization
- [ ] Images are optimized and lazy-loaded where appropriate
- [ ] No unnecessary re-renders (React: memo, useMemo, useCallback)
- [ ] Database queries use appropriate indexes

**Pillar 5: Accessibility**

- [ ] Interactive elements are keyboard accessible
- [ ] Images have meaningful alt text
- [ ] Color is not the sole means of conveying information
- [ ] Touch targets are at least 24x24px (mobile)

**Pillar 6: Maintainability**

- [ ] Code is self-documenting (clear naming)
- [ ] Complex logic has explanatory comments
- [ ] No magic numbers (use named constants)
- [ ] Dependencies are justified and minimal

**Pillar 7: Testing**

- [ ] New logic has corresponding tests
- [ ] Tests cover happy path and error cases
- [ ] Mocks are minimal and realistic
- [ ] No flaky test patterns (timing, order-dependent)

**Pillar 8: Architecture**

- [ ] Changes follow existing patterns in the codebase
- [ ] No circular dependencies introduced
- [ ] Proper separation of concerns
- [ ] Aligns with `domain-intelligence` constraints

### 3. Provide Feedback

Categorize each finding (see [feedback-categories.md](feedback-categories.md) for full definitions):

- **BLOCKER**: Must fix before merge (security, correctness)
- **SUGGESTION**: Recommended improvement (performance, style)
- **QUESTION**: Needs clarification from author
- **PRAISE**: Highlight good patterns (important for morale)

## References

- [pillar-details.md](pillar-details.md) — Detailed criteria, severity levels, and anti-patterns for all 8 pillars
- [feedback-categories.md](feedback-categories.md) — BLOCKER/CRITICAL/SUGGESTION/QUESTION/PRAISE definitions
- [language-quick-reference.md](language-quick-reference.md) — JS/TS, Python, Go common issues and best practices
- [ci-cd-integration.md](ci-cd-integration.md) — GitHub Actions workflows for automated review checks

## Templates

- `templates/review-checklist.md` — Printable review checklist

## Examples

- `examples/review-example.md` — Complete review of a sample PR

## Chaining

| Chain With                 | Purpose                                                 |
| -------------------------- | ------------------------------------------------------- |
| `security-review`          | Deep security audit when security pillar flags issues   |
| `accessibility-audit`      | Full WCAG audit when a11y pillar flags issues           |
| `performance-optimization` | Deep perf analysis when performance pillar flags issues |
| `testing-strategy`         | Determine what tests are missing                        |

## Troubleshooting

| Problem                  | Solution                                                |
| ------------------------ | ------------------------------------------------------- |
| PR too large to review   | Ask author to split; review in logical sections         |
| Disagreement on style    | Defer to linter config; style is not worth blocking on  |
| Security concern unclear | Escalate to `security-review` skill for full audit      |
| Review takes too long    | Focus on blockers first; defer suggestions to follow-up |
