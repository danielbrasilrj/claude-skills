# Coverage Analysis Tips

- **Ignore generated code**: Add `/* istanbul ignore next */` or configure `coveragePathIgnorePatterns`
- **Focus on branch coverage**: Statement coverage can be misleading; a function with 5 branches might show 80% statement coverage but only 20% branch coverage
- **Untested files**: Use `--coverage.all=true` to include files with zero imports in the report
- **Coverage ratchet**: Store current coverage in CI and fail if any metric decreases

## Performance Testing Integration

When tests reveal performance issues, chain to the **performance-optimization** skill:

- Add `performance.mark()` and `performance.measure()` in critical paths
- Use Playwright's `page.metrics()` to capture runtime performance in E2E
- Set Lighthouse CI budgets as part of the E2E test suite
