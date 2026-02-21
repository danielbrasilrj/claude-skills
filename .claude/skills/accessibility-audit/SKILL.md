---
name: accessibility-audit
description: |
  Audits and fixes accessibility issues in mobile and web apps. Covers screen reader compatibility,
  color contrast verification, touch target sizes, and WCAG 2.1 AA compliance. Includes automated
  testing setup (axe-core, Pa11y, Lighthouse CI) and manual testing procedures. Use when auditing
  accessibility, fixing a11y issues, setting up automated a11y testing, or ensuring WCAG compliance.
---

## Purpose

Accessibility Audit provides structured procedures for identifying and fixing accessibility issues across mobile and web platforms. It combines automated testing tools with manual verification checklists mapped to WCAG 2.1 AA success criteria to ensure apps are usable by everyone.

## When to Use

- Auditing an app for accessibility compliance
- Fixing specific accessibility issues
- Setting up automated accessibility testing in CI
- Preparing for an accessibility certification
- Reviewing a new feature for a11y before release

## Prerequisites

- Access to the app (web URL or device build)
- Screen readers for manual testing (VoiceOver, TalkBack, NVDA)
- Optional: axe-core, Pa11y, Lighthouse CI

## Procedures

### 1. Automated Scan (catches ~30-40% of issues)

Run automated tools first to catch low-hanging fruit:

```bash
# Lighthouse CLI
npx lighthouse https://app.example.com --only-categories=accessibility --output=json

# Pa11y
npx pa11y https://app.example.com --standard WCAG2AA

# axe-core in tests
npm install --save-dev jest-axe
```

### 2. Color Contrast Check

**WCAG 2.1 AA Requirements:**
- Normal text: **4.5:1** contrast ratio minimum
- Large text (18pt+ or 14pt+ bold): **3:1** minimum
- UI components and graphics: **3:1** minimum

Tools: WebAIM Contrast Checker, Chrome DevTools color picker

### 3. Touch Target Verification (Mobile)

- **Minimum (WCAG 2.5.8 AA):** 24×24 CSS pixels
- **Recommended (WCAG 2.5.5 AAA):** 44×44 CSS pixels
- Ensure adequate spacing between targets

### 4. Screen Reader Testing

Test with real assistive technology:

| Platform | Screen Reader | Shortcut |
|---|---|---|
| iOS | VoiceOver | Settings → Accessibility → VoiceOver |
| Android | TalkBack | Settings → Accessibility → TalkBack |
| macOS | VoiceOver | Cmd+F5 |
| Windows | NVDA | Free download from nvaccess.org |

**Verify:**
- [ ] All interactive elements are reachable and announced
- [ ] Images have meaningful alt text (decorative = `alt=""`)
- [ ] Headings follow logical hierarchy (h1 → h2 → h3)
- [ ] Form inputs have associated labels
- [ ] Dynamic content changes are announced (ARIA live regions)
- [ ] Focus order matches visual order

### 5. Keyboard Navigation (Web)

- [ ] All interactive elements reachable via Tab
- [ ] Focus indicator visible on all focused elements
- [ ] Escape closes modals and returns focus
- [ ] No keyboard traps
- [ ] Skip-to-content link present

### 6. Mobile-Specific Checks (WCAG 2.1)

- [ ] Content not locked to single orientation (1.3.4)
- [ ] Content reflows at 320px width without horizontal scroll (1.4.10)
- [ ] Single-pointer alternatives for multi-touch gestures (2.5.1)
- [ ] Motion-triggered actions have alternatives (2.5.4)

## Templates

- `templates/a11y-audit-checklist.md` — Full WCAG 2.1 AA checklist

## Examples

- `examples/audit-report-example.md` — Complete audit report

## Chaining

| Chain With | Purpose |
|---|---|
| `code-review` | Include a11y in code review checklist |
| `figma-handoff` | Verify designs meet a11y requirements |
| `ci-cd-pipeline` | Add automated a11y testing to pipeline |
| `testing-strategy` | Include a11y tests in test plan |

## Troubleshooting

| Problem | Solution |
|---|---|
| Too many automated findings | Prioritize: focus indicators → contrast → alt text → ARIA |
| False positives from tools | Verify manually; automated tools over-flag edge cases |
| Custom components not accessible | Use native semantics; add ARIA only when native isn't sufficient |
| Color contrast fails but design team resists | Show WCAG legal requirements; propose alternatives that meet both |
