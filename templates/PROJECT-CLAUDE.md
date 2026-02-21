# Project: [PROJECT_NAME]

## Stack

- **Framework**: [e.g., React Native with Expo]
- **Language**: TypeScript (strict mode)
- **Database**: [e.g., Supabase]
- **Deployment**: [e.g., EAS Build + Vercel]
- **Package manager**: [bun | pnpm | yarn | npm]

## Skills Library

This project uses skills from `claude_skills`. The skills are located at:
`~/.claude/skills/` (symlinked or cloned from the claude_skills repository)

### When to use skills

Before starting any task, check if a relevant skill exists:

1. **Research tasks** → `/deep-research`, `/data-analysis`
2. **New feature** → `/prd-driven-development` → `/sprint-planning`
3. **Writing code** → check `/domain-intelligence` for stack constraints
4. **API work** → `/api-contract-testing`
5. **Database changes** → `/database-ops` (NEVER destructive without confirmation)
6. **Code review** → `/code-review`
7. **Testing** → `/testing-strategy`
8. **Performance issues** → `/performance-optimization`
9. **Security concerns** → `/security-review`, `/secret-management`
10. **Marketing content** → `/conversion-copywriting`, `/email-marketing`, `/social-media-content`
11. **Accessibility** → `/accessibility-audit`
12. **CI/CD** → `/ci-cd-pipeline`
13. **Documentation** → `/documentation-generator`

### Skills to always check first

- **`/domain-intelligence`** — Read `architecture-decisions.yml` before ANY technical recommendation
- **`/database-ops`** — NEVER run destructive operations without backup + explicit confirmation
- **`/secret-management`** — NEVER hardcode secrets; use environment variables

## Rules

### Must Do
- Follow the stack defined in `architecture-decisions.yml`
- Use approved libraries only; suggest additions with rationale
- Write TypeScript with strict mode; no `any` types
- All user-facing text must be i18n-ready (use translation keys, not hardcoded strings)
- Run tests before committing
- All new features need acceptance criteria (Given/When/Then)

### Must NOT Do
- Never commit secrets, API keys, or credentials
- Never use `any` type in TypeScript
- Never run destructive database operations without confirmation
- Never skip error handling for async operations
- Never push directly to main/production branch
- Never install packages without checking `domain-intelligence` approved list
- Never hardcode text in a single language

## File Structure

```
src/
  components/     # Shared UI components
  features/       # Feature-based modules
  services/       # API and external service integrations
  hooks/          # Custom React hooks
  utils/          # Pure utility functions
  types/          # Shared TypeScript types
  i18n/           # Internationalization files
    locales/
      en/
      pt-BR/
```

## Git Conventions

- Branch naming: `feature/`, `fix/`, `chore/`, `docs/`
- Commit messages: conventional commits (feat:, fix:, chore:, docs:)
- PR size: < 400 lines of changes (split larger PRs)
- Always create a new branch from `develop`

## Testing

- Unit tests: co-located with source (`*.test.ts`)
- E2E tests: `e2e/` directory
- Coverage threshold: 80% for new code
- Run `npm test` before every commit
