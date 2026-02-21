# Sprint Planning -- Reference

## Story Splitting Patterns

When a user story is too large (13+ points) or violates INVEST, apply one of these splitting strategies:

### 1. Workflow Steps
Split by sequential steps in a user flow.
- **Before:** "As a user, I want to purchase a product"
- **After:**
  - "As a user, I want to add items to my cart"
  - "As a user, I want to enter shipping details"
  - "As a user, I want to complete payment"

### 2. Business Rule Variations
Split by different rules or conditions.
- **Before:** "As a user, I want to apply a discount code"
- **After:**
  - "As a user, I want to apply a percentage discount"
  - "As a user, I want to apply a fixed-amount discount"
  - "As a user, I want to see an error for expired codes"

### 3. Data Variations
Split by different data types or input formats.
- **Before:** "As a user, I want to import my data"
- **After:**
  - "As a user, I want to import from CSV"
  - "As a user, I want to import from JSON"

### 4. Interface Variations
Split by platform or device.
- **Before:** "As a user, I want a responsive dashboard"
- **After:**
  - "As a user, I want to view the dashboard on desktop"
  - "As a user, I want to view the dashboard on mobile"

### 5. CRUD Operations
Split create, read, update, delete into separate stories.

### 6. Performance / Optimization
Deliver functionality first, then optimize.
- Story 1: "Basic search returns results"
- Story 2: "Search results load within 200ms"

### 7. Spike + Implementation
When uncertainty is high, split research from implementation.
- Spike: "Investigate payment gateway API capabilities" (time-boxed, 1-2 days)
- Story: "Integrate Stripe payment processing" (follows spike)

## Velocity Tracking

### Calculating Velocity

```
Sprint Velocity = Sum of story points for COMPLETED stories only
```

- Do NOT count partially completed stories
- Track over at least 3 sprints before using for prediction
- Use the **average of the last 3 sprints** for planning

### Velocity Table Template

| Sprint | Planned | Completed | Velocity | Notes |
|--------|---------|-----------|----------|-------|
| Sprint 1 | 34 | 28 | 28 | New team member onboarding |
| Sprint 2 | 30 | 31 | 31 | |
| Sprint 3 | 32 | 29 | 29 | Holiday week |
| **Average** | | | **29** | |

### Capacity Planning Formula

```
Sprint Capacity = Average Velocity x (Available Days / Sprint Length) x Focus Factor

Focus Factor:
- 0.9 = Dedicated team, minimal interruptions
- 0.7 = Shared team, some interruptions
- 0.5 = Heavy support rotation or on-call
```

## Priority Frameworks

### MoSCoW Method

| Category | Meaning | Sprint Guidance |
|----------|---------|-----------------|
| **Must** | Sprint fails without it | Always include |
| **Should** | Important but not critical | Include if capacity allows |
| **Could** | Nice to have | Only if sprint is light |
| **Won't** | Explicitly excluded this sprint | Document for future |

### Value/Effort Matrix

```
High Value, Low Effort  -> Do First  (Quick Wins)
High Value, High Effort -> Do Second (Strategic)
Low Value, Low Effort   -> Do Third  (Fill-ins)
Low Value, High Effort  -> Don't Do  (Deprioritize)
```

## Definition of Done (DoD) Checklist

A story is DONE when ALL of the following are true:

- [ ] All acceptance criteria pass
- [ ] Code is reviewed and approved
- [ ] Unit tests written and passing (coverage >= threshold)
- [ ] Integration tests passing
- [ ] No critical or high-severity bugs
- [ ] Documentation updated (if user-facing)
- [ ] Deployed to staging environment
- [ ] Product owner has accepted the story

## GitHub Labels Standard

### Priority Labels
```
priority-critical  #d73a4a  (red)
priority-high      #e36209  (orange)
priority-medium    #fbca04  (yellow)
priority-low       #0e8a16  (green)
```

### Size Labels
```
size-XS  (1 point)     #c5def5
size-S   (2-3 points)  #bfd4f2
size-M   (5 points)    #0075ca
size-L   (8 points)    #0052a3
size-XL  (13+ points)  #003d7a
```

### Type Labels
```
type-feature   #a2eeef
type-bug       #d73a4a
type-chore     #d4c5f9
type-spike     #f9d0c4
type-tech-debt #e4e669
```

## Sprint Ceremonies Reference

| Ceremony | Duration | Participants | Output |
|----------|----------|-------------|--------|
| Sprint Planning | 1-2 hours | Full team | Sprint backlog |
| Daily Standup | 15 min | Dev team | Blockers identified |
| Sprint Review | 1 hour | Team + stakeholders | Demo, feedback |
| Sprint Retro | 1 hour | Full team | Action items |
| Backlog Refinement | 1 hour | PO + leads | Refined stories |

## Anti-Patterns to Avoid

1. **Waterfall in Disguise** -- All design stories in Sprint 1, all dev in Sprint 2-5, all QA in Sprint 6. Instead, deliver vertical slices each sprint.
2. **Points Inflation** -- Assigning higher points to appear productive. Points are relative, not absolute.
3. **Carrying Over Stories** -- If a story carries over 2+ sprints, it needs splitting.
4. **No Acceptance Criteria** -- Every story needs testable criteria BEFORE entering a sprint.
5. **Ignoring Velocity** -- Planning at 120% velocity leads to burnout and missed commitments.
6. **Story Farming** -- Breaking 1 story into 10 trivial stories to inflate completed count.
