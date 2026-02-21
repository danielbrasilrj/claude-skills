---
name: sprint-planning
description: >
  Agile sprint planning workflows. Generates sprint backlogs from PRDs,
  decomposes epics into INVEST-compliant user stories with story points,
  produces Given/When/Then acceptance criteria, and creates GitHub Issues.
---

# Sprint Planning

## Purpose

Automate and standardize agile sprint planning by converting high-level product requirements into actionable, well-structured sprint backlogs. This skill ensures every user story follows INVEST criteria, includes testable acceptance criteria in Given/When/Then format, and is ready for direct import into GitHub Issues.

## When to Use

- Starting a new sprint and need to populate the backlog from a PRD or epic list
- Breaking down epics or features into user stories with acceptance criteria
- Estimating story points using relative sizing (Fibonacci scale)
- Creating GitHub Issues from user stories with proper labels and metadata
- Running sprint retrospectives and capturing action items
- Reviewing backlog health (story quality, point distribution, dependency mapping)

## Prerequisites

- A PRD, epic list, or feature description to decompose
- Access to the project's GitHub repository (for issue creation)
- `gh` CLI installed and authenticated (for GitHub Issue operations)
- Understanding of the team's velocity (for capacity planning)

## Procedures

### 1. Epic Decomposition

Given an epic or PRD section, decompose it into user stories:

1. **Identify actors** -- who are the distinct user personas?
2. **Extract capabilities** -- what can each actor do?
3. **Define value** -- why does each capability matter?
4. **Apply INVEST criteria** to each story:
   - **I**ndependent -- no hidden coupling between stories
   - **N**egotiable -- details can be discussed, not locked
   - **V**aluable -- delivers value to a user or stakeholder
   - **E**stimable -- team can size it with reasonable confidence
   - **S**mall -- fits within a single sprint
   - **T**estable -- has clear pass/fail acceptance criteria
5. **Split stories** that violate INVEST (see REFERENCE.md for splitting patterns)

### 2. Acceptance Criteria (Given/When/Then)

Write acceptance criteria using Gherkin-style syntax:

```
Given [precondition or context]
When [action performed by the user]
Then [expected observable outcome]
```

Rules:
- Each story MUST have 2-5 acceptance criteria
- Cover the happy path, at least one edge case, and one error case
- Keep criteria atomic -- one behavior per criterion
- Use concrete values, not vague terms ("enters 'test@example.com'" not "enters an email")

### 3. Story Point Estimation

Use modified Fibonacci scale: 1, 2, 3, 5, 8, 13, 21.

| Points | Complexity | Uncertainty | Effort Analogy |
|--------|-----------|-------------|----------------|
| 1 | Trivial | None | Config change, copy update |
| 2 | Low | Minimal | Simple CRUD endpoint |
| 3 | Moderate | Low | Feature with known pattern |
| 5 | Medium | Some | New integration, moderate logic |
| 8 | High | Notable | Cross-cutting concern, new pattern |
| 13 | Very High | Significant | Major feature, architectural impact |
| 21 | Extreme | High | Should be split further |

When estimating, consider three dimensions:
- **Complexity** -- how intricate is the implementation?
- **Uncertainty** -- how much is unknown?
- **Effort** -- how much raw work is involved?

### 4. Sprint Backlog Assembly

1. **Set sprint capacity** = team size x days x velocity factor
2. **Prioritize stories** using MoSCoW or value/effort matrix
3. **Check dependencies** -- no story should block another in the same sprint without explicit ordering
4. **Validate total points** against historical velocity (aim for 80-90% capacity)
5. **Identify risks** and tag stories with risk labels

### 5. GitHub Issue Creation

For each user story, create a GitHub Issue using the template:

```bash
gh issue create \
  --title "STORY-ID: As a [role], I want [goal]" \
  --body "$(cat story-body.md)" \
  --label "user-story,sprint-N,priority-X" \
  --milestone "Sprint N" \
  --assignee "@me"
```

Apply labels systematically:
- `priority-critical`, `priority-high`, `priority-medium`, `priority-low`
- `size-S` (1-2), `size-M` (3-5), `size-L` (8-13), `size-XL` (21+)
- `type-feature`, `type-bug`, `type-chore`, `type-spike`

### 6. Sprint Retrospective

After each sprint, capture:
1. **What went well** -- practices to continue
2. **What could improve** -- pain points
3. **Action items** -- concrete, assigned, time-boxed improvements
4. **Velocity tracking** -- planned vs completed points

## Templates

- `templates/user-story.md` -- Standard user story with acceptance criteria
- `templates/sprint-retro.md` -- Sprint retrospective template
- `templates/github-issue.md` -- GitHub Issue body template

## Examples

- `examples/sprint-backlog-example.md` -- Complete sprint backlog from a sample PRD

## Chaining

| Upstream Skill | Purpose |
|---------------|---------|
| `prd-driven-development` | Generate PRDs that feed into sprint planning |

| Downstream Skill | Purpose |
|-----------------|---------|
| `code-review` | Review implementations of sprint stories |
| `testing-strategy` | Generate test plans from acceptance criteria |
| `documentation-generator` | Document completed features |

**Typical workflow:**
```
prd-driven-development -> sprint-planning -> [implementation] -> code-review -> testing-strategy
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Stories are too large (13+ points) | Apply story splitting patterns from REFERENCE.md |
| Acceptance criteria are vague | Use concrete values; add Given/When/Then structure |
| Sprint consistently overcommitted | Reduce to 70% of average velocity; track interruptions |
| Dependencies between stories | Reorder or split; consider vertical slicing |
| `gh` CLI auth fails | Run `gh auth login` and select correct repository scope |
| Stories lack testability | Rewrite with observable outcomes; add "Then I should see..." |
