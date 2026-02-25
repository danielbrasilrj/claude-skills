# CI/CD Integration for Automated Code Review

## Automated Review Checks

```yaml
# .github/workflows/code-review.yml
name: Automated Code Review
on: [pull_request]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Lint (Style)
        run: npm run lint
      - name: Type Check (Correctness)
        run: npm run type-check
      - name: Security Scan (Security)
        uses: snyk/actions/node@master
      - name: Test Coverage (Testing)
        run: npm test -- --coverage --coverageThreshold=80
      - name: Bundle Size (Performance)
        uses: andresz1/size-limit-action@v1
```

## Review Checklist Bot

Configure a GitHub Action to post the review checklist as a PR comment:

```yaml
- name: Post Review Checklist
  uses: actions/github-script@v7
  with:
    script: |
      const checklist = `
      ## Code Review Checklist
      - [ ] Correctness: Edge cases handled
      - [ ] Security: No hardcoded secrets
      - [ ] Performance: No N+1 queries
      - [ ] Accessibility: Keyboard navigation
      - [ ] Testing: New tests added
      `;
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: checklist
      });
```
