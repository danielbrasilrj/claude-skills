# Figma Handoff Reference Guide

## Table of Contents
1. [Design Token Taxonomy](#design-token-taxonomy)
2. [Component Spec Deep Dive](#component-spec-deep-dive)
3. [Responsive Breakpoint Documentation](#responsive-breakpoint-documentation)
4. [Accessibility Annotation Guide](#accessibility-annotation-guide)

---

## 1. Design Token Taxonomy

### Why Functional Naming?

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

### Color Token Structure

#### Semantic Color Tokens

Use this hierarchy: `color-[category]-[variant]-[state]`

**Categories:**

##### Action Colors (Interactive Elements)
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

##### Surface Colors (Backgrounds)
```
color-surface-page            // Page background
color-surface-container       // Card, modal backgrounds
color-surface-container-low   // Subtle container (lower elevation)
color-surface-container-high  // Emphasized container (higher elevation)
color-surface-overlay         // Overlay background (modals, dropdowns)
color-surface-inverse         // Dark surface on light theme (or vice versa)
```

##### Border Colors
```
color-border-default          // Default border
color-border-subtle           // Low-contrast border
color-border-strong           // High-contrast border
color-border-focus            // Focus ring
color-border-danger           // Error state border
```

##### Text Colors
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

##### Feedback Colors
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

### Typography Token Structure

Use this hierarchy: `font-[category]-[size]-[weight]` (optional weight)

#### Font Family Tokens
```
font-family-sans              // Primary sans-serif
font-family-serif             // Serif for long-form content
font-family-mono              // Code, data, monospace
```

#### Text Style Tokens

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

#### Full Typography Token Spec

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

### Spacing Token Structure

Use this hierarchy: `spacing-[category]-[size]`

#### Layout Spacing
```
spacing-layout-xs             // 4px
spacing-layout-sm             // 8px
spacing-layout-md             // 16px
spacing-layout-lg             // 24px
spacing-layout-xl             // 32px
spacing-layout-2xl            // 48px
spacing-layout-3xl            // 64px
```

#### Component Spacing
```
spacing-component-gap-xs      // 4px — tight component gaps
spacing-component-gap-sm      // 8px
spacing-component-gap-md      // 12px
spacing-component-gap-lg      // 16px
spacing-component-padding-sm  // 8px — inner padding
spacing-component-padding-md  // 12px
spacing-component-padding-lg  // 16px
```

#### Grid Spacing
```
spacing-grid-gutter           // Column gutter (16px or 24px)
spacing-grid-margin           // Page margins
```

---

### Elevation / Shadow Tokens

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
box-shadow: 0px 2px 8px rgba(0, 0, 0, 0.1), 0px 1px 2px rgba(0, 0, 0, 0.06);
```

---

### Border Radius Tokens

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

### Icon Size Tokens

```
icon-size-xs                  // 12px
icon-size-sm                  // 16px
icon-size-md                  // 20px
icon-size-lg                  // 24px
icon-size-xl                  // 32px
```

---

### Opacity Tokens

```
opacity-disabled              // 0.4
opacity-subtle                // 0.6
opacity-overlay               // 0.8
opacity-full                  // 1.0
```

---

## 2. Component Spec Deep Dive

### Anatomy of a Complete Component Spec

Every component spec must include:

1. **Component name** — Clear, concise (e.g., `Button`, `Input`, `Modal`)
2. **Purpose** — What problem does it solve?
3. **Variants** — All visual variants (size, style, state)
4. **Props/Attributes** — Framework-agnostic parameters
5. **States** — Default, hover, focus, active, disabled, loading, error
6. **Design tokens** — All colors, spacing, typography mapped to tokens
7. **Responsive behavior** — How it adapts across breakpoints
8. **Accessibility** — Focus order, ARIA, keyboard interactions, color contrast
9. **i18n considerations** — Text expansion, RTL support
10. **Assets** — Icons, images, export specs

---

### Component Variant Documentation

#### Variant Dimensions

Document every axis of variation:

| Dimension | Values | Example Component |
|-----------|--------|-------------------|
| **Size** | xs, sm, md, lg, xl | Button |
| **Style** | primary, secondary, outline, ghost, danger | Button |
| **State** | default, hover, focus, active, disabled, loading | Button |
| **Icon position** | left, right, icon-only | Button |

#### Variant Matrix Example (Button)

| Size | Style | State | Icon | Example |
|------|-------|-------|------|---------|
| md | primary | default | left | `[→ Save]` |
| lg | secondary | hover | right | `[Next →]` hover |
| sm | danger | disabled | none | `[Delete]` disabled |
| md | outline | focus | left | `[+ Add]` focused |

**Total combinations:** 5 sizes × 5 styles × 6 states × 3 icon positions = **450 possible variants**

**Best practice:** Document core variants only (e.g., 12-20 key combinations), then define combination rules.

---

### Props/Attributes Documentation

**Framework-agnostic format:**

| Prop | Type | Values | Default | Required | Description |
|------|------|--------|---------|----------|-------------|
| `label` | string | any | — | Yes | Button text |
| `size` | enum | xs, sm, md, lg, xl | md | No | Visual size |
| `style` | enum | primary, secondary, outline, ghost, danger | primary | No | Visual style |
| `icon` | string | icon-name | — | No | Icon to display |
| `iconPosition` | enum | left, right | left | No | Icon placement |
| `disabled` | boolean | true, false | false | No | Disabled state |
| `loading` | boolean | true, false | false | No | Loading state (shows spinner) |
| `fullWidth` | boolean | true, false | false | No | Expand to container width |
| `onClick` | function | — | — | No | Click handler |

---

### State Documentation

Document visual changes for every interactive state:

#### Button States Example

| State | Visual Changes | Design Tokens |
|-------|----------------|---------------|
| **Default** | Solid background | `color-action-primary`, `font-label-md` |
| **Hover** | Darker background | `color-action-primary-hover` |
| **Focus** | Focus ring (4px) | `color-border-focus` + `elevation-sm` |
| **Active** | Slightly darker, scale 0.98 | `color-action-primary-active` + transform |
| **Disabled** | 40% opacity, no pointer | `opacity-disabled` + cursor: not-allowed |
| **Loading** | Spinner replaces icon/text | `color-action-primary` + spinner animation |

---

### Design Token Mapping

**For every visual property, map to a design token:**

```yaml
# Button (Primary, Medium)
Background:
  default: color-action-primary
  hover: color-action-primary-hover
  active: color-action-primary-active
  disabled: color-action-primary-disabled

Text:
  default: color-text-inverse
  disabled: color-text-inverse (with opacity-disabled)

Border:
  default: none
  focus: color-border-focus (4px ring)

Spacing:
  padding-x: spacing-component-padding-md (12px)
  padding-y: spacing-component-padding-sm (8px)
  gap: spacing-component-gap-sm (8px between icon and label)

Typography:
  font: font-label-md

Border Radius:
  radius: radius-interactive-md (8px)

Elevation:
  default: elevation-none
  focus: elevation-sm
```

---

## 3. Responsive Breakpoint Documentation

### Standard Breakpoints

| Name | Min Width | Max Width | Common Devices | Layout Type |
|------|-----------|-----------|----------------|-------------|
| **xs** | 0px | 319px | Small phones (portrait) | Single column, full-width |
| **sm** | 320px | 767px | Phones (portrait) | Single column, mobile baseline |
| **md** | 768px | 1023px | Tablets, phones (landscape) | 2-column or tabs |
| **lg** | 1024px | 1439px | Desktop, laptops | Multi-column, desktop baseline |
| **xl** | 1440px | ∞ | Large desktop, ultra-wide | Max-width container (1280px) |

---

### Breakpoint Behavior Documentation Template

For each component, document how it changes at each breakpoint:

#### Button Example

| Breakpoint | Layout | Size | Spacing | Other |
|------------|--------|------|---------|-------|
| **xs-sm** | Full-width | md | padding: 12px | Stacked if multiple |
| **md** | Inline (auto-width) | md | padding: 12px 16px | Side-by-side |
| **lg-xl** | Inline | lg | padding: 14px 20px | Side-by-side |

#### Card Grid Example

| Breakpoint | Columns | Gap | Card Width | Max Width |
|------------|---------|-----|------------|-----------|
| **xs-sm** | 1 column | 16px | 100% | — |
| **md** | 2 columns | 24px | 50% - gap | — |
| **lg** | 3 columns | 24px | 33.33% - gap | — |
| **xl** | 3 columns | 32px | 33.33% - gap | 1280px container |

---

### Responsive Design Patterns

#### 1. Stacking Pattern
**Description:** Horizontal layouts become vertical on mobile

**Example:** Navigation menu
- **lg-xl:** Horizontal nav bar with inline links
- **sm-md:** Hamburger menu → vertical drawer

---

#### 2. Column Collapse Pattern
**Description:** Multi-column grids reduce to fewer columns or single column

**Example:** Product grid
- **xl:** 4 columns
- **lg:** 3 columns
- **md:** 2 columns
- **sm:** 1 column

---

#### 3. Content Reflow Pattern
**Description:** Sidebar content moves below main content on mobile

**Example:** Article + sidebar layout
- **lg-xl:** 2 columns (70% article, 30% sidebar)
- **sm-md:** Single column (article stacked above sidebar)

---

#### 4. Typography Scaling Pattern
**Description:** Font sizes reduce on smaller screens

**Example:** Heading sizes
```
font-heading-xl:
  lg-xl: 48px
  md: 36px
  sm: 28px
```

---

#### 5. Visibility Toggle Pattern
**Description:** Show/hide elements based on screen size

**Example:** Data table
- **lg-xl:** Full table with all columns
- **md:** Hide less important columns
- **sm:** Card view (stack rows vertically)

---

### Container Queries (Modern Approach)

**Container queries** (CSS `@container`) allow components to adapt based on their parent container width, not viewport width.

**Example:**
```css
/* Card adapts based on its container, not viewport */
.card {
  container-type: inline-size;
}

@container (min-width: 400px) {
  .card-content {
    display: flex; /* Side-by-side layout */
  }
}

@container (max-width: 399px) {
  .card-content {
    display: block; /* Stacked layout */
  }
}
```

**When to use:**
- Component must work in multiple contexts (sidebar, modal, grid)
- Parent width varies independently of viewport

---

## 4. Accessibility Annotation Guide

### WCAG 2.1 AA Requirements

#### Color Contrast Ratios

| Element Type | Minimum Ratio | Example |
|--------------|---------------|---------|
| Normal text (< 18px) | 4.5:1 | `#000000` on `#FFFFFF` = 21:1 ✅ |
| Large text (≥ 18px or ≥ 14px bold) | 3:1 | `#767676` on `#FFFFFF` = 4.54:1 ✅ |
| UI components (buttons, inputs) | 3:1 | Button border vs background |
| Graphical objects (icons, charts) | 3:1 | Icon color vs background |

**Tool:** Use [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

---

### Focus Order

**Definition:** The sequence in which elements receive keyboard focus when pressing `Tab`

**How to annotate:**
1. Number each focusable element in reading order
2. Mark non-focusable decorative elements with `N/A`
3. Note any skip links or focus traps

**Example (Login Form):**
```
1. Email input
2. Password input
3. "Show password" toggle
4. "Forgot password?" link
5. "Sign In" button
6. "Create account" link
```

**Best practices:**
- Focus order matches visual reading order (top-to-bottom, left-to-right)
- Skip repetitive navigation with "Skip to main content" link
- Modals trap focus inside (can't tab outside until closed)

---

### ARIA Roles and Attributes

#### Common ARIA Roles

| Role | Use Case | Example |
|------|----------|---------|
| `button` | Non-button elements acting as buttons | `<div role="button">` |
| `navigation` | Navigation section | `<nav role="navigation">` |
| `dialog` | Modal dialogs | `<div role="dialog">` |
| `alert` | Important messages | `<div role="alert">` |
| `tab`, `tablist`, `tabpanel` | Tab interface | Tab navigation |
| `menu`, `menuitem` | Dropdown menus | Hamburger menu |

#### Common ARIA Attributes

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `aria-label` | Accessible label for element | `<button aria-label="Close">×</button>` |
| `aria-labelledby` | References element ID for label | `<dialog aria-labelledby="modal-title">` |
| `aria-describedby` | References element ID for description | `<input aria-describedby="error-msg">` |
| `aria-expanded` | Indicates expanded/collapsed state | `<button aria-expanded="false">Menu</button>` |
| `aria-hidden` | Hides element from screen readers | `<div aria-hidden="true">` (decorative icon) |
| `aria-live` | Announces dynamic content changes | `<div aria-live="polite">` (notifications) |
| `aria-disabled` | Disabled state | `<button aria-disabled="true">` |
| `aria-current` | Current item in set | `<a aria-current="page">Home</a>` |

---

### Keyboard Interactions

Document expected keyboard behavior for every interactive component:

#### Button
| Key | Action |
|-----|--------|
| `Enter` or `Space` | Activate button |
| `Tab` | Move focus to next element |
| `Shift+Tab` | Move focus to previous element |

#### Dropdown Menu
| Key | Action |
|-----|--------|
| `Enter` or `Space` | Open/close menu |
| `Arrow Down` | Move focus to next item |
| `Arrow Up` | Move focus to previous item |
| `Escape` | Close menu |
| `Home` | Focus first item |
| `End` | Focus last item |

#### Modal Dialog
| Key | Action |
|-----|--------|
| `Escape` | Close modal |
| `Tab` | Cycle focus within modal (trapped) |
| `Shift+Tab` | Cycle focus backward |

#### Tabs
| Key | Action |
|-----|--------|
| `Arrow Right` | Move to next tab |
| `Arrow Left` | Move to previous tab |
| `Home` | Move to first tab |
| `End` | Move to last tab |
| `Tab` | Move focus into tab panel content |

---

### Screen Reader Announcements

Document what a screen reader should announce for key interactions:
API Error: Claude's response exceeded the 32000 output token maximum. To configure this behavior, set the CLAUDE_CODE_MAX_OUTPUT_TOKENS environment variable.
I'll continue from where I left off in the Figma Handoff REFERENCE.md file:

===FILE: /Users/danielcarmo/Env/Projects/personal/claude_skills/claude_skills/.claude/skills/figma-handoff/REFERENCE.md===
(continuing from Screen Reader Announcements section)

### Screen Reader Announcements

Document what a screen reader should announce for key interactions:

#### Button Example
**Visual:** `[→ Save]` button  
**Screen Reader Output:** "Save, button"

**With loading state:**  
**Screen Reader Output:** "Saving, button, busy"

**With disabled state:**  
**Screen Reader Output:** "Save, button, dimmed" (or "unavailable" depending on screen reader)

---

#### Form Input Example
**Visual:** Email input with label and error  
**Screen Reader Output (on focus):** "Email address, required, invalid entry, edit text. Error: Please enter a valid email address."

**ARIA markup:**
```html
<label for="email">Email address</label>
<input 
  id="email" 
  type="email" 
  required 
  aria-invalid="true" 
  aria-describedby="email-error"
>
<span id="email-error">Please enter a valid email address</span>
```

---

#### Modal Example
**Visual:** Modal dialog opens  
**Screen Reader Output:** "Confirm deletion, dialog. Are you sure you want to delete this item? This action cannot be undone."

**ARIA markup:**
```html
<div role="dialog" aria-labelledby="modal-title" aria-describedby="modal-desc">
  <h2 id="modal-title">Confirm deletion</h2>
  <p id="modal-desc">Are you sure you want to delete this item? This action cannot be undone.</p>
</div>
```

---

### Focus Indicators

**Requirement:** All interactive elements must have a visible focus indicator

**WCAG 2.1 AA Standard:**
- Focus indicator must have 3:1 contrast ratio with background
- Minimum 2px thick outline or border
- Must be visible on all interactive states

**Best practice focus ring:**
```css
/* Design token approach */
:focus-visible {
  outline: 2px solid var(--color-border-focus);
  outline-offset: 2px;
  border-radius: var(--radius-interactive-md);
}
```

**Common focus styles:**
| Style | CSS | Use Case |
|-------|-----|----------|
| Outline ring | `outline: 2px solid blue; outline-offset: 2px;` | Default, works everywhere |
| Border | `border: 2px solid blue;` | Inputs, buttons (may affect layout) |
| Box shadow | `box-shadow: 0 0 0 4px rgba(0,100,255,0.3);` | Soft glow effect |
| Background change | `background-color: lightblue;` | List items, menu items |

---

### Alt Text Guidelines

#### Decorative Images
**Use case:** Purely visual, adds no information  
**Alt text:** `alt=""` (empty string)  
**Example:** Background patterns, dividers, spacer images

---

#### Informative Images
**Use case:** Conveys information or content  
**Alt text:** Brief description of what the image shows  
**Examples:**
- Product photo: `alt="Blue running shoes, size 10"`
- Chart: `alt="Bar chart showing 30% increase in sales from 2024 to 2025"`
- Icon with no visible label: `alt="Search"`

---

#### Functional Images (Links/Buttons)
**Use case:** Image is clickable and performs an action  
**Alt text:** Describe the action, not the image  
**Examples:**
- Logo linking to homepage: `alt="Return to homepage"`
- Shopping cart icon: `alt="View shopping cart (3 items)"`
- Download button with icon: `alt="Download PDF report"`

---

#### Complex Images
**Use case:** Infographics, detailed charts, diagrams  
**Alt text:** Short summary + link to long description  
**Example:**
```html
<img 
  src="sales-chart.png" 
  alt="Sales performance by region, 2025" 
  aria-describedby="chart-description"
>
<div id="chart-description">
  Detailed description: North region grew 45%, South 30%, East 12%, West -5%...
</div>
```

---

### i18n Text Expansion Guidelines

#### Text Expansion Ratios

| English Length | pt-BR Expansion | Design Implications |
|----------------|-----------------|---------------------|
| 1-10 chars | +30% | "Save" (4) → "Salvar" (6) — allow 6-8 chars |
| 11-20 chars | +25% | "Get started" (11) → "Começar agora" (13) — allow 14-16 chars |
| 21-40 chars | +20% | Button labels, short sentences — test at +20% |
| 40+ chars | +15% | Paragraphs, body text — less expansion ratio |

---

#### Design Rules for Text Expansion

1. **Never use fixed-width containers for translatable text**
   - Bad: `width: 120px;` for a button
   - Good: `min-width: 120px; padding: 0 16px;`

2. **Allow wrapping for labels in tight spaces**
   - Bad: `white-space: nowrap; overflow: hidden;`
   - Good: Allow 2 lines for single-line labels

3. **Test with longest locale**
   - Always test UI with pt-BR strings (longest)
   - Use pseudo-localization tools (Figma plugins)

4. **Account for vertical expansion**
   - Portuguese may need +1 line in paragraph blocks
   - List items may wrap to 2 lines

---

#### RTL (Right-to-Left) Support

**Languages:** Arabic, Hebrew

**What needs to flip:**
- Layout direction (flex-direction, text-align)
- Padding/margin (left ↔ right)
- Icons with directional meaning (arrows, chevrons)

**What stays the same:**
- Numbers, dates, times
- Logos, brand marks
- Media controls (play, pause)

**CSS approach:**
```css
/* Use logical properties for auto RTL support */
.card {
  padding-inline-start: 16px; /* Becomes padding-right in RTL */
  padding-inline-end: 24px;   /* Becomes padding-left in RTL */
  margin-inline: auto;
}
```

**Figma annotation:**
- Mark components as "RTL-ready" or "Requires RTL variant"
- Note which icons need mirrored versions

---

### Handoff Checklist

Before delivering component spec to engineering:

**Design Tokens:**
- [ ] All colors mapped to semantic tokens (not hex values)
- [ ] All spacing uses token references
- [ ] All typography uses token references
- [ ] All shadows/elevation uses token references
- [ ] All border-radius uses token references

**Responsive:**
- [ ] Behavior documented for all breakpoints (xs, sm, md, lg, xl)
- [ ] Typography scaling defined
- [ ] Layout changes annotated (stacking, column collapse, etc.)
- [ ] Visibility toggles specified

**Accessibility:**
- [ ] Focus order numbered
- [ ] ARIA roles specified for custom components
- [ ] ARIA attributes listed (aria-label, aria-expanded, etc.)
- [ ] Keyboard interactions documented
- [ ] Screen reader announcements written
- [ ] Color contrast ratios verified (4.5:1 text, 3:1 UI)
- [ ] Alt text provided for images

**i18n:**
- [ ] Text expansion tested (+20-30% for pt-BR)
- [ ] No fixed-width containers for text
- [ ] Wrapping allowed for labels
- [ ] RTL considerations noted if applicable

**Assets:**
- [ ] Icons exported as SVG
- [ ] Images exported at 1x, 2x, 3x (or vector)
- [ ] Naming convention consistent (kebab-case or camelCase)
- [ ] All states exported (default, hover, focus, disabled, etc.)

**Documentation:**
- [ ] Component purpose clear
- [ ] All variants documented
- [ ] Props/attributes defined
- [ ] States described with visuals
- [ ] Edge cases addressed
