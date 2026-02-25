# OpenAPI Specification Fundamentals

## OpenAPI 3.1 vs 3.0

| Feature      | OpenAPI 3.0             | OpenAPI 3.1              |
| ------------ | ----------------------- | ------------------------ |
| JSON Schema  | Subset                  | Full JSON Schema 2020-12 |
| Webhooks     | No                      | Yes                      |
| `$ref` scope | Limited                 | Any location             |
| `null` type  | workaround              | Native support           |
| Examples     | `example` or `examples` | Unified `examples`       |

**Recommendation**: Use OpenAPI 3.1 for new projects. If tooling doesn't support 3.1, use 3.0.3.

## Core Specification Structure

```yaml
openapi: 3.1.0
info: # Metadata
  title: My API
  version: 1.0.0
servers: # Base URLs
  - url: https://api.example.com/v1
paths: # Endpoints
  /users:
    get: ...
    post: ...
components: # Reusable schemas
  schemas:
    User: ...
  responses:
    NotFound: ...
  securitySchemes:
    bearerAuth: ...
security: # Global security requirements
  - bearerAuth: []
```
