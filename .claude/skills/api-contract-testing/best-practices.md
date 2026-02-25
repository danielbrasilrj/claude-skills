# Best Practices

## 1. Spec-First Development

**DO**:

1. Write OpenAPI spec first
2. Review and validate spec with stakeholders
3. Generate mocks and typed clients
4. Frontend and backend develop in parallel
5. Backend implements to match spec

**DON'T**:

1. Write code first
2. Generate spec from code
3. Treat spec as documentation afterthought

## 2. Version Your API

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

## 3. Use Semantic Versioning for Spec

```yaml
info:
  version: 1.2.3 # MAJOR.MINOR.PATCH
  # MAJOR: Breaking changes
  # MINOR: New features (backwards compatible)
  # PATCH: Bug fixes
```

## 4. Include Examples

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

## 5. Document Security Requirements

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
      security: [] # Override: no auth required
```

## 6. Use Webhooks (OpenAPI 3.1)

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
                  author: { type: string } # Just the ID, not full User
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

## Further Reading

- [OpenAPI Specification 3.1](https://spec.openapis.org/oas/v3.1.0)
- [Prism Documentation](https://stoplight.io/open-source/prism)
- [MSW Documentation](https://mswjs.io)
- [Spectral Rulesets](https://stoplight.io/open-source/spectral)
- [Consumer-Driven Contract Testing](https://martinfowler.com/articles/consumerDrivenContracts.html)
