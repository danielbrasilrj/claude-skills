# Code Review Example: User Authentication Feature

**PR #342**: Add email/password authentication  
**Author**: @sarah-dev  
**Reviewer**: @code-reviewer  
**Date**: 2026-02-21

---

## PR Summary

Implements user registration and login with email/password. Includes API endpoints, database schema, and React components.

**Files Changed**: 12 files, +487 lines, -23 lines

---

## Review Notes

### Pillar 1: Correctness ✅

**PRAISE**: Error handling is thorough
```typescript
// src/services/auth.service.ts
try {
  const user = await this.userRepository.create({ email, passwordHash });
  return { success: true, user };
} catch (error) {
  if (error.code === 'ER_DUP_ENTRY') {
    return { success: false, error: 'Email already registered' };
  }
  throw error; // Re-throw unexpected errors
}
```

**SUGGESTION**: Add email format validation
```typescript
// src/services/auth.service.ts:45
async register(email: string, password: string) {
  // Add this check
  if (!this.isValidEmail(email)) {
    return { success: false, error: 'Invalid email format' };
  }
  // ...
}

private isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
```

**QUESTION**: What happens if user registers but email verification fails?
```typescript
// src/services/auth.service.ts:52
await this.sendVerificationEmail(user.email);
// Should this be in a try/catch? What if email service is down?
```

---

### Pillar 2: Code Style ✅

**PRAISE**: Consistent naming and file organization

**NITPICK**: Minor formatting inconsistency
```typescript
// src/components/LoginForm.tsx:78
// Inconsistent spacing around ternary
const buttonText = isLoading? 'Logging in...' : 'Log In';
// Should be:
const buttonText = isLoading ? 'Logging in...' : 'Log In';
```

---

### Pillar 3: Security 🔴

**BLOCKER**: Password hashing uses weak algorithm
```typescript
// src/services/auth.service.ts:28
const passwordHash = crypto.createHash('md5').update(password).digest('hex');
```
**Fix**: Use bcrypt or argon2
```typescript
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12;
const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);
```

**BLOCKER**: JWT secret is hardcoded
```typescript
// src/services/auth.service.ts:65
const token = jwt.sign({ userId: user.id }, 'my-secret-key', { expiresIn: '7d' });
```
**Fix**: Load from environment variable
```typescript
const token = jwt.sign(
  { userId: user.id },
  process.env.JWT_SECRET,
  { expiresIn: '7d' }
);
```

**CRITICAL**: No rate limiting on login endpoint
```typescript
// src/routes/auth.routes.ts:18
router.post('/login', authController.login);
```
**Fix**: Add rate limiting middleware
```typescript
import rateLimit from 'express-rate-limit';

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: 'Too many login attempts, please try again later'
});

router.post('/login', loginLimiter, authController.login);
```

**SUGGESTION**: Use httpOnly cookies for JWT instead of localStorage
```typescript
// src/components/LoginForm.tsx:42
localStorage.setItem('token', response.token); // Vulnerable to XSS
```
**Better**: Server sets httpOnly cookie
```typescript
// Server-side
res.cookie('token', token, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'strict',
  maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
});

// Client-side: No token handling needed, cookie sent automatically
```

---

### Pillar 4: Performance ✅

**SUGGESTION**: Add database index on email field
```sql
-- migrations/003_add_auth_tables.sql:8
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
**Add**:
```sql
CREATE INDEX idx_users_email ON users(email);
```

**PRAISE**: Login component uses debounced validation
```typescript
// src/components/LoginForm.tsx:32
const debouncedValidate = useMemo(
  () => debounce(validateEmail, 300),
  []
);
```

---

### Pillar 5: Accessibility 🟡

**MAJOR**: Form inputs missing labels
```typescript
// src/components/LoginForm.tsx:55
<input
  type="email"
  placeholder="Email"
  value={email}
  onChange={(e) => setEmail(e.target.value)}
/>
```
**Fix**: Add proper labels
```typescript
<label htmlFor="email">Email</label>
<input
  id="email"
  type="email"
  placeholder="you@example.com"
  value={email}
  onChange={(e) => setEmail(e.target.value)}
  aria-required="true"
  aria-invalid={emailError ? 'true' : 'false'}
  aria-describedby={emailError ? 'email-error' : undefined}
/>
{emailError && <span id="email-error" role="alert">{emailError}</span>}
```

**MAJOR**: Error messages not announced to screen readers
```typescript
// src/components/LoginForm.tsx:88
{error && <div className="error">{error}</div>}
```
**Fix**: Add ARIA live region
```typescript
{error && (
  <div className="error" role="alert" aria-live="assertive">
    {error}
  </div>
)}
```

**SUGGESTION**: Add skip link for keyboard users
```typescript
// src/components/LoginForm.tsx
<a href="#main-content" className="skip-link">
  Skip to main content
</a>
```

---

### Pillar 6: Maintainability ✅

**PRAISE**: Clear separation of concerns (controller → service → repository)

**SUGGESTION**: Extract magic numbers to constants
```typescript
// src/services/auth.service.ts:65
const token = jwt.sign({ userId: user.id }, secret, { expiresIn: '7d' });

// src/services/auth.service.ts:28
const passwordHash = await bcrypt.hash(password, 12);
```
**Better**:
```typescript
// src/config/auth.config.ts
export const AUTH_CONFIG = {
  JWT_EXPIRES_IN: '7d',
  BCRYPT_SALT_ROUNDS: 12,
  PASSWORD_MIN_LENGTH: 8,
  EMAIL_VERIFICATION_TIMEOUT: 24 * 60 * 60 * 1000 // 24 hours
};
```

**QUESTION**: Why is `sendVerificationEmail` in the service layer?
```typescript
// src/services/auth.service.ts:52
await this.sendVerificationEmail(user.email);
```
**Suggestion**: Move to separate email service for better separation of concerns

---

### Pillar 7: Testing 🟡

**CRITICAL**: No tests for authentication service
```
tests/
  └── components/
      └── LoginForm.test.tsx
```
**Required**: Add tests for auth.service.ts
```typescript
// tests/services/auth.service.test.ts
describe('AuthService', () => {
  describe('register', () => {
    it('creates user with hashed password', async () => {
      const result = await authService.register('test@example.com', 'password123');
      expect(result.success).toBe(true);
      expect(result.user.passwordHash).not.toBe('password123');
    });

    it('rejects duplicate email', async () => {
      await authService.register('test@example.com', 'password123');
      const result = await authService.register('test@example.com', 'password456');
      expect(result.success).toBe(false);
      expect(result.error).toBe('Email already registered');
    });

    it('rejects weak passwords', async () => {
      const result = await authService.register('test@example.com', '123');
      expect(result.success).toBe(false);
      expect(result.error).toContain('password');
    });
  });

  describe('login', () => {
    it('returns token for valid credentials', async () => {
      await authService.register('test@example.com', 'password123');
      const result = await authService.login('test@example.com', 'password123');
      expect(result.success).toBe(true);
      expect(result.token).toBeDefined();
    });

    it('rejects invalid password', async () => {
      await authService.register('test@example.com', 'password123');
      const result = await authService.login('test@example.com', 'wrongpassword');
      expect(result.success).toBe(false);
    });
  });
});
```

**MAJOR**: LoginForm tests don't cover error states
```typescript
// tests/components/LoginForm.test.tsx
it('renders login form', () => {
  render(<LoginForm />);
  expect(screen.getByPlaceholderText('Email')).toBeInTheDocument();
});
```
**Add**:
```typescript
it('displays error when login fails', async () => {
  mockLogin.mockRejectedValue(new Error('Invalid credentials'));
  render(<LoginForm />);
  
  fireEvent.change(screen.getByLabelText('Email'), { target: { value: 'test@example.com' } });
  fireEvent.change(screen.getByLabelText('Password'), { target: { value: 'wrong' } });
  fireEvent.click(screen.getByText('Log In'));
  
  await waitFor(() => {
    expect(screen.getByRole('alert')).toHaveTextContent('Invalid credentials');
  });
});
```

**PRAISE**: Good test coverage for happy path in LoginForm component

---

### Pillar 8: Architecture ✅

**PRAISE**: Clean layered architecture (routes → controllers → services → repositories)

**SUGGESTION**: Consider using DTO (Data Transfer Object) for API requests
```typescript
// src/controllers/auth.controller.ts:12
async register(req: Request, res: Response) {
  const { email, password } = req.body; // No validation
  // ...
}
```
**Better**:
```typescript
// src/dto/auth.dto.ts
export class RegisterDTO {
  @IsEmail()
  email: string;

  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
  password: string;
}

// src/controllers/auth.controller.ts
async register(req: Request, res: Response) {
  const dto = plainToClass(RegisterDTO, req.body);
  const errors = await validate(dto);
  if (errors.length > 0) {
    return res.status(400).json({ errors });
  }
  // ...
}
```

---

## Feedback Summary

### 🔴 Blockers (Must Fix Before Merge)
1. **Security**: Replace MD5 with bcrypt/argon2 for password hashing
2. **Security**: Move JWT secret to environment variable

### 🟡 Critical (Should Fix Before Merge)
1. **Security**: Add rate limiting to login endpoint
2. **Testing**: Add tests for AuthService (register, login, token validation)
3. **Accessibility**: Add proper form labels and ARIA attributes

### 🟢 Suggestions (Can Defer to Follow-up PR)
1. Email format validation in registration
2. Database index on users.email field
3. Extract magic numbers to constants
4. Use httpOnly cookies instead of localStorage for tokens
5. Move email service out of auth service
6. Consider DTO pattern for request validation

### ❓ Questions
1. How should we handle email verification failures during registration?
2. Should we implement password reset in this PR or separately?
3. What's the plan for social login (OAuth) integration?

### 🎉 Praise
- Excellent error handling in service layer
- Clean separation of concerns (controller → service → repository)
- Good use of debounced validation in LoginForm
- Thorough happy-path test coverage

---

## Approval Status

**⏸️ REQUEST CHANGES** - Do not merge until security blockers are resolved.

**Next Steps**:
1. Fix MD5 → bcrypt
2. Move JWT secret to .env
3. Add rate limiting middleware
4. Add AuthService tests
5. Fix accessibility issues in LoginForm

Once blockers are resolved, re-request review.

**Estimated Time to Address**: 2-3 hours

---

## Reviewer Notes

Great first pass at authentication! The architecture is clean and the happy path works well. The main concerns are security-related (weak hashing, hardcoded secrets) and missing tests. These are all straightforward to fix.

After addressing blockers, I recommend a follow-up PR for:
- Password strength requirements UI
- Email verification flow
- Password reset functionality
- OAuth integration (Google, GitHub)

Keep up the good work!

**Reviewer**: @code-reviewer  
**Date**: 2026-02-21
