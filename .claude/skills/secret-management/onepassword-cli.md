# 1Password CLI Integration

## Setup

```bash
# Install 1Password CLI
brew install --cask 1password-cli

# Sign in
op signin

# Create a service account (for CI/CD)
op service-account create "GitHub Actions" --vault "Infrastructure"
# Save the token: ops_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## Development Workflow

**Inject secrets into environment:**

```bash
# Store .env template in repository
# .env.template
DATABASE_URL="op://Infrastructure/Production DB/url"
API_KEY="op://Infrastructure/External API/api_key"
STRIPE_SECRET="op://Infrastructure/Stripe/secret_key"

# Load secrets and run app
op run --env-file=.env.template -- npm start

# Or export to shell
eval $(op signin)
export DATABASE_URL=$(op read "op://Infrastructure/Production DB/url")
export API_KEY=$(op read "op://Infrastructure/External API/api_key")
```

## CI/CD Integration

**GitHub Actions:**

```yaml
name: Deploy
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Load secrets from 1Password
        uses: 1password/load-secrets-action@v1
        with:
          export-env: true
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
          DATABASE_URL: 'op://Infrastructure/Production DB/url'
          API_KEY: 'op://Infrastructure/External API/api_key'

      - name: Deploy
        run: |
          echo "DATABASE_URL is available as env var"
          ./deploy.sh
```

## Secret References Format

```
op://[vault]/[item]/[field]
op://[vault]/[item]/[section]/[field]

Examples:
op://Infrastructure/AWS Prod/access_key_id
op://Infrastructure/Database/credentials/password
op://Infrastructure/API Keys/stripe/secret_key
```

## Create and Manage Secrets

```bash
# Create a new item
op item create --category=login \
  --vault=Infrastructure \
  --title="Production DB" \
  --url="postgres://db.example.com:5432" \
  username=admin \
  password=$(op generate-password --letters=20 --digits=5 --symbols=5)

# Read a secret
op read "op://Infrastructure/Production DB/password"

# Update a secret
op item edit "Production DB" password=$(op generate-password)

# List items in vault
op item list --vault=Infrastructure

# Delete an item
op item delete "Production DB" --vault=Infrastructure
```
