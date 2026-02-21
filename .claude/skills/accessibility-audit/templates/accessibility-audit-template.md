# Accessibility Audit Report

**Application:** {{APP_NAME}}
**Auditor:** {{AUDITOR_NAME}}
**Date:** {{YYYY-MM-DD}}
**Standard:** WCAG 2.1 Level AA

---

## Summary

**Overall Compliance:** [ ] Pass [ ] Partial [ ] Fail

| Category | Pass | Fail | N/A | Notes |
|----------|------|------|-----|-------|
| Perceivable | /__ | /__ | /__ | |
| Operable | /__ | /__ | /__ | |
| Understandable | /__ | /__ | /__ | |
| Robust | /__ | /__ | /__ | |

---

## Perceivable

### 1.1 Text Alternatives
- [ ] All images have meaningful alt text
- [ ] Decorative images use `alt=""`
- [ ] Icon buttons have accessible names (`aria-label`)
- [ ] Complex images have detailed descriptions

### 1.3 Adaptable
- [ ] Semantic HTML used (header, nav, main, footer)
- [ ] Heading hierarchy is logical (h1 > h2 > h3, no skips)
- [ ] Lists use proper `ul/ol/li` markup
- [ ] Form inputs have associated `<label>` elements

### 1.4 Distinguishable
- [ ] Text contrast ratio >= 4.5:1 (normal text)
- [ ] Large text contrast ratio >= 3:1 (18px+ or 14px+ bold)
- [ ] UI component contrast >= 3:1
- [ ] Text resizable to 200% without loss
- [ ] Content reflows at 320px width (no horizontal scroll)

---

## Operable

### 2.1 Keyboard Accessible
- [ ] All functionality available via keyboard
- [ ] No keyboard traps
- [ ] Focus order is logical
- [ ] Focus indicator is visible (2px+ outline, 3:1 contrast)

### 2.4 Navigable
- [ ] Skip-to-main-content link present
- [ ] Page titles are descriptive
- [ ] Link text describes destination (no "click here")
- [ ] Multiple ways to find pages (nav, search, sitemap)

### 2.5 Input Modalities
- [ ] Touch targets >= 44x44pt (iOS) / 48x48dp (Android)
- [ ] Pointer gestures have single-pointer alternative

---

## Understandable

### 3.1 Readable
- [ ] Page language specified (`<html lang="en">`)
- [ ] Language changes marked (`<span lang="fr">`)

### 3.2 Predictable
- [ ] Focus doesn't trigger context change
- [ ] Navigation consistent across pages

### 3.3 Input Assistance
- [ ] Form errors clearly identified with text (not color alone)
- [ ] Error messages suggest how to fix
- [ ] Required fields indicated
- [ ] Important actions are reversible or confirmed

---

## Robust

### 4.1 Compatible
- [ ] Valid HTML (no duplicate IDs)
- [ ] ARIA roles and properties correct
- [ ] Status messages use live regions (`role="status"`, `role="alert"`)

---

## Findings

### Critical (Must Fix)

| # | Issue | WCAG | Location | Severity |
|---|-------|------|----------|----------|
| 1 | {{Description}} | {{Criterion}} | {{Page/Component}} | Critical |

### Major (Should Fix)

| # | Issue | WCAG | Location | Severity |
|---|-------|------|----------|----------|
| 1 | {{Description}} | {{Criterion}} | {{Page/Component}} | Major |

### Minor (Nice to Fix)

| # | Issue | WCAG | Location | Severity |
|---|-------|------|----------|----------|
| 1 | {{Description}} | {{Criterion}} | {{Page/Component}} | Minor |

---

## Testing Tools Used

- [ ] axe DevTools (Chrome extension)
- [ ] Lighthouse accessibility audit
- [ ] VoiceOver (macOS/iOS)
- [ ] TalkBack (Android)
- [ ] NVDA (Windows)
- [ ] WebAIM Contrast Checker
- [ ] Keyboard-only navigation test

---

## Sign-Off

| Role | Name | Date |
|------|------|------|
| Auditor | | |
| Developer | | |
| Stakeholder | | |
