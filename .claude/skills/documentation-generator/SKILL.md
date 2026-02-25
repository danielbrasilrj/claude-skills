---
name: documentation-generator
description: Generates docs for APIs, components, and architecture. Covers JSDoc/TypeDoc, READMEs, and ADRs.
---

## Purpose

Documentation Generator creates and maintains project documentation using established formats and templates. It produces living documentation that stays in sync with code through CI/CD integration, covering everything from API references to architecture decision records.

## When to Use

- Creating or updating project README files
- Writing Architecture Decision Records (ADRs)
- Documenting API endpoints
- Generating component documentation
- Setting up automated documentation pipelines

## Prerequisites

- Access to the codebase or API specifications
- Optional: TypeDoc (`npm install typedoc`), JSDoc (`npm install jsdoc`)

## Procedures

### 1. Architecture Decision Records (ADRs)

Use the MADR (Markdown ADR) template for all architectural decisions. See [adr-guide.md](adr-guide.md) for full example, storage conventions, and lifecycle management.

```markdown
# ADR-NNN: [Decision Title]

## Status

[Proposed | Accepted | Deprecated | Superseded by ADR-XXX]

## Context

[What is the issue? What forces are at play?]

## Decision

[What is the change that we're proposing and/or doing?]

## Consequences

### Positive

- [benefit]

### Negative

- [tradeoff]

### Neutral

- [side effect]

## Alternatives Considered

### [Option A]

- Pros: ...
- Cons: ...

### [Option B]

- Pros: ...
- Cons: ...
```

Store ADRs in `docs/decisions/` with sequential numbering.

### 2. API Documentation

See [api-documentation.md](api-documentation.md) for full REST endpoint template, OpenAPI/Swagger integration, and multi-language examples. For each endpoint, document:

- Method + path
- Request parameters/body with types
- Response schema with examples
- Error codes and meanings
- Authentication requirements

### 3. Component Documentation

See [component-documentation.md](component-documentation.md) for full module documentation template with usage patterns, testing, and architecture diagrams. For each component:

- Purpose and usage
- Props/inputs with types and defaults
- Events/outputs
- Usage examples
- Accessibility notes

### 4. Auto-Documentation in CI

See [ci-cd-docs.md](ci-cd-docs.md) for full GitHub Actions workflow, pre-commit hooks, and quality checklist.

```yaml
# GitHub Actions: generate docs on push to main
- name: Generate TypeDoc
  run: npx typedoc --out docs/api src/index.ts
- name: Deploy to GitHub Pages
  uses: peaceiris/actions-gh-pages@v4
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./docs
```

## Templates

- `templates/adr-template.md` — MADR-style ADR template
- `templates/api-doc.md` — API endpoint documentation template
- `templates/component-doc.md` — Component documentation template

## Examples

- `examples/adr-example.md` — Example ADR for choosing a database

## Chaining

| Chain With             | Purpose                                 |
| ---------------------- | --------------------------------------- |
| `domain-intelligence`  | Document tech stack decisions as ADRs   |
| `api-contract-testing` | Generate docs from OpenAPI specs        |
| `ci-cd-pipeline`       | Set up auto-doc generation in CI        |
| `code-review`          | Verify documentation is included in PRs |

## References

- [jsdoc-typedoc.md](jsdoc-typedoc.md) -- JSDoc comment format, tags reference, TypeDoc configuration and generation
- [api-documentation.md](api-documentation.md) -- REST endpoint template, OpenAPI/Swagger integration, multi-language examples
- [adr-guide.md](adr-guide.md) -- MADR template with full example, storage/naming conventions, ADR lifecycle
- [readme-template.md](readme-template.md) -- Project README structure with all standard sections
- [component-documentation.md](component-documentation.md) -- Module/service documentation template with API, testing, architecture
- [ci-cd-docs.md](ci-cd-docs.md) -- GitHub Actions doc workflow, pre-commit hooks, quality checklist, further reading

## Troubleshooting

| Problem            | Solution                                        |
| ------------------ | ----------------------------------------------- |
| TypeDoc fails      | Check tsconfig paths; ensure exports are public |
| ADRs getting stale | Include ADR review in sprint retrospectives     |
| Docs out of sync   | Add doc generation to CI; fail build on drift   |
