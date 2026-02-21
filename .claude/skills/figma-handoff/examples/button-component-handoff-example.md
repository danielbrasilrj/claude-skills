# Button Component Specification

Complete handoff documentation for a production-ready Button component.

---

## Component Name

**Button**

---

## Purpose

The Button component allows users to trigger actions, submit forms, or navigate to different pages. It provides consistent visual feedback across all interactive states and ensures accessibility compliance.

Use buttons for primary actions that change application state or submit data. For navigation to external pages, use text links instead.

---

## Visual Reference

**Figma Link:** https://figma.com/file/abc123/Design-System?node-id=42:195

**Screenshots:**
- All variants: [Primary, Secondary, Outline, Ghost, Danger in all sizes]
- State progression: [Default → Hover → Focus → Active → Disabled → Loading]

---

## Variants

| Variant Dimension | Options | Default |
|------------------|---------|---------|
| **Size** | sm, md, lg | md |
| **Style** | primary, secondary, outline, ghost, danger | primary |
| **Icon Position** | none, left, right, icon-only | none |
| **Width** | auto, full-width | auto |

**Total unique variants:** 15 core combinations documented (5 styles × 3 sizes)

---

## Props/Attributes

| Prop | Type | Values | Default | Required | Description |
|------|------|--------|---------|----------|-------------|
| `label` | string | any text | — | Yes* | Button text (*not required for icon-only) |
| `size` | enum | sm, md, lg | md | No | Visual size of button |
| `variant` | enum | primary, secondary, outline, ghost, danger | primary | No | Visual style variant |
| `disabled` | boolean | true, false | false | No | Disables button interactions |
| `loading` | boolean | true, false | false | No | Shows spinner, disables interactions |
| `icon` | string | icon-name | — | No | Icon component to display |
| `iconPosition` | enum | left, right | left | No | Position of icon relative to label |
| `iconOnly` | boolean | true, false | false | No | Icon-only mode (no label) |
| `fullWidth` | boolean | true, false | false | No | Expands button to 100% of container width |
| `ariaLabel` | string | any text | — | No** | Accessible label (**required for icon-only) |
| `onClick` | function | callback | — | No | Click event handler |

---

## States

| State | Visual Changes | Design Tokens Used | Notes |
|-------|----------------|-------------------|-------|
| **Default** | Solid background, white text, 8px radius | `color-action-primary`, `color-text-inverse`, `font-label-md`, `radius-interactive-md` | Resting state |
| **Hover** | Darker background, cursor pointer | `color-action-primary-hover` | On mouse over |
| **Focus** | 4px blue focus ring, slight shadow | `color-border-focus`, `elevation-sm` | Keyboard navigation |
| **Active** | Slightly darker, scale 98% | `color-action-primary-active`, `transform: scale(0.98)` | While clicking/tapping |
| **Disabled** | 40% opacity, no pointer events | `opacity-disabled`, `cursor: not-allowed` | Cannot interact |
| **Loading** | Spinner replaces icon, disabled state | `color-action-primary`, spinner animation, disabled | Async action in progress |

---

## Design Tokens

### Primary Variant (Medium Size)

#### Background
```yaml
default: color-action-primary (#0066FF)
hover: color-action-primary-hover (#0052CC)
active: color-action-primary-active (#003D99)
disabled: color-action-primary-disabled (#0066FF at 40% opacity)
loading: color-action-primary (#0066FF)
```

#### Text
```yaml
default: color-text-inverse (#FFFFFF)
disabled: color-text-inverse (#FFFFFF at 40% opacity)
loading: color-text-inverse (#FFFFFF)
```

#### Border
```yaml
default: none
focus: color-border-focus (#0066FF) — 4px ring with 2px offset
disabled: none
```

#### Spacing
```yaml
padding-x: spacing-component-padding-md (16px)
padding-y: spacing-component-padding-sm (10px)
gap: spacing-component-gap-sm (8px) — between icon and label
min-height: 40px
```

#### Typography
```yaml
font: font-label-md
  font-family: Inter, -apple-system, sans-serif
  font-size: 14px
  font-weight: 600
  line-height: 20px
  letter-spacing: 0
```

#### Border Radius
```yaml
radius: radius-interactive-md (8px)
```

#### Elevation
```yaml
default: elevation-none
hover: elevation-none
focus: elevation-sm (0px 2px 4px rgba(0,0,0,0.1))
active: elevation-none
```

---

### Secondary Variant (Medium Size)

#### Background
```yaml
default: color-action-secondary (#F3F4F6)
hover: color-action-secondary-hover (#E5E7EB)
active: color-action-secondary-active (#D1D5DB)
disabled: color-action-secondary-disabled (#F3F4F6 at 40% opacity)
```

#### Text
```yaml
default: color-text-default (#1F2937)
disabled: color-text-disabled (#9CA3AF)
```

#### Border
```yaml
default: none
focus: color-border-focus (#0066FF) — 4px ring with 2px offset
```

#### Spacing
```yaml
(Same as Primary)
```

---

### Outline Variant (Medium Size)

#### Background
```yaml
default: transparent
hover: color-action-primary (#0066FF at 8% opacity)
active: color-action-primary (#0066FF at 12% opacity)
disabled: transparent
```

#### Text
```yaml
default: color-action-primary (#0066FF)
hover: color-action-primary-hover (#0052CC)
disabled: color-text-disabled (#9CA3AF)
```

#### Border
```yaml
default: color-border-default (#D1D5DB) — 1px solid
hover: color-action-primary (#0066FF) — 1px solid
active: color-action-primary-active (#003D99) — 1px solid
focus: color-border-focus (#0066FF) — 4px ring with 2px offset
disabled: color-border-subtle (#E5E7EB) — 1px solid
```

---

### Ghost Variant (Medium Size)

#### Background
```yaml
default: transparent
hover: color-action-primary (#0066FF at 8% opacity)
active: color-action-primary (#0066FF at 12% opacity)
disabled: transparent
```

#### Text
```yaml
default: color-action-primary (#0066FF)
hover: color-action-primary-hover (#0052CC)
disabled: color-text-disabled (#9CA3AF)
```

#### Border
```yaml
default: none
focus: color-border-focus (#0066FF) — 4px ring with 2px offset
```

---

### Danger Variant (Medium Size)

#### Background
```yaml
default: color-action-danger (#DC2626)
hover: color-action-danger-hover (#B91C1C)
active: color-action-danger-active (#991B1B)
disabled: color-action-danger-disabled (#DC2626 at 40% opacity)
```

#### Text
```yaml
default: color-text-inverse (#FFFFFF)
disabled: color-text-inverse (#FFFFFF at 40% opacity)
```

#### Border
```yaml
default: none
focus: color-border-focus (#DC2626) — 4px ring with 2px offset
```

---

### Size Variations

#### Small (sm)
```yaml
padding-x: spacing-component-padding-sm (12px)
padding-y: 6px
gap: 6px
min-height: 32px
font: font-label-sm (12px, 600 weight)
icon-size: icon-size-sm (16px)
```

#### Medium (md) — Default
```yaml
padding-x: spacing-component-padding-md (16px)
padding-y: 10px
gap: 8px
min-height: 40px
font: font-label-md (14px, 600 weight)
icon-size: icon-size-md (20px)
```

#### Large (lg)
```yaml
padding-x: spacing-component-padding-lg (20px)
padding-y: 12px
gap: 10px
min-height: 48px
font: font-label-lg (16px, 600 weight)
icon-size: icon-size-lg (24px)
```

---

## Responsive Behavior

| Breakpoint | Width | Size | Spacing | Other Changes |
|------------|-------|------|---------|---------------|
| **xs (0-319px)** | Full-width by default | md | Standard padding | Stack vertically if multiple buttons |
| **sm (320-767px)** | Full-width for primary actions, auto for secondary | md | Standard padding | Stack or inline based on context |
| **md (768-1023px)** | Auto-width (inline) | md | Standard padding | Side-by-side layout |
| **lg (1024-1439px)** | Auto-width | md or lg (context-dependent) | Standard padding | Side-by-side layout |
| **xl (1440px+)** | Auto-width | lg preferred for hero CTAs | Standard padding | Side-by-side layout |

**Notes:**
- On mobile (xs-sm), primary action buttons often go full-width for easier tapping
- Multiple buttons stack vertically on mobile with 12px gap
- On tablet and desktop (md+), buttons are inline with 12px horizontal gap

---

## Accessibility

### Focus Order

**Focusable:** Yes

**Tab order position:** Depends on DOM order (buttons appear in sequence with other focusable elements)

**Example in a form:**
```
1. Email input
2. Password input
3. "Show password" toggle button
4. "Sign In" button ← This component
5. "Forgot password?" link
6. "Create account" button ← This component
```

---

### ARIA Attributes

| Attribute | Value | When Used |
|-----------|-------|-----------|
| `role` | `button` | Only if using `<div>` or `<span>` (avoid — use `<button>` instead) |
| `aria-label` | Custom label | **Required** for icon-only buttons (e.g., "Close modal", "Delete item") |
| `aria-disabled` | `true` | When `disabled=true` (use `disabled` attribute on `<button>` as well) |
| `aria-busy` | `true` | When `loading=true` (indicates async action in progress) |
| `aria-pressed` | `true` / `false` | Only for toggle buttons (not standard action buttons) |

**Example (Icon-only close button):**
```html
<button 
  type="button" 
  class="btn btn-ghost btn-icon-only" 
  aria-label="Close modal"
>
  <svg><!-- close icon --></svg>
</button>
```

---

### Keyboard Interactions

| Key | Action |
|-----|--------|
| `Enter` | Activate button (trigger onClick) |
| `Space` | Activate button (trigger onClick) |
| `Tab` | Move focus to next focusable element |
| `Shift+Tab` | Move focus to previous focusable element |

**Notes:**
- Both `Enter` and `Space` should trigger the button (native `<button>` behavior)
- Do NOT prevent default behavior for `Enter` inside forms (allows form submission)
- Loading buttons should not respond to keyboard while `loading=true`

---

### Screen Reader Announcement

**Default button:**
> "Save changes, button"

**Icon-only button with aria-label:**
> "Close modal, button"

**Disabled button:**
> "Save changes, button, dimmed" (or "unavailable" depending on screen reader)

**Loading button:**
> "Saving changes, button, busy"

**Danger button:**
> "Delete account, button"

---

### Color Contrast

All combinations verified with WebAIM Contrast Checker:

| Variant | Element | Foreground | Background | Ratio | Pass/Fail |
|---------|---------|------------|------------|-------|-----------|
| Primary | Label (default) | #FFFFFF | #0066FF | 4.54:1 | ✅ AA |
| Primary | Label (hover) | #FFFFFF | #0052CC | 5.12:1 | ✅ AA |
| Secondary | Label (default) | #1F2937 | #F3F4F6 | 9.2:1 | ✅ AAA |
| Outline | Border (default) | #D1D5DB | #FFFFFF | 3.2:1 | ✅ AA (UI) |
| Outline | Label (default) | #0066FF | #FFFFFF | 4.54:1 | ✅ AA |
| Ghost | Label (default) | #0066FF | transparent | N/A | ✅ (depends on parent background) |
| Danger | Label (default) | #FFFFFF | #DC2626 | 5.0:1 | ✅ AA |
| All | Focus ring | #0066FF | #FFFFFF | 4.54:1 | ✅ AA |

**Minimum required:**
- Text (< 18px): 4.5:1 ✅
- UI components (borders, icons): 3:1 ✅

---

## i18n Considerations

### Text Expansion

**English button labels:**
- "Save" (4 chars)
- "Get Started" (11 chars)
- "Create Account" (14 chars)

**pt-BR equivalents:**
- "Salvar" (6 chars) — +50%
- "Começar" (7 chars) OR "Começar Agora" (13 chars) — +18%
- "Criar Conta" (11 chars) — -21% (rare shrinkage case)

**Design strategy:**
- ✅ Use `padding: 0 16px;` (flexible width)
- ✅ Set `min-width: 80px` to prevent tiny buttons
- ❌ Avoid `width: 120px;` (fixed width will truncate)

**Text overflow handling:**
- Labels over 40 characters: Allow wrapping to 2 lines max
- If exceeds 2 lines: Truncate with "..." and provide tooltip on hover
- Test all button labels in pt-BR before shipping

---

### RTL Support

**Does this component need RTL support?** Yes

**What needs to flip:**
- [x] Icon position (left ↔ right)
- [x] Padding (use logical properties: `padding-inline-start`, `padding-inline-end`)
- [x] Text alignment (implicit with `dir="rtl"`)
- [x] Flex direction for icon + label

**Icon mirroring required:** Yes, for directional icons only
- Arrow icons (arrow-right, arrow-left, chevron-right, chevron-left) need mirrored versions
- Non-directional icons (close, checkmark, plus) do NOT need mirroring

**CSS approach:**
```css
.btn {
  padding-inline-start: 16px; /* Becomes padding-right in RTL */
  padding-inline-end: 16px;   /* Becomes padding-left in RTL */
}

.btn-icon-left {
  /* Automatically flips to right in RTL with flex-direction */
  display: flex;
  flex-direction: row;
}

[dir="rtl"] .btn-icon-arrow {
  transform: scaleX(-1); /* Mirror arrow icons */
}
```

---

## Assets

### Icons

| Icon Name | Usage | Format | Size | Notes |
|-----------|-------|--------|-------|-------|
| `icon-arrow-right` | Right icon position | SVG | 20px (md), 16px (sm), 24px (lg) | Needs RTL mirroring |
| `icon-arrow-left` | Left icon position | SVG | 20px (md), 16px (sm), 24px (lg) | Needs RTL mirroring |
| `icon-plus` | Add actions | SVG | 20px (md), 16px (sm), 24px (lg) | No mirroring needed |
| `icon-close` | Icon-only close buttons | SVG | 20px (md), 16px (sm), 24px (lg) | No mirroring needed |
| `icon-spinner` | Loading state | SVG (animated) | 20px (md), 16px (sm), 24px (lg) | Rotates 360° continuously |
| `icon-checkmark` | Success actions | SVG | 20px (md), 16px (sm), 24px (lg) | No mirroring needed |
| `icon-trash` | Delete actions (danger variant) | SVG | 20px (md), 16px (sm), 24px (lg) | No mirroring needed |

**Export settings:**
- Format: SVG (optimized with SVGO)
- Color: Single-color (currentColor for CSS inheritance)
- Stroke width: 2px (consistent across all icons)

---

## Edge Cases

| Scenario | Behavior | Notes |
|----------|----------|-------|
| **Label > 40 characters** | Text wraps to 2 lines max, then truncates with "..." | Avoid long labels; use concise action verbs |
| **Icon-only button without aria-label** | ❌ Fails accessibility audit | Must include `aria-label` for screen readers |
| **Loading state triggered** | Button disabled, spinner replaces icon/label, width locked | Prevents layout shift during async actions |
| **Multiple buttons in a row** | 12px horizontal gap on desktop, stack vertically on mobile | Use flexbox with gap |
| **Button inside a form** | Add `type="button"` to prevent form submission | Only `type="submit"` buttons should submit forms |
| **Very long pt-BR label** | Allow wrapping to 2 lines; test in narrowest breakpoint | Always test with pt-BR strings |
| **Button with emoji in label** | Emoji renders inline; ensure emoji is decorative (not essential) | Screen readers may announce emoji name |

---

## Usage Guidelines

### When to Use

- **Primary actions:** Submit forms, complete workflows, confirm dialogs
- **Navigation:** Move to next step, go to a different page (if action-driven, not external link)
- **Triggering UI changes:** Open modals, expand sections, toggle states
- **Destructive actions:** Delete items, remove content (use danger variant)

---

### When NOT to Use

- **External links:** Use `<a>` tag with text link styling (not a button)
- **Inline text actions:** Use text link for "Learn more" within paragraphs
- **Non-interactive elements:** Decorative or static UI (use `<div>` or `<span>`)
- **Page navigation (non-action):** Use text link or navigation component

---

## Code Considerations

### Semantic HTML

**Correct:**
```html
<button type="button" class="btn btn-primary btn-md">
  <svg class="btn-icon"><!-- icon --></svg>
  <span>Save Changes</span>
</button>
```

**Incorrect:**
```html
<!-- ❌ Don't use div or span for buttons -->
<div role="button" class="btn btn-primary" onclick="save()">
  Save Changes
</div>
```

**Accessibility requirements:**
- Always use `<button>` element (native keyboard support, screen reader semantics)
- Include `type="button"` to prevent form submission (unless it's a submit button)
- Disabled state: use both `disabled` attribute AND `aria-disabled="true"`
- Icon-only: must include `aria-label`

**Form button types:**
```html
<button type="submit">Submit Form</button>  <!-- Submits parent form -->
<button type="button">Cancel</button>       <!-- Does not submit -->
<button type="reset">Clear Form</button>    <!-- Resets form fields -->
```

---

## Related Components

- **Icon** — Used inside button for left/right icons
- **Spinner** — Shown during loading state
- **Tooltip** — Can wrap button for additional context (icon-only buttons)
- **Button Group** — Multiple buttons grouped together with shared borders

---

## Notes

**Implementation priorities:**
1. Use `<button>` element (not div/span)
2. Support all 5 style variants + 3 sizes
3. Implement hover, focus, active, disabled, loading states
4. Ensure 4.5:1 color contrast for all variants
5. Add focus ring for keyboard navigation
6. Support icon left/right/only modes
7. Test with pt-BR labels (+30% expansion)
8. Verify RTL flipping for directional icons

**Open questions:**
- Should we support custom colors beyond the 5 variants? (Answer: No — use design tokens only)
- Should loading state show spinner + label, or just spinner? (Answer: Spinner replaces icon only; label remains)
