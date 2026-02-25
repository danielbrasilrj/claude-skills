# Accessibility Annotation Guide

## WCAG 2.1 AA Requirements

### Color Contrast Ratios

| Element Type                         | Minimum Ratio | Example                         |
| ------------------------------------ | ------------- | ------------------------------- |
| Normal text (< 18px)                 | 4.5:1         | `#000000` on `#FFFFFF` = 21:1   |
| Large text (>= 18px or >= 14px bold) | 3:1           | `#767676` on `#FFFFFF` = 4.54:1 |
| UI components (buttons, inputs)      | 3:1           | Button border vs background     |
| Graphical objects (icons, charts)    | 3:1           | Icon color vs background        |

**Tool:** Use [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

---

## Focus Order

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

## ARIA Roles and Attributes

### Common ARIA Roles

| Role                         | Use Case                              | Example                   |
| ---------------------------- | ------------------------------------- | ------------------------- |
| `button`                     | Non-button elements acting as buttons | `<div role="button">`     |
| `navigation`                 | Navigation section                    | `<nav role="navigation">` |
| `dialog`                     | Modal dialogs                         | `<div role="dialog">`     |
| `alert`                      | Important messages                    | `<div role="alert">`      |
| `tab`, `tablist`, `tabpanel` | Tab interface                         | Tab navigation            |
| `menu`, `menuitem`           | Dropdown menus                        | Hamburger menu            |

### Common ARIA Attributes

| Attribute          | Purpose                               | Example                                       |
| ------------------ | ------------------------------------- | --------------------------------------------- |
| `aria-label`       | Accessible label for element          | `<button aria-label="Close">x</button>`       |
| `aria-labelledby`  | References element ID for label       | `<dialog aria-labelledby="modal-title">`      |
| `aria-describedby` | References element ID for description | `<input aria-describedby="error-msg">`        |
| `aria-expanded`    | Indicates expanded/collapsed state    | `<button aria-expanded="false">Menu</button>` |
| `aria-hidden`      | Hides element from screen readers     | `<div aria-hidden="true">` (decorative icon)  |
| `aria-live`        | Announces dynamic content changes     | `<div aria-live="polite">` (notifications)    |
| `aria-disabled`    | Disabled state                        | `<button aria-disabled="true">`               |
| `aria-current`     | Current item in set                   | `<a aria-current="page">Home</a>`             |

---

## Keyboard Interactions

Document expected keyboard behavior for every interactive component:

### Button

| Key                | Action                         |
| ------------------ | ------------------------------ |
| `Enter` or `Space` | Activate button                |
| `Tab`              | Move focus to next element     |
| `Shift+Tab`        | Move focus to previous element |

### Dropdown Menu

| Key                | Action                      |
| ------------------ | --------------------------- |
| `Enter` or `Space` | Open/close menu             |
| `Arrow Down`       | Move focus to next item     |
| `Arrow Up`         | Move focus to previous item |
| `Escape`           | Close menu                  |
| `Home`             | Focus first item            |
| `End`              | Focus last item             |

### Modal Dialog

| Key         | Action                             |
| ----------- | ---------------------------------- |
| `Escape`    | Close modal                        |
| `Tab`       | Cycle focus within modal (trapped) |
| `Shift+Tab` | Cycle focus backward               |

### Tabs

| Key           | Action                            |
| ------------- | --------------------------------- |
| `Arrow Right` | Move to next tab                  |
| `Arrow Left`  | Move to previous tab              |
| `Home`        | Move to first tab                 |
| `End`         | Move to last tab                  |
| `Tab`         | Move focus into tab panel content |

---

## Screen Reader Announcements

Document what a screen reader should announce for key interactions:

### Button Example

**Visual:** `[-> Save]` button
**Screen Reader Output:** "Save, button"

**With loading state:**
**Screen Reader Output:** "Saving, button, busy"

**With disabled state:**
**Screen Reader Output:** "Save, button, dimmed" (or "unavailable" depending on screen reader)

---

### Form Input Example

**Visual:** Email input with label and error
**Screen Reader Output (on focus):** "Email address, required, invalid entry, edit text. Error: Please enter a valid email address."

**ARIA markup:**

```html
<label for="email">Email address</label>
<input id="email" type="email" required aria-invalid="true" aria-describedby="email-error" />
<span id="email-error">Please enter a valid email address</span>
```

---

### Modal Example

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

## Focus Indicators

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

## Alt Text Guidelines

### Decorative Images

**Use case:** Purely visual, adds no information
**Alt text:** `alt=""` (empty string)
**Example:** Background patterns, dividers, spacer images

### Informative Images

**Use case:** Conveys information or content
**Alt text:** Brief description of what the image shows
**Examples:**

- Product photo: `alt="Blue running shoes, size 10"`
- Chart: `alt="Bar chart showing 30% increase in sales from 2024 to 2025"`
- Icon with no visible label: `alt="Search"`

### Functional Images (Links/Buttons)

**Use case:** Image is clickable and performs an action
**Alt text:** Describe the action, not the image
**Examples:**

- Logo linking to homepage: `alt="Return to homepage"`
- Shopping cart icon: `alt="View shopping cart (3 items)"`
- Download button with icon: `alt="Download PDF report"`

### Complex Images

**Use case:** Infographics, detailed charts, diagrams
**Alt text:** Short summary + link to long description
**Example:**

```html
<img
  src="sales-chart.png"
  alt="Sales performance by region, 2025"
  aria-describedby="chart-description"
/>
<div id="chart-description">
  Detailed description: North region grew 45%, South 30%, East 12%, West -5%...
</div>
```

---

## i18n Text Expansion Guidelines

### Text Expansion Ratios

| English Length | pt-BR Expansion | Design Implications                                             |
| -------------- | --------------- | --------------------------------------------------------------- |
| 1-10 chars     | +30%            | "Save" (4) -> "Salvar" (6) -- allow 6-8 chars                   |
| 11-20 chars    | +25%            | "Get started" (11) -> "Comecar agora" (13) -- allow 14-16 chars |
| 21-40 chars    | +20%            | Button labels, short sentences -- test at +20%                  |
| 40+ chars      | +15%            | Paragraphs, body text -- less expansion ratio                   |

### Design Rules for Text Expansion

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

### RTL (Right-to-Left) Support

**Languages:** Arabic, Hebrew

**What needs to flip:**

- Layout direction (flex-direction, text-align)
- Padding/margin (left <-> right)
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
  padding-inline-end: 24px; /* Becomes padding-left in RTL */
  margin-inline: auto;
}
```

**Figma annotation:**

- Mark components as "RTL-ready" or "Requires RTL variant"
- Note which icons need mirrored versions
