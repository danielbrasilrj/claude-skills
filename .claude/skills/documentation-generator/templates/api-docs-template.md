# API Endpoint: {{METHOD}} {{PATH}}

> Brief one-sentence description of what this endpoint does

## Overview

Longer description of the endpoint's purpose, use cases, and when to use it.

---

## Authentication

**Required**: Yes | No

**Method**: Bearer Token | API Key | OAuth 2.0 | None

**Permissions**: `{{permission:scope}}` (e.g., `users:read`, `admin:write`)

---

## Request

### HTTP Method and Path

```http
{{METHOD}} {{FULL_PATH}}
```

**Example:**
```http
POST https://api.example.com/v1/users
```

### Headers

| Header | Required | Type | Description |
|--------|----------|------|-------------|
| `Content-Type` | Yes | string | Must be `application/json` |
| `Authorization` | Yes | string | Bearer token: `Bearer <JWT>` |
| `X-Request-ID` | No | string | Unique request identifier for tracing |

**Example:**
```http
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
X-Request-ID: 550e8400-e29b-41d4-a716-446655440000
```

### Path Parameters

{{If endpoint has path parameters like /users/:userId}}

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `{{paramName}}` | {{type}} | Yes | {{Description}} |

**Example:**
```
/users/123e4567-e89b-12d3-a456-426614174000
```

### Query Parameters

{{If endpoint accepts query parameters like ?filter=active}}

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `{{paramName}}` | {{type}} | Yes/No | {{default}} | {{Description}} |

**Example:**
```
?page=1&limit=20&sort=createdAt&order=desc
```

### Request Body

{{If endpoint accepts a request body}}

**Schema:**

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `{{field}}` | {{type}} | Yes/No | {{constraints}} | {{Description}} |

**Example:**
```json
{
  "email": "alice@example.com",
  "name": "Alice Johnson",
  "role": "admin",
  "metadata": {
    "department": "Engineering",
    "startDate": "2024-01-15"
  }
}
```

**JSON Schema:**
```json
{
  "type": "object",
  "required": ["email", "name"],
  "properties": {
    "email": {
      "type": "string",
      "format": "email",
      "maxLength": 255
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100
    },
    "role": {
      "type": "string",
      "enum": ["user", "admin", "moderator"],
      "default": "user"
    },
    "metadata": {
      "type": "object",
      "additionalProperties": true
    }
  }
}
```

---

## Response

### Success Response

**Status Code**: `{{2XX}}` (e.g., `200 OK`, `201 Created`, `204 No Content`)

**Headers:**
```http
Content-Type: application/json
X-Request-ID: 550e8400-e29b-41d4-a716-446655440000
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1642245600
```

**Body:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "email": "alice@example.com",
  "name": "Alice Johnson",
  "role": "admin",
  "emailVerified": true,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

**Schema:**

| Field | Type | Description |
|-------|------|-------------|
| `{{field}}` | {{type}} | {{Description}} |

### Error Responses

#### 400 Bad Request

**Description**: Request validation failed

```json
{
  "error": "Validation failed",
  "code": "VALIDATION_ERROR",
  "details": [
    {
      "field": "email",
      "message": "Email format is invalid",
      "value": "invalid-email"
    },
    {
      "field": "name",
      "message": "Name must be at least 1 character",
      "value": ""
    }
  ]
}
```

#### 401 Unauthorized

**Description**: Missing or invalid authentication credentials

```json
{
  "error": "Authentication required",
  "code": "UNAUTHORIZED"
}
```

#### 403 Forbidden

**Description**: Valid authentication but insufficient permissions

```json
{
  "error": "Insufficient permissions. Requires users:create permission.",
  "code": "FORBIDDEN"
}
```

#### 404 Not Found

**Description**: Resource does not exist

```json
{
  "error": "User not found",
  "code": "NOT_FOUND",
  "resourceId": "123e4567-e89b-12d3-a456-426614174000"
}
```

#### 409 Conflict

**Description**: Resource already exists or conflicting state

```json
{
  "error": "Email is already registered",
  "code": "EMAIL_CONFLICT",
  "details": {
    "field": "email",
    "value": "alice@example.com"
  }
}
```

#### 422 Unprocessable Entity

**Description**: Request is well-formed but semantically incorrect

```json
{
  "error": "Cannot assign admin role without approval",
  "code": "ROLE_ASSIGNMENT_FORBIDDEN"
}
```

#### 429 Too Many
API Error: Claude's response exceeded the 32000 output token maximum. To configure this behavior, set the CLAUDE_CODE_MAX_OUTPUT_TOKENS environment variable.
I'll continue generating the remaining documentation files:

===FILE: /Users/danielcarmo/Env/Projects/personal/claude_skills/claude_skills/.claude/skills/documentation-generator/templates/api-docs-template.md===
# API Endpoint: {{METHOD}} {{PATH}}

> Brief one-sentence description of what this endpoint does

## Overview

Longer description of the endpoint's purpose, use cases, and when to use it.

---

## Authentication

**Required**: Yes | No

**Method**: Bearer Token | API Key | OAuth 2.0 | None

**Permissions**: `{{permission:scope}}` (e.g., `users:read`, `admin:write`)

---

## Request

### HTTP Method and Path

```http
{{METHOD}} {{FULL_PATH}}
```

**Example:**
```http
POST https://api.example.com/v1/users
```

### Headers

| Header | Required | Type | Description |
|--------|----------|------|-------------|
| `Content-Type` | Yes | string | Must be `application/json` |
| `Authorization` | Yes | string | Bearer token: `Bearer <JWT>` |

### Request Body

**Schema:**

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `{{field}}` | {{type}} | Yes/No | {{constraints}} | {{Description}} |

**Example:**
```json
{
  "email": "alice@example.com",
  "name": "Alice Johnson"
}
```

---

## Response

### Success Response

**Status Code**: `{{2XX}}`

**Body:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "email": "alice@example.com",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

### Error Responses

#### 400 Bad Request
```json
{
  "error": "Validation failed",
  "code": "VALIDATION_ERROR"
}
```

#### 401 Unauthorized
```json
{
  "error": "Authentication required",
  "code": "UNAUTHORIZED"
}
```

---

## Rate Limiting

- **Limit**: {{N}} requests per {{time window}}
- **Headers**: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

---

## Examples

### cURL

```bash
curl -X {{METHOD}} https://api.example.com{{PATH}} \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"email":"alice@example.com","name":"Alice"}'
```

### JavaScript (fetch)

```javascript
const response = await fetch('https://api.example.com{{PATH}}', {
  method: '{{METHOD}}',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    email: 'alice@example.com',
    name: 'Alice'
  })
});

const data = await response.json();
```

### Python (requests)

```python
import requests

response = requests.{{method}}(
    'https://api.example.com{{PATH}}',
    headers={'Authorization': f'Bearer {token}'},
    json={'email': 'alice@example.com', 'name': 'Alice'}
)

data = response.json()
```

---

## Notes

{{Any additional notes, caveats, or important information}}
