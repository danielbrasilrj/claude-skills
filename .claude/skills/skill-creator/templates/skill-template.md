# Skill Template

Use this template to create a new Claude Code skill. Replace all `[placeholders]` with your content.

```markdown
---
name: [skill-name]
description: |
  [2-3 sentences describing what this skill does AND when to use it.
  This is the PRIMARY trigger mechanism. Include all "when to use" info here.
  Example: "Helps debug API integration issues by analyzing logs, network requests,
  and response payloads. Use when APIs return unexpected errors, timeouts occur,
  or responses don't match documentation."]
# Optional flags (uncomment if needed):
# disable-model-invocation: true    # User-only invoke (for side effects like git commit)
# user-invocable: false              # Claude-only invoke (background knowledge)
# mode: true                         # Modifies Claude's behavior (use sparingly)
---

## Purpose

[2-3 sentences explaining the skill's purpose in more detail than the description.
What problem does it solve? What value does it provide?]

## When to Use

[Bulleted list of specific trigger scenarios. These should mirror what's in the description
but can be more detailed. Focus on user intent and context.]

- [Scenario 1: "When setting up X for the first time"]
- [Scenario 2: "When debugging Y errors"]
- [Scenario 3: "When optimizing Z performance"]
- [Scenario 4: Additional scenarios...]

## Prerequisites

[List required tools, accounts, configurations, or knowledge needed before using this skill.
If there are no prerequisites, write "None."]

- [Tool/service 1: "GitHub account with admin access"]
- [Tool/service 2: "Node.js 18+ installed"]
- [Configuration: "API credentials in .env file"]
- [Knowledge: "Basic understanding of X concept"]

## Procedures

[This is the main content. Break down the skill into numbered procedures.
Each procedure should be a discrete task or workflow. Keep procedures actionable.]

### 1. [First Procedure Name]

[Brief description of what this procedure accomplishes]

**Steps:**

1. [First step with command or action]
   ```bash
   # Example command
   command --flag value
   ```

2. [Second step with explanation]
   - [Sub-step if needed]
   - [Another sub-step]

3. [Third step]

**Expected Result:** [What success looks like]

---

### 2. [Second Procedure Name]

[Brief description]

| Column 1 | Column 2 | Column 3 |
|---|---|---|
| [Data] | [Data] | [Data] |
| [Data] | [Data] | [Data] |

**Notes:**
- [Important note about this procedure]
- [Common pitfall to avoid]

---

### 3. [Third Procedure Name]

[For code-heavy procedures, include examples:]

```javascript
// Example code with comments
function exampleFunction() {
  // Explanation of what this does
  return result;
}
```

**Configuration:**
```yaml
# Example configuration file
key: value
nested:
  option: true
```

---

## Templates

[List all template files in the templates/ directory with brief descriptions.
Templates are reusable boilerplates that users can copy/modify.]

- `templates/[template-name].md` — [What this template provides]
- `templates/[another-template].yml` — [What this template provides]

[If no templates, write: "No templates for this skill."]

---

## Examples

[List all example files in the examples/ directory with brief descriptions.
Examples show complete, real-world usage scenarios.]

- `examples/[example-name].md` — [What this example demonstrates]
- `examples/[another-example].md` — [What this example demonstrates]

[If no examples, write: "No examples for this skill."]

---

## Chaining

[List other skills that work well with this one. Explain why you'd chain them.
This helps Claude discover related skills and suggest workflows.]

| Chain With | Purpose |
|---|---|
| `[skill-name]` | [Why/when to use together] |
| `[another-skill]` | [Why/when to use together] |
| `[third-skill]` | [Why/when to use together] |

[If no obvious chains, write: "This skill works independently."]

---

## Troubleshooting

[Common issues users encounter and how to fix them. Use a table format for quick reference.]

| Problem | Solution |
|---|---|
| [Issue description] | [Fix or workaround] |
| [Another issue] | [Fix or workaround] |
| [Third issue] | [Fix or workaround] |

[If no known issues, write: "No common issues documented yet."]

---

## Additional Notes

[Optional section for:
- Important warnings or cautions
- Performance considerations
- Security implications
- Compatibility information
- Links to external documentation

Delete this section if not needed.]
```

---

## Guidelines for Using This Template

### Description (Frontmatter)

The `description` field is the **most important** part of your skill. It determines when Claude will discover and invoke your skill.

**Good description:**
```yaml
description: |
  Generates comprehensive API documentation from OpenAPI specs, including examples,
  error codes, and SDKs in multiple languages. Use when you have an OpenAPI/Swagger
  file and need client documentation, when API docs are outdated, or when onboarding
  new developers to your API.
```

**Bad description:**
```yaml
description: |
  Helps with API documentation.
```

**Rules:**
- Include WHAT the skill does (1 sentence)
- Include WHEN to use it (multiple scenarios)
- Be specific about inputs/outputs
- Use keywords that match user intent

### Procedures

- Keep each procedure focused on ONE task
- Use numbered steps for sequential actions
- Include code examples with comments
- Show expected outputs
- Add tables for comparisons or options
- Use subsections if a procedure is complex

### Keep It Under 500 Lines

If your SKILL.md exceeds 500 lines:
1. Move detailed content to REFERENCE.md
2. Keep high-level procedures in SKILL.md
3. Link to REFERENCE.md: "For detailed implementation, see REFERENCE.md"

### Examples Are Critical

Include at least one complete example showing:
- Real-world scenario
- Full procedure from start to finish
- Actual commands/code (not placeholders)
- Expected results

### Chaining

Help Claude build workflows by suggesting related skills:
- Skills that run before this one (setup/prerequisites)
- Skills that run after this one (deployment/verification)
- Skills that complement this one (parallel workflows)

---

## Validation Checklist

Before finalizing your skill, verify:

- [ ] `name` is lowercase-hyphens, max 64 chars
- [ ] `description` includes WHAT and WHEN (trigger scenarios)
- [ ] Description is detailed enough for discovery
- [ ] Body is under 500 lines (move overflow to REFERENCE.md)
- [ ] At least 1 example in `examples/` directory
- [ ] Procedures are numbered and actionable
- [ ] Code examples have comments
- [ ] Troubleshooting table has common issues
- [ ] Chaining section suggests related skills
- [ ] No hardcoded framework assumptions (unless domain-specific)
- [ ] All file references use relative paths from skill directory

---

Save this template as `SKILL.md` in your skill directory and start filling it in!
