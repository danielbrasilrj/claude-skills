# API Contract Testing Example: User Management API

## Scenario

We're building a user management API with the following requirements:
- User registration and login
- CRUD operations for users
- Role-based access control (admin, user)
- Pagination for list endpoints

## Step 1: Design the OpenAPI Spec

```yaml
# openapi.yaml
openapi: 3.1.0

info:
  title: User Management API
  version: 1.0.0
  description: API for managing users with role-based access control

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: http://localhost:3000/v1
    description: Local development

tags:
  - name: Auth
  - name: Users

paths:
  /auth/register:
    post:
      summary: Register new user
      tags: [Auth]
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [email, password, name]
              properties:
                email: { type: string, format: email }
                password: { type: string, minLength: 8 }
                name: { type: string }
            example:
              email: john@example.com
              password: SecurePass123!
              name: John Doe
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AuthResponse'
              example:
                token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
                user:
                  id: 550e8400-e29b-41d4-a716-446655440000
                  email: john@example.com
                  name: John Doe
                  role: user
        '400':
          $ref: '#/components/responses/ValidationError'
        '409':
          description: Email already exists
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              example:
                error: Email already registered

  /auth/login:
    post:
      summary: Login
      tags: [Auth]
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [email, password]
              properties:
                email: { type: string }
                password: { type: string }
      responses:
        '200':
          description: Login successful
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AuthResponse'
        '401':
          description: Invalid credentials
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              example:
                error: Invalid email or password

  /users:
    get:
      summary: List users
      tags: [Users]
      parameters:
        - name: page
          in: query
          schema: { type: integer, minimum: 1, default: 1 }
        - name: limit
          in: query
          schema: { type: integer, minimum: 1, maximum: 100, default: 20 }
        - name: role
          in: query
          schema: { type: string, enum: [admin, user] }
      responses:
        '200':
          description: User list
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
              example:
                data:
                  - id: 550e8400-e29b-41d4-a716-446655440000
                    email: john@example.com
                    name: John Doe
                    role: user
                pagination:
                  page: 1
                  limit: 20
                  total: 100
                  totalPages: 5

    post:
      summary: Create user (admin only)
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserInput'
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '403':
          description: Forbidden
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              example:
                error: Admin access required

  /users/{id}:
    parameters:
      - name: id
        in: path
        required: true
        schema: { type: string, format: uuid }

    get:
      summary: Get user by ID
      tags: [Users]
      responses:
        '200':
          description: User details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '404':
          $ref: '#/components/responses/NotFound'

    patch:
      summary: Update user
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                name: { type: string }
                role: { type: string, enum: [admin, user] }
      responses:
        '200':
          description: User updated
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '403':
          $ref: '#/components/responses/Forbidden'
        '404':
          $ref: '#/components/responses/NotFound'

    delete:
      summary: Delete user
      tags: [Users]
      responses:
        '204':
          description: User deleted
        '403':
          $ref: '#/components/responses/Forbidden'
        '404':
          $ref: '#/components/responses/NotFound'

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    User:
      type: object
      required: [id, email, name, role]
      properties:
        id: { type: string, format: uuid }
        email: { type: string, format: email }
        name: { type: string }
        role: { type: string, enum: [admin, user] }

    CreateUserInput:
      type: object
      required: [email, password, name]
      properties:
        email: { type: string, format: email }
        password: { type: string, minLength: 8 }
        name: { type: string }
        role: { type: string, enum: [admin, user], default: user }

    AuthResponse:
      type: object
      required: [token, user]
      properties:
        token: { type: string }
        user:
          $ref: '#/components/schemas/User'

    Error:
      type: object
      required: [error]
      properties:
        error: { type: string }
        details:
          type: array
          items:
            type: object
            properties:
              field: { type: string }
              message: { type: string }

  responses:
    ValidationError:
      description: Validation failed
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            error: Validation failed
            details:
              - field: email
                message: Invalid email format
              - field: password
                message: Password must be at least 8 characters

    NotFound:
      description: Resource not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            error: Resource not found

    Forbidden:
      description: Forbidden
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            error: Forbidden

security:
  - bearerAuth: []
```

## Step 2: Validate the Spec

```bash
# Install Spectral
npm install @stoplight/spectral-cli --save-dev

# Lint the spec
npx spectral lint openapi.yaml
```

**Output:**
```
No errors found!
```

## Step 3: Generate Typed Client

```bash
# Install openapi-typescript
npm install openapi-typescript openapi-fetch --save-dev

# Generate types
npx openapi-typescript openapi.yaml -o src/api/schema.d.ts
```

**Usage in Frontend:**

```typescript
// src/api/client.ts
import createClient from 'openapi-fetch'
import type { paths } from './schema'

const client = createClient<paths>({
  baseUrl: 'http://localhost:3000/v1',
  headers: {
    'Content-Type': 'application/json'
  }
})

// Add auth token interceptor
client.use({
  async onRequest({ request }) {
    const token = localStorage.getItem('token')
    if (token) {
      request.headers.set('Authorization', `Bearer ${token}`)
    }
    return request
  }
})

export default client

// src/api/users.ts
import client from './client'

export async function register(email: string, password: string, name: string) {
  const { data, error } = await client.POST('/auth/register', {
    body: { email, password, name }
  })
  
  if (error) {
    throw new Error(error.error)
  }
  
  return data
}

export async function login(email: string, password: string) {
  const { data, error } = await client.POST('/auth/login', {
    body: { email, password }
  })
  
  if (error) {
    throw new Error(error.error)
  }
  
  localStorage.setItem('token', data.token)
  return data
}

export async function getUsers(page = 1, limit = 20, role?: 'admin' | 'user') {
  const { data, error } = await client.GET('/users', {
    params: { query: { page, limit, role } }
  })
  
  if (error) {
    throw new Error(error.error)
  }
  
  return data
}

export async function getUserById(id: string) {
  const { data, error } = await client.GET('/users/{id}', {
    params: { path: { id } }
  })
  
  if (error) {
    throw new Error(error.error)
  }
  
  return data
}

export async function updateUser(id: string, updates: { name?: string; role?: 'admin' | 'user' }) {
  const { data, error } = await client.PATCH('/users/{id}', {
    params: { path: { id } },
    body: updates
  })
  
  if (error) {
    throw new Error(error.error)
  }
  
  return data
}
```

## Step 4: Set Up Mock Server (MSW)

```bash
npm install msw --save-dev
npx msw init public/ --save
```

```typescript
// src/mocks/handlers.ts
import { http, HttpResponse } from 'msw'

const users = [
  { id: '1', email: 'john@example.com', name: 'John Doe', role: 'user' },
  { id: '2', email: 'admin@example.com', name: 'Admin User', role: 'admin' }
]

let nextId = 3

export const handlers = [
  // Register
  http.post('/v1/auth/register', async ({ request }) => {
    const body = await request.json()
    
    if (users.some(u => u.email === body.email)) {
      return HttpResponse.json(
        { error: 'Email already registered' },
        { status: 409 }
      )
    }
    
    const user = {
      id: String(nextId++),
      email: body.email,
      name: body.name,
      role: 'user'
    }
    users.push(user)
    
    return HttpResponse.json(
      {
        token: 'mock-jwt-token',
        user
      },
      { status: 201 }
    )
  }),

  // Login
  http.post('/v1/auth/login', async ({ request }) => {
    const body = await request.json()
    const user = users.find(u => u.email === body.email)
    
    if (!user) {
      return HttpResponse.json(
        { error: 'Invalid email or password' },
        { status: 401 }
      )
    }
    
    return HttpResponse.json({
      token: 'mock-jwt-token',
      user
    })
  }),

  // List users
  http.get('/v1/users', ({ request }) => {
    const url = new URL(request.url)
    const page = parseInt(url.searchParams.get('page') || '1')
    const limit = parseInt(url.searchParams.get('limit') || '20')
    const role = url.searchParams.get('role')
    
    let filteredUsers = users
    if (role) {
      filteredUsers = users.filter(u => u.role === role)
    }
    
    const start = (page - 1) * limit
    const paginatedUsers = filteredUsers.slice(start, start + limit)
    
    return HttpResponse.json({
      data: paginatedUsers,
      pagination: {
        page,
        limit,
        total: filteredUsers.length,
        totalPages: Math.ceil(filteredUsers.length / limit)
      }
    })
  }),

  // Get user by ID
  http.get('/v1/users/:id', ({ params }) => {
    const user = users.find(u => u.id === params.id)
    
    if (!user) {
      return HttpResponse.json(
        { error: 'Resource not found' },
        { status: 404 }
      )
    }
    
    return HttpResponse.json(user)
  }),

  // Update user
  http.patch('/v1/users/:id', async ({ params, request }) => {
    const user = users.find(u => u.id === params.id)
    
    if (!user) {
      return HttpResponse.json(
        { error: 'Resource not found' },
        { status: 404 }
      )
    }
    
    const updates = await request.json()
    Object.assign(user, updates)
    
    return HttpResponse.json(user)
  }),

  // Delete user
  http.delete('/v1/users/:id', ({ params }) => {
    const index = users.findIndex(u => u.id === params.id)
    
    if (index === -1) {
      return HttpResponse.json(
        { error: 'Resource not found' },
        { status: 404 }
      )
    }
    
    users.splice(index, 1)
    return new HttpResponse(null, { status: 204 })
  })
]

// src/mocks/browser.ts
import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'

export const worker = setupWorker(...handlers)

// src/main.tsx
if (import.meta.env.DEV) {
  const { worker } = await import('./mocks/browser')
  await worker.start()
}
```

## Step 5: Add Contract Validation to CI

```yaml
# .github/workflows/api-contract.yml
name: API Contract Validation

on:
  pull_request:
    paths:
      - 'openapi.yaml'
      - 'src/api/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      
      - name: Install dependencies
        run: npm ci
      
      - name: Lint OpenAPI spec
        run: npx spectral lint openapi.yaml
      
      - name: Generate types
        run: npx openapi-typescript openapi.yaml -o src/api/schema.d.ts
      
      - name: Check for contract drift
        run: |
          if ! git diff --exit-code src/api/schema.d.ts; then
            echo "❌ Contract has changed but types were not regenerated!"
            echo "Run 'npm run generate:types' and commit the changes."
            exit 1
          fi
      
      - name: Type check
        run: npm run type-check
```

## Step 6: Test with Actual API

**Start API server:**
```bash
npm run dev  # Runs on http://localhost:3000
```

**Test endpoints:**
```bash
# Register
curl -X POST http://localhost:3000/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","password":"SecurePass123!","name":"Test User"}'

# Response:
# {
#   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
#   "user": {
#     "id": "550e8400-e29b-41d4-a716-446655440000",
#     "email": "test@example.com",
#     "name": "Test User",
#     "role": "user"
#   }
# }

# List users (requires auth)
curl http://localhost:3000/v1/users?page=1&limit=10 \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'

# Response:
# {
#   "data": [
#     { "id": "1", "email": "test@example.com", "name": "Test User", "role": "user" }
#   ],
#   "pagination": {
#     "page": 1,
#     "limit": 10,
#     "total": 1,
#     "totalPages": 1
#   }
# }
```

## Step 7: Monitor for Contract Drift

**Add pre-commit hook:**
```bash
# .husky/pre-commit
#!/bin/sh
npm run generate:types
git add src/api/schema.d.ts
```

**Package.json scripts:**
```json
{
  "scripts": {
    "generate:types": "openapi-typescript openapi.yaml -o src/api/schema.d.ts",
    "check:contract": "npm run generate:types && git diff --exit-code src/api/schema.d.ts",
    "lint:spec": "spectral lint openapi.yaml"
  }
}
```

## Benefits Achieved

✅ **Frontend/Backend Parallel Development**
- Frontend uses MSW mocks immediately
- Backend implements to match spec
- No blocking dependencies

✅ **Type Safety**
- API client is fully typed
- Compile-time errors if API changes
- Auto-complete in IDE

✅ **Living Documentation**
- Spec is always up-to-date (enforced by CI)
- Can generate Swagger UI docs
- Examples show realistic data

✅ **Prevents Breaking Changes**
- CI fails if spec changes but types not regenerated
- Contract drift detected automatically
- Breaking changes require explicit version bump

✅ **Faster Development**
- No manual type definitions
- Mocks work out of the box
- Consistent error handling

## Next Steps

1. **Add GraphQL** (if needed): Use GraphQL Code Generator with similar workflow
2. **Generate API docs**: Use Redoc or Swagger UI to serve interactive docs
3. **Add Webhooks**: Use OpenAPI 3.1 webhooks for event-driven architecture
4. **Contract tests**: Use Dredd or Pact for comprehensive contract testing
5. **Monitor production**: Use Optic to detect runtime contract violations
