# Screen Reader Testing Procedures

## VoiceOver (macOS/iOS)

**Enable VoiceOver:**

- macOS: Cmd + F5
- iOS: Settings -> Accessibility -> VoiceOver

**Basic Navigation:**

- VO + Right Arrow: Next item
- VO + Left Arrow: Previous item
- VO + A: Start reading
- VO + U: Rotor (headings, links, form controls)
- Control: Stop speaking

**Testing Checklist:**

- [ ] All content is announced
- [ ] Headings announced with level
- [ ] Links announced with destination
- [ ] Form fields announced with label and type
- [ ] Images announced with alt text
- [ ] Buttons announced as "button"
- [ ] Navigation is logical

## TalkBack (Android)

**Enable TalkBack:**

- Settings -> Accessibility -> TalkBack

**Basic Navigation:**

- Swipe Right: Next item
- Swipe Left: Previous item
- Double-tap: Activate
- Swipe Down then Right: Start reading
- Swipe Up then Down: First item

**Testing Checklist:**

- [ ] All touch targets are reachable
- [ ] Touch target sizes >= 48x48 dp
- [ ] Content announced in logical order
- [ ] Form fields have proper labels
- [ ] Custom controls are accessible

## NVDA (Windows)

**Download:** https://www.nvaccess.org/download/

**Basic Navigation:**

- Down Arrow: Next item
- Up Arrow: Previous item
- Tab: Next focusable element
- H: Next heading
- F: Next form field
- NVDA + Down Arrow: Start reading

**Testing Checklist:**

- [ ] All content readable with keyboard
- [ ] Landmarks announced (navigation, main, etc.)
- [ ] Tables announced with headers
- [ ] Lists announced with item count
