# MSW (Mock Service Worker) Patterns

## Request Handler Patterns

```typescript
import { http, HttpResponse, delay } from 'msw';

// Successful response
http.get('/api/users', () => {
  return HttpResponse.json([
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' },
  ]);
});

// Error response
http.get('/api/users/:id', ({ params }) => {
  if (params.id === '999') {
    return new HttpResponse(null, { status: 404 });
  }
  return HttpResponse.json({ id: params.id, name: 'Alice' });
});

// Slow response (test loading states)
http.get('/api/slow', async () => {
  await delay(3000);
  return HttpResponse.json({ data: 'finally' });
});

// Network error (test error boundaries)
http.get('/api/unstable', () => {
  return HttpResponse.error();
});

// One-time override in a specific test
server.use(
  http.get('/api/users', () => {
    return new HttpResponse(null, { status: 500 });
  }),
);
```

## Browser Integration (for component/E2E tests)

```typescript
// src/mocks/browser.ts
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);

// Start in development or test
if (process.env.NODE_ENV === 'development') {
  worker.start({ onUnhandledRequest: 'bypass' });
}
```
