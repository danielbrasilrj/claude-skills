---
name: ci-cd-pipeline
description: |
  DevOps skill for setting up and maintaining CI/CD pipelines using GitHub Actions. Covers
  automated testing, building, and deploying mobile apps (EAS Build, Fastlane) and web apps
  (Vercel, Netlify). Includes environment variable management, staging vs production workflows,
  and ready-to-use YAML templates. Use when setting up CI/CD, configuring GitHub Actions,
  automating deployments, or managing build environments.
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

Always cache dependencies to reduce build times:

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

- iOS builds require `macos-latest` runners (more expensive)
- Use EAS Build profiles: `development`, `preview`, `production`
- Fastlane Match for shared code signing certificates
- OTA updates via EAS Update for non-native changes

### 5. Web Pipeline Key Points

- Vercel auto-deploys on push (preview for PRs, production for main)
- Set up branch-based deployment rules
- Environment variables injected at build time via platform settings

### 6. Environment Strategy

| Branch | Environment | Deployment |
|---|---|---|
| `feature/*` | — | PR checks only |
| `develop` | Development | Auto-deploy to dev |
| `staging` | Staging | Auto-deploy to staging |
| `main` | Production | Manual approval + deploy |

## Templates

- `templates/github-actions-mobile.yml` — Mobile CI/CD workflow
- `templates/github-actions-web.yml` — Web CI/CD workflow
- `templates/eas-config.json` — EAS Build configuration

## Examples

- `examples/full-pipeline-example.md` — Complete pipeline walkthrough

## Chaining

| Chain With | Purpose |
|---|---|
| `domain-intelligence` | Check deployment targets and hosting constraints |
| `testing-strategy` | Define which tests run at each pipeline stage |
| `secret-management` | Configure secrets for CI/CD |
| `code-review` | Add automated review checks to pipeline |
| `api-contract-testing` | Add contract validation step |

## Troubleshooting

| Problem | Solution |
|---|---|
| iOS build fails on Linux runner | iOS requires `macos-latest`; check `runs-on` |
| Cache miss every build | Verify cache key uses correct lock file hash |
| EAS Build queue slow | Use `--non-interactive` flag; consider priority plan |
| Secrets not available in PR | PRs from forks can't access secrets; use `pull_request_target` cautiously |
