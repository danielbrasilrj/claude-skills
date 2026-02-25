# Workflow Integration

## PRD -> Task -> PR -> Code Flow

1. **PRD Published** -> Create Epic in Linear/Jira with link to PRD
2. **Phase Breakdown** -> Create tasks for each phase, set dependencies
3. **Sprint Planning** -> Pull Phase 1 tasks into current sprint
4. **PR Template** -> Require "Closes #TASK, implements PRD-XXX Section Y"
5. **Code Review** -> Verify PR matches acceptance criteria from PRD
6. **Testing** -> QA validates all Given/When/Then scenarios
7. **Traceability Matrix** -> Document PRD section -> Commits -> Tests

## Sample PR Description Template

```markdown
## PRD Reference

Implements PRD-047 Section 3.2: User Search by Email

## Acceptance Criteria Validated

- [x] AC1: Search by email returns results in < 300ms
- [x] AC2: No results shows helpful message
- [x] AC3: Results highlight matching text

## Technical Implementation

- Added trigram index on customers.email (migration 2024-01-25)
- Created CustomerSearchService.ts with fuzzy matching
- Updated SearchInput.tsx to handle empty states

## Testing

- Unit tests: src/services/CustomerSearchService.test.ts
- Integration tests: cypress/e2e/customer-search.cy.ts
- Performance: p95 latency 287ms (target: < 300ms)

## Screenshots

[Attach before/after screenshots]
```

## Further Reading

- **Behavior-Driven Development**: "The Cucumber Book" by Matt Wynne
- **Product Requirements**: "Inspired" by Marty Cagan
- **Technical Writing for AI**: "Docs for Developers" by Jared Bhatti
- **Dependency Management**: "Software Architecture in Practice" by Len Bass
