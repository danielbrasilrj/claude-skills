# Claude Skills Library

## Purpose

A modular library of 26 reusable Claude AI skills for cross-platform app development, content creation, quality assurance, and automation. Each skill is a self-contained instruction set that Claude Code loads on demand to execute specialized procedures.

## Architecture

Skills are organized under `.claude/skills/<skill-name>/` following Anthropic's official Claude Code Skills specification:

```
claude_skills/
  CLAUDE.md              <- You are here. Project-level instructions.
  .claude/
    skills/
      <skill-name>/
        SKILL.md          <- Primary skill definition (YAML frontmatter + body)
        REFERENCE.md      <- Optional overflow content (>500 lines)
        templates/        <- Optional skill-specific templates
        examples/         <- Optional usage examples
  tools/
    setup.sh              <- Environment validation
    skill-index-generator.js  <- Generates skill index from frontmatter
```

## How to Navigate and Use Skills

### For Claude: Skill Resolution Protocol

1. **Identify**: Scan the master index below. Match the user's request against trigger keywords and descriptions.
2. **Load**: Read only the `SKILL.md` file(s) for matched skills. Do NOT load all skills upfront.
3. **Chain**: If a task spans multiple domains, load and execute skills sequentially. For example, a new feature might chain: `prd-driven-development` -> `cross-platform-dev` -> `testing-strategy` -> `code-review`.
4. **Escalate**: If a `SKILL.md` references a `REFERENCE.md`, load it only when the specific section is needed.

### Progressive Disclosure (3-Level Loading)

| Level | What                  | When to Load                                    |
|-------|-----------------------|-------------------------------------------------|
| 1     | Frontmatter (YAML)    | Always. Used for skill identification.          |
| 2     | SKILL.md body         | When the skill is selected for execution.       |
| 3     | REFERENCE.md, extras  | When SKILL.md body references external content. |

This pattern minimizes context window usage while keeping full capability available.

## Master Skill Index

| # | Name | Category | Trigger Keywords | Description |
|---|------|----------|-----------------|-------------|
| 1 | `deep-research` | research | research, investigate, analyze topic, literature review | Conducts multi-source deep research with structured reports and citations |
| 2 | `domain-intelligence` | research | competitor, market, industry, domain analysis | Gathers and synthesizes domain-specific intelligence and market insights |
| 3 | `data-analysis` | research | data, analytics, metrics, dashboard, visualization | Analyzes datasets, generates insights, and creates visualization recommendations |
| 4 | `figma-handoff` | design | figma, design handoff, UI implementation, design tokens | Translates Figma designs into production-ready code with design tokens |
| 5 | `conversion-copywriting` | design | copy, copywriting, landing page, conversion, CTA | Writes conversion-optimized copy using proven frameworks (AIDA, PAS, BAB) |
| 6 | `ab-test-generator` | design | A/B test, experiment, variant, hypothesis | Designs statistically sound A/B test plans with variants and success metrics |
| 7 | `cross-platform-dev` | engineering | cross-platform, mobile, React Native, Flutter, responsive | Builds cross-platform applications with shared logic and platform-specific UI |
| 8 | `api-contract-testing` | engineering | API, contract, OpenAPI, schema, endpoint testing | Validates API contracts, generates tests from OpenAPI specs, checks backward compatibility |
| 9 | `ci-cd-pipeline` | engineering | CI/CD, pipeline, deploy, GitHub Actions, automation | Creates and optimizes CI/CD pipelines for build, test, and deployment |
| 10 | `code-review` | engineering | code review, PR review, pull request, refactor | Performs systematic code reviews with actionable feedback and best practices |
| 11 | `database-ops` | engineering | database, migration, schema, query optimization, SQL | Manages database schemas, migrations, query optimization, and data modeling |
| 12 | `sprint-planning` | management | sprint, planning, backlog, estimation, velocity | Facilitates sprint planning with story decomposition, estimation, and capacity planning |
| 13 | `documentation-generator` | management | docs, documentation, API docs, JSDoc, README | Generates comprehensive documentation from code, APIs, and project context |
| 14 | `prd-driven-development` | management | PRD, product requirements, feature spec, user stories | Transforms product requirements into actionable development plans and user stories |
| 15 | `social-media-content` | content | social media, post, tweet, LinkedIn, Instagram, content calendar | Creates platform-specific social media content with scheduling recommendations |
| 16 | `email-marketing` | content | email, newsletter, campaign, drip sequence, email marketing | Designs email campaigns with segmentation, sequences, and performance tracking |
| 17 | `seo-local` | content | SEO, local SEO, keywords, Google Business, search ranking | Optimizes content and technical setup for local search visibility |
| 18 | `remote-trigger` | automation | trigger, webhook, remote action, event-driven, automation | Sets up event-driven triggers and webhook integrations for automated workflows |
| 19 | `web-scraping` | automation | scrape, crawl, extract data, web scraping, parsing | Builds reliable web scrapers with rate limiting, error handling, and data extraction |
| 20 | `notification-system` | automation | notification, alert, push, email alert, messaging | Designs multi-channel notification systems with templates and delivery logic |
| 21 | `testing-strategy` | quality | test, testing, unit test, integration test, e2e, coverage | Defines comprehensive testing strategies across unit, integration, and e2e layers |
| 22 | `accessibility-audit` | quality | accessibility, a11y, WCAG, screen reader, ARIA | Audits and fixes accessibility issues following WCAG 2.1 AA/AAA guidelines |
| 23 | `performance-optimization` | quality | performance, speed, optimization, lighthouse, bundle size | Identifies and resolves performance bottlenecks across frontend, backend, and infrastructure |
| 24 | `security-review` | security | security, vulnerability, OWASP, penetration, audit | Conducts security reviews following OWASP guidelines with remediation steps |
| 25 | `secret-management` | security | secrets, env vars, vault, credentials, API keys | Implements secure secret storage, rotation, and access control patterns |
| 26 | `skill-creator` | meta | create skill, new skill, skill template, meta | Scaffolds new skills following the Claude Code Skills specification |

## Categories

- **research**: Deep investigation, data analysis, and domain intelligence gathering.
- **design**: UI/UX implementation, copywriting, and experimentation.
- **engineering**: Core development, APIs, CI/CD, code quality, and databases.
- **management**: Planning, documentation, and requirements.
- **content**: Marketing content across social, email, and search channels.
- **automation**: Triggers, scrapers, and notification pipelines.
- **quality**: Testing, accessibility, and performance.
- **security**: Vulnerability assessment and secret management.
- **meta**: Tools for creating and managing skills themselves.

## Versioning

Skills follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes to skill interface or output format.
- **MINOR**: New capabilities added, backward compatible.
- **PATCH**: Bug fixes, prompt refinements, documentation updates.

Version is tracked in each skill's YAML frontmatter (when present) and in the root `CHANGELOG.md`.

Current library version: **v1.0.0**

## Contributing

1. Use the `skill-creator` skill to scaffold a new skill.
2. Follow the naming convention: lowercase-hyphens, max 64 characters.
3. Keep `SKILL.md` under 500 lines. Move overflow to `REFERENCE.md`.
4. Include YAML frontmatter with required fields: `name`, `description`.
5. Test the skill in isolation before submitting.
6. Update `CHANGELOG.md` with your changes.
7. Run `node tools/skill-index-generator.js` to regenerate the index.

## Internationalization (i18n)

Content-facing skills (`social-media-content`, `email-marketing`, `seo-local`, `conversion-copywriting`) support multi-language output generation. Default languages: **en** (English), **pt-BR** (Brazilian Portuguese). Specify the target language in your prompt when invoking these skills.
