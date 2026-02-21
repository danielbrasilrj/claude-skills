# PRD: {{FEATURE_NAME}}

**Status**: Draft | Under Review | Approved | In Progress | Shipped  
**Owner**: {{PRODUCT_MANAGER_NAME}}  
**Engineering Lead**: {{ENG_LEAD_NAME}}  
**Design Lead**: {{DESIGN_LEAD_NAME}}  
**Target Ship Date**: {{YYYY-MM-DD}}  
**PRD ID**: PRD-{{XXX}}

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | {{YYYY-MM-DD}} | {{AUTHOR}} | Initial draft |

---

## Table of Contents
1. [Problem Statement](#problem-statement)
2. [User Stories](#user-stories)
3. [Acceptance Criteria](#acceptance-criteria)
4. [Technical Constraints](#technical-constraints)
5. [Out of Scope](#out-of-scope)
6. [Dependencies](#dependencies)
7. [Implementation Phases](#implementation-phases)
8. [Success Metrics](#success-metrics)
9. [Risks and Mitigations](#risks-and-mitigations)
10. [Open Questions](#open-questions)
11. [AI Implementation Context](#ai-implementation-context)

---

## Problem Statement

### Current Pain Point
{{Describe the user problem in 2-3 sentences. Focus on observable impact, not solutions.}}

**Example:**
> Support agents currently spend 15 minutes per ticket manually searching across 5 disconnected tools (Zendesk, Stripe, internal admin panel, Metabase, and AWS logs) to find complete customer order history. This context-switching overhead directly impacts agent productivity and customer satisfaction.

### User Impact
- **Who**: {{Specific user segment or role}}
- **Frequency**: {{How often they encounter this problem}}
- **Cost**: {{Quantify in time, money, or frustration}}

**Example:**
- **Who**: 200 customer support agents across 3 shifts
- **Frequency**: Every ticket (avg 50 tickets/agent/day = 10,000 tickets/day)
- **Cost**: 15 min/ticket × 10,000 tickets = 2,500 hours/day wasted on search

### Business Impact
- **Revenue**: {{Opportunity cost or direct revenue impact}}
- **Metric**: {{Which company KPI this affects}}
- **Competitive**: {{How this affects market position}}

**Example:**
- **Revenue**: $1.2M annual cost in agent time waste (2,500 hrs/day × $20/hr × 250 work days)
- **Metric**: NPS score currently 42 (target: 65). Slow responses are #1 complaint.
- **Competitive**: Competitors with unified dashboards resolve tickets 40% faster (8 min vs. 15 min average)

---

## User Stories

### Epic: {{High-level capability name}}

#### Story 1: {{Specific user action}}
**As a** {{user role}}  
**I want** {{capability}}  
**So that** {{benefit/outcome}}

**Acceptance Criteria:**
- **AC1**: {{Given/When/Then scenario}}
- **AC2**: {{Given/When/Then scenario}}
- **AC3**: {{Given/When/Then scenario}}

**Technical Context for AI:**
- **Input**: {{Data structure/format}}
- **Process**: {{Algorithm/business logic}}
- **Output**: {{Result structure/format}}
- **Dependencies**: {{What must exist first}}

---

**Example:**

### Epic: Unified Customer Search

#### Story 1: Search Customers by Email
**As a** support agent  
**I want** to search for customers by email address  
**So that** I can instantly access their complete profile without switching tools

**Acceptance Criteria:**
- **AC1**: Successful Search
  - Given a customer with email "john.doe@example.com" exists in the database
  - When I type "john.doe@example.com" into the search box
  - Then I see their customer record displayed within 300ms
  - And the email field is highlighted in yellow
  - And the search result shows their name, order count, lifetime value, and last interaction date

- **AC2**: Partial Match
  - Given a customer with email "john.doe@example.com" exists
  - When I type "john.doe" (without full email)
  - Then I see all customers matching that prefix (max 10 results)
  - And results are sorted by most recent activity first

- **AC3**: No Results Handling
  - Given no customer matches the email "nonexistent@fake.com"
  - When I search for this email
  - Then I see the message "No customers found. Try a different search term."
  - And a "Create New Customer" button appears
  - But no error state is shown (this is a valid search, just empty results)

**Technical Context for AI:**
- **Input**: 
  ```typescript
  { 
    query: string, 
    searchType: 'email' | 'name' | 'orderId',
    limit?: number // default 10
  }
  ```
- **Process**: 
  - Use PostgreSQL full-text search with trigram index on `customers.email`
  - If query contains '@', treat as exact email match
  - If query lacks '@', treat as prefix search with ILIKE
  - Return results within 300ms (p95 latency budget)
- **Output**: 
  ```typescript
  {
    results: Customer[], 
    matchCount: number,
    durationMs: number
  }
  ```
- **Dependencies**: 
  - Database migration `2024-01-15-add-search-indexes.sql` (adds trigram index)
  - Customer model with fields: `id`, `email`, `name`, `createdAt`, `lastActivityAt`

---

#### Story 2: {{Next user story}}
{{Repeat the pattern above for each story}}

---

## Technical Constraints

### Performance Requirements
- API response time: p95 < {{X}}ms, p99 < {{Y}}ms
- Database query budget: max {{N}} queries per request
- Frontend bundle size: JavaScript < {{X}}KB gzipped
- Lighthouse Performance score: ≥ {{N}}

**Example:**
- API response time: p95 < 500ms, p99 < 1000ms
- Database query budget: max 3 queries per search request
- Frontend bundle size: Search feature adds < 50KB gzipped to main bundle
- Lighthouse Performance score: ≥ 90 on desktop, ≥ 80 on mobile

### Security Requirements
- Authentication: {{Method (e.g., JWT, OAuth2)}}
- Authorization: {{RBAC, ABAC, rules}}
- Data encryption: {{At rest, in transit}}
- Rate limiting: {{Requests per time window}}
- Audit logging: {{What events to log}}

**Example:**
- Authentication: JWT with RS256 signing, 24-hour token expiry
- Authorization: Agents can only search customers in their assigned region
- Data encryption: TLS 1.3 in transit, AES-256 at rest for PII fields
- Rate limiting: 100 searches per minute per agent (prevent abuse)
- Audit logging: Log all search queries with agent ID, timestamp, and query term

### Technology Stack Constraints
- **Backend**: {{Language, framework, version}}
- **Frontend**: {{Framework, version}}
- **Database**: {{Type, version, constraints}}
- **Deployment**: {{Platform, containerization}}
- **Must Use**: {{Existing libraries/services that must be reused}}
- **Must Avoid**: {{Technologies that are forbidden}}

**Example:**
- **Backend**: Node.js 20 LTS, Express 4.19.x, TypeScript 5.3+
- **Frontend**: React 18.2, TypeScript 5.3+, TanStack Query for data fetching
- **Database**: PostgreSQL 15.x, no NoSQL for transactional customer data
- **Deployment**: Docker containers on AWS ECS Fargate, deployed via GitHub Actions
- **Must Use**: Existing `AuthMiddleware` from `src/middleware/auth.ts`
- **Must Avoid**: No direct SQL queries; use Sequelize ORM for type safety

### Compliance Requirements
- {{Regulation (e.g., GDPR, HIPAA, SOC 2)}}: {{Specific requirements}}

**Example:**
- **GDPR**: Support right to erasure (delete customer on request), data export (CSV download)
- **SOC 2**: Audit log all customer data access with retention for 1 year
- **PCI-DSS**: N/A (payment processing handled by Stripe, out of scope)

---

## Out of Scope

The following features are explicitly excluded from this PRD and will NOT be implemented in this version:

### Deferred to Future Versions
{{List features that are important but not in this release}}

**Example:**
- **Advanced Filters** (Deferred to v2.0)
  - Filter by customer lifetime value range
  - Filter by signup date range
  - Filter by subscription status
  - Reason: 80% of searches are by email/name only; these add complexity without immediate value

- **Saved Searches** (Deferred to v2.1)
  - Save frequently used search queries
  - Reason: Requires additional UI complexity; wait for user demand signals

### Permanently Out of Scope
{{List features that will never be part of this feature}}

**Example:**
- **Customer Creation from Search Results**
  - Reason: Customer creation has complex validation rules and belongs in dedicated admin flow
  - Workaround: Link to existing customer creation page

### Dependencies Not Ready
{{List features blocked by other work}}

**Example:**
- **Cross-Region Search** (Blocked by Infrastructure Work)
  - Blocker: Waiting on PRD-051 (Multi-Region Database Federation)
  - Expected: Q3 2024
  - Impact: For now, agents can only search customers in their assigned region

---

## Dependencies

### Technical Dependencies
{{List systems, APIs, or infrastructure that must exist first}}

**Example:**
| Dependency | Type | Owner | Status | Blocker? |
|------------|------|-------|--------|----------|
| Customer database schema | Internal | Backend Team | ✅ Complete | No |
| Trigram search indexes | Internal | DBA Team | 🟡 In Progress | Yes (must complete by Jan 25) |
| Authentication middleware | Internal | Auth Team | ✅ Complete | No |
| AWS VPC peering (prod) | Infrastructure | DevOps | 🟡 In Progress | No (dev env ready) |

### Product Dependencies
{{List other PRDs or features that must ship first}}

**Example:**
| PRD | Feature | Relationship | Status |
|-----|---------|--------------|--------|
| PRD-042 | Organization Management | Required (need org-based permissions) | ✅ Shipped |
| PRD-049 | Audit Logging System | Required (compliance) | 🟡 In QA |

### Design Dependencies
{{List mockups, user research, or design systems needed}}

**Example:**
- ✅ High-fidelity mockups (Figma): [Link to Figma file]
- ✅ User research findings: 15 agent interviews completed
- 🟡 Design system components: SearchInput component needs dark mode variant

---

## Implementation Phases

{{Structure phases in dependency order. Each phase should be independently testable.}}

### Phase 1: Foundation (No Dependencies)
**Goal**: {{What capabilities this phase enables}}  
**Estimated Effort**: {{Story points or days}}  
**Testability**: {{How to verify this phase works in isolation}}

#### Tasks:
1. {{Task name}}
   - **File**: {{File path where this will be implemented}}
   - **Description**: {{What to build}}
   - **Inputs**: {{What data this consumes}}
   - **Outputs**: {{What data this produces}}
   - **Tests**: {{What tests to write}}

2. {{Next task}}

**Completion Criteria:**
- [ ] {{Checklist item for done}}
- [ ] {{Checklist item for done}}

**Claude Implementation Notes:**
{{Specific guidance for AI coding agent}}

---

**Example:**

### Phase 1: Database and Models (No Dependencies)
**Goal**: Searchable customer data layer  
**Estimated Effort**: 3 story points  
**Testability**: Unit tests for model queries

#### Tasks:
1. Create database migration for search indexes
   - **File**: `migrations/2024-01-25-add-customer-search-indexes.sql`
   - **Description**: Add trigram indexes on `customers.email` and `customers.name` for fast fuzzy search
   - **SQL**:
     ```sql
     CREATE EXTENSION IF NOT EXISTS pg_trgm;
     CREATE INDEX idx_customers_email_trgm ON customers USING gin (email gin_trgm_ops);
     CREATE INDEX idx_customers_name_trgm ON customers USING gin (name gin_trgm_ops);
     ```
   - **Tests**: Verify migration runs without errors in dev and staging

2. Add search methods to Customer model
   - **File**: `src/models/Customer.ts`
   - **Description**: Add static methods `searchByEmail()` and `searchByName()`
   - **Interface**:
     ```typescript
     class Customer extends Model {
       static searchByEmail(query: string, limit: number = 10): Promise<Customer[]>
       static searchByName(query: string, limit: number = 10): Promise<Customer[]>
     }
     ```
   - **Implementation**: Use Sequelize `Op.iLike` with trigram similarity
   - **Tests**: 
     - Unit test: searchByEmail("john@") returns matching customers
     - Unit test: searchByName("John") returns fuzzy matches (e.g., "Jon", "Johnn")
     - Performance test: queries complete in < 100ms for 1M customer dataset

**Completion Criteria:**
- [ ] Migration runs successfully in dev and staging environments
- [ ] Customer.searchByEmail() returns results sorted by relevance
- [ ] Customer.searchByName() handles partial matches
- [ ] Unit tests achieve 100% coverage on search methods
- [ ] Performance tests verify < 100ms query time

**Claude Implementation Notes:**
- Use Sequelize v6 TypeScript definitions for type safety
- Apply `.toLowerCase()` to search queries before matching (case-insensitive)
- Limit results to 10 by default to prevent slow queries on large result sets
- Sort results by `similarity(email, :query) DESC` using PostgreSQL trigram similarity function

---

### Phase 2: API and Business Logic (Depends on Phase 1)
{{Continue the pattern for subsequent phases}}

---

### Phase 3: Frontend UI (Depends on Phase 2)
{{Continue the pattern}}

---

### Phase 4: Integration and Testing (Depends on Phase 1-3)
{{Final integration phase}}

---

## Success Metrics

{{Use the Goals/Signals/Metrics framework}}

### Goal 1: {{Business objective}}
**Signal**: {{Observable user behavior}}  
**Metrics**:
- **Leading**: {{Early indicator}} (target: {{value}})
- **Lagging**: {{Final outcome}} (target: {{value}})  
**Measurement**: {{How/where to track this}}

---

**Example:**

### Goal 1: Reduce Support Ticket Resolution Time
**Signal**: Agents find customer context faster  
**Metrics**:
- **Leading**: Average searches per ticket (target: ≤ 2, down from 5)
- **Lagging**: Mean ticket resolution time (target: 12 minutes, down from 15 minutes)  
**Measurement**: Track search events in PostHog, correlate with ticket close times from Zendesk API

### Goal 2: Increase Agent Adoption
**Signal**: Agents prefer unified search over old tools  
**Metrics**:
- **Survey**: Agent NPS on search feature (target: ≥ 50)
- **Behavioral**: 80% of agents use search ≥10 times/day within 30 days of launch  
**Measurement**: Quarterly agent survey + usage analytics from application logs

### Goal 3: Maintain System Performance Under Load
**Signal**: Search remains fast even during peak hours  
**Metrics**:
- **p95 latency**: < 300ms (monitor 24/7)
- **Error rate**: < 0.1% of search requests
- **Uptime**: 99.9% availability  
**Measurement**: DataDog APM monitoring with PagerDuty alerts on threshold breach

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| {{Risk description}} | High/Med/Low | High/Med/Low | {{How to prevent or reduce}} |

**Example:**
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Database query performance degrades with 10M+ customers | Medium | High | Implement query result caching (Redis, 5 min TTL); add database read replicas |
| Agents bypass new search and continue using old tools | Medium | High | Sunset old tools 30 days after launch; provide training sessions |
| Trigram indexes consume excessive disk space | Low | Medium | Monitor index size weekly; add index cleanup job if > 20% of table size |
| Search exposes customer PII to unauthorized agents | Low | Critical | Implement row-level security in PostgreSQL based on agent region; audit log all searches |

---

## Open Questions

{{List unresolved questions that need answers before or during implementation}}

- [ ] **Q1**: {{Question}}
  - **Owner**: {{Who will answer this}}
  - **Deadline**: {{When we need the answer}}
  - **Impact if unresolved**: {{What happens if we don't answer this}}

**Example:**
- [ ] **Q1**: Should search include soft-deleted customers?
  - **Owner**: Product Manager + Legal Team
  - **Deadline**: Jan 20 (before Phase 1 completion)
  - **Impact if unresolved**: May violate GDPR right to erasure if deleted customers appear in results

- [ ] **Q2**: What happens if an agent searches for a customer in a different region?
  - **Owner**: Engineering Lead + Product Manager
  - **Deadline**: Jan 22 (before Phase 2)
  - **Impact if unresolved**: May expose data across regions, violating data residency requirements

---

## AI Implementation Context

{{This section provides structured guidance for AI coding agents like Claude}}

### Architecture Overview
{{High-level system design}}

**Example:**
```
┌─────────────┐
│   Browser   │
│  (React UI) │
└──────┬──────┘
       │ HTTPS
       ▼
┌─────────────────────────────┐
│   API Gateway (Express)     │
│   - Authentication          │
│   - Rate Limiting           │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│  CustomerSearchService      │
│  - Input validation         │
│  - Query orchestration      │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│  Customer Model (Sequelize) │
│  - searchByEmail()          │
│  - searchByName()           │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│  PostgreSQL 15              │
│  - customers table          │
│  - trigram indexes          │
└─────────────────────────────┘
```

### Component Specifications

#### Component 1: {{Name}}
**Purpose**: {{What this component does}}  
**File Location**: {{Path}}  
**Dependencies**: {{Other components/libraries}}

**Interface**:
```typescript
{{Type definitions}}
```

**Business Logic**:
1. {{Step 1}}
2. {{Step 2}}
3. {{Step 3}}

**Error Handling**:
- {{Error case 1}}: {{How to handle}}
- {{Error case 2}}: {{How to handle}}

**Testing Requirements**:
- {{Test type}}: {{Test scenario}}

---

**Example:**

#### Component 1: CustomerSearchService
**Purpose**: Orchestrates customer search logic, applies authorization rules, and formats results  
**File Location**: `src/services/CustomerSearchService.ts`  
**Dependencies**: 
- `src/models/Customer.ts` (database queries)
- `src/middleware/auth.ts` (agent authentication)
- `src/utils/logger.ts` (audit logging)

**Interface**:
```typescript
export interface SearchParams {
  query: string;
  searchType: 'email' | 'name' | 'orderId';
  agentId: string;
  agentRegion: string;
  limit?: number;
}

export interface SearchResult {
  results: CustomerDTO[];
  matchCount: number;
  durationMs: number;
}

export class CustomerSearchService {
  async search(params: SearchParams): Promise<SearchResult>
}
```

**Business Logic**:
1. Validate `query` is not empty and is < 100 characters
2. Sanitize `query` to prevent SQL injection (trim, escape)
3. Check agent has permission to search (must be authenticated, must have 'search:customers' permission)
4. If `searchType === 'email'`, call `Customer.searchByEmail(query, limit)`
5. If `searchType === 'name'`, call `Customer.searchByName(query, limit)`
6. Filter results to only include customers in agent's region (row-level security)
7. Transform `Customer` models to `CustomerDTO` (exclude sensitive fields like SSN)
8. Log search event: `{ agentId, query, resultCount, timestamp }`
9. Return `SearchResult` with results, match count, and duration

**Error Handling**:
- Invalid query (empty or too long): Throw `ValidationError` with message "Query must be 1-100 characters"
- Agent lacks permission: Throw `AuthorizationError` with message "Insufficient permissions"
- Database timeout: Throw `DatabaseError` with message "Search timed out. Try a more specific query."
- Database connection failure: Throw `DatabaseError` with message "Service temporarily unavailable"

**Testing Requirements**:
- Unit test: Valid email search returns matching customers
- Unit test: Cross-region search is filtered (agent in US-WEST cannot see EU customers)
- Unit test: Empty query throws ValidationError
- Integration test: End-to-end search from API endpoint returns correct results
- Performance test: Search completes in < 300ms for 1M customer dataset

---

### File Structure
{{Expected directory layout after implementation}}

**Example:**
```
src/
├── models/
│   └── Customer.ts              (Phase 1)
├── services/
│   └── CustomerSearchService.ts (Phase 2)
├── controllers/
│   └── SearchController.ts      (Phase 2)
├── routes/
│   └── search.routes.ts         (Phase 2)
└── middleware/
    └── auth.ts                  (existing, reuse)

migrations/
└── 2024-01-25-add-customer-search-indexes.sql (Phase 1)

tests/
├── unit/
│   ├── Customer.test.ts         (Phase 1)
│   └── CustomerSearchService.test.ts (Phase 2)
└── integration/
    └── search-api.test.ts       (Phase 4)

frontend/
└── src/
    ├── components/
    │   ├── SearchInput.tsx      (Phase 3)
    │   └── SearchResults.tsx    (Phase 3)
    └── hooks/
        └── useCustomerSearch.ts (Phase 3)
```

---

## Appendix

### Related Documents
- Design Mockups: {{Link to Figma}}
- User Research: {{Link to research findings}}
- Technical Spec: {{Link to detailed architecture doc}}

### Glossary
- **{{Term}}**: {{Definition}}

**Example:**
- **Trigram Index**: PostgreSQL indexing technique that breaks text into 3-character sequences for fast fuzzy matching
- **Row-Level Security (RLS)**: Database feature that filters query results based on user attributes (e.g., agent region)
- **p95 Latency**: 95th percentile response time (95% of requests faster than this threshold)

---

## Approval Signatures

| Role | Name | Approval Date | Signature |
|------|------|---------------|-----------|
| Product Manager | {{Name}} | {{Date}} | ✅ |
| Engineering Lead | {{Name}} | {{Date}} | ✅ |
| Design Lead | {{Name}} | {{Date}} | ✅ |
| CTO (if required) | {{Name}} | {{Date}} | ✅ |
