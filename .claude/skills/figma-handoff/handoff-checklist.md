# Handoff Checklist

Before delivering component spec to engineering:

## Design Tokens

- [ ] All colors mapped to semantic tokens (not hex values)
- [ ] All spacing uses token references
- [ ] All typography uses token references
- [ ] All shadows/elevation uses token references
- [ ] All border-radius uses token references

## Responsive

- [ ] Behavior documented for all breakpoints (xs, sm, md, lg, xl)
- [ ] Typography scaling defined
- [ ] Layout changes annotated (stacking, column collapse, etc.)
- [ ] Visibility toggles specified

## Accessibility

- [ ] Focus order numbered
- [ ] ARIA roles specified for custom components
- [ ] ARIA attributes listed (aria-label, aria-expanded, etc.)
- [ ] Keyboard interactions documented
- [ ] Screen reader announcements written
- [ ] Color contrast ratios verified (4.5:1 text, 3:1 UI)
- [ ] Alt text provided for images

## i18n

- [ ] Text expansion tested (+20-30% for pt-BR)
- [ ] No fixed-width containers for text
- [ ] Wrapping allowed for labels
- [ ] RTL considerations noted if applicable

## Assets

- [ ] Icons exported as SVG
- [ ] Images exported at 1x, 2x, 3x (or vector)
- [ ] Naming convention consistent (kebab-case or camelCase)
- [ ] All states exported (default, hover, focus, disabled, etc.)

## Documentation

- [ ] Component purpose clear
- [ ] All variants documented
- [ ] Props/attributes defined
- [ ] States described with visuals
- [ ] Edge cases addressed
