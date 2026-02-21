# Component Specification Template

Use this template for handing off any component from Figma to engineering.

---

## Component Name

**[Component Name]** (e.g., Button, Input, Modal, Card)

---

## Purpose

**What problem does this component solve?**

[1-2 sentences describing the component's purpose and when to use it]

**Example:**
> The Button component allows users to trigger actions, submit forms, or navigate. It provides consistent visual feedback across all interactive states.

---

## Visual Reference

**Figma Link:** [Insert Figma frame URL]

**Screenshots:**
- [Attach screenshot of all variants side-by-side]
- [Attach screenshot of all states for primary variant]

---

## Variants

Document all dimensions of variation:

| Variant Dimension | Options | Default |
|------------------|---------|---------|
| **Size** | [xs, sm, md, lg, xl] | [md] |
| **Style** | [primary, secondary, outline, ghost, danger] | [primary] |
| **Icon Position** | [none, left, right, icon-only] | [none] |
| **Width** | [auto, full-width] | [auto] |

**Total unique variants:** [X combinations documented below]

---

## Props/Attributes

Framework-agnostic component API:

| Prop | Type | Values | Default | Required | Description |
|------|------|--------|---------|----------|-------------|
| `label` | string | any | — | Yes | [Description] |
| `size` | enum | [values] | [default] | No | [Description] |
| `style` | enum | [values] | [default] | No | [Description] |
| `disabled` | boolean | true, false | false | No | [Description] |
| `loading` | boolean | true, false | false | No | [Description] |
| `icon` | string | icon-name | — | No | [Description] |
| `iconPosition` | enum | left, right | left | No | [Description] |
| `fullWidth` | boolean | true, false | false | No | [Description] |
| `onClick` | function | — | — | No | [Description] |

---

## States

Document visual changes for every interactive state:

| State | Visual Changes | Design Tokens Used | Notes |
|-------|----------------|-------------------|-------|
| **Default** | [Describe appearance] | [List tokens] | [Any notes] |
| **Hover** | [Describe changes] | [List tokens] | [Pointer cursor] |
| **Focus** | [Describe focus ring] | [List tokens] | [Keyboard accessible] |
| **Active** | [Describe pressed state] | [List tokens] | [While clicking] |
| **Disabled** | [Describe disabled look] | [List tokens] | [No pointer events] |
| **Loading** | [Describe loading spinner] | [List tokens] | [Optional state] |

---

## Design Tokens

Map every visual property to a design token:

### Primary Variant (Medium Size)

#### Background
```yaml
default: color-action-primary
hover: color-action-primary-hover
active: color-action-primary-active
disabled: color-action-primary-disabled
```

#### Text
```yaml
default: color-text-inverse
disabled: color-text-inverse (with opacity-disabled)
```

#### Border
```yaml
default: none
focus: color-border-focus (4px ring)
```

#### Spacing
```yaml
padding-x: spacing-component-padding-md
padding-y: spacing-component-padding-sm
gap: spacing-component-gap-sm (between icon and label)
```

#### Typography
```yaml
font: font-label-md
```

#### Border Radius
```yaml
radius: radius-interactive-md
```

#### Elevation
```yaml
default: elevation-none
focus: elevation-sm
```

---

### Secondary Variant (Medium Size)

[Repeat token mapping for secondary variant]

---

### Outline Variant (Medium Size)

[Repeat token mapping for outline variant]

---

## Responsive Behavior

Document how the component adapts across breakpoints:

| Breakpoint | Layout | Size | Spacing | Other Changes |
|------------|--------|------|---------|---------------|
| **xs (0-319px)** | [Behavior] | [Size] | [Spacing] | [Notes] |
| **sm (320-767px)** | [Behavior] | [Size] | [Spacing] | [Notes] |
| **md (768-1023px)** | [Behavior] | [Size] | [Spacing] | [Notes] |
| **lg (1024-1439px)** | [Behavior] | [Size] | [Spacing] | [Notes] |
| **xl (1440px+)** | [Behavior] | [Size] | [Spacing] | [Notes] |

**Example (Button):**
| Breakpoint | Width | Size | Notes |
|------------|-------|------|-------|
| xs-sm | Full-width | md | Stacked if multiple buttons |
| md-xl | Auto-width | md | Inline side-by-side |

---

## Accessibility

### Focus Order

**Focusable:** [Yes / No]

**Tab order position:** [Number in sequence, or N/A]

**Example:**
```
1. Email input
2. Password input
3. Sign In button ← This component
4. Create account link
```

---

### ARIA Attributes

| Attribute | Value | When Used |
|-----------|-------|-----------|
| `role` | [role value] | [Condition] |
| `aria-label` | [label text] | [When no visible label] |
| `aria-disabled` | [true/false] | [When disabled] |
| `aria-expanded` | [true/false] | [For toggles/dropdowns] |
| `aria-pressed` | [true/false] | [For toggle buttons] |
| `aria-busy` | [true] | [When loading] |

**Example (Button):**
| Attribute | Value | When Used |
|-----------|-------|-----------|
| `role` | `button` | Only if using `<div>` or `<span>` instead of `<button>` |
| `aria-label` | Custom label | Icon-only buttons (e.g., "Close modal") |
| `aria-disabled` | `true` | When disabled=true |
| `aria-busy` | `true` | When loading=true |

---

### Keyboard Interactions

| Key | Action |
|-----|--------|
| `Enter` | [Action description] |
| `Space` | [Action description] |
| `Tab` | [Action description] |
| `Shift+Tab` | [Action description] |
| `Escape` | [Action description, if applicable] |

**Example (Button):**
| Key | Action |
|-----|--------|
| `Enter` or `Space` | Activate button (trigger onClick) |
| `Tab` | Move focus to next focusable element |
| `Shift+Tab` | Move focus to previous focusable element |

---

### Screen Reader Announcement

**Default state:**
> "[Label], button"

**Disabled state:**
> "[Label], button, dimmed"

**Loading state:**
> "[Label], button, busy"

**Icon-only with aria-label:**
> "[aria-label value], button"

---

### Color Contrast

Verify all text and UI elements meet WCAG 2.1 AA:

| Element | Foreground | Background | Ratio | Pass/Fail |
|---------|------------|------------|-------|-----------|
| Button label (default) | [color token] | [color token] | [X:1] | [✅/❌] |
| Button label (hover) | [color token] | [color token] | [X:1] | [✅/❌] |
| Button border (outline) | [color token] | [color token] | [X:1] | [✅/❌] |
| Focus ring | [color token] | [color token] | [X:1] | [✅/❌] |

**Minimum required:**
- Text (< 18px): 4.5:1
- Text (≥ 18px or ≥ 14px bold): 3:1
- UI components: 3:1

**Tool:** [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

---

## i18n Considerations

### Text Expansion

**Longest expected label length (English):** [X characters]

**pt-BR expansion estimate:** [+25-30%]

**Container width strategy:**
- [ ] Fixed width (specify max characters supported)
- [x] Flexible width with padding (recommended)
- [ ] Allow wrapping to 2 lines

**Example:**
- English: "Save" (4 chars) → pt-BR: "Salvar" (6 chars)
- Design for up to 8 characters to accommodate longer labels

---

### RTL Support

**Does this component need RTL support?** [Yes / No]

**If yes, what needs to flip:**
- [ ] Layout direction (flex-direction: row-reverse)
- [ ] Icon position (left ↔ right)
- [ ] Padding/margin (swap left/right)
- [ ] Text alignment

**Icon mirroring required:** [Yes / No]
- If yes, specify which icons need mirrored versions (e.g., arrows, chevrons)

---

## Assets

List all exported assets needed for implementation:

### Icons

| Icon Name | Usage | Format | Sizes | Notes |
|-----------|-------|--------|-------|-------|
| [icon-name] | [Where used] | SVG | [20px, 24px] | [Color, stroke, etc.] |

**Example:**
| Icon Name | Usage | Format | Sizes | Notes |
|-----------|-------|--------|-------|-------|
| `icon-arrow-right` | Right icon position | SVG | 20px | Single color, 2px stroke |
| `icon-spinner` | Loading state | SVG (animated) | 20px | Replaces icon/label |

---

### Images

| Image Name | Usage | Format | Sizes | Notes |
|-----------|-------|--------|-------|-------|
| [image-name] | [Where used] | [PNG/JPG/SVG] | [1x, 2x, 3x] | [Notes] |

---

## Edge Cases

Document unusual scenarios and how to handle them:

| Scenario | Behavior | Notes |
|----------|----------|-------|
| Very long label text | [Truncate / Wrap / Scroll] | [Additional details] |
| Icon-only with no label | [Must include aria-label] | [Screen reader requirement] |
| Multiple buttons side-by-side | [Layout behavior] | [Spacing, responsive stacking] |
| Button in loading state | [Disable interactions] | [Show spinner, maintain width] |

**Example (Button):**
| Scenario | Behavior | Notes |
|----------|----------|-------|
| Label > 50 characters | Text wraps to 2 lines max, then truncates with "..." | Avoid long labels; use tooltips for full text |
| Icon-only button | Must include `aria-label` | Screen reader needs label (e.g., "Close") |
| Loading state | Disable button, show spinner, keep width stable | Prevents layout shift |

---

## Usage Guidelines

### When to Use

- [Use case 1]
- [Use case 2]
- [Use case 3]

**Example (Button):**
- Primary actions (submit forms, complete workflows)
- Navigation (next step, go to page)
- Triggering modals or dialogs

---

### When NOT to Use

- [Anti-pattern 1]
- [Anti-pattern 2]
- [Anti-pattern 3]

**Example (Button):**
- Links to external pages (use `<a>` tag instead)
- Non-interactive decorative elements
- Inline text actions (use text link instead)

---

## Code Considerations

**Semantic HTML:**
```html
<!-- Use <button> element, not <div> or <span> -->
<button type="button" class="btn btn-primary">
  [Label]
</button>
```

**Accessibility requirements:**
- Always use `<button>` element (not `<div role="button">` unless necessary)
- Include `type="button"` (prevents form submission if inside `<form>`)
- Disabled state: use `disabled` attribute + `aria-disabled="true"`

---

## Related Components

List related components that may be used together:

- [Component 1] — [Relationship]
- [Component 2] — [Relationship]

**Example (Button):**
- Icon component — Used inside button for left/right icons
- Spinner component — Shown during loading state
- Tooltip component — Can wrap button for additional context

---

## Notes

[Add any additional context, open questions, or implementation notes here]
