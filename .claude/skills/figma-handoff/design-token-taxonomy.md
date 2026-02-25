# Design Token Taxonomy

## Why Functional Naming?

**Functional tokens** describe purpose, not value. This allows design systems to scale across themes, modes, and platforms.

**Bad (literal):**

```
color-blue-500
spacing-16px
font-inter-24-bold
```

**Good (functional):**

```
color-action-primary
spacing-component-gap-md
font-heading-lg
```

**Benefits:**

- Easy theme switching (light/dark mode)
- Platform-agnostic (works in web, iOS, Android)
- Self-documenting (name describes usage)

---

## Color Token Structure

### Semantic Color Tokens

Use this hierarchy: `color-[category]-[variant]-[state]`

**Categories:**

#### Action Colors (Interactive Elements)

```
color-action-primary          // Primary buttons, links
color-action-primary-hover    // Hover state
color-action-primary-active   // Active/pressed state
color-action-primary-disabled // Disabled state

color-action-secondary        // Secondary buttons
color-action-secondary-hover
color-action-secondary-active
color-action-secondary-disabled

color-action-danger           // Destructive actions (delete, remove)
color-action-danger-hover
color-action-danger-active
color-action-danger-disabled
```

#### Surface Colors (Backgrounds)

```
color-surface-page            // Page background
color-surface-container       // Card, modal backgrounds
color-surface-container-low   // Subtle container (lower elevation)
color-surface-container-high  // Emphasized container (higher elevation)
color-surface-overlay         // Overlay background (modals, dropdowns)
color-surface-inverse         // Dark surface on light theme (or vice versa)
```

#### Border Colors

```
color-border-default          // Default border
color-border-subtle           // Low-contrast border
color-border-strong           // High-contrast border
color-border-focus            // Focus ring
color-border-danger           // Error state border
```

#### Text Colors

```
color-text-default            // Primary text
color-text-subtle             // Secondary text
color-text-disabled           // Disabled text
color-text-inverse            // Text on dark backgrounds
color-text-danger             // Error messages
color-text-success            // Success messages
color-text-link               // Link text
color-text-link-hover         // Link hover
```

#### Feedback Colors

```
color-feedback-success
color-feedback-success-subtle // Background for success banners
color-feedback-warning
color-feedback-warning-subtle
color-feedback-error
color-feedback-error-subtle
color-feedback-info
color-feedback-info-subtle
```

---

## Typography Token Structure

Use this hierarchy: `font-[category]-[size]-[weight]` (optional weight)

### Font Family Tokens

```
font-family-sans              // Primary sans-serif
font-family-serif             // Serif for long-form content
font-family-mono              // Code, data, monospace
```

### Text Style Tokens

**Headings:**

```
font-heading-xl               // H1, hero text
font-heading-lg               // H2
font-heading-md               // H3
font-heading-sm               // H4
font-heading-xs               // H5, H6
```

**Body Text:**

```
font-body-lg                  // Large body (18-20px)
font-body-md                  // Default body (16px)
font-body-sm                  // Small body (14px)
font-body-xs                  // Tiny text (12px)
```

**Special:**

```
font-label-lg                 // Large label
font-label-md                 // Default label
font-label-sm                 // Small label (form labels)
font-code                     // Monospace code
font-caption                  // Image captions, footnotes
```

### Full Typography Token Spec

Each token includes:

- `font-family`
- `font-size`
- `font-weight`
- `line-height`
- `letter-spacing` (optional)

**Example:**

```css
/* font-heading-lg */
font-family: var(--font-family-sans);
font-size: 32px;
font-weight: 700; /* Bold */
line-height: 1.25; /* 40px */
letter-spacing: -0.02em;
```

---

## Spacing Token Structure

Use this hierarchy: `spacing-[category]-[size]`

### Layout Spacing

```
spacing-layout-xs             // 4px
spacing-layout-sm             // 8px
spacing-layout-md             // 16px
spacing-layout-lg             // 24px
spacing-layout-xl             // 32px
spacing-layout-2xl            // 48px
spacing-layout-3xl            // 64px
```

### Component Spacing

```
spacing-component-gap-xs      // 4px — tight component gaps
spacing-component-gap-sm      // 8px
spacing-component-gap-md      // 12px
spacing-component-gap-lg      // 16px
spacing-component-padding-sm  // 8px — inner padding
spacing-component-padding-md  // 12px
spacing-component-padding-lg  // 16px
```

### Grid Spacing

```
spacing-grid-gutter           // Column gutter (16px or 24px)
spacing-grid-margin           // Page margins
```

---

## Elevation / Shadow Tokens

Use this hierarchy: `elevation-[level]`

```
elevation-none                // No shadow
elevation-sm                  // Subtle shadow (dropdowns, tooltips)
elevation-md                  // Standard shadow (cards)
elevation-lg                  // Emphasized shadow (modals)
elevation-xl                  // Heavy shadow (floating action buttons)
```

**CSS Example:**

```css
/* elevation-md */
box-shadow:
  0px 2px 8px rgba(0, 0, 0, 0.1),
  0px 1px 2px rgba(0, 0, 0, 0.06);
```

---

## Border Radius Tokens

Use this hierarchy: `radius-[category]-[size]`

```
radius-interactive-sm         // 4px — buttons, inputs
radius-interactive-md         // 8px — default buttons
radius-interactive-lg         // 12px — large buttons
radius-interactive-full       // 9999px — pill-shaped buttons

radius-container-sm           // 8px — small cards
radius-container-md           // 12px — default cards
radius-container-lg           // 16px — large modals
```

---

## Icon Size Tokens

```
icon-size-xs                  // 12px
icon-size-sm                  // 16px
icon-size-md                  // 20px
icon-size-lg                  // 24px
icon-size-xl                  // 32px
```

---

## Opacity Tokens

```
opacity-disabled              // 0.4
opacity-subtle                // 0.6
opacity-overlay               // 0.8
opacity-full                  // 1.0
```
