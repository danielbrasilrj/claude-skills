---
name: prd-driven-development
description: PRD-first development — creates PRDs from feature ideas, breaks into tasks with dependencies, maintains PRD-to-code traceability.
---

## Purpose

PRD-Driven Development ensures every feature starts with a clear specification before code is written. PRDs are structured for dual-audience consumption — humans for strategic alignment and AI coding agents for precise implementation. This prevents scope creep, missed requirements, and rework.

## When to Use

- Starting development on a new feature
- Converting a vague idea into implementable requirements
- Breaking a large feature into ordered implementation tasks
- Aligning stakeholders on scope before development
- Providing Claude with structured context for implementation

## Prerequisites

- Feature idea or user request
- Stakeholder input on priorities and constraints
- Access to `domain-intelligence` for tech stack context

## Procedures

### 1. Gather Context

Before writing the PRD, collect:

- **User problem**: What pain point does this solve?
- **Business goal**: What metric does this improve?
- **Constraints**: Timeline, budget, technical limitations
- **Existing context**: Related features, past decisions

### 2. Write the PRD

Use the template in `templates/prd-template.md`. Key sections:

1. **Problem Statement** — Why are we building this?
2. **User Stories** — Who benefits and how?
3. **Acceptance Criteria** — Given/When/Then for each story
4. **Technical Constraints** — Stack, performance, security requirements
5. **Out of Scope** — Explicitly list what this does NOT include
6. **Dependencies** — What must exist before this can be built?
7. **Success Metrics** — How do we know this worked?

### 3. Optimize for AI Consumption

Structure the PRD so Claude can consume it directly:

- Use dependency-ordered phases (foundations first)
- Make each phase independently testable
- Include explicit inputs/outputs for each component
- Reference `domain-intelligence` for tech stack specifics

### 4. Break Into Tasks

Use `templates/task-breakdown.md`:

1. Identify implementation phases from the PRD
2. For each phase, create atomic tasks (< 1 day each)
3. Define dependencies between tasks
4. Estimate effort using story points (reference `sprint-planning`)
5. Format for Linear/GitHub Issues

### 5. Maintain Traceability

Create a traceability matrix linking:

- PRD section → Task/Issue → PR/Commit → Test

## Templates

- `templates/prd-template.md` — Full PRD template
- `templates/task-breakdown.md` — Task breakdown template

## Examples

- `examples/prd-example.md` — Example PRD for user authentication

## Chaining

| Chain With                | Purpose                                 |
| ------------------------- | --------------------------------------- |
| `deep-research`           | Research before writing PRD             |
| `sprint-planning`         | Convert PRD tasks into sprint backlog   |
| `domain-intelligence`     | Check tech constraints                  |
| `documentation-generator` | Document the feature after shipping     |
| `testing-strategy`        | Plan tests based on acceptance criteria |

## References

- [prd-structure-standards.md](prd-structure-standards.md) -- Core principles, section templates, acceptance criteria patterns, pitfalls
- [ai-consumption-optimization.md](ai-consumption-optimization.md) -- AI context sections, dependency graphs, interface specs
- [stakeholder-alignment.md](stakeholder-alignment.md) -- Pre-PRD checklist, review process, version control
- [workflow-integration.md](workflow-integration.md) -- PRD-to-code flow, PR description template, further reading

## Troubleshooting

| Problem                          | Solution                                                 |
| -------------------------------- | -------------------------------------------------------- |
| PRD too vague for implementation | Add specific inputs/outputs and Given/When/Then criteria |
| Scope keeps growing              | Enforce Out of Scope section; defer additions to v2      |
| Tasks too large                  | Break into subtasks; each should be < 1 day              |
| Stakeholder disagreement         | Focus on Problem Statement alignment first               |
