# Secrets Management

## Repository Secrets

Configure in: `Settings -> Secrets and variables -> Actions -> New repository secret`

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

## Environment Secrets

Configure in: `Settings -> Environments -> New environment`

Environments: `development`, `staging`, `production`

**Benefits:**

- Approval required before deploying to production
- Environment-specific secrets
- Deployment protection rules

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production # Requires approval
    steps:
      - name: Deploy
        env:
          API_KEY: ${{ secrets.API_KEY }} # Production API key
        run: npm run deploy
```

## OIDC (Recommended for Cloud Deployments)

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
