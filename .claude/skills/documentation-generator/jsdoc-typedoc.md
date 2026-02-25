# JSDoc and TypeDoc Standards

## Core Principles

### Documentation as Code

Documentation should be:

- **Version Controlled**: Stored in git alongside code
- **Reviewed**: Subject to the same review process as code
- **Tested**: Validated for accuracy (links, code examples, API contracts)
- **Automated**: Generated from source code where possible

### Audience-First Writing

Every document must clearly define its audience and optimize for their needs:

| Audience              | Documentation Type        | Focus                                          |
| --------------------- | ------------------------- | ---------------------------------------------- |
| End Users             | User Guides, Tutorials    | Task completion, examples, troubleshooting     |
| Developers (Internal) | README, Architecture Docs | Setup, contribution guidelines, system design  |
| Developers (External) | API Reference, SDK Docs   | Integration, authentication, error handling    |
| Stakeholders          | ADRs, RFCs                | Decision rationale, tradeoffs, business impact |

### Information Hierarchy

Structure all documentation with progressive disclosure:

1. **Quick Start** - Get to "Hello World" in < 5 minutes
2. **Core Concepts** - Mental models and key terminology
3. **How-To Guides** - Task-oriented step-by-step instructions
4. **Reference** - Comprehensive API/configuration details
5. **Deep Dives** - Architecture, design decisions, advanced topics

## JSDoc Comment Format

Use JSDoc for all public APIs, classes, functions, and complex logic:

````typescript
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
  options: { includeDeleted?: boolean; limit?: number } = {},
): Promise<User> {
  // Implementation...
}
````

## JSDoc Tags Reference

| Tag           | Purpose                                    | Example                                      |
| ------------- | ------------------------------------------ | -------------------------------------------- |
| `@param`      | Document function parameters               | `@param userId - The user's unique ID`       |
| `@returns`    | Document return value                      | `@returns Promise resolving to User object`  |
| `@throws`     | Document exceptions                        | `@throws {ValidationError} If input invalid` |
| `@example`    | Provide usage examples                     | `@example const x = foo('bar');`             |
| `@see`        | Link to related documentation              | `@see {@link User}`                          |
| `@since`      | Version when added                         | `@since 1.2.0`                               |
| `@deprecated` | Mark as deprecated                         | `@deprecated Use newMethod() instead`        |
| `@internal`   | Mark as private (exclude from public docs) | `@internal`                                  |
| `@typeParam`  | Document generic type parameters           | `@typeParam T - The type of items in array`  |

## TypeDoc Configuration

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
  "categoryOrder": ["Core", "Models", "Services", "Utilities", "*"],
  "sort": ["source-order"],
  "validation": {
    "notExported": true,
    "invalidLink": true,
    "notDocumented": true
  }
}
```

## Generating TypeDoc

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
