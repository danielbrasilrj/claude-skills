# Documentation Generator Reference Guide

## Overview

This reference guide provides comprehensive standards and best practices for generating high-quality technical documentation, including API references, architecture decision records (ADRs), README files, and inline code documentation. All documentation should be treated as living artifacts that evolve with the codebase.

## Core Principles

### 1. Documentation as Code

Documentation should be:
- **Version Controlled**: Stored in git alongside code
- **Reviewed**: Subject to the same review process as code
- **Tested**: Validated for accuracy (links, code examples, API contracts)
- **Automated**: Generated from source code where possible

### 2. Audience-First Writing

Every document must clearly define its audience and optimize for their needs:

| Audience | Documentation Type | Focus |
|----------|-------------------|-------|
| End Users | User Guides, Tutorials | Task completion, examples, troubleshooting |
| Developers (Internal) | README, Architecture Docs | Setup, contribution guidelines, system design |
| Developers (External) | API Reference, SDK Docs | Integration, authentication, error handling |
| Stakeholders | ADRs, RFCs | Decision rationale, tradeoffs, business impact |

### 3. Information Hierarchy

Structure all documentation with progressive disclosure:

1. **Quick Start** - Get to "Hello World" in < 5 minutes
2. **Core Concepts** - Mental models and key terminology
3. **How-To Guides** - Task-oriented step-by-step instructions
4. **Reference** - Comprehensive API/configuration details
5. **Deep Dives** - Architecture, design decisions, advanced topics

## JSDoc and TypeDoc Standards

### JSDoc Comment Format

Use JSDoc for all public APIs, classes, functions, and complex logic:

```typescript
/**
 * Brief one-line description of what this function does.
 * 
 * More detailed explanation if needed. Explain the "why" and "when to use this",
 * not just the "what" (the code already shows the "what").
 * 
 * @param userId - The unique identifier for the user (UUID v4 format)
 * @param options - Configuration options for the search
 * @param options.includeDeleted - Whether to include soft-deleted users in results
 * @param options.limit - Maximum number of results to return (default: 10, max: 100)
 * 
 * @returns Promise resolving to an array of User objects matching the search criteria
 * 
 * @throws {ValidationError} If userId is not a valid UUID
 * @throws {NotFoundError} If no user exists with the given ID
 * @throws {DatabaseError} If database connection fails
 * 
 * @example
 * ```typescript
 * const user = await findUserById('123e4567-e89b-12d3-a456-426614174000');
 * console.log(user.email); // 'alice@example.com'
 * ```
 * 
 * @example
 * ```typescript
 * // Include soft-deleted users
 * const allUsers = await findUserById(userId, { includeDeleted: true });
 * ```
 * 
 * @see {@link User} for the User model structure
 * @see {@link https://docs.example.com/user-management|User Management Guide}
 * 
 * @since 1.2.0
 * @deprecated Use findUserByIdV2() instead. This method will be removed in v3.0.
 */
async function findUserById(
  userId: string,
  options: { includeDeleted?: boolean; limit?: number } = {}
): Promise<User> {
  // Implementation...
}
```

### JSDoc Tags Reference

| Tag | Purpose | Example |
|-----|---------|---------|
| `@param` | Document function parameters | `@param userId - The user's unique ID` |
| `@returns` | Document return value | `@returns Promise resolving to User object` |
| `@throws` | Document exceptions | `@throws {ValidationError} If input invalid` |
| `@example` | Provide usage examples | `@example const x = foo('bar');` |
| `@see` | Link to related documentation | `@see {@link User}` |
| `@since` | Version when added | `@since 1.2.0` |
| `@deprecated` | Mark as deprecated | `@deprecated Use newMethod() instead` |
| `@internal` | Mark as private (exclude from public docs) | `@internal` |
| `@typeParam` | Document generic type parameters | `@typeParam T - The type of items in array` |

### TypeDoc Configuration

Create `typedoc.json` in project root:

```json
{
  "$schema": "https://typedoc.org/schema.json",
  "entryPoints": ["src/index.ts"],
  "out": "docs/api",
  "plugin": ["typedoc-plugin-markdown"],
  "excludePrivate": true,
  "excludeInternal": true,
  "excludeExternals": true,
  "readme": "README.md",
  "name": "My Project API Documentation",
  "includeVersion": true,
  "categorizeByGroup": true,
  "defaultCategory": "Other",
  "categoryOrder": [
    "Core",
    "Models",
    "Services",
    "Utilities",
    "*"
  ],
  "sort": ["source-order"],
  "validation": {
    "notExported": true,
    "invalidLink": true,
    "notDocumented": true
  }
}
```

### Generating TypeDoc

```bash
# Install TypeDoc
npm install --save-dev typedoc typedoc-plugin-markdown

# Generate HTML documentation
npx typedoc

# Generate Markdown documentation
npx typedoc --plugin typedoc-plugin-markdown

# Watch mode (regenerate on file changes)
npx typedoc --watch
```

## API Documentation Standards

### REST API Endpoint Documentation

For each API endpoint, document using this template:

```markdown
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

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_FAILED` | Request body failed validation |
| 400 | `EMAIL_ALREADY_EXISTS` | Email is already registered |
| 401 | `UNAUTHORIZED` | Missing or invalid authentication token |
| 403 | `FORBIDDEN` | Valid token but lacks required permissions |
| 500 | `INTERNAL_SERVER_ERROR` | Unexpected server error |

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
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    email: 'alice@example.com',
    name: 'Alice Johnson',
    role: 'admin'
  })
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
```

### OpenAPI/Swagger Integration

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
```

Generate docs with Redoc or Swagger UI:

```bash
# Generate static HTML with Redoc
npx redoc-cli bundle openapi.yaml -o docs/api.html

# Serve interactive Swagger UI
npx swagger-ui-watcher openapi.yaml
```

## Architecture Decision Records (ADRs)

### MADR Template (Markdown ADR)

Use the MADR format for all architectural decisions:

```markdown
# ADR-001: Use PostgreSQL for Primary Database

## Status
Accepted

## Context

We need to choose a primary database for our SaaS application. Key requirements:
- **Data model**: Relational data (users, organizations, subscriptions, billing)
- **Transactions**: ACID compliance for billing operations
- **Scale**: Expected 100k users in first year, 1M within 3 years
- **Query patterns**: Complex joins for analytics dashboards
- **Budget**: Prefer open-source to minimize licensing costs
- **Team expertise**: Team has PostgreSQL experience from previous projects

## Decision

We will use **PostgreSQL 15** as the primary database for all application data.

## Consequences

### Positive
- **ACID compliance**: Strong consistency for billing and financial transactions
- **Rich data types**: JSON support for flexible schema evolution
- **Mature ecosystem**: Extensive tooling (pgAdmin, DataGrip, pg_stat_statements)
- **Open source**: No licensing fees, large community support
- **Performance**: Proven scalability to millions of rows with proper indexing
- **Team familiarity**: No learning curve, can start development immediately

### Negative
- **Vertical scaling limits**: Eventually will need read replicas or sharding
- **Operational complexity**: Requires database administration expertise
- **No native multi-region**: Need to implement replication manually (vs. DynamoDB global tables)

### Neutral
- **Hosting**: Will use AWS RDS for managed hosting (automated backups, patches)
- **Migration path**: Can migrate to CockroachDB or YugabyteDB for global scale if needed
- **ORM**: Will use Sequelize for TypeScript type safety

## Alternatives Considered

### MySQL
- **Pros**: Similar to PostgreSQL, widely used
- **Cons**: Weaker JSON support, less robust for complex queries, licensing concerns (Oracle)
- **Rejected**: PostgreSQL offers better feature set with no licensing risk

### MongoDB
- **Pros**: Flexible schema, horizontal scaling
- **Cons**: No ACID transactions (until v4.0), complex joins are inefficient, higher operational overhead
- **Rejected**: Our data is highly relational; MongoDB would require complex application-level joins

### DynamoDB
- **Pros**: Fully managed, auto-scaling, multi-region
- **Cons**: No joins, expensive for analytics queries, vendor lock-in to AWS
- **Rejected**: Query patterns require complex joins that DynamoDB cannot support efficiently

## References
- [PostgreSQL Documentation](https://www.postgresql.org/docs/15/)
- [Sequelize ORM](https://sequelize.org/)
- [AWS RDS PostgreSQL](https://aws.amazon.com/rds/postgresql/)

## Decision Date
2024-01-15

## Decision Makers
- Sarah Chen (Product Manager)
- Marcus Rodriguez (Engineering Lead)
- David Kim (CTO)

## Review Date
2025-01-15 (annual review)
```

### ADR Storage and Naming

- **Location**: `docs/decisions/` or `docs/adr/`
- **Naming**: `ADR-NNN-short-title.md` (e.g., `ADR-001-use-postgresql.md`)
- **Numbering**: Sequential (001, 002, 003...)
- **Index**: Maintain `docs/decisions/README.md` with table of all ADRs

**Example ADR Index:**

```markdown
# Architecture Decision Records

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-001](./ADR-001-use-postgresql.md) | Use PostgreSQL for Primary Database | Accepted | 2024-01-15 |
| [ADR-002](./ADR-002-jwt-authentication.md) | Use JWT for Authentication | Accepted | 2024-01-20 |
| [ADR-003](./ADR-003-react-frontend.md) | Use React for Frontend Framework | Accepted | 2024-01-22 |
| [ADR-004](./ADR-004-monorepo-structure.md) | Use Monorepo with Turborepo | Proposed | 2024-01-25 |
| [ADR-005](./ADR-005-graphql-api.md) | Use GraphQL for API | Rejected | 2024-01-28 |
```

### ADR Lifecycle

```
Proposed → Accepted → Deprecated → Superseded
           ↓
        Rejected
```

- **Proposed**: Under discussion, not yet implemented
- **Accepted**: Decision made, implementation in progress or complete
- **Deprecated**: Still in use but discouraged for new work
- **Superseded**: Replaced by a newer ADR (link to successor)
- **Rejected**: Considered but not adopted

When superseding an ADR, update both:

```markdown
# ADR-001: Use REST API

## Status
~~Accepted~~ **Superseded by [ADR-015](./ADR-015-use-graphql.md)**

[Rest of ADR content...]
```

## README Structure

### Project README Template

```markdown
# Project Name

> One-sentence description of what this project does

[![CI Status](https://img.shields.io/github/workflow/status/org/repo/CI)](https://github.com/org/repo/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/npm/v/package-name)](https://www.npmjs.com/package/package-name)

## Overview

2-3 paragraph explanation:
1. What problem does this solve?
2. Who is this for?
3. What makes this different/better than alternatives?

## Features

- ✅ **Feature 1**: Brief explanation of value
- ✅ **Feature 2**: Brief explanation of value
- ✅ **Feature 3**: Brief explanation of value
- 🚧 **Upcoming**: Feature in development

## Quick Start

### Prerequisites

- Node.js 20+ and npm 10+
- PostgreSQL 15+
- (Optional) Docker for local development

### Installation

```bash
# Clone the repository
git clone https://github.com/org/repo.git
cd repo

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Run database migrations
npm run migrate

# Start development server
npm run dev
```

Visit http://localhost:3000 to see the app running.

## Usage

### Basic Example

```typescript
import { createUser } from './user-service';

const user = await createUser({
  email: 'alice@example.com',
  name: 'Alice Johnson'
});

console.log(user.id); // '123e4567-e89b-12d3-a456-426614174000'
```

### Advanced Example

```typescript
// More complex usage example
```

## Documentation

- **[API Reference](./docs/api.md)** - Complete API documentation
- **[Architecture](./docs/architecture.md)** - System design and data flow
- **[Contributing](./CONTRIBUTING.md)** - How to contribute to this project
- **[Changelog](./CHANGELOG.md)** - Version history and release notes

## Configuration

Environment variables:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | Yes | - | PostgreSQL connection string |
| `JWT_SECRET` | Yes | - | Secret key for signing JWTs |
| `PORT` | No | `3000` | HTTP server port |
| `NODE_ENV` | No | `development` | Environment (development, production) |

## Development

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

### Code Quality

```bash
# Lint code
npm run lint

# Format code
npm run format

# Type check
npm run typecheck
```

### Database Migrations

```bash
# Create a new migration
npm run migrate:create -- --name add-users-table

# Run pending migrations
npm run migrate

# Rollback last migration
npm run migrate:rollback
```

## Deployment

### Production Build

```bash
npm run build
npm start
```

### Docker

```bash
docker build -t my-app .
docker run -p 3000:3000 my-app
```

### Environment Variables

Set these in your production environment:
- `DATABASE_URL`
- `JWT_SECRET`
- `NODE_ENV=production`

## Troubleshooting

### Common Issues

**Issue**: Database connection fails  
**Solution**: Check `DATABASE_URL` is set correctly. Ensure PostgreSQL is running.

**Issue**: Tests fail with "Cannot find module"  
**Solution**: Run `npm install` to ensure all dependencies are installed.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## License

MIT © [Organization Name](https://example.com)

## Support

- **Documentation**: https://docs.example.com
- **Issues**: https://github.com/org/repo/issues
- **Discussions**: https://github.com/org/repo/discussions
- **Email**: support@example.com
```

## Component/Module Documentation

### Module Documentation Template

For each significant module or service:

```markdown
# UserService

Handles all user-related operations including creation, retrieval, updating, and deletion (CRUD).

## Purpose

The UserService encapsulates business logic for user management, providing a clean interface for controllers and other services to interact with user data without directly accessing the database.

## Dependencies

- **User Model** (`src/models/User.ts`) - Database model for users
- **EmailService** (`src/services/EmailService.ts`) - For sending verification emails
- **Logger** (`src/utils/logger.ts`) - For logging events

## API

### createUser(data: CreateUserData): Promise<User>

Creates a new user account.

**Parameters:**
- `data.email` (string, required) - User's email address (must be unique)
- `data.name` (string, required) - User's full name
- `data.role` (string, optional) - User's role (default: 'user')

**Returns:**
Promise resolving to the created User object.

**Throws:**
- `ValidationError` - If email is invalid or name is too short
- `ConflictError` - If email is already registered
- `DatabaseError` - If database operation fails

**Example:**
```typescript
const user = await userService.createUser({
  email: 'alice@example.com',
  name: 'Alice Johnson',
  role: 'admin'
});
```

### findUserById(userId: string): Promise<User | null>

Retrieves a user by their unique ID.

**Parameters:**
- `userId` (string, required) - UUID of the user

**Returns:**
Promise resolving to User object if found, null otherwise.

**Example:**
```typescript
const user = await userService.findUserById('123e4567-e89b-12d3-a456-426614174000');
if (user) {
  console.log(user.email);
}
```

## Usage Patterns

### Basic CRUD Operations

```typescript
import { userService } from './services/UserService';

// Create
const newUser = await userService.createUser({
  email: 'alice@example.com',
  name: 'Alice Johnson'
});

// Read
const user = await userService.findUserById(newUser.id);

// Update
const updated = await userService.updateUser(user.id, { name: 'Alice Smith' });

// Delete
await userService.deleteUser(user.id);
```

### Error Handling

```typescript
try {
  const user = await userService.createUser({ email: 'invalid-email', name: 'Test' });
} catch (error) {
  if (error instanceof ValidationError) {
    console.error('Invalid input:', error.message);
  } else if (error instanceof ConflictError) {
    console.error('Email already exists');
  } else {
    console.error('Unexpected error:', error);
  }
}
```

## Testing

### Unit Tests

```typescript
import { userService } from './UserService';
import { User } from '../models/User';

describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid data', async () => {
      const user = await userService.createUser({
        email: 'test@example.com',
        name: 'Test User'
      });
      
      expect(user.email).toBe('test@example.com');
      expect(user.name).toBe('Test User');
      expect(user.role).toBe('user'); // default
    });
    
    it('should throw ValidationError for invalid email', async () => {
      await expect(
        userService.createUser({ email: 'invalid', name: 'Test' })
      ).rejects.toThrow(ValidationError);
    });
  });
});
```

## Architecture

### Data Flow

```
Controller → UserService → User Model → PostgreSQL
                ↓
          EmailService → SendGrid
```

1. Controller receives HTTP request
2. UserService validates business logic
3. User Model persists to database
4. EmailService sends verification email (async)
5. Response returned to controller

### Dependencies Diagram

```
UserService
├── User (model)
├── EmailService
├── Logger
└── ValidationUtils
```

## Configuration

No specific configuration required. Uses application-wide database and email settings.

## Changelog

### v1.2.0 (2024-01-15)
- Added `findUsersByRole()` method
- Improved error messages for validation failures

### v1.1.0 (2024-01-10)
- Added soft delete functionality
- Deprecated `deleteUser()` in favor of `softDeleteUser()`

### v1.0.0 (2024-01-01)
- Initial release with basic CRUD operations
```

## Auto-Documentation in CI/CD

### GitHub Actions Workflow

Create `.github/workflows/docs.yml`:

```yaml
name: Generate and Deploy Documentation

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  docs:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Generate TypeDoc
        run: npx typedoc --out docs/api src/index.ts
      
      - name: Generate OpenAPI docs
        run: npx redoc-cli bundle openapi.yaml -o docs/api-reference.html
      
      - name: Validate documentation
        run: |
          # Check for broken links
          npx markdown-link-check docs/**/*.md
          
          # Validate OpenAPI spec
          npx @redocly/cli lint openapi.yaml
      
      - name: Deploy to GitHub Pages
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs
          cname: docs.example.com
```

### Pre-Commit Hook for Documentation

Create `.husky/pre-commit`:

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

# Regenerate TypeDoc before committing
npm run docs:generate

# Add generated docs to commit
git add docs/api

# Validate JSDoc comments
npm run docs:lint
```

## Documentation Quality Checklist

Before publishing documentation, verify:

- [ ] **Accuracy**: All code examples run without errors
- [ ] **Completeness**: All public APIs are documented
- [ ] **Clarity**: Explanations are understandable to target audience
- [ ] **Links**: All internal and external links work
- [ ] **Examples**: Each major feature has a working example
- [ ] **Errors**: Common errors and solutions are documented
- [ ] **Versioning**: Documentation version matches code version
- [ ] **Review**: At least one other person has reviewed the docs
- [ ] **Accessibility**: Documentation is accessible (alt text, semantic HTML)
- [ ] **Search**: Documentation is searchable (indexed by search engine)

## Further Reading

- **Style Guide**: [Google Developer Documentation Style Guide](https://developers.google.com/style)
- **API Design**: [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines)
- **TypeDoc**: [Official TypeDoc Documentation](https://typedoc.org/)
- **OpenAPI**: [OpenAPI Specification](https://swagger.io/specification/)
- **ADRs**: [MADR (Markdown ADR) Template](https://adr.github.io/madr/)
