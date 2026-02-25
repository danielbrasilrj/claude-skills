# Component Spec Deep Dive

## Anatomy of a Complete Component Spec

Every component spec must include:

1. **Component name** -- Clear, concise (e.g., `Button`, `Input`, `Modal`)
2. **Purpose** -- What problem does it solve?
3. **Variants** -- All visual variants (size, style, state)
4. **Props/Attributes** -- Framework-agnostic parameters
5. **States** -- Default, hover, focus, active, disabled, loading, error
6. **Design tokens** -- All colors, spacing, typography mapped to tokens
7. **Responsive behavior** -- How it adapts across breakpoints
8. **Accessibility** -- Focus order, ARIA, keyboard interactions, color contrast
9. **i18n considerations** -- Text expansion, RTL support
10. **Assets** -- Icons, images, export specs

---

## Component Variant Documentation

### Variant Dimensions

Document every axis of variation:

| Dimension         | Values                                           | Example Component |
| ----------------- | ------------------------------------------------ | ----------------- |
| **Size**          | xs, sm, md, lg, xl                               | Button            |
| **Style**         | primary, secondary, outline, ghost, danger       | Button            |
| **State**         | default, hover, focus, active, disabled, loading | Button            |
| **Icon position** | left, right, icon-only                           | Button            |

### Variant Matrix Example (Button)

| Size | Style     | State    | Icon  | Example             |
| ---- | --------- | -------- | ----- | ------------------- |
| md   | primary   | default  | left  | `[-> Save]`         |
| lg   | secondary | hover    | right | `[Next ->]` hover   |
| sm   | danger    | disabled | none  | `[Delete]` disabled |
| md   | outline   | focus    | left  | `[+ Add]` focused   |

**Total combinations:** 5 sizes x 5 styles x 6 states x 3 icon positions = **450 possible variants**

**Best practice:** Document core variants only (e.g., 12-20 key combinations), then define combination rules.

---

## Props/Attributes Documentation

**Framework-agnostic format:**

| Prop           | Type     | Values                                     | Default | Required | Description                   |
| -------------- | -------- | ------------------------------------------ | ------- | -------- | ----------------------------- |
| `label`        | string   | any                                        | --      | Yes      | Button text                   |
| `size`         | enum     | xs, sm, md, lg, xl                         | md      | No       | Visual size                   |
| `style`        | enum     | primary, secondary, outline, ghost, danger | primary | No       | Visual style                  |
| `icon`         | string   | icon-name                                  | --      | No       | Icon to display               |
| `iconPosition` | enum     | left, right                                | left    | No       | Icon placement                |
| `disabled`     | boolean  | true, false                                | false   | No       | Disabled state                |
| `loading`      | boolean  | true, false                                | false   | No       | Loading state (shows spinner) |
| `fullWidth`    | boolean  | true, false                                | false   | No       | Expand to container width     |
| `onClick`      | function | --                                         | --      | No       | Click handler                 |

---

## State Documentation

Document visual changes for every interactive state:

### Button States Example

| State        | Visual Changes              | Design Tokens                              |
| ------------ | --------------------------- | ------------------------------------------ |
| **Default**  | Solid background            | `color-action-primary`, `font-label-md`    |
| **Hover**    | Darker background           | `color-action-primary-hover`               |
| **Focus**    | Focus ring (4px)            | `color-border-focus` + `elevation-sm`      |
| **Active**   | Slightly darker, scale 0.98 | `color-action-primary-active` + transform  |
| **Disabled** | 40% opacity, no pointer     | `opacity-disabled` + cursor: not-allowed   |
| **Loading**  | Spinner replaces icon/text  | `color-action-primary` + spinner animation |

---

## Design Token Mapping

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
