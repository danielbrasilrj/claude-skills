# Claude Skills — Quick Start

Get Claude Code working with the skills library in any project in 3 steps.

## Setup (1 minute)

```bash
# 1. Clone the skills repo (once, anywhere on your machine)
git clone https://github.com/YOUR_USERNAME/claude_skills.git ~/claude_skills

# 2. In your project, symlink the skills
mkdir -p .claude
ln -s ~/claude_skills/.claude/skills .claude/skills

# 3. Copy the project template and customize
cp ~/claude_skills/templates/PROJECT-CLAUDE.md ./CLAUDE.md
# Edit CLAUDE.md with your project's stack details
```

## Verify

```bash
# Check skills are linked
ls .claude/skills/
# Should show: deep-research, domain-intelligence, code-review, etc.

# Optional: set up your architecture config
cp .claude/skills/domain-intelligence/templates/architecture-decisions.yml .
# Edit architecture-decisions.yml with your stack
```

## Use

Open Claude Code in your project and it will automatically:
- Read your `CLAUDE.md` for project rules
- Discover all skills via `.claude/skills/`
- Use relevant skills based on your requests

### Common Commands

| Command | What it does |
|---|---|
| `/deep-research` | Research a topic with web search + Perplexity |
| `/code-review` | Review code with 8-pillar checklist |
| `/prd-driven-development` | Create a PRD for a new feature |
| `/sprint-planning` | Break work into user stories and tasks |
| `/testing-strategy` | Plan tests for a feature |
| `/skill-creator` | Create a new custom skill |

### Create New Skill

```bash
bash .claude/skills/skill-creator/scripts/create-skill.sh my-new-skill
```

## That's it

Claude now has access to 26 specialized skills. It will automatically use the right skill for each task.
