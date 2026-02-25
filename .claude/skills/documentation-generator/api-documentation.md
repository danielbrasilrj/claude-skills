# API Documentation Standards

## REST API Endpoint Documentation

For each API endpoint, document using this template:

````markdown
## POST /api/users

Create a new user account.

### Authentication

Requires: `Bearer <JWT>` in `Authorization` header
Permissions: `users:create`

### Request

**Headers:**

```http
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
````

**Body:**

```json
{
  "email": "alice@example.com",
  "name": "Alice Johnson",
  "role": "admin"
}
```

**Schema:**
| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `email` | string | Yes | Valid email format, max 255 chars | User's email address (must be unique) |
| `name` | string | Yes | Max 100 chars | User's full name |
| `role` | string | No | Enum: `user`, `admin`, `moderator` | User's role (default: `user`) |

### Response

**Success (201 Created):**

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "email": "alice@example.com",
  "name": "Alice Johnson",
  "role": "admin",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

**Error (400 Bad Request):**

```json
{
  "error": "Validation failed",
  "details": [
    {
      "field": "email",
      "message": "Email is already registered"
    }
  ]
}
```

**Error (401 Unauthorized):**

```json
{
  "error": "Authentication required"
}
```

**Error (403 Forbidden):**

```json
{
  "error": "Insufficient permissions. Requires users:create permission."
}
```

### Error Codes

| Status | Code                    | Description                                |
| ------ | ----------------------- | ------------------------------------------ |
| 400    | `VALIDATION_FAILED`     | Request body failed validation             |
| 400    | `EMAIL_ALREADY_EXISTS`  | Email is already registered                |
| 401    | `UNAUTHORIZED`          | Missing or invalid authentication token    |
| 403    | `FORBIDDEN`             | Valid token but lacks required permissions |
| 500    | `INTERNAL_SERVER_ERROR` | Unexpected server error                    |

### Rate Limiting

- **Limit**: 100 requests per 15 minutes per IP
- **Headers**:
  - `X-RateLimit-Limit: 100`
  - `X-RateLimit-Remaining: 87`
  - `X-RateLimit-Reset: 1642245600` (Unix timestamp)

### Example Usage

**cURL:**

```bash
curl -X POST https://api.example.com/api/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"email":"alice@example.com","name":"Alice Johnson","role":"admin"}'
```

**JavaScript (fetch):**

```javascript
const response = await fetch('https://api.example.com/api/users', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${token}`,
  },
  body: JSON.stringify({
    email: 'alice@example.com',
    name: 'Alice Johnson',
    role: 'admin',
  }),
});

const user = await response.json();
console.log(user.id); // '123e4567-e89b-12d3-a456-426614174000'
```

**Python (requests):**

```python
import requests

response = requests.post(
    'https://api.example.com/api/users',
    headers={
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {token}'
    },
    json={
        'email': 'alice@example.com',
        'name': 'Alice Johnson',
        'role': 'admin'
    }
)

user = response.json()
print(user['id'])  # '123e4567-e89b-12d3-a456-426614174000'
```

````

## OpenAPI/Swagger Integration

Generate API docs from OpenAPI spec:

```yaml
# openapi.yaml
openapi: 3.0.0
info:
  title: My API
  version: 1.0.0
  description: Comprehensive API for user management

paths:
  /api/users:
    post:
      summary: Create a new user
      operationId: createUser
      tags:
        - Users
      security:
        - BearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/ValidationError'
        '401':
          $ref: '#/components/responses/Unauthorized'

components:
  schemas:
    CreateUserRequest:
      type: object
      required:
        - email
        - name
      properties:
        email:
          type: string
          format: email
          maxLength: 255
        name:
          type: string
          maxLength: 100
        role:
          type: string
          enum: [user, admin, moderator]
          default: user

    User:
      type: object
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
        name:
          type: string
        role:
          type: string
          enum: [user, admin, moderator]
        createdAt:
          type: string
          format: date-time

  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  responses:
    ValidationError:
      description: Validation failed
      content:
        application/json:
          schema:
            type: object
            properties:
              error:
                type: string
              details:
                type: array
                items:
                  type: object
                  properties:
                    field:
                      type: string
                    message:
                      type: string
````

Generate docs with Redoc or Swagger UI:

```bash
# Generate static HTML with Redoc
npx redoc-cli bundle openapi.yaml -o docs/api.html

# Serve interactive Swagger UI
npx swagger-ui-watcher openapi.yaml
```
