# Test File Template

Use this as a starting point for any test file. Adapt the framework-specific syntax as needed.

## Vitest / Jest Unit Test

```typescript
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
// For Jest: remove the import line above (globals are available)

import { MyService } from '../my-service';
import { MyDependency } from '../my-dependency';

// -------------------------------------------------------
// Mocks
// -------------------------------------------------------
vi.mock('../my-dependency', () => ({
  MyDependency: vi.fn().mockImplementation(() => ({
    fetchData: vi.fn().mockResolvedValue({ id: '1', name: 'Test' }),
  })),
}));

// -------------------------------------------------------
// Test Suite
// -------------------------------------------------------
describe('MyService', () => {
  let service: MyService;
  let dependency: MyDependency;

  // -- Setup / Teardown ----------------------------------
  beforeEach(() => {
    dependency = new MyDependency();
    service = new MyService(dependency);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  // -- Happy Path ----------------------------------------
  describe('getData', () => {
    it('should return formatted data from dependency', async () => {
      // Arrange
      const expected = { id: '1', name: 'Test', formatted: true };

      // Act
      const result = await service.getData('1');

      // Assert
      expect(result).toEqual(expected);
      expect(dependency.fetchData).toHaveBeenCalledWith('1');
      expect(dependency.fetchData).toHaveBeenCalledTimes(1);
    });
  });

  // -- Edge Cases ----------------------------------------
  describe('getData edge cases', () => {
    it('should return null when id is empty', async () => {
      const result = await service.getData('');
      expect(result).toBeNull();
    });

    it('should handle special characters in id', async () => {
      const result = await service.getData('id/with/slashes');
      expect(result).toBeDefined();
    });
  });

  // -- Error Handling ------------------------------------
  describe('getData errors', () => {
    it('should throw ServiceError when dependency fails', async () => {
      // Arrange
      vi.mocked(dependency.fetchData).mockRejectedValueOnce(
        new Error('Network error')
      );

      // Act & Assert
      await expect(service.getData('1')).rejects.toThrow('ServiceError');
    });

    it('should retry on transient failure', async () => {
      vi.mocked(dependency.fetchData)
        .mockRejectedValueOnce(new Error('timeout'))
        .mockResolvedValueOnce({ id: '1', name: 'Test' });

      const result = await service.getData('1');

      expect(result).toBeDefined();
      expect(dependency.fetchData).toHaveBeenCalledTimes(2);
    });
  });
});
```

## React Component Test (Testing Library)

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';

import { LoginForm } from '../LoginForm';

describe('LoginForm', () => {
  const defaultProps = {
    onSubmit: vi.fn(),
    onForgotPassword: vi.fn(),
  };

  function renderForm(overrides = {}) {
    const props = { ...defaultProps, ...overrides };
    const user = userEvent.setup();
    const result = render(<LoginForm {...props} />);
    return { ...result, user, props };
  }

  it('renders email and password fields', () => {
    renderForm();
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
  });

  it('submits with valid credentials', async () => {
    const { user, props } = renderForm();

    await user.type(screen.getByLabelText(/email/i), 'user@test.com');
    await user.type(screen.getByLabelText(/password/i), 'pass123');
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    await waitFor(() => {
      expect(props.onSubmit).toHaveBeenCalledWith({
        email: 'user@test.com',
        password: 'pass123',
      });
    });
  });

  it('shows validation error for invalid email', async () => {
    const { user } = renderForm();

    await user.type(screen.getByLabelText(/email/i), 'invalid');
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    expect(await screen.findByText(/valid email/i)).toBeInTheDocument();
  });

  it('disables submit button while loading', () => {
    renderForm({ isLoading: true });
    expect(screen.getByRole('button', { name: /sign in/i })).toBeDisabled();
  });
});
```

## Playwright E2E Test

```typescript
import { test, expect } from '@playwright/test';

test.describe('User Registration Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/register');
  });

  test('completes registration successfully', async ({ page }) => {
    await page.getByLabel('Full name').fill('Jane Doe');
    await page.getByLabel('Email').fill('jane@example.com');
    await page.getByLabel('Password').fill('SecureP@ss1');
    await page.getByLabel('Confirm password').fill('SecureP@ss1');
    await page.getByRole('button', { name: 'Create account' }).click();

    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByText('Welcome, Jane')).toBeVisible();
  });

  test('shows error for duplicate email', async ({ page }) => {
    // Assumes seed data includes this email
    await page.getByLabel('Full name').fill('Jane Doe');
    await page.getByLabel('Email').fill('existing@example.com');
    await page.getByLabel('Password').fill('SecureP@ss1');
    await page.getByLabel('Confirm password').fill('SecureP@ss1');
    await page.getByRole('button', { name: 'Create account' }).click();

    await expect(page.getByText('Email already registered')).toBeVisible();
  });
});
```

## Maestro Mobile E2E Test

```yaml
appId: com.example.app
name: User Registration Flow
---
- launchApp:
    clearState: true

- tapOn: "Create Account"

- inputText:
    id: "fullName"
    text: "Jane Doe"
- inputText:
    id: "email"
    text: "jane@example.com"
- inputText:
    id: "password"
    text: "SecureP@ss1"

- tapOn: "Sign Up"

- waitForAnimationToEnd

- assertVisible: "Welcome, Jane"
- takeScreenshot: "registration-success"
```
