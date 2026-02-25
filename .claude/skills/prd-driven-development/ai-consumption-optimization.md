# AI Consumption Optimization

## Explicit Context Sections

Include an "AI Implementation Context" section for each major component:

````markdown
## AI Implementation Context

### Component: UserAuthenticationService

**Purpose**: Validate credentials and generate JWT tokens

**File Location**: `src/services/auth/UserAuthenticationService.ts`

**Dependencies**:

- `src/models/User.ts` (User model)
- `src/utils/jwt.ts` (token generation)
- `bcrypt` package for password comparison

**Interface**:

```typescript
interface AuthService {
  authenticate(email: string, password: string): Promise<AuthResult>;
}

type AuthResult =
  | { success: true; token: string; user: UserDTO }
  | { success: false; error: 'INVALID_CREDENTIALS' | 'ACCOUNT_LOCKED' };
```
````

**Business Logic**:

1. Normalize email to lowercase
2. Query User.findByEmail(email)
3. If not found, return INVALID_CREDENTIALS (no early return to prevent timing attacks)
4. Compare password with bcrypt.compare(password, user.password_hash)
5. If invalid, return INVALID_CREDENTIALS
6. If valid, generate JWT with payload { userId: user.id, email: user.email }
7. Update user.last_login to current timestamp
8. Return success with token and sanitized user object (exclude password_hash)

**Security Constraints**:

- Use constant-time comparison to prevent timing attacks
- Log all authentication attempts (success/failure) for audit
- Rate limit: max 5 attempts per email per 15 minutes

**Testing Requirements**:

- Unit test: valid credentials -> returns token
- Unit test: invalid password -> returns error
- Unit test: non-existent email -> returns error (same timing as invalid password)
- Integration test: token can be verified and contains correct payload

````

## Dependency Graphs

For complex features, include a visual dependency graph:

```markdown
## Component Dependency Graph

````

+-----------------------+
| Database Schema | (Phase 1)
+-----------+-----------+
|
+----------+-----------+
| | |
+-----v----+ +--v--------+ |
| Models | | Indexes | | (Phase 1)
+-----+----+ +-----------+ |
| |
+-----v-----------+ |
| Auth Service | | (Phase 2)
+-----+-----------+ |
| |
+-----v-----------+ |
| Middleware | | (Phase 2)
+-----+-----------+ |
| |
+---------------------+
|
+-----v-----------+
| API Routes | (Phase 3)
+-----+-----------+
|
+-----v-----------+
| UI Components | (Phase 4)
+-----------------+

```

This graph indicates Claude should implement:
- Phase 1 first (no dependencies)
- Phase 2 after Phase 1 completes
- Phase 3 after Phase 2 completes
- Phase 4 last (depends on all previous phases)
```
