---
name: skill-creator
description: Creates new Claude Code skills — generates directory structure, SKILL.md template, and validation checklist.
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
  SKILL.md          # Core workflow + checklist (<150 lines ideal)
  scripts/          # Helper scripts
  templates/        # Reusable templates
  examples/         # Usage examples
```

Add focused `.md` files as needed (e.g., `patterns.md`, `examples.md`). Do NOT create a monolithic `REFERENCE.md`.

### 2. Write SKILL.md

**YAML Frontmatter (required):**

```yaml
---
name: my-new-skill # Required. Max 64 chars. lowercase-hyphens only.
description: | # Required. Primary trigger mechanism.
  Does X when Y happens. Use when     # Include WHAT it does AND WHEN to use it.
  the user needs to Z.                # All trigger info goes HERE, not in body.
disable-model-invocation: true # Optional. User-only invoke (for side effects).
user-invocable: false # Optional. Claude-only invoke (background knowledge).
mode: false # Optional. True = modifies Claude's behavior.
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

## Focused Reference Files

- `[topic].md` — [Detailed content for topic, extracted from SKILL.md]

## Templates

- `templates/[name].md` — [Description]

## Examples

- `examples/[name].md` — [Description]

## Chaining

| Chain With    | Purpose     |
| ------------- | ----------- |
| `other-skill` | [Why chain] |

## Troubleshooting

| Problem | Solution |
| ------- | -------- |
| [Issue] | [Fix]    |
```

### 3. Progressive Disclosure with Focused Reference Files

Skills use a 3-level loading model. Level 3 uses **focused topic files** instead of a monolithic REFERENCE.md.

- **Level 1 (Frontmatter):** `name` + `description` only. Loaded at discovery time.
- **Level 2 (SKILL.md body):** Core workflow, philosophy, checklist. Loaded when skill is invoked. **Keep under 150 lines ideal, 500 max.**
- **Level 3 (Focused `.md` files):** Detailed content split by concern. Loaded only when SKILL.md references them.

**Example — TDD skill structure:**

```
.claude/skills/tdd/
  SKILL.md            # Core workflow + checklist (~120 lines)
  mocking.md          # Mocking patterns, DI, test doubles
  refactoring.md      # Red-green-refactor detailed guidance
  deep-modules.md     # Module design philosophy
  interface-design.md # Contract-first patterns
  tests.md            # Test structure, naming, assertions
```

Each `.md` is self-contained — readable without the others, referenced from SKILL.md only when needed:

```markdown
For mocking strategies and dependency injection, see `mocking.md`.
```

**When to extract into a focused reference file:**

- Content >15 lines of code examples or templates
- Independent subsections serving different user personas
- Technical formulas, SQL, language-specific syntax
- Reusable patterns that other skills might reference
- Any topic that can stand alone as a mini-guide

**Naming conventions for reference files:**

- `lowercase-kebab-case.md`
- Named after the topic: `mocking.md`, `examples.md`, `migration-patterns.md`
- Never generic: NO `reference-1.md`, `details.md`, `extra.md`
- Self-contained — each file readable independently

**Anti-pattern:** A single `REFERENCE.md` that grows into a 500+ line dump. Split by concern instead.

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
- [ ] Reference content split into focused topic files (no monolithic REFERENCE.md)

## Templates

- `templates/skill-template.md` — SKILL.md template with all sections
- `templates/reference-template.md` — Focused reference file template

## Examples

- `examples/example-new-skill.md` — Example of creating a skill from scratch

## Chaining

| Chain With                | Purpose                                        |
| ------------------------- | ---------------------------------------------- |
| `documentation-generator` | Document the new skill                         |
| `domain-intelligence`     | Check if skill aligns with project constraints |

## Troubleshooting

| Problem                              | Solution                                    |
| ------------------------------------ | ------------------------------------------- |
| Skill not discovered by Claude       | Check `description` has trigger keywords    |
| Skill auto-invokes when it shouldn't | Add `disable-model-invocation: true`        |
| SKILL.md too long                    | Extract topics into focused `.md` files     |
| Name rejected                        | Check: max 64 chars, lowercase-hyphens only |
