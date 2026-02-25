# Best Practices

## 1. Fail Fast

Run linting and type checks before expensive tests/builds:

```yaml
jobs:
  lint:
    # ...
  test:
    needs: lint # Wait for lint to pass first
```

## 2. Use Concurrency Groups

Cancel in-progress runs when new commits pushed:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

## 3. Optimize Docker Builds

```dockerfile
# Multi-stage build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

## 4. Use Build Matrix Sparingly

Matrix builds multiply cost (3 OSes x 3 Node versions = 9 builds). Only use when necessary.

## 5. Monitor Build Times

Add timing to steps:

```yaml
- name: Build
  run: time npm run build
```

## Troubleshooting

| Problem                                 | Solution                                                                               |
| --------------------------------------- | -------------------------------------------------------------------------------------- |
| **Cache miss every build**              | Verify cache key uses correct lock file hash                                           |
| **iOS build fails on Linux**            | iOS requires `macos-latest` runner                                                     |
| **Secrets not available in PR**         | PRs from forks can't access secrets; use `pull_request_target` cautiously              |
| **EAS Build queue slow**                | Use `--non-interactive`, consider priority plan, or self-host with `eas build --local` |
| **Deployment fails silently**           | Add `set -e` to fail on first error in bash scripts                                    |
| **Environment variables not available** | Check if using `env:` at step level vs job level                                       |

## Further Reading

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [EAS Build Documentation](https://docs.expo.dev/build/introduction/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Vercel CLI Documentation](https://vercel.com/docs/cli)
- [AWS OIDC Configuration](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
