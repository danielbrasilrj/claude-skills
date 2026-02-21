# Cross-Platform QA Checklist

Use this checklist before every cross-platform release. Each item must pass on **all target platforms** (iOS, Android, Web) unless marked platform-specific.

## Visual Consistency

- [ ] Colors match design tokens across all platforms
- [ ] Typography renders correctly (font family, size, weight, line height)
- [ ] Spacing and padding are consistent
- [ ] Icons render at correct size and color
- [ ] Images load and scale properly (1x, 2x, 3x)
- [ ] Dark mode displays correctly on all platforms
- [ ] Animations run smoothly (no jank)
- [ ] Loading states (skeletons, spinners) display correctly
- [ ] Empty states display correctly
- [ ] Error states display correctly

## Layout and Responsiveness

- [ ] Portrait orientation displays correctly (mobile)
- [ ] Landscape orientation displays correctly (mobile)
- [ ] Tablet layout adapts (if targeting tablets)
- [ ] Web responsive breakpoints: mobile (< 768px), tablet (768-1023px), desktop (1024px+)
- [ ] Content does not overflow or clip unexpectedly
- [ ] Scroll behavior is correct (bounces on iOS, overscroll glow on Android)
- [ ] Safe area insets respected (iOS notch, Android status bar, web viewport)
- [ ] Keyboard does not cover input fields

## Navigation

- [ ] All navigation routes are reachable
- [ ] Back button/gesture works correctly (hardware back on Android, swipe on iOS, browser back on web)
- [ ] Deep links resolve to correct screens
- [ ] Tab bar highlights correct tab
- [ ] Modal presentation follows platform conventions
- [ ] Navigation transitions are smooth
- [ ] Web URLs are shareable and bookmarkable
- [ ] Web: browser forward/back works as expected

## Input Handling

- [ ] Touch targets are at least 44x44pt (iOS) / 48x48dp (Android)
- [ ] Text inputs accept and display input correctly
- [ ] Keyboard type matches input (email, number, phone, password)
- [ ] Form validation displays errors correctly
- [ ] Web: mouse hover states display correctly
- [ ] Web: keyboard navigation (Tab, Enter, Escape) works
- [ ] Web: focus indicators are visible
- [ ] Gestures (swipe, pinch, long press) work as expected (mobile)

## Performance

- [ ] Cold start time within baseline (mobile < 2s, web LCP < 1.5s)
- [ ] List scrolling at 60 FPS
- [ ] No memory leaks on repeated navigation
- [ ] Images are optimized (WebP, proper sizing)
- [ ] Web: Lighthouse score > 90 (Performance)
- [ ] Web: initial bundle < 200 KB
- [ ] API calls use proper caching
- [ ] No unnecessary re-renders

## Accessibility

- [ ] Screen reader announces all interactive elements (VoiceOver, TalkBack, NVDA)
- [ ] Accessible labels on all buttons, images, and inputs
- [ ] Color contrast ratio meets WCAG AA (4.5:1 text, 3:1 large text)
- [ ] Text scales with system font size settings
- [ ] Focus order is logical
- [ ] Web: ARIA landmarks present (main, nav, banner)
- [ ] Web: skip navigation link present
- [ ] Reduced motion preference is respected

## Offline and Network

- [ ] App handles offline state gracefully (shows cached data or offline message)
- [ ] Network error messages are user-friendly
- [ ] Retry mechanism works for failed requests
- [ ] Data syncs correctly when connectivity returns
- [ ] Slow network (3G) does not cause timeouts or crashes

## Platform-Specific

### iOS Only
- [ ] Supports current iOS version and one prior
- [ ] Dynamic Type sizing works
- [ ] Haptic feedback on appropriate interactions
- [ ] App Tracking Transparency prompt (if applicable)
- [ ] Sign in with Apple available (if social auth exists)

### Android Only
- [ ] Supports target and minimum API levels
- [ ] Material You theming adapts to system colors (Android 12+)
- [ ] Edge-to-edge rendering (Android 15+)
- [ ] Runtime permissions handled correctly
- [ ] Back gesture navigation works

### Web Only
- [ ] SEO meta tags present
- [ ] Open Graph tags for social sharing
- [ ] Favicon and PWA manifest configured
- [ ] Service worker caches critical assets
- [ ] Cookie consent / privacy compliance
- [ ] Cross-browser: Chrome, Firefox, Safari, Edge

## Security

- [ ] Authentication tokens stored securely (Keychain/Keystore on mobile, httpOnly cookies on web)
- [ ] Sensitive data not logged to console
- [ ] API keys not in client bundle
- [ ] Certificate pinning enabled (mobile, if required)
- [ ] Biometric auth works correctly (mobile)

## Sign-Off

| Platform | Tester | Date | Status |
|---|---|---|---|
| iOS | | | |
| Android | | | |
| Web | | | |

**Release Approved**: [ ] Yes / [ ] No

**Notes**:
