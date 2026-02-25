# GitHub Actions Fundamentals

## Workflow Structure

```yaml
name: CI/CD Pipeline
on: # Trigger events
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch: # Manual trigger

jobs:
  build:
    runs-on: ubuntu-latest # Runner type
    steps:
      - uses: actions/checkout@v4 # Pre-built action
      - name: Custom step
        run: npm install # Shell command
```

## Runner Types

| Runner           | OS            | Use Case                   | Cost                                |
| ---------------- | ------------- | -------------------------- | ----------------------------------- |
| `ubuntu-latest`  | Linux         | Most builds, tests, Docker | Free (public), $0.008/min (private) |
| `windows-latest` | Windows       | .NET, Windows apps         | Free (public), $0.016/min (private) |
| `macos-latest`   | macOS         | iOS builds, Xcode          | Free (public), $0.08/min (private)  |
| `macos-13`       | macOS (Intel) | Legacy iOS builds          | Same as macos-latest                |
| `macos-14`       | macOS (M1)    | Faster iOS builds          | Same as macos-latest                |

**Cost Optimization**: iOS builds are 10x more expensive than Linux. Minimize iOS build frequency.

## Event Triggers

```yaml
on:
  # Push to specific branches
  push:
    branches:
      - main
      - develop
      - 'release/**'
    paths:
      - 'src/**' # Only trigger if src/ changed
      - 'package.json'

  # Pull requests
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [main]

  # Scheduled (cron)
  schedule:
    - cron: '0 2 * * *' # Daily at 2 AM UTC

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
            node: 18 # Skip macOS + Node 18
      fail-fast: false # Continue even if one fails
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
