---
name: domain-intelligence
description: Embeds stack decisions, approved libs, forbidden patterns. Read before any technical recommendation.
user-invocable: false
---

## Purpose

Domain Intelligence is a background knowledge skill that defines the architectural rules, tech stack decisions, and organizational constraints for a project. It acts as a guardrail — Claude reads it before recommending any technology, library, or pattern to ensure alignment with project-specific decisions.

## When to Use

- Before making any technology recommendation
- When starting development on a new project
- When Claude needs to understand which database, framework, or service is approved
- When reviewing code for compliance with organizational standards
- When generating architecture documentation

## Prerequisites

- A filled-in `templates/architecture-decisions.yml` for your project
- Understanding of your organization's tech stack and constraints

## Procedures

### 1. Initialize Domain Intelligence for a Project

Copy `templates/architecture-decisions.yml` to your project root and fill in your stack:

```bash
cp .claude/skills/domain-intelligence/templates/architecture-decisions.yml ./architecture-decisions.yml
```

### 2. Define Your Stack

Edit the YAML file with your project's specific choices. Key sections:

- **platform**: Target platforms (ios, android, web)
- **framework**: Primary framework (react-native, flutter, nextjs, etc.)
- **language**: Primary language and version
- **database**: Database choice and hosting
- **approved_libraries**: Vetted and approved packages
- **forbidden_patterns**: Anti-patterns and banned approaches
- **api_conventions**: REST/GraphQL standards, naming, versioning
- **deployment**: CI/CD, hosting, environments

### 3. Reference in Other Skills

Other skills should check domain-intelligence before recommending tools:

```
Before recommending a specific technology:
1. Read the project's architecture-decisions.yml
2. Check if the recommendation aligns with approved_libraries
3. Verify it doesn't violate forbidden_patterns
4. If no constraint exists, recommend the best general option and note it's not yet in the approved list
```

### 4. Update Process

When making a new architectural decision:

1. Document it in architecture-decisions.yml
2. Add an ADR using the `documentation-generator` skill
3. Notify the team of the change

## Templates

- `templates/architecture-decisions.yml` — Project stack configuration template

## Examples

- `examples/example-stack-config.yml` — Example for a React Native + Supabase project

## Chaining

| Chain With                | Purpose                                          |
| ------------------------- | ------------------------------------------------ |
| All technical skills      | Read before making any technology recommendation |
| `documentation-generator` | Generate ADRs for new decisions                  |
| `code-review`             | Validate code against approved patterns          |
| `ci-cd-pipeline`          | Align CI/CD with deployment targets              |

## Troubleshooting

| Problem                              | Solution                                                     |
| ------------------------------------ | ------------------------------------------------------------ |
| architecture-decisions.yml not found | Copy template to project root and customize                  |
| Conflicting constraints              | Flag to user; constraints may need updating                  |
| New library needed but not approved  | Recommend it with rationale; suggest adding to approved list |
