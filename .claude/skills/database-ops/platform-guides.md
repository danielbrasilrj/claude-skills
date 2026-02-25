# Platform-Specific Guides

## Supabase

### Row Level Security (RLS) Patterns

```sql
-- Enable RLS on table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read own posts
CREATE POLICY "Users can read own posts"
ON posts FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can insert own posts
CREATE POLICY "Users can insert own posts"
ON posts FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update own posts
CREATE POLICY "Users can update own posts"
ON posts FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Public read access
CREATE POLICY "Public posts are viewable"
ON posts FOR SELECT
USING (is_public = true);

-- Policy: Admin full access
CREATE POLICY "Admins have full access"
ON posts FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_id = auth.uid()
        AND role = 'admin'
    )
);
```

### RLS Performance Tips

- Always index columns used in policies: `CREATE INDEX idx_posts_user_id ON posts(user_id);`
- Avoid joins in policies (use arrays with `ANY` instead)
- Cache role checks in JWT claims when possible
- Use `SECURITY DEFINER` functions for complex authorization logic

### Supabase Realtime

```sql
-- Enable realtime on table
ALTER PUBLICATION supabase_realtime ADD TABLE posts;

-- Realtime respects RLS policies automatically
```

## Prisma

### Schema Definition

```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
}

model Post {
  id        String   @id @default(uuid())
  title     String
  content   String?
  published Boolean  @default(false)
  authorId  String
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
  @@index([published, createdAt])
}
```

### Migration Workflow

```bash
# Create migration from schema changes
npx prisma migrate dev --name add_posts_table

# Apply migration to production
npx prisma migrate deploy

# Resolve migration conflicts
npx prisma migrate resolve --applied "20260221120000_migration_name"

# Reset database (DESTRUCTIVE - dev only)
npx prisma migrate reset
```

### Common Prisma Pitfalls

- Always use `directUrl` for migrations with PgBouncer
- Use `@updatedAt` for automatic timestamp updates
- Remember `onDelete: Cascade` for foreign keys
- Use raw SQL for complex queries: `prisma.$queryRaw`

## Drizzle

### Schema Definition

```typescript
import { pgTable, uuid, text, timestamp, boolean, index } from 'drizzle-orm/pg-core';

export const users = pgTable(
  'users',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    email: text('email').notNull().unique(),
    name: text('name'),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  },
  (table) => ({
    emailIdx: index('idx_users_email').on(table.email),
  }),
);

export const posts = pgTable(
  'posts',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    title: text('title').notNull(),
    content: text('content'),
    published: boolean('published').notNull().default(false),
    authorId: uuid('author_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  },
  (table) => ({
    authorIdx: index('idx_posts_author_id').on(table.authorId),
    publishedCreatedIdx: index('idx_posts_published_created').on(table.published, table.createdAt),
  }),
);
```

### Migration Workflow

```bash
# Generate migration from schema
npx drizzle-kit generate:pg

# Apply migrations
npx drizzle-kit push:pg

# Studio for database exploration
npx drizzle-kit studio
```

## Firebase Firestore

### Security Rules Patterns

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write own document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Public read, authenticated write
    match /posts/{postId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null
        && resource.data.authorId == request.auth.uid;
    }

    // Role-based access
    match /admin/{document=**} {
      allow read, write: if request.auth != null
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Validate data structure
    match /posts/{postId} {
      allow create: if request.auth != null
        && request.resource.data.keys().hasAll(['title', 'content', 'authorId'])
        && request.resource.data.title is string
        && request.resource.data.title.size() > 0
        && request.resource.data.authorId == request.auth.uid;
    }
  }
}
```

**CRITICAL: Remove test mode before production:**

```javascript
// DANGEROUS - NEVER use in production
match /{document=**} {
  allow read, write: if true; // This is test mode, remove it!
}
```
