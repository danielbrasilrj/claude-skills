---
name: performance-optimization
description: |
  Procedures for mobile and web performance profiling, bundle size analysis, image optimization,
  lazy loading strategies, and database query optimization. Includes Core Web Vitals targets,
  performance budget templates, and benchmark script patterns. Use when optimizing app performance,
  reducing bundle size, profiling slow queries, or setting up performance monitoring.
---

## Purpose

Performance Optimization provides structured procedures for identifying and fixing performance bottlenecks across mobile and web applications. It covers the full stack from frontend bundle optimization through backend query profiling, with measurable targets based on Core Web Vitals.

## When to Use

- App feels slow or users report performance issues
- Bundle size exceeds budget thresholds
- Core Web Vitals scores are poor
- Database queries are slow
- Setting up performance monitoring and budgets
- Pre-launch performance audit

## Prerequisites

- Access to app build artifacts or running app
- Chrome DevTools or platform-specific profiler
- Optional: Lighthouse CI, size-limit, bundlesize

## Procedures

### 1. Measure First (Never Optimize Without Data)

**Core Web Vitals Targets:**
| Metric | Good | Needs Improvement | Poor |
|---|---|---|---|
| LCP (Largest Contentful Paint) | ≤ 2.5s | ≤ 4.0s | > 4.0s |
| INP (Interaction to Next Paint) | ≤ 200ms | ≤ 500ms | > 500ms |
| CLS (Cumulative Layout Shift) | ≤ 0.1 | ≤ 0.25 | > 0.25 |

```bash
# Lighthouse audit
npx lighthouse https://app.example.com --output=json --only-categories=performance
```

### 2. Bundle Size Optimization

**Analysis:**
```bash
# Vite/Rollup
npx rollup-plugin-visualizer  # generates treemap

# Any bundler
npx source-map-explorer dist/main.js
```

**Optimization techniques:**
1. **Tree shaking** — requires ES Module imports (not CommonJS `require()`)
2. **Code splitting** — split by route: `React.lazy(() => import('./Page'))`
3. **Replace heavy libraries** — `date-fns` over `moment`, `lodash/debounce` over full lodash
4. **Remove unused deps** — `npx knip` or `npx depcheck`

### 3. Image Optimization

- Use modern formats: WebP (90% support), AVIF (85% support)
- Responsive images: `<img srcset="..." sizes="...">`
- Lazy load below-fold images: `<img loading="lazy">`
- Compress: target < 100KB for hero images, < 50KB for thumbnails

### 4. Lazy Loading Strategy

- **Above the fold**: Load immediately (never lazy-load)
- **Below the fold**: `loading="lazy"` for images/iframes
- **Routes**: Dynamic `import()` for non-critical pages
- **Components**: `React.lazy()` + `Suspense` for heavy components

### 5. Database Query Optimization

```sql
-- Find slow queries (PostgreSQL)
SELECT query, mean_exec_time, calls
FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 10;

-- Analyze specific query
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';
```

**Quick wins:**
- Add indexes on WHERE, JOIN, ORDER BY columns
- Fix N+1 queries (use eager loading / batch)
- Implement connection pooling (PgBouncer)
- Cache frequent reads (Redis)

### 6. Set Performance Budget

```json
{
  "budgets": [
    { "metric": "js-bundle", "max": "200KB", "warning": "150KB" },
    { "metric": "total-transfer", "max": "500KB" },
    { "metric": "lcp", "max": "2500ms" },
    { "metric": "cls", "max": "0.1" }
  ]
}
```

Enforce in CI with `size-limit` or `bundlesize`.

## Templates

- `templates/performance-budget.md` — Budget configuration template
- `templates/optimization-checklist.md` — Full optimization checklist

## Examples

- `examples/optimization-report.md` — Complete optimization report

## Chaining

| Chain With | Purpose |
|---|---|
| `ci-cd-pipeline` | Add perf budget checks to CI |
| `code-review` | Flag perf anti-patterns in review |
| `database-ops` | Optimize database layer |
| `data-analysis` | Analyze performance metrics |

## Troubleshooting

| Problem | Solution |
|---|---|
| Bundle too large but can't find cause | Use source-map-explorer for treemap visualization |
| Tree shaking not working | Check for CommonJS imports; ensure ES module syntax |
| LCP still slow after optimization | Check server response time; consider CDN |
| Mobile-specific slowness | Profile on real device, not emulator; check memory usage |
