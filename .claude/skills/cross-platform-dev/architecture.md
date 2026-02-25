# Architecture Deep Dive

## Shared Core + Native UI Pattern

The fundamental principle: **share everything that is not UI**. The boundary is clear:

| Layer             | Shared?   | Notes                                                      |
| ----------------- | --------- | ---------------------------------------------------------- |
| Domain models     | Yes       | Pure TypeScript/Dart classes                               |
| Use cases         | Yes       | Application logic, no UI imports                           |
| Repositories      | Yes       | Interface definitions are shared; implementations may vary |
| API clients       | Yes       | HTTP layer is platform-agnostic                            |
| State management  | Yes       | Zustand, Riverpod, etc.                                    |
| Navigation config | Yes       | Route definitions; navigator implementation varies         |
| UI components     | Partially | Primitives shared, complex widgets may need overrides      |
| Native modules    | No        | Platform-specific bridges                                  |
| Platform config   | No        | App.json, build.gradle, Info.plist                         |

## Dependency Injection for Platform Variants

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
    storage: Platform.OS === 'web' ? new WebStorageService() : new SecureStorageService(),
    biometrics: Platform.OS === 'web' ? new WebAuthnService() : new NativeBiometricService(),
    notifications: Platform.OS === 'web' ? new WebPushService() : new NativePushService(),
  };
}

export const container = createContainer();
```

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
