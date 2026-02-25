# Platform-Specific Patterns

## iOS Considerations

- **Safe Areas**: Always use `useSafeAreaInsets()` for layout
- **Haptic Feedback**: Use `expo-haptics` or `react-native-haptic-feedback`
- **Large Titles**: iOS navigation bars support large titles; enable for top-level screens
- **Swipe Back**: Enabled by default in stack navigators; do not disable
- **Dynamic Type**: Support iOS accessibility text sizes with `allowFontScaling`
- **App Tracking Transparency**: Required for iOS 14.5+ if using ad tracking

## Android Considerations

- **Material Design 3**: Follow Material You guidelines for theming
- **Back Button**: Hardware/gesture back must be handled in navigation
- **Status Bar**: Translucent by default; manage with `StatusBar` component
- **Permissions**: Request at runtime; handle "Don't ask again" state
- **Foldables**: Test on foldable form factors if targeting Samsung/Pixel Fold
- **Edge-to-Edge**: Android 15+ enforces edge-to-edge; prepare layouts accordingly

## Web Considerations

- **SEO**: Use SSR/SSG where possible (Next.js, Expo Web with static export)
- **URL Routing**: Web expects shareable URLs; map all routes to URL paths
- **Hover States**: Web has hover; mobile does not. Use `@media (hover: hover)`
- **Keyboard Navigation**: Tab order, focus rings, arrow key navigation
- **Bundle Size**: Aggressive code splitting; lazy-load feature modules
- **PWA**: Configure service worker, manifest.json, offline support

---

## Navigation Patterns by Platform

### Tab Navigation

| Platform | Pattern                                                             |
| -------- | ------------------------------------------------------------------- |
| iOS      | Bottom tab bar, up to 5 items, "More" for overflow                  |
| Android  | Bottom navigation bar (Material), or navigation drawer for 5+ items |
| Web      | Top navigation bar or sidebar; breadcrumbs for deep hierarchies     |

### Modal Presentation

| Platform | Pattern                                         |
| -------- | ----------------------------------------------- |
| iOS      | Page sheet (iOS 15+), partial height modals     |
| Android  | Full-screen dialog or bottom sheet              |
| Web      | Centered modal with backdrop; URL should update |
