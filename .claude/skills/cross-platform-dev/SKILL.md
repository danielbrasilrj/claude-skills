---
name: cross-platform-dev
description: Stack-agnostic cross-platform mobile and web development. Manages platform-specific code, shared components, navigation patterns, and state management with a "Shared Core + Native UI" philosophy.
---

# Cross-Platform Development

## Purpose

Guide the development of applications that target multiple platforms (iOS, Android, Web) from a single codebase. Enforce the "Shared Core + Native UI" pattern where business logic, state management, and data access are shared while UI adapts to each platform's conventions. Works with React Native, Expo, Flutter, or any framework defined by domain-intelligence.

## When to Use

- Starting a new cross-platform project (mobile + web)
- Adding a new feature that must work across platforms
- Refactoring platform-specific code into shared modules
- Setting up navigation that respects platform conventions
- Implementing shared state management
- Creating components that adapt to platform capabilities
- Running the cross-platform QA checklist before release

## Prerequisites

- Framework decision made via domain-intelligence skill (React Native/Expo, Flutter, etc.)
- Node.js 18+ (for RN/Expo) or Dart/Flutter SDK installed
- Platform SDKs: Xcode (iOS), Android Studio (Android)
- Understanding of target platform design guidelines (HIG, Material Design)

## Procedures

### 1. Project Structure Setup

Organize code by feature, not by platform. Each feature module contains its own shared logic and platform-specific UI.

```
src/
  features/
    auth/
      domain/           # Shared business logic
        models.ts
        auth.repository.ts
        auth.use-cases.ts
      data/              # Shared data access
        auth.api.ts
        auth.storage.ts
      ui/                # Platform-adaptive UI
        LoginScreen.tsx
        LoginScreen.web.tsx  # Web override (if needed)
        components/
          LoginForm.tsx
  shared/
    components/          # Cross-platform primitives
    hooks/               # Shared hooks
    utils/               # Pure utility functions
    navigation/          # Navigation config
    state/               # Global state management
  platform/
    ios/                 # iOS-specific native code
    android/             # Android-specific native code
    web/                 # Web-specific adapters
```

### 2. Shared Core Pattern

All business logic lives in the domain layer and is 100% platform-agnostic.

**Repository Pattern for Data Access:**

```typescript
// features/auth/domain/auth.repository.ts
export interface AuthRepository {
  login(email: string, password: string): Promise<User>;
  logout(): Promise<void>;
  getCurrentUser(): Promise<User | null>;
  refreshToken(): Promise<string>;
}

// features/auth/data/auth.api.ts
export class AuthApiRepository implements AuthRepository {
  constructor(private api: HttpClient, private storage: TokenStorage) {}

  async login(email: string, password: string): Promise<User> {
    const response = await this.api.post('/auth/login', { email, password });
    await this.storage.setToken(response.token);
    return response.user;
  }
  // ...
}
```

**Use Cases (Application Logic):**

```typescript
// features/auth/domain/auth.use-cases.ts
export class LoginUseCase {
  constructor(
    private authRepo: AuthRepository,
    private analytics: AnalyticsService
  ) {}

  async execute(email: string, password: string): Promise<Result<User>> {
    try {
      const user = await this.authRepo.login(email, password);
      this.analytics.track('login_success');
      return Result.ok(user);
    } catch (error) {
      this.analytics.track('login_failure', { reason: error.message });
      return Result.fail(error);
    }
  }
}
```

### 3. Platform-Specific Code

Use file extensions for platform overrides. The bundler resolves the correct file automatically.

```
Component.tsx          # Default (shared)
Component.native.tsx   # Mobile override (iOS + Android)
Component.ios.tsx      # iOS-only override
Component.android.tsx  # Android-only override
Component.web.tsx      # Web-only override
```

**Platform Detection Hook:**

```typescript
// shared/hooks/usePlatform.ts
import { Platform } from 'react-native';

export function usePlatform() {
  return {
    isIOS: Platform.OS === 'ios',
    isAndroid: Platform.OS === 'android',
    isWeb: Platform.OS === 'web',
    isMobile: Platform.OS !== 'web',
    select: Platform.select,
  };
}
```

### 4. Navigation

Use a declarative navigation config that maps to platform-appropriate navigators.

```typescript
// shared/navigation/routes.ts
export const routes = {
  auth: {
    login: 'auth/login',
    register: 'auth/register',
    forgotPassword: 'auth/forgot-password',
  },
  main: {
    home: 'main/home',
    profile: 'main/profile',
    settings: 'main/settings',
  },
} as const;

// Navigation uses stack on mobile, flat routes on web
// React Navigation (mobile) + React Router or Expo Router (web)
```

### 5. State Management

Use a framework-agnostic state layer. Zustand (React), Riverpod (Flutter), or similar.

```typescript
// shared/state/auth.store.ts
import { create } from 'zustand';

interface AuthState {
  user: User | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isLoading: false,
  login: async (email, password) => {
    set({ isLoading: true });
    const result = await loginUseCase.execute(email, password);
    if (result.isOk) set({ user: result.value, isLoading: false });
    else set({ isLoading: false });
  },
  logout: async () => {
    await logoutUseCase.execute();
    set({ user: null });
  },
}));
```

### 6. Responsive and Adaptive UI

```typescript
// shared/hooks/useResponsive.ts
import { useWindowDimensions } from 'react-native';

type Breakpoint = 'mobile' | 'tablet' | 'desktop';

export function useResponsive() {
  const { width } = useWindowDimensions();

  const breakpoint: Breakpoint =
    width < 768 ? 'mobile' : width < 1024 ? 'tablet' : 'desktop';

  return {
    breakpoint,
    isMobile: breakpoint === 'mobile',
    isTablet: breakpoint === 'tablet',
    isDesktop: breakpoint === 'desktop',
    columns: breakpoint === 'mobile' ? 1 : breakpoint === 'tablet' ? 2 : 3,
  };
}
```

### 7. QA Checklist Execution

Before any release, run through the cross-platform QA checklist (see `templates/cross-platform-checklist.md`). This covers:

- Visual consistency across platforms
- Navigation behavior per platform conventions
- Input handling (keyboard, gestures, mouse)
- Performance baselines per platform
- Accessibility compliance
- Offline and edge-case scenarios

## Templates

- `templates/cross-platform-checklist.md` -- Full QA checklist for multi-platform validation

## Examples

- `examples/shared-component-example.md` -- A complete adaptive component with platform overrides

## Chaining

| Trigger | Target Skill | Purpose |
|---|---|---|
| Framework not decided | `domain-intelligence` | Define tech stack before building |
| API integration needed | `api-contract-testing` | Generate typed clients for shared data layer |
| Ready to ship | `ci-cd-pipeline` | Build and deploy for all platforms |
| PR ready for review | `code-review` | Review with cross-platform pillars |
| Performance concerns | `performance-optimization` | Profile per platform |
| Accessibility gaps | `accessibility-audit` | WCAG compliance per platform |

## Troubleshooting

| Problem | Cause | Solution |
|---|---|---|
| Platform file not resolving | Incorrect extension | Verify bundler config supports `.native.tsx`, `.web.tsx` etc. |
| Style differences across platforms | Missing platform normalization | Use a design token system; avoid raw pixel values |
| Navigation mismatch | Wrong navigator type | Use stack on mobile, flat on web; check Expo Router config |
| Web bundle too large | Native modules included in web build | Use `Platform.select` or `.web.tsx` overrides to tree-shake |
| Android keyboard covers input | Missing `KeyboardAvoidingView` | Wrap forms with platform-specific keyboard handling |
| iOS safe area issues | Missing SafeAreaProvider | Wrap root with `SafeAreaProvider` from `react-native-safe-area-context` |
| Shared hook crashes on one platform | Platform API not available | Guard with `Platform.OS` check or provide platform-specific implementation |
