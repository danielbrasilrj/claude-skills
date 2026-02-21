#!/usr/bin/env node
/**
 * skill-index-generator.js
 *
 * Reads all .claude/skills/*/SKILL.md files, parses YAML frontmatter,
 * and generates a markdown table with: name, description, category.
 *
 * Usage:
 *   node tools/skill-index-generator.js              # prints to stdout
 *   node tools/skill-index-generator.js > INDEX.md   # writes to file
 *
 * Uses only built-in Node.js modules (no npm dependencies).
 */

const fs = require("fs");
const path = require("path");

const SKILLS_DIR = path.resolve(__dirname, "..", ".claude", "skills");

/**
 * Category mapping based on skill directory name.
 * Used as fallback when frontmatter does not specify a category.
 */
const CATEGORY_MAP = {
  "deep-research": "research",
  "domain-intelligence": "research",
  "data-analysis": "research",
  "figma-handoff": "design",
  "conversion-copywriting": "design",
  "ab-test-generator": "design",
  "cross-platform-dev": "engineering",
  "api-contract-testing": "engineering",
  "ci-cd-pipeline": "engineering",
  "code-review": "engineering",
  "database-ops": "engineering",
  "sprint-planning": "management",
  "documentation-generator": "management",
  "prd-driven-development": "management",
  "social-media-content": "content",
  "email-marketing": "content",
  "seo-local": "content",
  "remote-trigger": "automation",
  "web-scraping": "automation",
  "notification-system": "automation",
  "testing-strategy": "quality",
  "accessibility-audit": "quality",
  "performance-optimization": "quality",
  "security-review": "security",
  "secret-management": "security",
  "skill-creator": "meta",
};

/**
 * Parse YAML frontmatter from a markdown string.
 * Handles basic YAML key: value pairs and multi-line description strings.
 * Returns an object with parsed fields.
 */
function parseFrontmatter(content) {
  const frontmatter = {};

  // Check for YAML frontmatter delimiters
  if (!content.startsWith("---")) {
    return frontmatter;
  }

  const endIndex = content.indexOf("---", 3);
  if (endIndex === -1) {
    return frontmatter;
  }

  const yamlBlock = content.substring(3, endIndex).trim();
  const lines = yamlBlock.split("\n");

  let currentKey = null;
  let currentValue = "";

  for (const line of lines) {
    // Check if this is a new key: value pair
    const keyValueMatch = line.match(/^(\w[\w-]*)\s*:\s*(.*)$/);

    if (keyValueMatch) {
      // Save previous key if any
      if (currentKey) {
        frontmatter[currentKey] = cleanValue(currentValue);
      }

      currentKey = keyValueMatch[1];
      currentValue = keyValueMatch[2];
    } else if (currentKey && (line.startsWith("  ") || line.startsWith("\t"))) {
      // Continuation of multi-line value
      currentValue += " " + line.trim();
    }
  }

  // Save last key
  if (currentKey) {
    frontmatter[currentKey] = cleanValue(currentValue);
  }

  return frontmatter;
}

/**
 * Remove surrounding quotes and trim whitespace from a YAML value.
 */
function cleanValue(value) {
  let cleaned = value.trim();
  // Remove surrounding quotes (single or double)
  if (
    (cleaned.startsWith('"') && cleaned.endsWith('"')) ||
    (cleaned.startsWith("'") && cleaned.endsWith("'"))
  ) {
    cleaned = cleaned.slice(1, -1);
  }
  return cleaned;
}

/**
 * Discover all skill directories and read their SKILL.md frontmatter.
 */
function discoverSkills() {
  const skills = [];

  if (!fs.existsSync(SKILLS_DIR)) {
    console.error(`Error: Skills directory not found at ${SKILLS_DIR}`);
    console.error("Make sure you are running this from the project root.");
    process.exit(1);
  }

  const entries = fs.readdirSync(SKILLS_DIR, { withFileTypes: true });

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;

    const skillName = entry.name;
    const skillMdPath = path.join(SKILLS_DIR, skillName, "SKILL.md");

    const skill = {
      name: skillName,
      description: "(no SKILL.md found)",
      category: CATEGORY_MAP[skillName] || "uncategorized",
      hasSkillMd: false,
    };

    if (fs.existsSync(skillMdPath)) {
      skill.hasSkillMd = true;
      const content = fs.readFileSync(skillMdPath, "utf-8");
      const frontmatter = parseFrontmatter(content);

      if (frontmatter.name) {
        skill.name = frontmatter.name;
      }
      if (frontmatter.description) {
        skill.description = frontmatter.description;
      }
      if (frontmatter.category) {
        skill.category = frontmatter.category;
      }
    }

    skills.push(skill);
  }

  // Sort by category, then by name
  skills.sort((a, b) => {
    const catOrder = [
      "research",
      "design",
      "engineering",
      "management",
      "content",
      "automation",
      "quality",
      "security",
      "meta",
      "uncategorized",
    ];
    const catA = catOrder.indexOf(a.category);
    const catB = catOrder.indexOf(b.category);
    if (catA !== catB) return catA - catB;
    return a.name.localeCompare(b.name);
  });

  return skills;
}

/**
 * Generate a markdown table from discovered skills.
 */
function generateTable(skills) {
  const lines = [];

  lines.push("# Skill Index");
  lines.push("");
  lines.push(
    `> Auto-generated by \`skill-index-generator.js\` on ${new Date().toISOString().split("T")[0]}`
  );
  lines.push(`> Found **${skills.length}** skill(s)`);
  lines.push("");
  lines.push("| # | Name | Category | Description | SKILL.md |");
  lines.push("|---|------|----------|-------------|----------|");

  skills.forEach((skill, index) => {
    const status = skill.hasSkillMd ? "Yes" : "No";
    const description = skill.description.replace(/\|/g, "\\|");
    lines.push(
      `| ${index + 1} | \`${skill.name}\` | ${skill.category} | ${description} | ${status} |`
    );
  });

  lines.push("");
  return lines.join("\n");
}

// ── Main ────────────────────────────────────────────────────────────

const skills = discoverSkills();
const output = generateTable(skills);
process.stdout.write(output);
