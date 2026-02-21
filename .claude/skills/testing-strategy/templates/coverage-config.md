# Coverage Configuration Templates

Ready-to-use coverage configurations for CI gates.

## Vitest Coverage Config

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    coverage: {
      provider: 'v8', // or 'istanbul'
      reporter: ['text', 'text-summary', 'lcov', 'json-summary'],
      reportsDirectory: './coverage',

      // Include/exclude
      include: ['src/**/*.{ts,tsx}'],
      exclude: [
        'src/**/*.d.ts',
        'src/**/*.test.{ts,tsx}',
        'src/**/*.stories.{ts,tsx}',
        'src/**/index.ts',        // barrel exports
        'src/test/**',            // test utilities
        'src/mocks/**',           // MSW handlers
        'src/types/**',           // type-only files
      ],

      // Thresholds -- CI will fail if below these
      thresholds: {
        statements: 70,
        branches: 65,
        functions: 70,
        lines: 70,
      },

      // Include untested files in report
      all: true,
    },
  },
});
```

## Jest Coverage Config

```javascript
// jest.config.js
module.exports = {
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'text-summary', 'lcov', 'json-summary'],

  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.test.{js,jsx,ts,tsx}',
    '!src/**/*.stories.{js,jsx,ts,tsx}',
    '!src/**/index.{js,ts}',
    '!src/test/**',
    '!src/mocks/**',
    '!src/types/**',
  ],

  coverageThreshold: {
    global: {
      statements: 70,
      branches: 65,
      functions: 70,
      lines: 70,
    },
    // Per-directory thresholds for critical code
    './src/services/': {
      statements: 90,
      branches: 85,
      functions: 90,
      lines: 90,
    },
  },
};
```

## GitHub Actions CI Coverage Gate

```yaml
name: Test & Coverage

on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci

      # Unit + Integration tests with coverage
      - run: npm run test -- --coverage --reporter=json-summary
        env:
          CI: true

      # Upload coverage to artifact
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: coverage/lcov-report/

      # Post coverage summary as PR comment (optional)
      - name: Coverage Summary
        if: github.event_name == 'pull_request'
        uses: davelosert/vitest-coverage-report-action@v2
        with:
          json-summary-path: coverage/coverage-summary.json
```

## Threshold Progression Strategy

Start low and ratchet up over time:

| Phase | Timeline | Statements | Branches | Functions |
|---|---|---|---|---|
| **Bootstrap** | Week 1-2 | 40% | 30% | 40% |
| **Foundation** | Month 1 | 60% | 50% | 60% |
| **Standard** | Month 2-3 | 70% | 65% | 70% |
| **Mature** | Month 4+ | 80% | 75% | 80% |
| **Critical paths** | Always | 90%+ | 85%+ | 90%+ |

**Ratchet script** -- never let coverage go down:

```bash
#!/bin/bash
# scripts/check-coverage-ratchet.sh
CURRENT=$(jq '.total.lines.pct' coverage/coverage-summary.json)
PREVIOUS=$(jq '.total.lines.pct' coverage-baseline.json 2>/dev/null || echo 0)

if (( $(echo "$CURRENT < $PREVIOUS" | bc -l) )); then
  echo "Coverage decreased from ${PREVIOUS}% to ${CURRENT}%"
  exit 1
fi

# Save new baseline
cp coverage/coverage-summary.json coverage-baseline.json
echo "Coverage: ${CURRENT}% (baseline: ${PREVIOUS}%)"
```

## Playwright Coverage (E2E)

To collect code coverage during E2E tests:

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  use: {
    // Enable coverage collection via Istanbul
    contextOptions: {
      // coverage is collected via a separate instrumentation step
    },
  },
  webServer: {
    command: 'npx nyc --reporter=lcov npm run dev',
    port: 3000,
    reuseExistingServer: !process.env.CI,
  },
});
```

Note: E2E coverage supplements unit/integration coverage. Do not use E2E coverage alone as a quality gate -- it is too coarse-grained.
