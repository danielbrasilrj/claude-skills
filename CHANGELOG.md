# Changelog

All notable changes to the Claude Skills Library will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-02-21

### Added

Initial release with 26 skills across 9 categories.

#### Research
- `deep-research` - Conducts multi-source deep research with structured reports and citations
- `domain-intelligence` - Gathers and synthesizes domain-specific intelligence and market insights
- `data-analysis` - Analyzes datasets, generates insights, and creates visualization recommendations

#### Design
- `figma-handoff` - Translates Figma designs into production-ready code with design tokens
- `conversion-copywriting` - Writes conversion-optimized copy using proven frameworks (AIDA, PAS, BAB)
- `ab-test-generator` - Designs statistically sound A/B test plans with variants and success metrics

#### Engineering
- `cross-platform-dev` - Builds cross-platform applications with shared logic and platform-specific UI
- `api-contract-testing` - Validates API contracts, generates tests from OpenAPI specs, checks backward compatibility
- `ci-cd-pipeline` - Creates and optimizes CI/CD pipelines for build, test, and deployment
- `code-review` - Performs systematic code reviews with actionable feedback and best practices
- `database-ops` - Manages database schemas, migrations, query optimization, and data modeling

#### Management
- `sprint-planning` - Facilitates sprint planning with story decomposition, estimation, and capacity planning
- `documentation-generator` - Generates comprehensive documentation from code, APIs, and project context
- `prd-driven-development` - Transforms product requirements into actionable development plans and user stories

#### Content
- `social-media-content` - Creates platform-specific social media content with scheduling recommendations
- `email-marketing` - Designs email campaigns with segmentation, sequences, and performance tracking
- `seo-local` - Optimizes content and technical setup for local search visibility

#### Automation
- `remote-trigger` - Sets up event-driven triggers and webhook integrations for automated workflows
- `web-scraping` - Builds reliable web scrapers with rate limiting, error handling, and data extraction
- `notification-system` - Designs multi-channel notification systems with templates and delivery logic

#### Quality
- `testing-strategy` - Defines comprehensive testing strategies across unit, integration, and e2e layers
- `accessibility-audit` - Audits and fixes accessibility issues following WCAG 2.1 AA/AAA guidelines
- `performance-optimization` - Identifies and resolves performance bottlenecks across frontend, backend, and infrastructure

#### Security
- `security-review` - Conducts security reviews following OWASP guidelines with remediation steps
- `secret-management` - Implements secure secret storage, rotation, and access control patterns

#### Meta
- `skill-creator` - Scaffolds new skills following the Claude Code Skills specification

#### Infrastructure
- Project structure with `CLAUDE.md`, `README.md`, and tooling
- `tools/setup.sh` for environment validation
- `tools/skill-index-generator.js` for generating skill index from frontmatter
- Progressive disclosure architecture (3-level loading pattern)
- i18n support for content-facing skills (en, pt-BR)
