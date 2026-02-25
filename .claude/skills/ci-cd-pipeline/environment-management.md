# Environment Management

## Branch-Based Deployment Strategy

| Branch      | Environment | Auto-Deploy        | Approval Required |
| ----------- | ----------- | ------------------ | ----------------- |
| `feature/*` | --          | No, PR checks only | N/A               |
| `develop`   | Development | Yes                | No                |
| `staging`   | Staging     | Yes                | No                |
| `main`      | Production  | Yes                | Yes (recommended) |

## Environment Variables

**Build-time** (injected during build):

```yaml
- name: Build with env vars
  env:
    VITE_API_URL: https://api.example.com
    VITE_SENTRY_DSN: ${{ secrets.SENTRY_DSN }}
  run: npm run build
```

**Runtime** (loaded from server):

```javascript
// config.js (loaded at runtime)
export const config = {
  apiUrl: window.ENV.API_URL,
  sentryDsn: window.ENV.SENTRY_DSN,
};
```

## Complete Pipeline Example

```yaml
name: Full CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  # Job 1: Lint & Type Check
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check

  # Job 2: Unit Tests
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --coverage
      - name: Upload coverage
        uses: codecov/codecov-action@v4

  # Job 3: Build
  build:
    needs: [lint, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: build
          path: dist/

  # Job 4: Deploy to Staging
  deploy-staging:
    needs: build
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: build
          path: dist/
      - name: Deploy to staging
        run: echo "Deploy to staging"

  # Job 5: Deploy to Production
  deploy-production:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production # Requires approval
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: build
          path: dist/
      - name: Deploy to production
        run: echo "Deploy to production"
```
