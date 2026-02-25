# Mock Server Setup

## Prism (Standalone Mock Server)

**Installation**

```bash
npm install -g @stoplight/prism-cli
```

**Basic Usage**

```bash
# Mock server on port 4010
prism mock openapi.yaml --port 4010

# Validate responses against spec (strict mode)
prism mock openapi.yaml --port 4010 --errors

# Dynamic response based on examples
prism mock openapi.yaml --dynamic
```

**Example-based Responses**
Prism returns examples from your spec:

```yaml
paths:
  /users/{id}:
    get:
      responses:
        '200':
          content:
            application/json:
              examples:
                john:
                  value:
                    id: '1'
                    name: 'John Doe'
                    email: 'john@example.com'
                jane:
                  value:
                    id: '2'
                    name: 'Jane Smith'
                    email: 'jane@example.com'
```

**Prism in Docker**

```bash
docker run --rm -it \
  -v $(pwd)/openapi.yaml:/openapi.yaml \
  -p 4010:4010 \
  stoplight/prism:4 mock -h 0.0.0.0 /openapi.yaml
```

## MSW (Mock Service Worker)

**Installation**

```bash
npm install msw --save-dev
```

**Setup for Browser**

```typescript
// src/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/v1/users/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'John Doe',
      email: 'john@example.com',
    });
  }),

  http.post('/api/v1/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: '123', ...body }, { status: 201 });
  }),

  http.get('/api/v1/users', ({ request }) => {
    const url = new URL(request.url);
    const page = url.searchParams.get('page') || '1';

    return HttpResponse.json({
      data: [
        { id: '1', name: 'John Doe' },
        { id: '2', name: 'Jane Smith' },
      ],
      pagination: {
        page: parseInt(page),
        limit: 20,
        total: 100,
        totalPages: 5,
      },
    });
  }),
];

// src/mocks/browser.ts
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);

// src/main.tsx
if (process.env.NODE_ENV === 'development') {
  const { worker } = await import('./mocks/browser');
  await worker.start();
}
```

**Setup for Node.js (Tests)**

```typescript
// src/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);

// src/setupTests.ts
import { server } from './mocks/server';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## Type-Safe MSW with openapi-msw

Generate type-safe MSW handlers from OpenAPI spec:

```bash
npm install openapi-msw --save-dev
npx openapi-msw ./openapi.yaml -o ./src/mocks/handlers.ts
```

Generated handlers have TypeScript types:

```typescript
// Auto-generated from spec
export const handlers = [
  http.get('/api/v1/users/:id', ({ params }) => {
    // params.id is typed as string
    // Response type is inferred from spec
    return HttpResponse.json({
      id: params.id,
      name: 'John Doe',
      email: 'john@example.com',
    });
  }),
];
```
