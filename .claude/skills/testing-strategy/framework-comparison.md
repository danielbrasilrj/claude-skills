# Framework Comparison Deep Dive

## Vitest vs Jest

| Feature               | Vitest                                | Jest                                       |
| --------------------- | ------------------------------------- | ------------------------------------------ |
| Speed (Vite projects) | ~4x faster (native ESM, no transform) | Slower (Babel transform required)          |
| Config                | Extends `vite.config.ts`              | Separate `jest.config.ts`                  |
| ESM support           | Native                                | Experimental (`--experimental-vm-modules`) |
| Watch mode            | Instant (HMR-based)                   | Full re-run or `--onlyChanged`             |
| Snapshot testing      | Yes (compatible format)               | Yes (original)                             |
| Module mocking        | `vi.mock()` with hoisting             | `jest.mock()` with hoisting                |
| Coverage              | `c8` or `istanbul` built-in           | `istanbul` built-in                        |
| Concurrent tests      | `it.concurrent` built-in              | `--maxWorkers` only                        |
| UI                    | `@vitest/ui` browser dashboard        | N/A                                        |
| React Native          | Not supported                         | Built-in support                           |
| Community size        | Growing fast                          | Largest ecosystem                          |

**Migration path**: Vitest is mostly Jest-compatible. Replace `jest.fn()` with `vi.fn()`, `jest.mock()` with `vi.mock()`, and update config. Run `npx vitest --reporter=verbose` to validate.

## Playwright vs Cypress

| Feature           | Playwright                           | Cypress                                  |
| ----------------- | ------------------------------------ | ---------------------------------------- |
| Multi-browser     | Chromium, Firefox, WebKit            | Chromium (+ Firefox/WebKit experimental) |
| Multi-tab/origin  | Full support                         | Limited                                  |
| Auto-wait         | Built-in for all actions             | Built-in but less granular               |
| Trace viewer      | Included (screenshots, DOM, network) | Dashboard (paid)                         |
| Parallelism       | Built-in sharding                    | Paid parallelization                     |
| Mobile emulation  | Device presets                       | Viewport only                            |
| API testing       | `request` context built-in           | `cy.request()`                           |
| Component testing | Experimental                         | Stable                                   |
| iframes           | Full support                         | Limited                                  |
| Speed             | Faster (WebSocket protocol)          | Slower (proxy-based)                     |

## Maestro for Mobile E2E

Maestro uses YAML flows, making mobile E2E accessible without complex setup:

```yaml
appId: com.example.app
---
- launchApp
- tapOn: 'Sign In'
- inputText:
    id: 'email'
    text: 'test@example.com'
- inputText:
    id: 'password'
    text: 'password123'
- tapOn: 'Submit'
- assertVisible: 'Welcome'
- takeScreenshot: 'login-success'
```

**Key capabilities**:

- Runs on real devices and emulators
- Visual element selection (no XPath fragility)
- Built-in retry and wait logic
- CI integration via `maestro cloud`
- Screenshot comparison for visual regression
