# API Contract Testing Reference Guide

## Introduction

API contract testing ensures that your API implementation matches its specification, enabling parallel frontend/backend development, preventing breaking changes, and serving as living documentation.

This guide covers the full contract-first workflow: designing OpenAPI specs, generating typed clients, setting up mock servers, and automating contract validation in CI.

---

## OpenAPI Specification Fundamentals

### OpenAPI 3.1 vs 3.0

| Feature | OpenAPI 3.0 | OpenAPI 3.1 |
|---------|-------------|-------------|
| JSON Schema | Subset | Full JSON Schema 2020-12 |
| Webhooks | ❌ | ✅ |
| `$ref` scope | Limited | Any location |
| `null` type | workaround | Native support |
| Examples | `example` or `examples` | Unified `examples` |

**Recommendation**: Use OpenAPI 3.1 for new projects. If tooling doesn't support 3.1, use 3.0.3.

### Core Specification Structure

```yaml
openapi: 3.1.0
info:                    # Metadata
  title: My API
  version: 1.0.0
servers:                 # Base URLs
  - url: https://api.example.com/v1
paths:                   # Endpoints
  /users:
    get: ...
    post: ...
components:              # Reusable schemas
  schemas:
    User: ...
  responses:
    NotFound: ...
  securitySchemes:
    bearerAuth: ...
security:                # Global security requirements
  - bearerAuth: []
```

---

## Schema Design Best Practices

### Use `$ref` for Reusability

```yaml
# ❌ BAD: Duplicated schema
paths:
  /users:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                type: object
                properties:
                  id: { type: string }
                  name: { type: string }
  /users/{id}:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                type: object
                properties:
                  id: { type: string }
                  name: { type: string }

# ✅ GOOD: Reusable schema
components:
  schemas:
    User:
      type: object
      required: [id, name]
      properties:
        id: { type: string, format: uuid }
        name: { type: string, minLength: 1 }

paths:
  /users:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
  /users/{id}:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
```

### Define Error Responses Consistently

```yaml
components:
  responses:
    BadRequest:
      description: Invalid request
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            error: 'Validation failed'
            details:
              - field: 'email'
                message: 'Invalid email format'
    
    Unauthorized:
      description: Authentication required
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            error: 'Authentication required'
    
    NotFound:
      description: Resource not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            error: 'User not found'

  schemas:
    Error:
      type: object
      required: [error]
      properties:
        error:
          type: string
          description: Human-readable error message
        details:
          type: array
          description: Validation errors (optional)
          items:
            type: object
            properties:
              field: { type: string }
              message: { type: string }
```

### Use Path Parameters vs Query Parameters

| Use Case | Parameter Type | Example |
|----------|---------------|---------|
| Resource identifier | Path | `/users/{id}` |
| Filtering | Query | `/users?role=admin` |
| Pagination | Query | `/users?page=2&limit=20` |
| Sorting | Query | `/users?sort=name&order=asc` |
| Versioning | Path | `/v1/users` |

### Pagination Patterns

**Offset-based** (simple, not ideal for real-time data)
```yaml
/users:
  get:
    parameters:
      - name: page
        in: query
        schema:
          type: integer
          minimum: 1
          default: 1
      - name: limit
        in: query
        schema:
          type: integer
          minimum: 1
          maximum: 100
          default: 20
    responses:
      '200':
        content:
          application/json:
            schema:
              type: object
              properties:
                data:
                  type: array
                  items:
                    $ref: '#/components/schemas/User'
                pagination:
                  type: object
                  properties:
                    page: { type: integer }
                    limit: { type: integer }
                    total: { type: integer }
                    totalPages: { type: integer }
```

**Cursor-based** (better for real-time data, handles insertions/deletions)
```yaml
/users:
  get:
    parameters:
      - name: cursor
        in: query
        schema:
          type: string
        description: Opaque cursor for next page
      - name: limit
        in: query
        schema:
          type: integer
          default: 20
    responses:
      '200':
        content:
          application/json:
            schema:
              type: object
              properties:
                data:
                  type: array
                  items:
                    $ref: '#/components/schemas/User'
                pagination:
                  type: object
                  properties:
                    nextCursor: { type: string, nullable: true }
                    hasMore: { type: boolean }
```

---

## Mock Server Setup

### Prism (Standalone Mock Server)

**Installation**
```bash
npm install -g @stoplight/prism-cli
```

**Basic Usage**
```bash
# Mock server on port 4010
prism mock openapi.yaml --port 4010

# Validate responses against spec (strict mode)
prism mock openapi.yaml --port 4010 --errors

# Dynamic response based on examples
prism mock openapi.yaml --dynamic
```

**Example-based Responses**
Prism returns examples from your spec:
```yaml
paths:
  /users/{id}:
    get:
      responses:
        '200':
          content:
            application/json:
              examples:
                john:
                  value:
                    id: '1'
                    name: 'John Doe'
                    email: 'john@example.com'
                jane:
                  value:
                    id: '2'
                    name: 'Jane Smith'
                    email: 'jane@example.com'
```

**Prism in Docker**
```bash
docker run --rm -it \
  -v $(pwd)/openapi.yaml:/openapi.yaml \
  -p 4010:4010 \
  stoplight/prism:4 mock -h 0.0.0.0 /openapi.yaml
```

### MSW (Mock Service Worker)

**Installation**
```bash
npm install msw --save-dev
```

**Setup for Browser**
```typescript
// src/mocks/handlers.ts
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/v1/users/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'John Doe',
      email: 'john@example.com'
    })
  }),

  http.post('/api/v1/users', async ({ request }) => {
    const body = await request.json()
    return HttpResponse.json(
      { id: '123', ...body },
      { status: 201 }
    )
  }),

  http.get('/api/v1/users', ({ request }) => {
    const url = new URL(request.url)
    const page = url.searchParams.get('page') || '1'
    
    return HttpResponse.json({
      data: [
        { id: '1', name: 'John Doe' },
        { id: '2', name: 'Jane Smith' }
      ],
      pagination: {
        page: parseInt(page),
        limit: 20,
        total: 100,
        totalPages: 5
      }
    })
  })
]

// src/mocks/browser.ts
import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'

export const worker = setupWorker(...handlers)

// src/main.tsx
if (process.env.NODE_ENV === 'development') {
  const { worker } = await import('./mocks/browser')
  await worker.start()
}
```

**Setup for Node.js (Tests)**
```typescript
// src/mocks/server.ts
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)

// src/setupTests.ts
import { server } from './mocks/server'

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

### Type-Safe MSW with openapi-msw

Generate type-safe MSW handlers from OpenAPI spec:

```bash
npm install openapi-msw --save-dev
npx openapi-msw ./openapi.yaml -o ./src/mocks/handlers.ts
```

Generated handlers have TypeScript types:
```typescript
// Auto-generated from spec
export const handlers = [
  http.get('/api/v1/users/:id', ({ params }) => {
    // params.id is typed as string
    // Response type is inferred from spec
    return HttpResponse.json({
      id: params.id,
      name: 'John Doe',
      email: 'john@example.com'
    })
  })
]
```

---

## Typed Client Generation

### openapi-typescript

**Installation**
```bash
npm install openapi-typescript --save-dev
```

**Generate Types**
```bash
npx openapi-typescript ./openapi.yaml -o ./src/api/schema.d.ts
```

**Usage with fetch**
```typescript
import type { paths } from './api/schema'

type GetUserResponse = paths['/users/{id}']['get']['responses']['200']['content']['application/json']
type CreateUserRequest = paths['/users']['post']['requestBody']['content']['application/json']

async function getUser(id: string): Promise<GetUserResponse> {
  const response = await fetch(`/api/v1/users/${id}`)
  return response.json()
}

async function createUser(data: CreateUserRequest): Promise<GetUserResponse> {
  const response = await fetch('/api/v1/users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  })
  return response.json()
}
```

**Usage with openapi-fetch (recommended)**
```bash
npm install openapi-fetch
```

```typescript
import createClient from 'openapi-fetch'
import type { paths } from './api/schema'

const client = createClient<paths>({ baseUrl: '/api/v1' })

// Fully typed requests and responses
const { data, error } = await client.GET('/users/{id}', {
  params: { path: { id: '123' } }
})

const { data: newUser, error: createError } = await client.POST('/users', {
  body: {
    name: 'John Doe',
    email: 'john@example.com'
  }
})
```

### Orval (Full Client Generator)

**Installation**
```bash
npm install orval --save-dev
```

**Configuration**
```typescript
// orval.config.ts
import { defineConfig } from 'orval'

export default defineConfig({
  petstore: {
    input: './openapi.yaml',
    output: {
      mode: 'tags-split',
      target: './src/api/generated',
      client: 'react-query',
      prettier: true,
      override: {
        mutator: {
          path: './src/api/client.ts',
          name: 'customClient'
        }
      }
    }
  }
})
```

**Custom Client**
```typescript
// src/api/client.ts
import axios, { AxiosRequestConfig } from 'axios'

export const customClient = <T>(config: AxiosRequestConfig): Promise<T> => {
  const source = axios.CancelToken.source()
  const promise = axios({
    ...config,
    baseURL: '/api/v1',
    cancelToken: source.token
  }).then(({ data }) => data)

  // @ts-ignore
  promise.cancel = () => source.cancel('Query was cancelled')

  return promise
}
```

**Generate Client**
```bash
npx orval
```

**Generated React Query Hooks**
```typescript
// Auto-generated
import { useGetUsers, useCreateUser } from './api/generated'

function UserList() {
  const { data, isLoading } = useGetUsers({ page: 1, limit: 20 })
  const createUser = useCreateUser()

  const handleCreate = () => {
    createUser.mutate({
      name: 'John Doe',
      email: 'john@example.com'
    })
  }

  if (isLoading) return <div>Loading...</div>

  return (
    <div>
      {data?.data.map(user => (
        <div key={user.id}>{user.name}</div>
      ))}
      <button onClick={handleCreate}>Create User</button>
    </div>
  )
}
```

---

## Contract Validation in CI

### Spectral (OpenAPI Linter)

**Installation**
```bash
npm install @stoplight/spectral-cli --save-dev
```

**Basic Linting**
```bash
npx spectral lint openapi.yaml
```

**Custom Rules**
```yaml
# .spectral.yaml
extends: [[spectral:oas, all]]
rules:
  operation-operationId: error
  operation-summary: error
  operation-description: warn
  operation-tags: error
  oas3-examples-value-or-externalValue: error
  
  # Custom rule: require error responses
  require-error-responses:
    message: All operations must define 400 and 500 responses
    given: $.paths.*[get,post,put,patch,delete]
    severity: error
    then:
      - field: responses
        function: schema
        functionOptions:
          schema:
            type: object
            required: ['400', '500']
```

**Run in CI**
```yaml
# .github/workflows/api-contract.yml
- name: Validate OpenAPI Spec
  run: npx spectral lint openapi.yaml --fail-severity warn
```

### Prism Proxy (Runtime Validation)

Validate actual API responses against spec:

```bash
# Run API server on :3000, proxy through Prism
npx prism proxy openapi.yaml http://localhost:3000 --errors
```

**In CI**
```yaml
- name: Start API Server
  run: npm start &
  
- name: Validate API Responses
  run: |
    npx prism proxy openapi.yaml http://localhost:3000 --errors &
    PRISM_PID=$!
    npm run test:integration
    kill $PRISM_PID
```

### Contract Tests with Dredd

**Installation**
```bash
npm install dredd --save-dev
```

**Configuration**
```yaml
# dredd.yml
dry-run: null
hookfiles: null
language: nodejs
sandbox: false
server: npm start
server-wait: 3
init: false
custom: {}
names: false
only: []
reporter: []
output: []
header: []
sorted: false
user: null
inline-errors: false
details: false
method: []
color: true
level: info
timestamp: false
silent: false
path: []
blueprint: openapi.yaml
endpoint: http://localhost:3000/api/v1
```

**Run Tests**
```bash
npx dredd
```

**Hooks for Setup/Teardown**
```javascript
// hooks.js
const hooks = require('hooks')

hooks.before('Users > Get User', (transaction, done) => {
  // Create test user before request
  done()
})

hooks.after('Users > Delete User', (transaction, done) => {
  // Clean up after test
  done()
})
```

---

## Contract Drift Detection

### Automated Drift Detection

**Strategy**: Generate types on every build and fail if Git diff detected

```json
// package.json
{
  "scripts": {
    "generate:types": "openapi-typescript ./openapi.yaml -o ./src/api/schema.d.ts",
    "check:contract": "npm run generate:types && git diff --exit-code src/api/schema.d.ts"
  }
}
```

**In CI**
```yaml
- name: Check Contract Drift
  run: |
    npm run generate:types
    if ! git diff --exit-code src/api/schema.d.ts; then
      echo "Contract has changed but types were not regenerated!"
      echo "Run 'npm run generate:types' and commit the changes."
      exit 1
    fi
```

### Prevent Breaking Changes

Use `optic` to detect breaking changes:

```bash
npm install @useoptic/openapi-utilities --save-dev
```

```bash
npx optic diff openapi.yaml --base main --check
```

**Breaking Changes Detected**
- Removed endpoints
- Removed required fields
- Changed field types
- Removed enum values
- Changed response status codes

---

## Best Practices

### 1. Spec-First Development

✅ **DO**:
1. Write OpenAPI spec first
2. Review and validate spec with stakeholders
3. Generate mocks and typed clients
4. Frontend and backend develop in parallel
5. Backend implements to match spec

❌ **DON'T**:
1. Write code first
2. Generate spec from code
3. Treat spec as documentation afterthought

### 2. Version Your API

**URL Versioning** (recommended for public APIs)
```yaml
servers:
  - url: https://api.example.com/v1
  - url: https://api.example.com/v2
```

**Header Versioning** (flexible, same URL)
```yaml
paths:
  /users:
    get:
      parameters:
        - name: API-Version
          in: header
          required: true
          schema:
            type: string
            enum: ['1.0', '2.0']
```

### 3. Use Semantic Versioning for Spec

```yaml
info:
  version: 1.2.3  # MAJOR.MINOR.PATCH
  # MAJOR: Breaking changes
  # MINOR: New features (backwards compatible)
  # PATCH: Bug fixes
```

### 4. Include Examples

Every response should have an example:
```yaml
responses:
  '200':
    content:
      application/json:
        schema:
          $ref: '#/components/schemas/User'
        examples:
          john:
            summary: Example user John
            value:
              id: '1'
              name: 'John Doe'
              email: 'john@example.com'
```

### 5. Document Security Requirements

```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key

security:
  - bearerAuth: []

paths:
  /public:
    get:
      security: []  # Override: no auth required
```

### 6. Use Webhooks (OpenAPI 3.1)

```yaml
webhooks:
  userCreated:
    post:
      summary: User created event
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                event: { type: string, const: 'user.created' }
                data:
                  $ref: '#/components/schemas/User'
```

---

## Tooling Ecosystem

| Tool | Purpose | Best For |
|------|---------|----------|
| **Prism** | Mock server | Standalone development, quick prototyping |
| **MSW** | In-app mocking | Frontend tests, browser development |
| **openapi-typescript** | Type generation | Type-safe fetch clients |
| **openapi-fetch** | Typed client | Lightweight, no dependencies |
| **Orval** | Full client + hooks | React Query, SWR, Axios |
| **Spectral** | Spec linting | CI validation, style enforcement |
| **Dredd** | Contract testing | End-to-end contract validation |
| **Optic** | Breaking change detection | Prevent accidental breaking changes |
| **Swagger UI** | Interactive docs | Human-readable documentation |
| **Redoc** | Static docs | Beautiful documentation sites |

---

## Troubleshooting

### Mocks Return 500 Errors

**Cause**: Spec examples are invalid or missing required fields

**Solution**:
```bash
# Validate spec first
npx spectral lint openapi.yaml

# Check examples match schemas
npx prism mock openapi.yaml --errors
```

### Type Generation Fails

**Cause**: Circular references in spec

**Solution**:
```yaml
# Use allOf instead of circular refs
components:
  schemas:
    User:
      type: object
      properties:
        id: { type: string }
        posts:
          type: array
          items:
            allOf:
              - $ref: '#/components/schemas/Post'
              - type: object
                properties:
                  author: { type: string }  # Just the ID, not full User
```

### Contract Drift Not Detected

**Cause**: Types not regenerated on spec change

**Solution**: Add pre-commit hook
```bash
# .husky/pre-commit
#!/bin/sh
npm run generate:types
git add src/api/schema.d.ts
```

### MSW Handlers Drift from Spec

**Cause**: Manual MSW handlers not updated when spec changes

**Solution**: Use `openapi-msw` to generate handlers from spec
```bash
npx openapi-msw ./openapi.yaml -o ./src/mocks/handlers.ts
```

---

## Further Reading

- [OpenAPI Specification 3.1](https://spec.openapis.org/oas/v3.1.0)
- [Prism Documentation](https://stoplight.io/open-source/prism)
- [MSW Documentation](https://mswjs.io)
- [Spectral Rulesets](https://stoplight.io/open-source/spectral)
- [Consumer-Driven Contract Testing](https://martinfowler.com/articles/consumerDrivenContracts.html)
