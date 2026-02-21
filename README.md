# Claude Skills

26 reusable skills for Claude Code. Drop them into any project.

## Setup

```bash
# 1. Clone once (anywhere on your machine)
git clone https://github.com/danielbrasilrj/claude-skills.git ~/claude-skills

# 2. In your project, link the skills
mkdir -p .claude
ln -s ~/claude-skills/.claude/skills .claude/skills

# 3. Copy the CLAUDE.md template and edit it for your stack
cp ~/claude-skills/templates/PROJECT-CLAUDE.md ./CLAUDE.md
```

Done. Open Claude Code in your project — it reads `.claude/skills/` automatically.

## Skills

| Category | Skills |
|----------|--------|
| **Research** | `deep-research` `domain-intelligence` `data-analysis` |
| **Design** | `figma-handoff` `conversion-copywriting` `ab-test-generator` |
| **Engineering** | `cross-platform-dev` `api-contract-testing` `ci-cd-pipeline` `code-review` `database-ops` |
| **Management** | `sprint-planning` `prd-driven-development` `documentation-generator` |
| **Content** | `social-media-content` `email-marketing` `seo-local` |
| **Automation** | `remote-trigger` `web-scraping` `notification-system` |
| **Quality** | `testing-strategy` `accessibility-audit` `performance-optimization` |
| **Security** | `security-review` `secret-management` |
| **Meta** | `skill-creator` |

## How It Works

1. You make a request in Claude Code
2. Claude reads your project's `CLAUDE.md`
3. Loads the relevant skill(s) from `.claude/skills/`
4. Follows the skill's procedures to complete the task

Skills chain automatically — asking to "build a feature from this PRD" triggers `prd-driven-development` → `cross-platform-dev` → `testing-strategy` → `code-review`.

## Create a New Skill

```bash
bash .claude/skills/skill-creator/scripts/create-skill.sh my-skill
```

## License

[MIT](LICENSE) — Daniel Carmo
