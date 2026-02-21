---
name: api-contract-testing
description: |
  Procedures for designing, documenting, and testing API contracts using OpenAPI specifications.
  Covers mock server setup (MSW, Prism), contract validation in CI, and typed client code generation
  from specs. Use when designing new APIs, setting up mock servers for frontend development,
  generating typed API clients, or validating API contracts in CI pipelines.
---

## Purpose

API Contract Testing implements a contract-first development workflow where the OpenAPI specification is the single source of truth. It covers the full lifecycle from API design through mock server setup, typed client generation, and automated contract validation in CI.

## When to Use

- Designing a new REST or GraphQL API
- Setting up mock servers for parallel frontend/backend development
- Generating typed API clients from specifications
- Validating API responses against contracts in CI
- Documenting existing APIs with OpenAPI specs

## Prerequisites

- Node.js 18+ for tooling
- OpenAPI 3.0+ specification (or create one using the template)
- Optional: MSW (`npm install msw`), Prism (`npm install -g @stoplight/prism-cli`)
- Optional: openapi-typescript, Orval for client generation

## Procedures

### 1. Design the API Contract (Spec First)

Start with the OpenAPI spec before writing any code:

1. Copy `templates/openapi-spec.yml` as your starting point
2. Define all endpoints, request/response schemas, and error formats
3. Use `$ref` for shared schemas to avoid duplication
4. Include examples for every response

### 2. Set Up Mock Server

**Option A: Prism (standalone mock server)**
```bash
prism mock openapi-spec.yml --port 4010
# Frontend hits http://localhost:4010 during development
```

**Option B: MSW (in-app mocking)**
```typescript
import { http, HttpResponse } from 'msw'
import { setupWorker } from 'msw/browser'

const handlers = [
  http.get('/api/v1/users/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'John Doe',
      email: 'john@example.com'
    })
  })
]

const worker = setupWorker(...handlers)
worker.start()
```

### 3. Generate Typed Client

```bash
# Generate TypeScript types from OpenAPI spec
npx openapi-typescript openapi-spec.yml -o src/api/schema.d.ts

# Or use Orval for full client with React Query hooks
npx orval --config orval.config.ts
```

### 4. Contract Validation in CI

Add to your CI pipeline:
```yaml
- name: Validate API Contract
  run: |
    npx @stoplight/spectral-cli lint openapi-spec.yml
    npx prism proxy openapi-spec.yml http://localhost:3000 --errors
```

### 5. Keep Mocks in Sync

- Regenerate types whenever the spec changes
- Use `openapi-msw` for type-safe MSW handlers that fail at compile time if they drift
- Run contract tests in CI on every PR

## Templates

- `templates/openapi-spec.yml` — Starter OpenAPI 3.1 specification
- `templates/mock-server-setup.md` — MSW and Prism setup guide

## Examples

- `examples/user-api-contract.md` — Complete user API contract example

## Chaining

| Chain With | Purpose |
|---|---|
| `domain-intelligence` | Check API conventions (naming, versioning, pagination) |
| `ci-cd-pipeline` | Add contract validation to CI |
| `documentation-generator` | Generate API docs from spec |
| `code-review` | Validate API implementation matches contract |
| `testing-strategy` | Include contract tests in test plan |

## Troubleshooting

| Problem | Solution |
|---|---|
| Mocks drift from spec | Use openapi-msw for compile-time checks; regenerate on spec change |
| Spec validation errors | Run `spectral lint` locally before committing |
| Type generation fails | Check spec for circular refs; use `--immutable-types` flag |
| Prism returns 500 | Check spec examples are valid; ensure required fields present |
