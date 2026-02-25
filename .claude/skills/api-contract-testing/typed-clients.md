# Typed Client Generation

## openapi-typescript

**Installation**

```bash
npm install openapi-typescript --save-dev
```

**Generate Types**

```bash
npx openapi-typescript ./openapi.yaml -o ./src/api/schema.d.ts
```

**Usage with fetch**

```typescript
import type { paths } from './api/schema';

type GetUserResponse =
  paths['/users/{id}']['get']['responses']['200']['content']['application/json'];
type CreateUserRequest = paths['/users']['post']['requestBody']['content']['application/json'];

async function getUser(id: string): Promise<GetUserResponse> {
  const response = await fetch(`/api/v1/users/${id}`);
  return response.json();
}

async function createUser(data: CreateUserRequest): Promise<GetUserResponse> {
  const response = await fetch('/api/v1/users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  return response.json();
}
```

**Usage with openapi-fetch (recommended)**

```bash
npm install openapi-fetch
```

```typescript
import createClient from 'openapi-fetch';
import type { paths } from './api/schema';

const client = createClient<paths>({ baseUrl: '/api/v1' });

// Fully typed requests and responses
const { data, error } = await client.GET('/users/{id}', {
  params: { path: { id: '123' } },
});

const { data: newUser, error: createError } = await client.POST('/users', {
  body: {
    name: 'John Doe',
    email: 'john@example.com',
  },
});
```

## Orval (Full Client Generator)

**Installation**

```bash
npm install orval --save-dev
```

**Configuration**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  petstore: {
    input: './openapi.yaml',
    output: {
      mode: 'tags-split',
      target: './src/api/generated',
      client: 'react-query',
      prettier: true,
      override: {
        mutator: {
          path: './src/api/client.ts',
          name: 'customClient',
        },
      },
    },
  },
});
```

**Custom Client**

```typescript
// src/api/client.ts
import axios, { AxiosRequestConfig } from 'axios';

export const customClient = <T>(config: AxiosRequestConfig): Promise<T> => {
  const source = axios.CancelToken.source();
  const promise = axios({
    ...config,
    baseURL: '/api/v1',
    cancelToken: source.token,
  }).then(({ data }) => data);

  // @ts-ignore
  promise.cancel = () => source.cancel('Query was cancelled');

  return promise;
};
```

**Generate Client**

```bash
npx orval
```

**Generated React Query Hooks**

```typescript
// Auto-generated
import { useGetUsers, useCreateUser } from './api/generated'

function UserList() {
  const { data, isLoading } = useGetUsers({ page: 1, limit: 20 })
  const createUser = useCreateUser()

  const handleCreate = () => {
    createUser.mutate({
      name: 'John Doe',
      email: 'john@example.com'
    })
  }

  if (isLoading) return <div>Loading...</div>

  return (
    <div>
      {data?.data.map(user => (
        <div key={user.id}>{user.name}</div>
      ))}
      <button onClick={handleCreate}>Create User</button>
    </div>
  )
}
```

## Tooling Ecosystem

| Tool                   | Purpose                   | Best For                                  |
| ---------------------- | ------------------------- | ----------------------------------------- |
| **Prism**              | Mock server               | Standalone development, quick prototyping |
| **MSW**                | In-app mocking            | Frontend tests, browser development       |
| **openapi-typescript** | Type generation           | Type-safe fetch clients                   |
| **openapi-fetch**      | Typed client              | Lightweight, no dependencies              |
| **Orval**              | Full client + hooks       | React Query, SWR, Axios                   |
| **Spectral**           | Spec linting              | CI validation, style enforcement          |
| **Dredd**              | Contract testing          | End-to-end contract validation            |
| **Optic**              | Breaking change detection | Prevent accidental breaking changes       |
| **Swagger UI**         | Interactive docs          | Human-readable documentation              |
| **Redoc**              | Static docs               | Beautiful documentation sites             |
