# CI/CD Pipeline Reference Guide

## Introduction

This guide provides comprehensive patterns, best practices, and ready-to-use configurations for building robust CI/CD pipelines using GitHub Actions for mobile (React Native, EAS Build, Fastlane) and web (Vercel, Netlify, custom deployments) applications.

---

## GitHub Actions Fundamentals

### Workflow Structure

```yaml
name: CI/CD Pipeline
on:                          # Trigger events
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:         # Manual trigger

jobs:
  build:
    runs-on: ubuntu-latest   # Runner type
    steps:
      - uses: actions/checkout@v4    # Pre-built action
      - name: Custom step
        run: npm install             # Shell command
```

### Runner Types

| Runner | OS | Use Case | Cost |
|--------|-----|----------|------|
| `ubuntu-latest` | Linux | Most builds, tests, Docker | Free (public), $0.008/min (private) |
| `windows-latest` | Windows | .NET, Windows apps | Free (public), $0.016/min (private) |
| `macos-latest` | macOS | iOS builds, Xcode | Free (public), $0.08/min (private) |
| `macos-13` | macOS (Intel) | Legacy iOS builds | Same as macos-latest |
| `macos-14` | macOS (M1) | Faster iOS builds | Same as macos-latest |

**Cost Optimization**: iOS builds are 10x more expensive than Linux. Minimize iOS build frequency.

### Event Triggers

```yaml
on:
  # Push to specific branches
  push:
    branches:
      - main
      - develop
      - 'release/**'
    paths:
      - 'src/**'          # Only trigger if src/ changed
      - 'package.json'
  
  # Pull requests
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [main]
  
  # Scheduled (cron)
  schedule:
    - cron: '0 2 * * *'   # Daily at 2 AM UTC
  
  # Manual trigger with inputs
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options:
          - development
          - staging
          - production
```

---

## Caching Strategies

### Node.js Dependencies

```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: 'npm'          # Built-in caching for npm/yarn/pnpm
```

**Or explicit cache:**
```yaml
- name: Cache node_modules
  uses: actions/cache@v4
  with:
    path: |
      node_modules
      ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### Gradle (Android)

```yaml
- name: Cache Gradle
  uses: actions/cache@v4
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
    restore-keys: |
      ${{ runner.os }}-gradle-
```

### CocoaPods (iOS)

```yaml
- name: Cache Pods
  uses: actions/cache@v4
  with:
    path: ios/Pods
    key: ${{ runner.os }}-pods-${{ hashFiles('ios/Podfile.lock') }}
    restore-keys: |
      ${{ runner.os }}-pods-
```

### Docker Layers

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3

- name: Cache Docker layers
  uses: actions/cache@v4
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ github.sha }}
    restore-keys: |
      ${{ runner.os }}-buildx-
```

---

## Matrix Builds

Run tests across multiple environments in parallel:

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node: [18, 20, 22]
        exclude:
          - os: macos-latest
            node: 18           # Skip macOS + Node 18
      fail-fast: false         # Continue even if one fails
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
      - run: npm test
```

**Use Cases:**
- Test across Node.js versions
- Test on multiple OSes
- Test different database versions
- Test with multiple dependency versions

---

## Secrets Management

### Repository Secrets

Configure in: `Settings → Secrets and variables → Actions → New repository secret`

**Required secrets:**
```
EXPO_TOKEN               # EAS Build authentication
APPLE_ID                 # iOS distribution
APP_STORE_CONNECT_KEY    # App Store Connect API key
PLAY_STORE_SERVICE_ACCOUNT  # Google Play Console
VERCEL_TOKEN             # Vercel deployment
SENTRY_AUTH_TOKEN        # Error monitoring
```

**Usage:**
```yaml
- name: Deploy to Vercel
  env:
    VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
  run: vercel deploy --prod
```

### Environment Secrets

Configure in: `Settings → Environments → New environment`

Environments: `development`, `staging`, `production`

**Benefits:**
- Approval required before deploying to production
- Environment-specific secrets
- Deployment protection rules

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production    # Requires approval
    steps:
      - name: Deploy
        env:
          API_KEY: ${{ secrets.API_KEY }}  # Production API key
        run: npm run deploy
```

### OIDC (Recommended for Cloud Deployments)

Avoid long-lived credentials by using OpenID Connect:

**AWS:**
```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
    aws-region: us-east-1

- name: Deploy to S3
  run: aws s3 sync ./build s3://my-bucket
```

**Google Cloud:**
```yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: projects/123456789/locations/global/workloadIdentityPools/github/providers/github
    service_account: github-actions@my-project.iam.gserviceaccount.com

- name: Deploy to Cloud Run
  run: gcloud run deploy my-service --image gcr.io/my-project/my-image
```

---

## Mobile CI/CD Patterns

### EAS Build (Expo)

**Installation:**
```bash
npm install -g eas-cli
eas login
eas build:configure
```

**eas.json:**
```json
{
  "cli": {
    "version": ">= 5.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": true
      }
    },
    "preview": {
      "distribution": "internal",
      "channel": "preview"
    },
    "production": {
      "autoIncrement": true,
      "channel": "production"
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "your@email.com",
        "ascAppId": "1234567890",
        "appleTeamId": "ABCD123456"
      },
      "android": {
        "serviceAccountKeyPath": "./google-play-key.json",
        "track": "internal"
      }
    }
  }
}
```

**GitHub Actions Workflow:**
```yaml
name: EAS Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      
      - name: Setup EAS
        uses: expo/expo-github-action@v8
        with:
          eas-version: latest
          token: ${{ secrets.EXPO_TOKEN }}
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build iOS (production)
        run: eas build --platform ios --profile production --non-interactive
      
      - name: Build Android (production)
        run: eas build --platform android --profile production --non-interactive
```

**Cost Optimization:**
```yaml
# Only build iOS on main branch (expensive macOS runner)
- name: Build iOS
  if: github.ref == 'refs/heads/main'
  run: eas build --platform ios --profile production --non-interactive

# Build Android on all branches (cheap Linux runner)
- name: Build Android
  run: eas build --platform android --profile production --non-interactive
```

### Fastlane (Native React Native)

**Installation:**
```bash
cd ios
bundle install
bundle exec fastlane init
```

**Fastfile (ios/fastlane/Fastfile):**
```ruby
default_platform(:ios)

platform :ios do
  desc "Build and deploy to TestFlight"
  lane :beta do
    # Increment build number
    increment_build_number(xcodeproj: "MyApp.xcodeproj")
    
    # Match certificates (code signing)
    match(type: "appstore", readonly: true)
    
    # Build app
    build_app(
      scheme: "MyApp",
      export_method: "app-store"
    )
    
    # Upload to TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
    
    # Commit version bump
    commit_version_bump(xcodeproj: "MyApp.xcodeproj")
  end
  
  desc "Deploy to App Store"
  lane :release do
    match(type: "appstore", readonly: true)
    build_app(scheme: "MyApp")
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false,
      force: true,
      precheck_include_in_app_purchases: false
    )
  end
end
```

**GitHub Actions:**
```yaml
name: iOS Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: macos-14    # M1 runner (faster)
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Pods
        run: cd ios && pod install
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
          working-directory: ios
      
      - name: Build and deploy to TestFlight
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          FASTLANE_USER: ${{ secrets.APPLE_ID }}
          FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD: ${{ secrets.APP_STORE_CONNECT_KEY }}
        run: |
          cd ios
          bundle exec fastlane beta
```

### Android (Gradle)

**GitHub Actions:**
```yaml
name: Android Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      
      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
      
      - name: Build Release APK
        run: cd android && ./gradlew assembleRelease
      
      - name: Sign APK
        uses: r0adkll/sign-android-release@v1
        with:
          releaseDirectory: android/app/build/outputs/apk/release
          signingKeyBase64: ${{ secrets.SIGNING_KEY }}
          alias: ${{ secrets.KEY_ALIAS }}
          keyStorePassword: ${{ secrets.KEY_STORE_PASSWORD }}
          keyPassword: ${{ secrets.KEY_PASSWORD }}
      
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: com.example.app
          releaseFiles: android/app/build/outputs/apk/release/*.apk
          track: internal
```

---

## Web CI/CD Patterns

### Vercel

**Automatic Deployment** (no config needed):
- PR → Preview deployment
- `main` → Production deployment

**Custom Workflow:**
```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main, develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      
      - name: Install Vercel CLI
        run: npm install -g vercel
      
      - name: Pull Vercel Environment
        run: vercel pull --yes --environment=production --token=${{ secrets.VERCEL_TOKEN }}
      
      - name: Build Project
        run: vercel build --prod --token=${{ secrets.VERCEL_TOKEN }}
      
      - name: Deploy to Vercel
        run: vercel deploy --prebuilt --prod --token=${{ secrets.VERCEL_TOKEN }}
```

### Netlify

**netlify.toml:**
```toml
[build]
  command = "npm run build"
  publish = "dist"

[build.environment]
  NODE_VERSION = "20"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[context.production]
  environment = { VITE_API_URL = "https://api.example.com" }

[context.staging]
  environment = { VITE_API_URL = "https://staging-api.example.com" }
```

**GitHub Actions:**
```yaml
name: Deploy to Netlify

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      
      - run: npm ci
      - run: npm run build
      
      - name: Deploy to Netlify
        uses: nwtgck/actions-netlify@v3
        with:
          publish-dir: './dist'
          production-branch: main
          github-token: ${{ secrets.GITHUB_TOKEN }}
          deploy-message: "Deploy from GitHub Actions"
          enable-pull-request-comment: true
          enable-commit-comment: false
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

### AWS S3 + CloudFront

```yaml
name: Deploy to AWS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      
      - run: npm ci
      - run: npm run build
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
          aws-region: us-east-1
      
      - name: Deploy to S3
        run: aws s3 sync ./dist s3://my-bucket --delete
      
      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id E1234567890ABC \
            --paths "/*"
```

---

## Environment Management

### Branch-Based Deployment Strategy

| Branch | Environment | Auto-Deploy | Approval Required |
|--------|-------------|-------------|-------------------|
| `feature/*` | — | ❌ PR checks only | N/A |
| `develop` | Development | ✅ Auto | ❌ |
| `staging` | Staging | ✅ Auto | ❌ |
| `main` | Production | ✅ Auto | ✅ (recommended) |

### Environment Variables

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
  sentryDsn: window.ENV.SENTRY_DSN
}
```

---

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
    environment: production   # Requires approval
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: build
          path: dist/
      - name: Deploy to production
        run: echo "Deploy to production"
```

---

## Best Practices

### 1. Fail Fast
Run linting and type checks before expensive tests/builds:
```yaml
jobs:
  lint:
    # ...
  test:
    needs: lint    # Wait for lint to pass first
```

### 2. Use Concurrency Groups
Cancel in-progress runs when new commits pushed:
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### 3. Optimize Docker Builds
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

### 4. Use Build Matrix Sparingly
Matrix builds multiply cost (3 OSes × 3 Node versions = 9 builds). Only use when necessary.

### 5. Monitor Build Times
Add timing to steps:
```yaml
- name: Build
  run: time npm run build
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| **Cache miss every build** | Verify cache key uses correct lock file hash |
| **iOS build fails on Linux** | iOS requires `macos-latest` runner |
| **Secrets not available in PR** | PRs from forks can't access secrets; use `pull_request_target` cautiously |
| **EAS Build queue slow** | Use `--non-interactive`, consider priority plan, or self-
API Error: Claude's response exceeded the 32000 output token maximum. To configure this behavior, set the CLAUDE_CODE_MAX_OUTPUT_TOKENS environment variable.
I'll continue from where I left off with the remaining files:

===FILE: /Users/danielcarmo/Env/Projects/personal/claude_skills/claude_skills/.claude/skills/ci-cd-pipeline/REFERENCE.md===
(continuing from "EAS Build queue slow...")

**EAS Build queue slow** | Use `--non-interactive`, consider priority plan, or self-host with `eas build --local` |
| **Deployment fails silently** | Add `set -e` to fail on first error in bash scripts |
| **Environment variables not available** | Check if using `env:` at step level vs job level |

---

## Further Reading

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [EAS Build Documentation](https://docs.expo.dev/build/introduction/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Vercel CLI Documentation](https://vercel.com/docs/cli)
- [AWS OIDC Configuration](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
