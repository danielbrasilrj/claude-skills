# Testing Strategy & Performance Baselines

## Testing Strategy

### Unit Tests (Shared)

All domain logic, use cases, and repositories are tested with standard unit test frameworks. These run on Node.js regardless of target platform.

### Component Tests (Per Platform)

- **Mobile**: React Native Testing Library or Flutter widget tests
- **Web**: React Testing Library with jsdom

### E2E Tests (Per Platform)

| Platform | Tool                |
| -------- | ------------------- |
| iOS      | Detox, Maestro      |
| Android  | Detox, Maestro      |
| Web      | Playwright, Cypress |

### Visual Regression

Use Storybook with Chromatic or Percy for visual regression across breakpoints.

---

## Performance Baselines

| Metric                | Mobile Target       | Web Target         |
| --------------------- | ------------------- | ------------------ |
| Cold start            | < 2s                | < 1.5s (LCP)       |
| Navigation transition | < 300ms             | < 200ms            |
| List scroll FPS       | 60 FPS              | 60 FPS             |
| Bundle size (JS)      | < 5 MB (compressed) | < 200 KB (initial) |
| Memory usage          | < 150 MB            | < 100 MB           |
| API response handling | < 100ms parsing     | < 100ms parsing    |
