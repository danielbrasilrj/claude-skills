# Auto-Documentation in CI/CD

## GitHub Actions Workflow

Create `.github/workflows/docs.yml`:

```yaml
name: Generate and Deploy Documentation

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  docs:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Generate TypeDoc
        run: npx typedoc --out docs/api src/index.ts

      - name: Generate OpenAPI docs
        run: npx redoc-cli bundle openapi.yaml -o docs/api-reference.html

      - name: Validate documentation
        run: |
          # Check for broken links
          npx markdown-link-check docs/**/*.md

          # Validate OpenAPI spec
          npx @redocly/cli lint openapi.yaml

      - name: Deploy to GitHub Pages
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs
          cname: docs.example.com
```

## Pre-Commit Hook for Documentation

Create `.husky/pre-commit`:

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

# Regenerate TypeDoc before committing
npm run docs:generate

# Add generated docs to commit
git add docs/api

# Validate JSDoc comments
npm run docs:lint
```

## Documentation Quality Checklist

Before publishing documentation, verify:

- [ ] **Accuracy**: All code examples run without errors
- [ ] **Completeness**: All public APIs are documented
- [ ] **Clarity**: Explanations are understandable to target audience
- [ ] **Links**: All internal and external links work
- [ ] **Examples**: Each major feature has a working example
- [ ] **Errors**: Common errors and solutions are documented
- [ ] **Versioning**: Documentation version matches code version
- [ ] **Review**: At least one other person has reviewed the docs
- [ ] **Accessibility**: Documentation is accessible (alt text, semantic HTML)
- [ ] **Search**: Documentation is searchable (indexed by search engine)

## Further Reading

- **Style Guide**: [Google Developer Documentation Style Guide](https://developers.google.com/style)
- **API Design**: [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines)
- **TypeDoc**: [Official TypeDoc Documentation](https://typedoc.org/)
- **OpenAPI**: [OpenAPI Specification](https://swagger.io/specification/)
- **ADRs**: [MADR (Markdown ADR) Template](https://adr.github.io/madr/)
