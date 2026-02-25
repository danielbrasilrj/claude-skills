# Monorepo Setup & Design Token System

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

---

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
