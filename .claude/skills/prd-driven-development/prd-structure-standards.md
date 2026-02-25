# PRD Structure Standards

## Core Principles

### 1. Dual-Audience Design

Every PRD must serve two distinct audiences simultaneously:

**Human Stakeholders**

- Clear problem framing and business justification
- Strategic alignment with company objectives
- Visual mockups and user journey narratives
- Risk assessment and mitigation strategies

**AI Coding Agents**

- Explicit dependencies and execution order
- Structured acceptance criteria (Given/When/Then)
- Precise technical constraints and specifications
- Unambiguous inputs/outputs for each component

### 2. Dependency-First Ordering

Structure all PRD sections in dependency order to prevent implementation deadlocks:

```
Foundation Layer (no dependencies)
  |
Infrastructure Layer (depends on foundation)
  |
Business Logic Layer (depends on infrastructure)
  |
Presentation Layer (depends on business logic)
  |
Integration Layer (depends on all above)
```

**Example: User Authentication Feature**

1. Database schema for users table (foundation)
2. Password hashing service (infrastructure)
3. Authentication middleware (business logic)
4. Login UI components (presentation)
5. Session management integration (integration)

### 3. Acceptance Criteria Patterns

#### Given/When/Then Format

All acceptance criteria must follow Behavior-Driven Development (BDD) syntax:

```gherkin
Given [precondition/initial context]
When [action/trigger]
Then [expected outcome]
And [additional outcome]
But [constraint/exception]
```

**Good Example:**

```
AC1: Successful Login
Given a registered user with email "user@example.com" and password "SecurePass123"
When they submit valid credentials on the login form
Then they are redirected to the dashboard at "/dashboard"
And a session cookie "auth_token" is set with 24-hour expiry
And their last login timestamp is updated in the database

AC2: Failed Login
Given an unregistered email "unknown@example.com"
When they attempt to log in
Then they see error message "Invalid credentials"
And no session cookie is created
But the login form remains visible for retry
```

**Bad Example (Avoid):**

```
- Users should be able to log in
- Password should be secure
- Dashboard should load after login
```

#### Quantifiable Success Criteria

Every acceptance criterion must be measurable:

**Good:**

- "Search results load in < 300ms for 95th percentile"
- "Password must contain >=8 characters, >=1 uppercase, >=1 number, >=1 special character"
- "Export generates CSV with all 15 required columns within 5 seconds for datasets <=10,000 rows"

**Bad:**

- "Search should be fast"
- "Password should be strong"
- "Export should work well"

### 4. Out of Scope Section

Explicitly document what is NOT included to prevent scope creep:

```markdown
## Out of Scope

The following features are explicitly excluded from this PRD and deferred to future iterations:

### Deferred to v2.0

- Social login (Google, Facebook OAuth)
- Two-factor authentication (2FA)
- Password reset via SMS

### Permanently Out of Scope

- Single Sign-On (SSO) for enterprise
  - Reason: Enterprise plan feature, different pricing tier
- Biometric authentication
  - Reason: Requires native mobile app, web-only for now

### Dependencies Not Ready

- Role-based access control (RBAC)
  - Blocker: Waiting on PRD-047 (Organization Management)
  - Expected: Q3 2024
```

## Section Templates

### Section 1: Problem Statement

```markdown
## Problem Statement

### Current Pain Point

[Describe the user problem in 2-3 sentences. Focus on impact.]

### User Impact

- **Who**: [specific user segment]
- **Frequency**: [how often they encounter this]
- **Cost**: [time/money/frustration quantified]

### Business Impact

- **Revenue**: [opportunity cost or direct revenue impact]
- **Metric**: [which KPI this affects]
- **Competitive**: [how this affects market position]

### Example

"Currently, support agents spend 15 minutes per ticket manually searching
through 5 different tools to find customer order history. This affects 200
agents handling 50 tickets/day each, resulting in 2,500 wasted hours per
month. Competitors with unified dashboards resolve tickets 40% faster,
directly impacting our NPS score (current: 42, target: 65)."
```

### Section 2: User Stories

```markdown
## User Stories

### Epic: [High-level capability]

#### Story 1: [Specific user action]

**As a** [user role]
**I want** [capability]
**So that** [benefit/outcome]

**Acceptance Criteria:**

- AC1: [Given/When/Then]
- AC2: [Given/When/Then]
- AC3: [Given/When/Then]

**Technical Context for AI:**

- **Input**: [data structure/format]
- **Process**: [algorithm/business logic]
- **Output**: [result structure/format]
- **Dependencies**: [what must exist first]
```

### Section 3: Technical Constraints

**Categories:**

1. **Performance Requirements**

   ```markdown
   - API response time: p95 < 500ms, p99 < 1000ms
   - Database query budget: max 3 queries per request
   - Bundle size: JavaScript < 200KB gzipped
   - Lighthouse score: Performance >= 90
   ```

2. **Security Requirements**

   ```markdown
   - Authentication: JWT with RS256 signing
   - Password storage: bcrypt with cost factor 12
   - HTTPS: TLS 1.3 minimum
   - CORS: Whitelist specific origins only
   - Rate limiting: 100 req/min per IP
   ```

3. **Technology Stack Constraints**

   ```markdown
   - Backend: Node.js 20 LTS, Express 4.x
   - Database: PostgreSQL 15, avoid NoSQL for transactional data
   - Frontend: React 18, TypeScript 5.x
   - Deployment: Docker containers on AWS ECS
   - Must use existing authentication middleware (src/middleware/auth.ts)
   ```

4. **Compliance Requirements**
   ```markdown
   - GDPR: Right to erasure, data export
   - SOC 2: Audit logging for all data access
   - PCI-DSS: N/A (payment processing via Stripe)
   ```

### Section 4: Implementation Phases

Structure phases in dependency order with testability checkpoints:

```markdown
## Implementation Phases

### Phase 1: Foundation (No Dependencies)

**Goal**: Database schema and core models
**Estimated Effort**: 3 story points
**Testability**: Unit tests for model validation

#### Tasks:

1. Create database migration for `users` table
   - Columns: id, email, password_hash, created_at, last_login
   - Indexes: unique on email, btree on created_at
   - Reference: schema/users-table.sql

2. Implement User model with Sequelize ORM
   - File: src/models/User.ts
   - Methods: findByEmail(), create(), updateLastLogin()
   - Validation: email format, password length

**Completion Criteria:**

- [ ] Migration runs without errors
- [ ] User.create() persists to database
- [ ] User.findByEmail() returns correct record
- [ ] Unit tests: 100% coverage on User model

**Claude Context:**

- Use Sequelize v6 TypeScript definitions
- Password field is virtual; only password_hash is stored
- Email must be lowercase normalized before storage

---

### Phase 2: Authentication Service (Depends on Phase 1)

**Goal**: Password hashing and token generation
**Estimated Effort**: 5 story points
**Testability**: Integration tests with test database

[Continue pattern...]
```

### Section 5: Success Metrics

**Framework: Goals, Signals, Metrics**

```markdown
## Success Metrics

### Goal 1: Reduce Support Ticket Resolution Time

**Signal**: Agents find customer data faster
**Metrics**:

- **Leading**: Average search queries per ticket (target: <=2)
- **Lagging**: Mean time to resolution (target: 12 min, down from 15 min)
  **Measurement**: PostHog event tracking on search interactions

### Goal 2: Increase Agent Satisfaction

**Signal**: Fewer tool-switching complaints
**Metrics**:

- **Survey**: Agent NPS on search feature (target: >=50)
- **Behavioral**: Adoption rate within 30 days (target: >=80% of agents use it)
  **Measurement**: Quarterly agent survey + usage analytics
```

## Common Pitfalls and Solutions

| Pitfall                                        | Impact                            | Solution                                          |
| ---------------------------------------------- | --------------------------------- | ------------------------------------------------- |
| Vague acceptance criteria ("should work well") | AI cannot determine completion    | Use Given/When/Then with measurable outcomes      |
| Missing dependency ordering                    | Implementation deadlocks          | Create explicit phase structure with dependencies |
| Ambiguous technical constraints                | AI makes incorrect assumptions    | Specify exact tech stack, libraries, versions     |
| No "Out of Scope" section                      | Scope creep during implementation | Explicitly list deferred and excluded features    |
| Missing error handling requirements            | Production bugs                   | Include error cases in acceptance criteria        |
| Undefined performance budgets                  | Slow, unoptimized code            | Specify latency, bundle size, query limits        |
| No traceability plan                           | Lost context between PRD and code | Include file paths, component names in PRD        |

## Template Variables Reference

When using the PRD template, replace these placeholders:

| Variable               | Description                | Example                                     |
| ---------------------- | -------------------------- | ------------------------------------------- |
| `{{FEATURE_NAME}}`     | Feature title              | "User Authentication System"                |
| `{{USER_ROLE}}`        | Primary user type          | "Support Agent", "End User"                 |
| `{{BUSINESS_METRIC}}`  | KPI to improve             | "Ticket resolution time", "Conversion rate" |
| `{{TECH_STACK}}`       | Technology constraints     | "React 18, Node.js 20, PostgreSQL 15"       |
| `{{TARGET_SHIP_DATE}}` | Expected completion        | "2024-03-15"                                |
| `{{DEPENDENCIES}}`     | Prerequisite PRDs/features | "PRD-042 (User Management)"                 |
| `{{SUCCESS_METRIC}}`   | Primary success measure    | "Reduce search time by 40%"                 |
