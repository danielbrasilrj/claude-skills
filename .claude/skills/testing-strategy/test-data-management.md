# Test Data Management

## Factories (preferred over fixtures)

```typescript
// test/factories/user.ts
import { faker } from '@faker-js/faker';

export function buildUser(overrides: Partial<User> = {}): User {
  return {
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName(),
    role: 'user',
    createdAt: new Date(),
    ...overrides,
  };
}

// Usage
const admin = buildUser({ role: 'admin' });
const users = Array.from({ length: 5 }, () => buildUser());
```

## Seed Scripts for E2E

```typescript
// test/seed.ts
export async function seedTestData(db: Database) {
  const user = await db.users.create(buildUser({ email: 'e2e@test.com' }));
  const product = await db.products.create(buildProduct({ price: 29.99 }));
  return { user, product };
}
```
