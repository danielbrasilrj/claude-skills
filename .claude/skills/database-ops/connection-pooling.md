# Connection Pooling

## Why Connection Pooling Matters

Database connections are expensive:

- Each connection consumes ~10MB RAM on PostgreSQL
- Connection establishment takes 50-100ms
- Most databases limit connections (Supabase Free: 60 connections)

## PgBouncer Configuration

**Pool modes:**

- **Session pooling:** Client gets dedicated connection for entire session (default, safest)
- **Transaction pooling:** Connection returned after each transaction (recommended for serverless)
- **Statement pooling:** Connection returned after each statement (rarely used)

**Supabase connection strings:**

```bash
# Direct connection (limited to 60 concurrent on free tier)
postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres

# Pooled connection (supports up to 200 concurrent)
postgresql://postgres:[password]@db.[project-ref].supabase.co:6543/postgres?pgbouncer=true
```

**When to use pooled connection:**

- Serverless functions (AWS Lambda, Vercel)
- High-concurrency applications
- Short-lived connections

**When to use direct connection:**

- Long-running processes
- Migration scripts
- When using prepared statements
- When using LISTEN/NOTIFY

## Prisma Connection Pooling

```prisma
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  directUrl = env("DIRECT_DATABASE_URL") // For migrations
}
```

```bash
# .env
DATABASE_URL="postgresql://postgres:[password]@db.xxx.supabase.co:6543/postgres?pgbouncer=true"
DIRECT_DATABASE_URL="postgresql://postgres:[password]@db.xxx.supabase.co:5432/postgres"
```

```typescript
// Configure connection pool
const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
  // Connection pool settings
  connection: {
    pool_timeout: 5,
    connect_timeout: 10,
  },
});
```

## Drizzle Connection Pooling

```typescript
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';

// Pooled connection for queries
const queryClient = postgres(process.env.DATABASE_URL!, {
  max: 10, // Max connections in pool
  idle_timeout: 20, // Close idle connections after 20s
  connect_timeout: 10, // Connection timeout
});

const db = drizzle(queryClient);

// Direct connection for migrations
const migrationClient = postgres(process.env.DIRECT_DATABASE_URL!, {
  max: 1,
});
```
