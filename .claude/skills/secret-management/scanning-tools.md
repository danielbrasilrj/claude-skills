# Secret Scanning Tools Comparison

| Tool                       | Detection Method    | Pre-commit Hook | CI/CD | Cost                | Best For                             |
| -------------------------- | ------------------- | --------------- | ----- | ------------------- | ------------------------------------ |
| **gitleaks**               | Regex + entropy     | Yes             | Yes   | Free                | General purpose, fast                |
| **truffleHog**             | Regex + git history | Yes             | Yes   | Free                | Deep git history scanning            |
| **detect-secrets**         | Entropy + plugins   | Yes             | Yes   | Free                | Python projects, low false positives |
| **git-secrets**            | Regex patterns      | Yes             | No    | Free                | AWS credentials specifically         |
| **GitHub Secret Scanning** | Platform-native     | N/A             | Yes   | Free (public repos) | GitHub-hosted repos                  |
| **GitGuardian**            | AI + regex          | Yes             | Yes   | Paid                | Enterprise, dashboards               |

## Gitleaks Setup (Recommended)

```bash
# Install
brew install gitleaks

# Scan repository
gitleaks detect --source . --verbose

# Scan git history
gitleaks detect --source . --log-opts="--all"

# Pre-commit hook
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks

# Install hooks
pre-commit install

# CI/CD (GitHub Actions)
# .github/workflows/gitleaks.yml
name: Secret Scanning
on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Custom configuration (.gitleaks.toml):**

```toml
[extend]
useDefault = true

[[rules]]
id = "custom-api-key"
description = "Custom API Key Pattern"
regex = '''(?i)(api[_-]?key|apikey)[[:space:]]*[:=][[:space:]]*['"][a-z0-9]{32}['"]'''

[allowlist]
description = "Allowlist for test files"
paths = [
  '''.*_test\.go''',
  '''.*\.example'''
]

[[allowlist.regexes]]
description = "Ignore placeholder values"
regex = '''(YOUR|REPLACE|EXAMPLE|TODO)'''
```

## TruffleHog Setup

```bash
# Install
brew install trufflesecurity/trufflehog/trufflehog

# Scan repository
trufflehog git file://. --only-verified

# Scan git history with JSON output
trufflehog git file://. --json > secrets.json

# Scan GitHub repository
trufflehog github --org=myorg --repo=myrepo

# Pre-commit hook
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/trufflesecurity/trufflehog
    rev: v3.63.0
    hooks:
      - id: trufflehog
        args: ['git', 'file://.', '--only-verified']
```
