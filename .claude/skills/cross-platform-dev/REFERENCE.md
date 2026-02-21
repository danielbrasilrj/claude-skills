# Cross-Platform Development -- Reference

## Architecture Deep Dive

### Shared Core + Native UI Pattern

The fundamental principle: **share everything that is not UI**. The boundary is clear:

| Layer | Shared? | Notes |
|---|---|---|
| Domain models | Yes | Pure TypeScript/Dart classes |
| Use cases | Yes | Application logic, no UI imports |
| Repositories | Yes | Interface definitions are shared; implementations may vary |
| API clients | Yes | HTTP layer is platform-agnostic |
| State management | Yes | Zustand, Riverpod, etc. |
| Navigation config | Yes | Route definitions; navigator implementation varies |
| UI components | Partially | Primitives shared, complex widgets may need overrides |
| Native modules | No | Platform-specific bridges |
| Platform config | No | App.json, build.gradle, Info.plist |

### Dependency Injection for Platform Variants

When a service has different implementations per platform, use DI:

```typescript
// shared/di/container.ts
import { Platform } from 'react-native';

interface ServiceContainer {
  storage: StorageService;
  biometrics: BiometricService;
  notifications: NotificationService;
}

function createContainer(): ServiceContainer {
  return {
    storage: Platform.OS === 'web'
      ? new WebStorageService()
      : new SecureStorageService(),
    biometrics: Platform.OS === 'web'
      ? new WebAuthnService()
      : new NativeBiometricService(),
    notifications: Platform.OS === 'web'
      ? new WebPushService()
      : new NativePushService(),
  };
}

export const container = createContainer();
```

## Platform-Specific Patterns

### iOS Considerations

- **Safe Areas**: Always use `useSafeAreaInsets()` for layout
- **Haptic Feedback**: Use `expo-haptics` or `react-native-haptic-feedback`
- **Large Titles**: iOS navigation bars support large titles; enable for top-level screens
- **Swipe Back**: Enabled by default in stack navigators; do not disable
- **Dynamic Type**: Support iOS accessibility text sizes with `allowFontScaling`
- **App Tracking Transparency**: Required for iOS 14.5+ if using ad tracking

### Android Considerations

- **Material Design 3**: Follow Material You guidelines for theming
- **Back Button**: Hardware/gesture back must be handled in navigation
- **Status Bar**: Translucent by default; manage with `StatusBar` component
- **Permissions**: Request at runtime; handle "Don't ask again" state
- **Foldables**: Test on foldable form factors if targeting Samsung/Pixel Fold
- **Edge-to-Edge**: Android 15+ enforces edge-to-edge; prepare layouts accordingly

### Web Considerations

- **SEO**: Use SSR/SSG where possible (Next.js, Expo Web with static export)
- **URL Routing**: Web expects shareable URLs; map all routes to URL paths
- **Hover States**: Web has hover; mobile does not. Use `@media (hover: hover)`
- **Keyboard Navigation**: Tab order, focus rings, arrow key navigation
- **Bundle Size**: Aggressive code splitting; lazy-load feature modules
- **PWA**: Configure service worker, manifest.json, offline support

## Navigation Patterns by Platform

### Tab Navigation

| Platform | Pattern |
|---|---|
| iOS | Bottom tab bar, up to 5 items, "More" for overflow |
| Android | Bottom navigation bar (Material), or navigation drawer for 5+ items |
| Web | Top navigation bar or sidebar; breadcrumbs for deep hierarchies |

### Modal Presentation

| Platform | Pattern |
|---|---|
| iOS | Page sheet (iOS 15+), partial height modals |
| Android | Full-screen dialog or bottom sheet |
| Web | Centered modal with backdrop; URL should update |

## State Synchronization

### Offline-First Pattern

```typescript
// shared/state/sync.ts
export class SyncManager {
  private queue: SyncOperation[] = [];

  async enqueue(operation: SyncOperation) {
    this.queue.push(operation);
    await this.storage.save('sync_queue', this.queue);
    if (this.isOnline) await this.flush();
  }

  async flush() {
    while (this.queue.length > 0) {
      const op = this.queue[0];
      try {
        await this.api.execute(op);
        this.queue.shift();
        await this.storage.save('sync_queue', this.queue);
      } catch (error) {
        if (!isRetryable(error)) {
          this.queue.shift(); // Drop non-retryable
          this.reportError(op, error);
        }
        break; // Stop on retryable errors
      }
    }
  }
}
```

## Testing Strategy

### Unit Tests (Shared)

All domain logic, use cases, and repositories are tested with standard unit test frameworks. These run on Node.js regardless of target platform.

### Component Tests (Per Platform)

- **Mobile**: React Native Testing Library or Flutter widget tests
- **Web**: React Testing Library with jsdom

### E2E Tests (Per Platform)

| Platform | Tool |
|---|---|
| iOS | Detox, Maestro |
| Android | Detox, Maestro |
| Web | Playwright, Cypress |

### Visual Regression

Use Storybook with Chromatic or Percy for visual regression across breakpoints.

## Performance Baselines

| Metric | Mobile Target | Web Target |
|---|---|---|
| Cold start | < 2s | < 1.5s (LCP) |
| Navigation transition | < 300ms | < 200ms |
| List scroll FPS | 60 FPS | 60 FPS |
| Bundle size (JS) | < 5 MB (compressed) | < 200 KB (initial) |
| Memory usage | < 150 MB | < 100 MB |
| API response handling | < 100ms parsing | < 100ms parsing |

## Monorepo Setup

For large projects, use a monorepo with shared packages:

```
packages/
  core/              # Domain logic, use cases, models
  ui/                # Shared UI primitives
  api-client/        # Generated typed API client
  config/            # Shared configuration
apps/
  mobile/            # React Native / Expo app
  web/               # Next.js / Expo Web app
  admin/             # Admin dashboard (web only)
```

**Tooling**: Turborepo or Nx for build orchestration. pnpm workspaces for dependency management.

## Design Token System

Define tokens once, consume per platform:

```json
{
  "color": {
    "primary": { "value": "#2563EB" },
    "surface": { "value": "#FFFFFF" },
    "error": { "value": "#DC2626" }
  },
  "spacing": {
    "xs": { "value": 4 },
    "sm": { "value": 8 },
    "md": { "value": 16 },
    "lg": { "value": 24 },
    "xl": { "value": 32 }
  },
  "typography": {
    "heading": {
      "fontSize": { "value": 24 },
      "fontWeight": { "value": "700" },
      "lineHeight": { "value": 32 }
    }
  },
  "borderRadius": {
    "sm": { "value": 4 },
    "md": { "value": 8 },
    "lg": { "value": 16 },
    "full": { "value": 9999 }
  }
}
```

Use Style Dictionary or similar to transform tokens into platform-specific formats (CSS variables, RN StyleSheet, Flutter ThemeData).
