---
name: skill-creator
description: |
  Meta-skill that helps create new Claude Code skills. Generates the complete skill directory
  structure with SKILL.md template, REFERENCE.md, scripts, templates, and examples directories.
  Includes validation checklist for new skills and best practices from Anthropic's official
  skill authoring guide. Use when creating a new skill from scratch, validating an existing
  skill's structure, or reviewing skill quality.
disable-model-invocation: true
---

## Purpose

Skill Creator is a meta-skill that bootstraps new Claude Code skills following Anthropic's official specification. It generates the directory structure, provides templates with proper YAML frontmatter, and validates skill quality against a checklist.

## When to Use

- Creating a new skill from scratch
- Validating an existing skill's structure and quality
- Reviewing a skill before publishing
- Understanding the official skill authoring guidelines

## Prerequisites

- Write access to `.claude/skills/` directory
- Understanding of the skill's purpose and trigger scenarios

## Procedures

### 1. Create Skill Directory

Run the creation script:
```bash
bash .claude/skills/skill-creator/scripts/create-skill.sh my-new-skill
```

This creates:
```
.claude/skills/my-new-skill/
  SKILL.md          # Main skill file (edit this)
  REFERENCE.md      # Detailed reference (for overflow content)
  scripts/          # Helper scripts
  templates/        # Reusable templates
  examples/         # Usage examples
  references/       # Additional reference docs
```

### 2. Write SKILL.md

**YAML Frontmatter (required):**
```yaml
---
name: my-new-skill                    # Required. Max 64 chars. lowercase-hyphens only.
description: |                        # Required. Primary trigger mechanism.
  Does X when Y happens. Use when     # Include WHAT it does AND WHEN to use it.
  the user needs to Z.                # All trigger info goes HERE, not in body.
disable-model-invocation: true        # Optional. User-only invoke (for side effects).
user-invocable: false                 # Optional. Claude-only invoke (background knowledge).
mode: false                           # Optional. True = modifies Claude's behavior.
---
```

**Body structure (under 500 lines):**
```markdown
## Purpose
[2-3 sentences describing what this skill does]

## When to Use
- [Trigger scenario 1]
- [Trigger scenario 2]

## Prerequisites
- [Required tools, accounts, packages]

## Procedures
### 1. [First procedure]
[Numbered steps with code examples]

## Templates
- `templates/[name].md` — [Description]

## Examples
- `examples/[name].md` — [Description]

## Chaining
| Chain With | Purpose |
|---|---|
| `other-skill` | [Why chain] |

## Troubleshooting
| Problem | Solution |
|---|---|
| [Issue] | [Fix] |
```

### 3. Progressive Disclosure Rules

- **Level 1 (Frontmatter):** `name` + `description` only. Loaded at discovery time.
- **Level 2 (SKILL.md body):** Full procedures. Loaded when skill is invoked. **Keep under 500 lines.**
- **Level 3 (External files):** REFERENCE.md, scripts, templates. Loaded only when needed during execution.

If SKILL.md exceeds 500 lines, move detailed content to REFERENCE.md and reference it:
```markdown
For detailed [topic], see REFERENCE.md.
```

### 4. Naming Rules

- Max 64 characters
- Lowercase letters, numbers, and hyphens only
- No XML tags or reserved words
- Name becomes the `/slash-command` (e.g., `/my-new-skill`)

### 5. Validation Checklist

- [ ] `name` in frontmatter: max 64 chars, lowercase-hyphens
- [ ] `description` includes WHAT and WHEN (trigger info)
- [ ] Body under 500 lines
- [ ] All "when to use" info is in `description`, not body
- [ ] At least 1 example in `examples/`
- [ ] Procedures are numbered and actionable
- [ ] No hardcoded frameworks (stack-agnostic unless domain-specific)
- [ ] Side-effect skills have `disable-model-invocation: true`
- [ ] Background knowledge skills have `user-invocable: false`
- [ ] Chaining section references real skills

## Templates

- `templates/skill-template.md` — SKILL.md template with all sections
- `templates/reference-template.md` — REFERENCE.md template

## Examples

- `examples/example-new-skill.md` — Example of creating a skill from scratch

## Chaining

| Chain With | Purpose |
|---|---|
| `documentation-generator` | Document the new skill |
| `domain-intelligence` | Check if skill aligns with project constraints |

## Troubleshooting

| Problem | Solution |
|---|---|
| Skill not discovered by Claude | Check `description` has trigger keywords |
| Skill auto-invokes when it shouldn't | Add `disable-model-invocation: true` |
| SKILL.md too long | Move details to REFERENCE.md |
| Name rejected | Check: max 64 chars, lowercase-hyphens only |
