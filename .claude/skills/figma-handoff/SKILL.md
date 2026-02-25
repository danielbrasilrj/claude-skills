---
name: figma-handoff
description: Figma-to-code handoff — component specs, responsive breakpoints, a11y annotations, and design token mappings.
---

# Figma Handoff

## Purpose

Bridge the gap between design and engineering by producing structured,
framework-agnostic component specifications from Figma designs. Every handoff
includes responsive behavior, accessibility requirements, design token
references, and i18n considerations for text expansion across locales.

## When to Use

- A designer shares a Figma link or frame for implementation.
- A developer needs component specs before coding.
- You need to document responsive breakpoints for a layout.
- Accessibility annotations (focus order, ARIA roles) are required.
- Design tokens must be mapped from Figma styles to code variables.
- A component must support multiple locales with different text lengths.

## Prerequisites

- Figma file URL or exported frame images.
- Access to the project's design token naming convention (or use the
  functional naming defaults in this skill).
- Knowledge of target breakpoints (defaults: 320, 768, 1024, 1440 px).

## Procedures

### 1. Gather Design Context

Collect the following from the Figma source:

| Input               | Source                         |
| ------------------- | ------------------------------ |
| Component name      | Figma layer/frame name         |
| Variants            | Figma component set variants   |
| Spacing & sizing    | Auto-layout or manual values   |
| Colors              | Figma color styles             |
| Typography          | Figma text styles              |
| Icons/assets        | Exported SVG or icon names     |
| States              | Hover, focus, active, disabled |
| Responsive behavior | Constraints / auto-layout      |

### 2. Map Design Tokens

Use **functional naming** -- tokens describe purpose, not value:

```
color-action-primary        // not "blue-500"
color-text-default          // not "gray-900"
spacing-component-gap-md    // not "16px"
font-heading-lg             // not "Inter 24 Bold"
radius-interactive-default  // not "8px"
```

See [design-token-taxonomy.md](design-token-taxonomy.md) for the full token taxonomy.

### 3. Define Responsive Breakpoints

Document behavior at each breakpoint:

| Breakpoint | Width   | Layout changes              |
| ---------- | ------- | --------------------------- |
| xs         | < 320px | Stack vertical, full-width  |
| sm         | 320px   | Mobile baseline             |
| md         | 768px   | Tablet / two-column         |
| lg         | 1024px  | Desktop baseline            |
| xl         | 1440px  | Wide desktop, max-width cap |

For each breakpoint, note:

- Layout direction changes (row to column).
- Visibility toggling (show/hide elements).
- Font size scaling.
- Spacing adjustments.

### 4. Annotate Accessibility

For every interactive component:

1. **Focus order** -- Number each focusable element in tab sequence.
2. **ARIA role** -- Specify `role`, `aria-label`, `aria-expanded`, etc.
3. **Keyboard interaction** -- Document Enter, Space, Escape, Arrow behavior.
4. **Color contrast** -- Confirm WCAG 2.1 AA ratios (4.5:1 text, 3:1 large).
5. **Screen reader announcement** -- Write the expected spoken output.

### 5. Account for i18n Text Expansion

Portuguese (pt-BR) text is typically 20-30% longer than English. Design must
accommodate expansion:

| English length | pt-BR expansion | Example                                  |
| -------------- | --------------- | ---------------------------------------- |
| 1-10 chars     | +30%            | "Save" -> "Salvar"                       |
| 11-20 chars    | +25%            | "Add to cart" -> "Adicionar ao carrinho" |
| 21-40 chars    | +20%            | Longer strings compress ratio            |
| 40+ chars      | +15%            | Paragraphs expand less                   |

Rules:

- Never use fixed-width containers for translatable text.
- Allow min 2 lines for single-line labels in compact layouts.
- Test with pt-BR strings during spec review.

### 6. Generate Component Spec

Use the template at `templates/component-spec.md`. Fill every section.
Output is framework-agnostic -- no React/Vue/Angular-specific code.

### 7. Review Checklist

Before delivering the handoff:

- [ ] All design tokens use functional names.
- [ ] Responsive behavior documented for all breakpoints.
- [ ] Focus order numbered and keyboard interactions listed.
- [ ] ARIA attributes specified for interactive elements.
- [ ] Color contrast ratios verified (AA minimum).
- [ ] Text expansion tested with pt-BR equivalents.
- [ ] Assets exported and named consistently.
- [ ] States documented: default, hover, focus, active, disabled, loading.

## Templates

- `templates/component-spec.md` -- Full component specification template.

## Examples

- `examples/button-component-handoff.md` -- Complete Button component handoff.

## Chaining

| Skill                  | Relationship                              |
| ---------------------- | ----------------------------------------- |
| conversion-copywriting | Review CTA copy before handoff            |
| ab-test-generator      | Define experiment variants from specs     |
| accessibility-audit    | Deep-dive audit after initial annotations |

## References

- [design-token-taxonomy.md](design-token-taxonomy.md) -- Full token taxonomy (colors, typography, spacing, elevation, radius, icons, opacity)
- [component-spec.md](component-spec.md) -- Component spec deep dive (anatomy, variants, props, states, token mapping)
- [responsive-breakpoints.md](responsive-breakpoints.md) -- Breakpoint documentation and responsive design patterns
- [accessibility-annotations.md](accessibility-annotations.md) -- WCAG 2.1 AA guide (contrast, focus, ARIA, keyboard, screen reader, alt text, i18n)
- [handoff-checklist.md](handoff-checklist.md) -- Complete pre-delivery checklist

## Troubleshooting

| Issue                    | Resolution                                 |
| ------------------------ | ------------------------------------------ |
| Figma styles not mapped  | Export CSS from Figma Dev Mode or Inspect  |
| Token names conflict     | Prefix with component scope: `btn-*`       |
| pt-BR text overflows     | Switch to flex/auto layout, add min-height |
| Focus order ambiguous    | Ask designer to annotate reading order     |
| Missing states in design | Document gap, request designer update      |
