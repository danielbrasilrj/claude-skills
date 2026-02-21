#!/usr/bin/env bash
# Creates a new Claude Code skill with the standard directory structure.
# Usage: bash create-skill.sh <skill-name>

set -euo pipefail

SKILL_NAME="${1:-}"

if [ -z "$SKILL_NAME" ]; then
  echo "Usage: bash create-skill.sh <skill-name>"
  echo "  skill-name: lowercase letters, numbers, and hyphens only (max 64 chars)"
  exit 1
fi

# Validate name
if ! echo "$SKILL_NAME" | grep -qE '^[a-z0-9][a-z0-9-]{0,62}[a-z0-9]$'; then
  echo "Error: Skill name must be lowercase letters, numbers, and hyphens only (2-64 chars)"
  exit 1
fi

# Find .claude/skills directory
SKILLS_DIR=".claude/skills"
if [ ! -d "$SKILLS_DIR" ]; then
  echo "Error: $SKILLS_DIR directory not found. Run from the repository root."
  exit 1
fi

SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"

if [ -d "$SKILL_DIR" ]; then
  echo "Error: Skill '$SKILL_NAME' already exists at $SKILL_DIR"
  exit 1
fi

# Create directory structure
mkdir -p "$SKILL_DIR"/{scripts,templates,examples,references}

# Create SKILL.md
cat > "$SKILL_DIR/SKILL.md" << 'SKILLEOF'
---
name: SKILL_NAME_PLACEHOLDER
description: |
  [What this skill does]. [When to use it — include specific trigger scenarios].
  Use when [trigger 1], [trigger 2], or [trigger 3].
---

## Purpose

[2-3 sentences describing the skill's purpose and value.]

## When to Use

- [Trigger scenario 1]
- [Trigger scenario 2]
- [Trigger scenario 3]

## Prerequisites

- [Required tool or package]
- [Required access or account]

## Procedures

### 1. [First Procedure Name]

[Step-by-step instructions with code examples.]

### 2. [Second Procedure Name]

[Additional procedures as needed.]

## Templates

- `templates/[name].md` — [Description]

## Examples

- `examples/[name].md` — [Description]

## Chaining

| Chain With | Purpose |
|---|---|
| `[other-skill]` | [Why these skills work together] |

## Troubleshooting

| Problem | Solution |
|---|---|
| [Common issue] | [How to fix it] |
SKILLEOF

# Replace placeholder with actual name
sed -i '' "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_DIR/SKILL.md" 2>/dev/null || \
sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_DIR/SKILL.md"

# Create REFERENCE.md
cat > "$SKILL_DIR/REFERENCE.md" << 'EOF'
# Reference: Detailed Documentation

> This file contains detailed reference material for the skill.
> It is loaded only when Claude needs deeper context during execution (Level 3 progressive disclosure).

## Detailed Procedures

[Move detailed content here if SKILL.md exceeds 500 lines.]

## Reference Tables

[Add lookup tables, checklists, or detailed specifications here.]
EOF

echo "✓ Created skill: $SKILL_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit $SKILL_DIR/SKILL.md — fill in the template"
echo "  2. Add examples to $SKILL_DIR/examples/"
echo "  3. Add templates to $SKILL_DIR/templates/"
echo "  4. Run validation: check name (max 64 chars, lowercase-hyphens)"
