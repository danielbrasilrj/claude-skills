# Schema Design Best Practices

## Use `$ref` for Reusability

```yaml
# BAD: Duplicated schema
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

# GOOD: Reusable schema
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

## Define Error Responses Consistently

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

## Use Path Parameters vs Query Parameters

| Use Case            | Parameter Type | Example                      |
| ------------------- | -------------- | ---------------------------- |
| Resource identifier | Path           | `/users/{id}`                |
| Filtering           | Query          | `/users?role=admin`          |
| Pagination          | Query          | `/users?page=2&limit=20`     |
| Sorting             | Query          | `/users?sort=name&order=asc` |
| Versioning          | Path           | `/v1/users`                  |

## Pagination Patterns

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
