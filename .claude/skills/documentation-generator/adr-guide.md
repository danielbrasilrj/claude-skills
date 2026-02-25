# Architecture Decision Records (ADRs)

## MADR Template (Markdown ADR)

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

## ADR Storage and Naming

- **Location**: `docs/decisions/` or `docs/adr/`
- **Naming**: `ADR-NNN-short-title.md` (e.g., `ADR-001-use-postgresql.md`)
- **Numbering**: Sequential (001, 002, 003...)
- **Index**: Maintain `docs/decisions/README.md` with table of all ADRs

**Example ADR Index:**

```markdown
# Architecture Decision Records

| ADR                                        | Title                               | Status   | Date       |
| ------------------------------------------ | ----------------------------------- | -------- | ---------- |
| [ADR-001](./ADR-001-use-postgresql.md)     | Use PostgreSQL for Primary Database | Accepted | 2024-01-15 |
| [ADR-002](./ADR-002-jwt-authentication.md) | Use JWT for Authentication          | Accepted | 2024-01-20 |
| [ADR-003](./ADR-003-react-frontend.md)     | Use React for Frontend Framework    | Accepted | 2024-01-22 |
| [ADR-004](./ADR-004-monorepo-structure.md) | Use Monorepo with Turborepo         | Proposed | 2024-01-25 |
| [ADR-005](./ADR-005-graphql-api.md)        | Use GraphQL for API                 | Rejected | 2024-01-28 |
```

## ADR Lifecycle

```
Proposed -> Accepted -> Deprecated -> Superseded
             |
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
