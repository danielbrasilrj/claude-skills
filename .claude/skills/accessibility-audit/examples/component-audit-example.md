# Accessibility Audit: Login Form Component

**Component:** LoginForm
**Auditor:** Maria Santos
**Date:** 2026-02-21
**Standard:** WCAG 2.1 Level AA

---

## Component Description

A login form with email input, password input, "Remember me" checkbox, "Sign In" button, and "Forgot password?" link.

---

## Findings

### Finding 1: Missing form labels (Critical)

**WCAG:** 1.3.1 Info and Relationships (A)

**Issue:** Email and password inputs use placeholder text instead of visible labels. Screen readers may not announce the field purpose.

**Before:**
```html
<input type="email" placeholder="Email address">
<input type="password" placeholder="Password">
```

**After:**
```html
<label for="email">Email address</label>
<input id="email" type="email" autocomplete="email">

<label for="password">Password</label>
<input id="password" type="password" autocomplete="current-password">
```

---

### Finding 2: Error messages not announced (Critical)

**WCAG:** 3.3.1 Error Identification (A), 4.1.3 Status Messages (AA)

**Issue:** Validation errors appear visually but are not announced to screen readers. No `aria-invalid` or live region used.

**Before:**
```html
<input type="email" class="error">
<span class="error-text">Invalid email</span>
```

**After:**
```html
<input type="email" aria-invalid="true" aria-describedby="email-error">
<span id="email-error" role="alert">Please enter a valid email address</span>
```

---

### Finding 3: Low contrast on "Forgot password?" link (Major)

**WCAG:** 1.4.3 Contrast Minimum (AA)

**Issue:** Link color `#999` on white background = 2.85:1 ratio (fails 4.5:1 minimum).

**Fix:** Change to `#595959` (7:1 ratio) or `#767676` (4.54:1 ratio, minimum pass).

---

### Finding 4: No focus indicator on "Sign In" button (Major)

**WCAG:** 2.4.7 Focus Visible (AA)

**Issue:** `outline: none` removes the default focus indicator. Keyboard users cannot see which element is focused.

**Fix:**
```css
.btn-sign-in:focus-visible {
  outline: 2px solid #0066FF;
  outline-offset: 2px;
}
```

---

### Finding 5: Checkbox not keyboard-accessible (Major)

**WCAG:** 2.1.1 Keyboard (A)

**Issue:** Custom checkbox uses `<div>` with click handler. Not focusable or operable via keyboard.

**Fix:** Use native `<input type="checkbox">` with custom styling, or add `role="checkbox"`, `tabindex="0"`, and `Space` key handler.

---

### Finding 6: No autocomplete attributes (Minor)

**WCAG:** 1.3.5 Identify Input Purpose (AA)

**Issue:** Missing `autocomplete` attributes. Password managers and assistive tech cannot auto-fill fields.

**Fix:** Add `autocomplete="email"` and `autocomplete="current-password"`.

---

## Summary

| Severity | Count |
|----------|-------|
| Critical | 2 |
| Major | 3 |
| Minor | 1 |

**Recommendation:** Fix critical and major issues before release. The form is not usable for screen reader users in its current state.

**Estimated effort:** 2-4 hours for a frontend developer.
