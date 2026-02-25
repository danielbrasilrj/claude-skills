---
name: ci-cd-pipeline
description: CI/CD pipelines with GitHub Actions for mobile (EAS Build) and web (Vercel) apps. Includes env management and YAML templates.
---

## Purpose

CI/CD Pipeline provides ready-to-use GitHub Actions workflow templates and procedures for automating the build, test, and deploy cycle for mobile and web applications. It covers the full pipeline from PR checks through production deployment with environment management.

## When to Use

- Setting up CI/CD for a new project
- Adding automated testing to a GitHub Actions workflow
- Configuring mobile app builds (EAS Build, Fastlane)
- Setting up web deployments (Vercel, Netlify)
- Managing environment variables across dev/staging/production

## Prerequisites

- GitHub repository with Actions enabled
- For mobile: EAS CLI (`npm install -g eas-cli`) or Fastlane
- For web: Vercel CLI or Netlify CLI (optional)
- Repository secrets configured in GitHub Settings

## Procedures

### 1. Choose Pipeline Architecture

```
PR Check Pipeline:    lint → type-check → unit-tests → build
Staging Pipeline:     PR pipeline + integration-tests → deploy-staging
Production Pipeline:  staging pipeline + E2E-tests → deploy-production
```

### 2. Set Up GitHub Secrets

Required secrets (configure in Settings → Secrets):

- `EXPO_TOKEN` — EAS Build authentication
- `APPLE_ID` / `APP_STORE_CONNECT_KEY` — iOS distribution
- `PLAY_STORE_SERVICE_ACCOUNT` — Android distribution
- `VERCEL_TOKEN` — Web deployment (if using Vercel)

### 3. Implement Caching

Always cache dependencies to reduce build times. See [caching-strategies.md](caching-strategies.md) for Node.js, Gradle, CocoaPods, and Docker caching.

```yaml
- uses: actions/cache@v4
  with:
    path: |
      node_modules
      ~/.cache/yarn
    key: ${{ runner.os }}-node-${{ hashFiles('**/yarn.lock') }}
    restore-keys: ${{ runner.os }}-node-
```

### 4. Mobile Pipeline Key Points

See [mobile-patterns.md](mobile-patterns.md) for complete EAS Build, Fastlane, and Android workflow templates.

- iOS builds require `macos-latest` runners (more expensive)
- Use EAS Build profiles: `development`, `preview`, `production`
- Fastlane Match for shared code signing certificates
- OTA updates via EAS Update for non-native changes

### 5. Web Pipeline Key Points

See [web-patterns.md](web-patterns.md) for Vercel, Netlify, and AWS S3+CloudFront workflows.

- Vercel auto-deploys on push (preview for PRs, production for main)
- Set up branch-based deployment rules
- Environment variables injected at build time via platform settings

### 6. Environment Strategy

| Branch      | Environment | Deployment               |
| ----------- | ----------- | ------------------------ |
| `feature/*` | —           | PR checks only           |
| `develop`   | Development | Auto-deploy to dev       |
| `staging`   | Staging     | Auto-deploy to staging   |
| `main`      | Production  | Manual approval + deploy |

## Templates

- `templates/github-actions-mobile.yml` — Mobile CI/CD workflow
- `templates/github-actions-web.yml` — Web CI/CD workflow
- `templates/eas-config.json` — EAS Build configuration

## Examples

- `examples/full-pipeline-example.md` — Complete pipeline walkthrough

## Chaining

| Chain With             | Purpose                                          |
| ---------------------- | ------------------------------------------------ |
| `domain-intelligence`  | Check deployment targets and hosting constraints |
| `testing-strategy`     | Define which tests run at each pipeline stage    |
| `secret-management`    | Configure secrets for CI/CD                      |
| `code-review`          | Add automated review checks to pipeline          |
| `api-contract-testing` | Add contract validation step                     |

## Troubleshooting

| Problem                         | Solution                                                                  |
| ------------------------------- | ------------------------------------------------------------------------- |
| iOS build fails on Linux runner | iOS requires `macos-latest`; check `runs-on`                              |
| Cache miss every build          | Verify cache key uses correct lock file hash                              |
| EAS Build queue slow            | Use `--non-interactive` flag; consider priority plan                      |
| Secrets not available in PR     | PRs from forks can't access secrets; use `pull_request_target` cautiously |

## References

- [github-actions-fundamentals.md](github-actions-fundamentals.md) — Workflow structure, runner types, event triggers, and matrix builds
- [caching-strategies.md](caching-strategies.md) — Node.js, Gradle, CocoaPods, and Docker layer caching
- [secrets-management.md](secrets-management.md) — Repository secrets, environment secrets, and OIDC for cloud deployments
- [mobile-patterns.md](mobile-patterns.md) — EAS Build, Fastlane, and Android Gradle workflow templates
- [web-patterns.md](web-patterns.md) — Vercel, Netlify, and AWS S3+CloudFront deployment workflows
- [environment-management.md](environment-management.md) — Branch-based deployment strategy, env vars, and complete pipeline example
- [best-practices.md](best-practices.md) — Fail fast, concurrency groups, Docker optimization, troubleshooting, and further reading
