# PRD: User Authentication System

**Status**: Approved  
**Owner**: Sarah Chen (Product Manager)  
**Engineering Lead**: Marcus Rodriguez  
**Design Lead**: Emily Thompson  
**Target Ship Date**: 2024-03-15  
**PRD ID**: PRD-047

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2024-01-10 | Sarah Chen | Initial draft |
| 1.1 | 2024-01-15 | Sarah Chen | Added password requirements per security review |
| 1.2 | 2024-01-18 | Sarah Chen | Moved OAuth to v2.0 per timeline constraints |
| 2.0 | 2024-01-22 | Sarah Chen | Final approval, ready for implementation |

---

## Problem Statement

### Current Pain Point
Our SaaS platform currently lacks any user authentication system. Users can access the application by directly navigating to any URL, creating a critical security vulnerability. This prevents us from:
1. Identifying which users perform which actions (no audit trail)
2. Restricting access to paid features (no paywall)
3. Personalizing the user experience (no user context)

### User Impact
- **Who**: All 1,200 existing users + new signups (target: 500/month)
- **Frequency**: Every time they access the application (avg 3 sessions/day)
- **Cost**: Security risk of data exposure, inability to enforce paid tier limits, zero personalization leading to poor UX

### Business Impact
- **Revenue**: Cannot convert free users to paid tiers (estimated $120k ARR loss)
- **Metric**: User retention at 35% (industry avg with auth: 60%)
- **Competitive**: All competitors have secure authentication; we appear unprofessional
- **Risk**: GDPR compliance violation (no way to identify user data ownership)

---

## User Stories

### Epic: Basic Authentication

#### Story 1: User Registration
**As a** new user  
**I want** to create an account with email and password  
**So that** I can securely access the platform and save my work

**Acceptance Criteria:**
- **AC1**: Successful Registration
  - Given I am on the registration page at `/signup`
  - When I enter email "alice@example.com", password "SecurePass123!", and confirm password "SecurePass123!"
  - And I click the "Create Account" button
  - Then my account is created in the database
  - And I receive a confirmation email to "alice@example.com"
  - And I am redirected to `/onboarding` (not auto-logged in, must verify email first)

- **AC2**: Password Validation
  - Given I am on the registration page
  - When I enter a password that does NOT meet requirements (see Technical Context)
  - Then I see real-time validation errors below the password field
  - And the "Create Account" button is disabled
  - And error messages specify exactly what's wrong (e.g., "Password must contain at least 1 uppercase letter")

- **AC3**: Duplicate Email Prevention
  - Given a user with email "alice@example.com" already exists
  - When I try to register with the same email
  - Then I see error "An account with this email already exists"
  - And I see a link "Already have an account? Log in here"
  - But the existing user's data is not exposed (no hints about whether email exists until after submission)

**Technical Context for AI:**
- **Input**: 
  ```typescript
  {
    email: string,        // must match regex /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    password: string,     // min 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special
    confirmPassword: string
  }
  ```
- **Process**: 
  1. Validate email format (regex)
  2. Validate password strength (see password requirements below)
  3. Check email uniqueness via `User.findOne({ email })`
  4. Hash password with bcrypt (cost factor 12)
  5. Create user record with `emailVerified: false`
  6. Generate email verification token (JWT, 24-hour expiry)
  7. Send verification email via SendGrid
- **Output**: 
  ```typescript
  {
    success: true,
    userId: string,
    message: "Account created. Check your email to verify."
  }
  ```
- **Dependencies**: 
  - SendGrid API key configured in environment variables
  - Email templates in `src/email-templates/verify-email.html`

**Password Requirements (for validation):**
- Minimum 8 characters
- At least 1 uppercase letter (A-Z)
- At least 1 lowercase letter (a-z)
- At least 1 number (0-9)
- At least 1 special character (!@#$%^&*)
- No common passwords (check against list in `src/utils/common-passwords.txt` - top 10,000 most common)

---

#### Story 2: Email Verification
**As a** newly registered user  
**I want** to verify my email address  
**So that** I can prove I own the email and activate my account

**Acceptance Criteria:**
- **AC1**: Successful Verification
  - Given I received an email with a verification link `https://app.example.com/verify?token=abc123`
  - When I click the link within 24 hours
  - Then my `emailVerified` flag is set to `true` in the database
  - And I see a success message "Email verified! You can now log in."
  - And I am redirected to `/login` with a pre-filled email field

- **AC2**: Expired Token
  - Given I received a verification email 25 hours ago (token expired)
  - When I click the verification link
  - Then I see error "Verification link expired. Request a new one."
  - And I see a "Resend Verification Email" button
  - And clicking it sends a new verification email to my registered address

- **AC3**: Invalid Token
  - Given a verification URL with an invalid/malformed token
  - When I navigate to that URL
  - Then I see error "Invalid verification link"
  - And I see a link to "Return to Login"

**Technical Context for AI:**
- **Input**: 
  ```typescript
  { token: string }  // JWT containing { userId, email, type: 'email-verification' }
  ```
- **Process**: 
  1. Verify JWT signature with secret key from environment
  2. Check JWT expiry (24 hours from creation)
  3. Extract `userId` from payload
  4. Find user with `User.findById(userId)`
  5. If user already verified, skip database update (idempotent)
  6. Set `user.emailVerified = true` and `user.emailVerifiedAt = new Date()`
  7. Save user record
- **Output**: 
  ```typescript
  {
    success: true,
    message: "Email verified successfully"
  }
  ```
- **Dependencies**: 
  - JWT library (jsonwebtoken)
  - Environment variable `JWT_SECRET` for signing/verifying tokens

---

#### Story 3: User Login
**As a** registered user with verified email  
**I want** to log in with my email and password  
**So that** I can access my account and saved data

**Acceptance Criteria:**
- **AC1**: Successful Login
  - Given a verified user with email "alice@example.com" and password "SecurePass123!"
  - When I enter correct credentials on `/login`
  - And I click "Log In"
  - Then I am redirected to `/dashboard`
  - And a session cookie `auth_token` is set (HttpOnly, Secure, SameSite=Strict, 24-hour expiry)
  - And my `lastLoginAt` timestamp is updated in the database

- **AC2**: Unverified Email Login Attempt
  - Given a registered user who has NOT verified their email
  - When they try to log in with correct credentials
  - Then they see message "Please verify your email before logging in. Check your inbox."
  - And they see a "Resend Verification Email" button
  - And they are NOT logged in (no session created)

- **AC3**: Invalid Credentials
  - Given incorrect email or password
  - When I submit login form
  - Then I see generic error "Invalid email or password"
  - And I am NOT logged in
  - And the response time is constant (no timing attacks revealing whether email exists)

- **AC4**: Rate Limiting
  - Given I have made 5 failed login attempts for "alice@example.com" within 15 minutes
  - When I try to log in again (6th attempt)
  - Then I see error "Too many login attempts. Try again in 15 minutes."
  - And the IP address is temporarily blocked for this email
  - But other emails from the same IP can still attempt login (rate limit per email, not per IP)

**Technical Context for AI:**
- **Input**: 
  ```typescript
  { email: string, password: string }
  ```
- **Process**: 
  1. Normalize email to lowercase
  2. Find user with `User.findOne({ email })`
  3. If not found, use dummy bcrypt comparison (prevent timing attacks)
  4. Compare password with `bcrypt.compare(password, user.passwordHash)`
  5. If invalid, return generic error (don't reveal whether email or password was wrong)
  6. Check `user.emailVerified === true`; reject if false
  7. Generate session token (JWT with payload: `{ userId, email, iat }`)
  8. Set HttpOnly cookie with 24-hour expiry
  9. Update `user.lastLoginAt = new Date()`
  10. Log login event for audit trail
- **Output**: 
  ```typescript
  {
    success: true,
    token: string,  // JWT
    user: UserDTO   // Exclude passwordHash, only return safe fields
  }
  ```
  ```typescript
  // UserDTO structure
  {
    id: string,
    email: string,
    name: string | null,
    createdAt: Date,
    lastLoginAt: Date
  }
  ```
- **Dependencies**: 
  - bcrypt for password comparison
  - jsonwebtoken for session token generation
  - Redis for rate limiting (track failed attempts per email)

**Rate Limiting Implementation:**
- Use Redis key pattern: `ratelimit:login:{email}`
- Increment on each failed attempt, expire key after 15 minutes
- Block after 5 failed attempts
- Reset counter on successful login

---

#### Story 4: Session Management
**As a** logged-in user  
**I want** my session to persist across page refreshes  
**So that** I don't have to log in repeatedly during a session

**Acceptance Criteria:**
- **AC1**: Session Persistence
  - Given I am logged in with a valid session token
  - When I refresh the page or navigate to a different route
  - Then I remain logged in (session token is read from cookie)
  - And protected routes (/dashboard, /settings) are accessible
  - And my user data is available in the UI (name, email displayed in header)

- **AC2**: Session Expiry
  - Given my session token was created 25 hours ago (expired)
  - When I navigate to a protected route like `/dashboard`
  - Then I am redirected to `/login?redirectTo=/dashboard`
  - And I see message "Your session expired. Please log in again."
  - And after successful login, I am redirected back to `/dashboard`

- **AC3**: Logout
  - Given I am logged in
  - When I click "Log Out" in the navigation menu
  - Then my session cookie is deleted
  - And I am redirected to `/login`
  - And I see message "You have been logged out successfully"
  - And attempting to access protected routes shows login screen

**Technical Context for AI:**
- **Input**: 
  - Session token from `auth_token` cookie (sent automatically with every request)
- **Process**: 
  1. Extract token from `req.cookies.auth_token`
  2. Verify JWT signature and expiry
  3. Extract `userId` from token payload
  4. Optionally: Fetch user from database to check if account still exists/active
  5. Attach user object to `req.user` for downstream middleware
- **Output**: 
  - If valid: Continue to route handler with `req.user` populated
  - If invalid/expired: Return 401 Unauthorized, redirect to login
- **Dependencies**: 
  - Express middleware pattern: `src/middleware/auth.ts`
  - Cookie parser middleware

**Logout Implementation:**
- Frontend: Call `POST /auth/logout` endpoint
- Backend: Clear cookie with `res.clearCookie('auth_token')`
- Optional: Implement token blacklist in Redis for immediate invalidation (prevents replay if token stolen)

---

#### Story 5: Password Reset
**As a** user who forgot their password  
**I want** to reset my password via email  
**So that** I can regain access to my account

**Acceptance Criteria:**
- **AC1**: Request Password Reset
  - Given I am on the login page
  - When I click "Forgot Password?"
  - And I enter my email "alice@example.com" on the reset page
  - And I click "Send Reset Link"
  - Then I receive an email with a password reset link (expires in 1 hour)
  - And I see message "If an account exists with this email, you will receive a reset link."
  - But the system does NOT reveal whether the email exists (security)

- **AC2**: Reset Password
  - Given I received a reset email with token `xyz789`
  - When I click the link `https://app.example.com/reset-password?token=xyz789`
  - And I enter a new password "NewSecurePass456!" (meets requirements)
  - And I click "Reset Password"
  - Then my password is updated in the database (new bcrypt hash)
  - And I see message "Password reset successfully. You can now log in."
  - And I am redirected to `/login` with email pre-filled
  - And the reset token is invalidated (cannot be reused)

- **AC3**: Expired Reset Token
  - Given I received a reset email 65 minutes ago (expired)
  - When I try to use the reset link
  - Then I see error "Reset link expired. Request a new one."
  - And I see a link to return to "Forgot Password" page

**Technical Context for AI:**
- **Input (Request Reset)**: 
  ```typescript
  { email: string }
  ```
- **Process (Request Reset)**: 
  1. Find user with `User.findOne({ email })`
  2. If not found, still return success message (security: don't reveal existence)
  3. If found, generate reset token (JWT with payload: `{ userId, type: 'password-reset' }`, 1-hour expiry)
  4. Save token hash in `user.passwordResetToken` field (for invalidation check)
  5. Send email with reset link via SendGrid
- **Input (Reset Password)**: 
  ```typescript
  { token: string, newPassword: string }
  ```
- **Process (Reset Password)**: 
  1. Verify JWT signature and expiry
  2. Extract `userId` from token
  3. Find user with `User.findById(userId)`
  4. Validate new password meets requirements
  5. Hash new password with bcrypt
  6. Update `user.passwordHash` and clear `user.passwordResetToken`
  7. Invalidate all existing sessions (optional: force re-login on all devices)
- **Dependencies**: 
  - SendGrid for email delivery
  - Email template: `src/email-templates/reset-password.html`

---

## Technical Constraints

### Performance Requirements
- API response time: p95 < 500ms, p99 < 1000ms
- Login endpoint: p95 < 300ms (critical user path)
- Database query budget: max 2 queries per authentication check
- Frontend bundle size: Auth UI adds < 80KB gzipped to main bundle
- Lighthouse Performance score: ≥ 90 on login/signup pages

### Security Requirements
- **Password Storage**: bcrypt with cost factor 12 (OWASP recommendation)
- **Session Tokens**: JWT with RS256 (asymmetric) signing for stateless auth
  - Payload: `{ userId, email, iat, exp }`
  - Expiry: 24 hours
  - Stored in HttpOnly, Secure, SameSite=Strict cookie
- **HTTPS Only**: All authentication endpoints must use TLS 1.3
- **CORS**: Whitelist only `https://app.example.com` (no wildcard)
- **Rate Limiting**: 
  - Login: 5 attempts per email per 15 minutes
  - Password reset: 3 requests per email per hour
  - Registration: 10 accounts per IP per day
- **Audit Logging**: Log all authentication events (login, logout, failed attempts, password resets) with timestamp, IP, user agent
- **Token Invalidation**: Support logout by optionally maintaining a Redis blacklist for revoked tokens

### Technology Stack Constraints
- **Backend**: Node.js 20 LTS, Express 4.19.x, TypeScript 5.3+
- **Database**: PostgreSQL 15.x for user data (ACID transactions for critical auth operations)
- **Cache/Rate Limiting**: Redis 7.x for session storage and rate limiting
- **Email**: SendGrid API (already integrated, API key in env vars)
- **Frontend**: React 18.2, TypeScript 5.3+, TanStack Query for API calls
- **Validation**: Zod for runtime type checking on both frontend and backend
- **Deployment**: Docker containers on AWS ECS Fargate, deployed via GitHub Actions
- **Secrets Management**: AWS Secrets Manager for `JWT_SECRET`, `DATABASE_URL`, `SENDGRID_API_KEY`

### Compliance Requirements
- **GDPR**: 
  - Right to erasure: Implement account deletion endpoint
  - Right to data portability: Provide user data export
  - Consent: Log consent timestamp for terms of service
- **SOC 2**: 
  - Audit logging: All authentication events logged to CloudWatch
  - Data encryption: TLS 1.3 in transit, AES-256 at rest for password hashes (PostgreSQL encryption)
- **Password Policy**: Enforce minimum 8 characters per NIST guidelines, no max length (bcrypt supports up to 72 chars)

---

## Out of Scope

### Deferred to v2.0 (Post-MVP)
- **Social Login (OAuth)**
  - Google, GitHub, Facebook OAuth providers
  - Reason: Adds complexity; 80% of users prefer email/password per user research
  - Timeline: Q2 2024

- **Two-Factor Authentication (2FA)**
  - TOTP (Google Authenticator) and SMS-based 2FA
  - Reason: Low security risk for MVP user base; enterprise feature
  - Timeline: Q3 2024

- **Magic Link Login (Passwordless)**
  - Email-based one-time login links
  - Reason: Requires additional UX design and testing
  - Timeline: Q2 2024

### Permanently Out of Scope
- **Single Sign-On (SSO)**
  - SAML, OIDC for enterprise SSO
  - Reason: Enterprise-only feature, different pricing tier
  - Alternative: Manual provisioning for enterprise accounts

- **Biometric Authentication**
  - Fingerprint, Face ID
  - Reason: Requires native mobile app; web-only for now

### Dependencies Not Ready
- **Role-Based Access Control (RBAC)**
  - Blocker: Waiting on PRD-051 (Organization Management and Permissions)
  - Expected: Q2 2024
  - Workaround: For MVP, all authenticated users have same permissions

---

## Dependencies

### Technical Dependencies
| Dependency | Type | Owner | Status | Blocker? |
|------------|------|-------|--------|----------|
| PostgreSQL database | Infrastructure | DevOps | ✅ Complete | No |
| Redis cluster | Infrastructure | DevOps | ✅ Complete | No |
| SendGrid email service | External API | DevOps | ✅ Configured | No |
| HTTPS certificate | Infrastructure | DevOps | ✅ Complete | No |
| AWS Secrets Manager | Infrastructure | DevOps | ✅ Complete | No |

### Product Dependencies
| PRD | Feature | Relationship | Status |
|-----|---------|--------------|--------|
| N/A | First feature | No dependencies | ✅ Ready |

### Design Dependencies
- ✅ High-fidelity mockups (Figma): [Link to Figma file](#)
- ✅ User research findings: 20 user interviews completed (Oct 2023)
- ✅ Design system components: Button, Input, Form validation patterns ready

---

## Implementation Phases

### Phase 1: Database and Models (No Dependencies)
**Goal**: User data persistence layer  
**Estimated Effort**: 5 story points (2 days)  
**Testability**: Unit tests for model validation and queries

#### Tasks:
1. Create database migration for `users` table
   - **File**: `migrations/2024-02-01-create-users-table.sql`
   - **SQL**:
     ```sql
     CREATE TABLE users (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       email VARCHAR(255) UNIQUE NOT NULL,
       password_hash VARCHAR(255) NOT NULL,
       email_verified BOOLEAN DEFAULT FALSE,
       email_verified_at TIMESTAMP,
       password_reset_token VARCHAR(500),
       last_login_at TIMESTAMP,
       created_at TIMESTAMP DEFAULT NOW(),
       updated_at TIMESTAMP DEFAULT NOW()
     );
     
     CREATE INDEX idx_users_email ON users(email);
     CREATE INDEX idx_users_created_at ON users(created_at);
     ```
   - **Tests**: Run migration in dev/staging without errors

2. Implement User model with Sequelize ORM
   - **File**: `src/models/User.ts`
   - **Interface**:
     ```typescript
     class User extends Model {
       id: string;
       email: string;
       passwordHash: string;
       emailVerified: boolean;
       emailVerifiedAt: Date | null;
       passwordResetToken: string | null;
       lastLoginAt: Date | null;
       createdAt: Date;
       updatedAt: Date;
       
       // Methods
       static async findByEmail(email: string): Promise<User | null>;
       static async createUser(email: string, password: string): Promise<User>;
       async comparePassword(password: string): Promise<boolean>;
       async updateLastLogin(): Promise<void>;
     }
     ```
   - **Implementation**: 
     - Use bcrypt for password hashing (cost factor 12)
     - Email should be stored lowercase
     - Password field is virtual; only `passwordHash` persisted
   - **Tests**: 
     - Unit test: `User.createUser()` hashes password correctly
     - Unit test: `user.comparePassword()` validates correct/incorrect passwords
     - Unit test: Email uniqueness constraint throws error on duplicate

**Completion Criteria:**
- [ ] Migration creates `users` table with correct schema
- [ ] User model implements all methods (findByEmail, createUser, comparePassword, updateLastLogin)
- [ ] Password hashing uses bcrypt with cost factor 12
- [ ] Email is normalized to lowercase before saving
- [ ] Unit tests: 100% coverage on User model

**Claude Implementation Notes:**
- Use Sequelize v6 TypeScript definitions for type safety
- Configure Sequelize to use `underscored: true` (snake_case columns) and `timestamps: true`
- Add pre-save hook to hash password if changed
- Exclude `passwordHash` from default JSON serialization (use `toJSON()` override)

---

### Phase 2: Authentication Service (Depends on Phase 1)
**Goal**: Core authentication logic (login, registration, verification)  
**Estimated Effort**: 8 story points (3 days)  
**Testability**: Integration tests with test database

#### Tasks:
1. Implement AuthService for registration, login, verification
   - **File**: `src/services/AuthService.ts`
   - **Interface**:
     ```typescript
     export interface RegistrationParams {
       email: string;
       password: string;
     }
     
     export interface LoginParams {
       email: string;
       password: string;
     }
     
     export class AuthService {
       async register(params: RegistrationParams): Promise<{ userId: string }>;
       async login(params: LoginParams): Promise<{ token: string; user: UserDTO }>;
       async verifyEmail(token: string): Promise<{ success: boolean }>;
       async requestPasswordReset(email: string): Promise<void>;
       async resetPassword(token: string, newPassword: string): Promise<void>;
     }
     ```
   - **Implementation**: 
     - Validate email format with regex `/^[^\s@]+@[^\s@]+\.[^\s@]+$/`
     - Validate password strength (min 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special)
     - Check for common passwords using `src/utils/common-passwords.txt`
     - Generate JWT tokens with `jsonwebtoken` library
     - Send emails via SendGrid
   - **Tests**: 
     - Unit test: Registration with valid data creates user and sends email
     - Unit test: Registration with duplicate email throws error
     - Unit test: Login with correct credentials returns token
     - Unit test: Login with unverified email rejects login
     - Integration test: End-to-end email verification flow

2. Implement password validation utility
   - **File**: `src/utils/passwordValidator.ts`
   - **Interface**:
     ```typescript
     export interface PasswordValidationResult {
       valid: boolean;
       errors: string[];
     }
     
     export function validatePassword(password: string): PasswordValidationResult;
     ```
   - **Rules**: 
     - Min 8 characters
     - At least 1 uppercase, 1 lowercase, 1 number, 1 special char
     - Not in top 10,000 common passwords list
   - **Tests**: 
     - Unit test: "password123" fails (common password)
     - Unit test: "Short1!" fails (too short)
     - Unit test: "SecurePass123!" passes

3. Implement JWT token generation and verification
   - **File**: `src/utils/jwt.ts`
   - **Interface**:
     ```typescript
     export interface TokenPayload {
       userId: string;
       email: string;
       type: 'session' | 'email-verification' | 'password-reset';
     }
     
     export function generateToken(payload: TokenPayload, expiresIn: string): string;
     export function verifyToken(token: string): TokenPayload;
     ```
   - **Implementation**: 
     - Use RS256 algorithm (asymmetric keys)
     - Load private key from AWS Secrets Manager
     - Session tokens: 24-hour expiry
     - Email verification tokens: 24-hour expiry
     - Password reset tokens: 1-hour expiry
   - **Tests**: 
     - Unit test: Generated token can be verified
     - Unit test: Expired token throws error
     - Unit test: Tampered token throws error

**Completion Criteria:**
- [ ] AuthService implements all methods (register, login, verifyEmail, requestPasswordReset, resetPassword)
- [ ] Password validation rejects weak passwords
- [ ] JWT tokens are signed with RS256 and include correct payload
- [ ] Integration tests: Full registration → email verification → login flow works end-to-end
- [ ] Email sending is stubbed in tests (use SendGrid sandbox mode)

**Claude Implementation Notes:**
- Use Zod for runtime validation of inputs
- Return consistent error format: `{ error: string, field?: string }`
- Log all authentication events to CloudWatch for audit trail
- Use constant-time comparison for password checks (prevent timing attacks)

---

### Phase 3: API Endpoints (Depends on Phase 2)
**Goal**: Expose authentication over HTTP  
**Estimated Effort**: 5 story points (2 days)  
**Testability**: API integration tests

#### Tasks:
1. Create authentication routes
   - **File**: `src/routes/auth.routes.ts`
   - **Endpoints**:
     ```typescript
     POST /auth/register       // Register new user
     POST /auth/login          // Login with email/password
     POST /auth/logout         // Logout (clear session)
     GET  /auth/verify?token=  // Verify email
     POST /auth/forgot-password // Request password reset
     POST /auth/reset-password  // Reset password with token
     GET  /auth/me             // Get current user (requires auth)
     ```
   - **Implementation**: 
     - Use Express router
     - Apply rate limiting middleware (express-rate-limit)
     - Validate request bodies with Zod schemas
     - Return consistent JSON responses
   - **Tests**: 
     - Integration test: POST /auth/register creates user and returns 201
     - Integration test: POST /auth/login with invalid credentials returns 401
     - Integration test: GET /auth/me without token returns 401

2. Implement authentication middleware
   - **File**: `src/middleware/auth.ts`
   - **Interface**:
     ```typescript
     export function requireAuth(req: Request, res: Response, next: NextFunction): void;
     ```
   - **Implementation**: 
     - Extract token from `auth_token` cookie
     - Verify JWT signature and expiry
     - Fetch user from database
     - Attach user to `req.user`
     - If invalid, return 401 Unauthorized
   - **Tests**: 
     - Unit test: Valid token attaches user to req.user
     - Unit test: Expired token returns 401
     - Unit test: Missing token returns 401

3. Implement rate limiting
   - **File**: `src/middleware/rateLimiter.ts`
   - **Rules**: 
     - Login: 5 attempts per email per 15 minutes (use Redis)
     - Registration: 10 accounts per IP per day
     - Password reset: 3 requests per email per hour
   - **Implementation**: 
     - Use `express-rate-limit` with Redis store
     - Separate limiters for each endpoint
   - **Tests**: 
     - Integration test: 6th login attempt within 15 minutes returns 429 Too Many Requests
     - Integration test: Rate limit resets after 15 minutes

**Completion Criteria:**
- [ ] All endpoints return correct HTTP status codes (201, 200, 401, 429, etc.)
- [ ] Authentication middleware correctly validates sessions
- [ ] Rate limiting prevents brute-force attacks
- [ ] API integration tests: 100% coverage on happy path and error cases

**Claude Implementation Notes:**
- Use cookie-parser middleware to read cookies
- Set cookies with `res.cookie('auth_token', token, { httpOnly: true, secure: true, sameSite: 'strict', maxAge: 86400000 })`
- Return user-friendly error messages (don't expose internal errors to client)

---

### Phase 4: Frontend UI (Depends on Phase 3)
**Goal**: User-facing authentication screens  
**Estimated Effort**: 8 story points (3 days)  
**Testability**: E2E tests with Playwright

#### Tasks:
1. Create authentication pages
   - **Files**:
     - `frontend/src/pages/Login.tsx`
     - `frontend/src/pages/Signup.tsx`
     - `frontend/src/pages/VerifyEmail.tsx`
     - `frontend/src/pages/ForgotPassword.tsx`
     - `frontend/src/pages/ResetPassword.tsx`
   - **Implementation**: 
     - Use React Hook Form for form state
     - Use TanStack Query for API calls
     - Display validation errors inline
     - Show loading states during API calls
   - **Tests**: 
     - E2E test: User can register, verify email, and log in
     - E2E test: Invalid credentials show error message
     - E2E test: Expired verification link shows error

2. Create reusable form components
   - **Files**:
     - `frontend/src/components/Input.tsx`
     - `frontend/src/components/Button.tsx`
     - `frontend/src/components/FormError.tsx`
   - **Implementation**: 
     - Style with Tailwind CSS (already in design system)
     - Support error states, disabled states, loading states
   - **Tests**: 
     - Component test: Input shows error message when `error` prop is set
     - Component test: Button shows spinner when `loading` prop is true

3. Implement authentication context
   - **File**: `frontend/src/contexts/AuthContext.tsx`
   - **Interface**:
     ```typescript
     export interface AuthContextValue {
       user: UserDTO | null;
       login: (email: string, password: string) => Promise<void>;
       logout: () => Promise<void>;
       isAuthenticated: boolean;
       isLoading: boolean;
     }
     
     export const AuthContext = createContext<AuthContextValue | null>(null);
     export function useAuth(): AuthContextValue;
     ```
   - **Implementation**: 
     - Fetch user on mount via GET /auth/me
     - Provide login/logout methods
     - Handle token refresh (if expired, redirect to login)
   - **Tests**: 
     - Integration test: AuthContext fetches user on mount
     - Integration test: logout() clears user state

4. Implement protected route wrapper
   - **File**: `frontend/src/components/ProtectedRoute.tsx`
   - **Interface**:
     ```typescript
     export function ProtectedRoute({ children }: { children: React.ReactNode }): JSX.Element;
     ```
   - **Implementation**: 
     - Check `isAuthenticated` from AuthContext
     - If not authenticated, redirect to `/login?redirectTo={currentPath}`
     - After login, redirect back to original destination
   - **Tests**: 
     - E2E test: Unauthenticated user accessing /dashboard redirects to /login
     - E2E test: After login, user is redirected back to /dashboard

**Completion Criteria:**
- [ ] All authentication pages render correctly
- [ ] Form validation shows real-time errors
- [ ] Protected routes redirect unauthenticated users to login
- [ ] E2E tests: Full user journey (signup → verify → login → access protected route) works

**Claude Implementation Notes:**
- Use React Router v6 for routing
- Store user state in React Context (avoid prop drilling)
- Use TanStack Query's `onError` callback to handle 401 responses globally (redirect to login)
- Display toast notifications for success/error messages (use react-hot-toast)

---

### Phase 5: Email Templates (Depends on Phase 2)
**Goal**: Transactional emails for verification and password reset  
**Estimated Effort**: 3 story points (1 day)  
**Testability**: Manual testing in SendGrid sandbox

#### Tasks:
1. Create email templates
   - **Files**:
     - `src/email-templates/verify-email.html`
     - `src/email-templates/reset-password.html`
   - **Content**: 
     - Welcome message
     - Clear call-to-action button
     - Link expiry notice (24 hours for verification, 1 hour for reset)
     - Support contact information
   - **Design**: 
     - Use responsive email design (mobile-friendly)
     - Match brand colors and logo
   - **Tests**: 
     - Manual test: Send test email via SendGrid, verify rendering in Gmail/Outlook/Apple Mail

2. Implement email sending service
   - **File**: `src/services/EmailService.ts`
   - **Interface**:
     ```typescript
     export class EmailService {
       async sendVerificationEmail(email: string, token: string): Promise<void>;
       async sendPasswordResetEmail(email: string, token: string): Promise<void>;
     }
     ```
   - **Implementation**: 
     - Use SendGrid Node.js SDK
     - Load templates from files
     - Replace placeholders ({{token}}, {{email}}, {{verificationLink}})
   - **Tests**: 
     - Unit test: Email service calls SendGrid API with correct parameters
     - Integration test: Email is sent to sandbox (verify in SendGrid dashboard)

**Completion Criteria:**
- [ ] Email templates are mobile-responsive
- [ ] Emails are sent successfully via SendGrid
- [ ] Links in emails work correctly (verification and password reset)

**Claude Implementation Notes:**
- Use environment variable `SENDGRID_FROM_EMAIL` for sender address
- Log all email events (sent, failed) to CloudWatch
- Handle SendGrid errors gracefully (retry with exponential backoff)

---

### Phase 6: Security Hardening (Depends on Phase 1-5)
**Goal**: Final security review and hardening  
**Estimated Effort**: 3 story points (1 day)  
**Testability**: Security audit checklist

#### Tasks:
1. Implement CSRF protection
   - **File**: `src/middleware/csrf.ts`
   - **Implementation**: 
     - Use `csurf` middleware for CSRF tokens
     - Require CSRF token for all POST/PUT/DELETE requests
   - **Tests**: 
     - Integration test: POST without CSRF token returns 403

2. Add security headers
   - **File**: `src/middleware/security.ts`
   - **Implementation**: 
     - Use `helmet` middleware
     - Set Content-Security-Policy, X-Frame-Options, X-Content-Type-Options
   - **Tests**: 
     - Integration test: Response includes security headers

3. Implement session token blacklist
   - **File**: `src/services/TokenBlacklist.ts`
   - **Implementation**: 
     - Use Redis to store revoked tokens
     - Check blacklist in auth middleware
   - **Tests**: 
     - Integration test: Logged-out token is rejected

4. Security audit checklist
   - [ ] All passwords hashed with bcrypt cost factor 12
   - [ ] All endpoints use HTTPS (no HTTP allowed)
   - [ ] Rate limiting enabled on login, registration, password reset
   - [ ] CSRF protection on all state-changing endpoints
   - [ ] Security headers set (helmet middleware)
   - [ ] Audit logging for all authentication events
   - [ ] No sensitive data logged (passwords, tokens)
   - [ ] SQL injection prevention (Sequelize ORM prevents this)
   - [ ] XSS prevention (React escapes by default)

**Completion Criteria:**
- [ ] All security checklist items verified
- [ ] Penetration testing (manual) finds no critical vulnerabilities
- [ ] Code review by security team approved

**Claude Implementation Notes:**
- Run `npm audit` to check for vulnerable dependencies
- Use Snyk for continuous dependency monitoring
- Document all security decisions in ADR (Architecture Decision Record)

---

## Success Metrics

### Goal 1: Enable User Registration
**Signal**: Users create accounts successfully  
**Metrics**:
- **Leading**: Registration completion rate (target: ≥ 70% of users who start registration complete it)
- **Lagging**: 500 new registrations in first month  
**Measurement**: Track signup funnel in PostHog (started registration → verified email → first login)

### Goal 2: Secure User Authentication
**Signal**: No security incidents related to authentication  
**Metrics**:
- **Failed login rate**: < 5% (indicates strong password adoption)
- **Account takeover incidents**: 0
- **Audit log coverage**: 100% of auth events logged  
**Measurement**: Monitor CloudWatch logs for suspicious activity; set up PagerDuty alerts for unusual patterns

### Goal 3: Maintain Fast Login Performance
**Signal**: Users can log in quickly  
**Metrics**:
- **p95 login latency**: < 300ms (from form submit to dashboard load)
- **Error rate**: < 0.5% of login attempts
- **Uptime**: 99.9% availability  
**Measurement**: DataDog APM monitoring on /auth/login endpoint

### Goal 4: Email Verification Adoption
**Signal**: Users verify their email addresses  
**Metrics**:
- **Email verification rate**: ≥ 80% of users verify within 24 hours of registration
- **Email deliverability**: ≥ 95% of verification emails delivered (not bounced)  
**Measurement**: Track verification events in database; monitor SendGrid delivery reports

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Users forget passwords frequently | High | Medium | Implement password reset flow (Phase 2); consider adding "magic link" login in v2.0 |
| Email deliverability issues (verification emails go to spam) | Medium | High | Use authenticated domain for SendGrid; add SPF/DKIM records; test with multiple email providers |
| Brute-force attacks on login endpoint | Medium | High | Implement rate limiting (5 attempts per email per 15 minutes); add CAPTCHA after 3 failed attempts (deferred to v2.0) |
| JWT secret key leakage | Low | Critical | Store secret in AWS Secrets Manager (not in code); rotate keys quarterly; implement token blacklist for immediate revocation |
| Database performance degradation under high signup load | Low | Medium | Add database read replicas; implement connection pooling; monitor query performance with pg_stat_statements |
| Users reuse weak passwords | High | Medium | Enforce password strength validation; check against common password list; add password strength meter in UI |

---

## Open Questions

- [x] **Q1**: Should we support passwordless "magic link" login in MVP?
  - **Owner**: Sarah Chen (PM) + Emily Thompson (Design)
  - **Deadline**: Jan 15, 2024
  - **Resolution**: No, defer to v2.0. User research shows 80% prefer traditional email/password.
  - **Impact if unresolved**: N/A (resolved)

- [x] **Q2**: What should be the JWT token expiry time? (24 hours vs. 7 days vs. 30 days)
  - **Owner**: Marcus Rodriguez (Eng) + Security Team
  - **Deadline**: Jan 18, 2024
  - **Resolution**: 24 hours for session tokens. Implement "remember me" in v2.0 with refresh tokens.
  - **Impact if unresolved**: N/A (resolved)

- [ ] **Q3**: Should we force password reset for users who haven't logged in for 90 days?
  - **Owner**: Security Team + Sarah Chen (PM)
  - **Deadline**: Feb 15, 2024 (before Phase 6)
  - **Impact if unresolved**: May fail SOC 2 audit requirement for inactive account management

---

## AI Implementation Context

### Architecture Overview
```
┌──────────────────┐
│   React Frontend │
│   - Login UI     │
│   - Signup UI    │
└────────┬─────────┘
         │ HTTPS (cookie: auth_token)
         ▼
┌──────────────────────────────┐
│   Express API Gateway        │
│   - CORS middleware          │
│   - Rate limiting            │
│   - CSRF protection          │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│   Auth Middleware            │
│   - Verify JWT               │
│   - Attach req.user          │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│   AuthService                │
│   - register()               │
│   - login()                  │
│   - verifyEmail()            │
│   - resetPassword()          │
└────────┬─────────────────────┘
         │
         ├──────────┬─────────────┐
         │          │             │
         ▼          ▼             ▼
┌────────────┐ ┌─────────┐ ┌────────────┐
│ User Model │ │ Redis   │ │  SendGrid  │
│ (Sequelize)│ │ (Rate   │ │  (Email)   │
│            │ │  Limit) │ │            │
└─────┬──────┘ └─────────┘ └────────────┘
      │
      ▼
┌──────────────┐
│ PostgreSQL   │
│ users table  │
└──────────────┘
```

### File Structure
```
backend/
├── src/
│   ├── models/
│   │   └── User.ts                      (Phase 1)
│   ├── services/
│   │   ├── AuthService.ts               (Phase 2)
│   │   ├── EmailService.ts              (Phase 5)
│   │   └── TokenBlacklist.ts            (Phase 6)
│   ├── utils/
│   │   ├── jwt.ts                       (Phase 2)
│   │   ├── passwordValidator.ts         (Phase 2)
│   │   └── common-passwords.txt         (Phase 2)
│   ├── middleware/
│   │   ├── auth.ts                      (Phase 3)
│   │   ├── rateLimiter.ts               (Phase 3)
│   │   ├── csrf.ts                      (Phase 6)
│   │   └── security.ts                  (Phase 6)
│   ├── routes/
│   │   └── auth.routes.ts               (Phase 3)
│   └── email-templates/
│       ├── verify-email.html            (Phase 5)
│       └── reset-password.html          (Phase 5)
├── migrations/
│   └── 2024-02-01-create-users-table.sql (Phase 1)
└── tests/
    ├── unit/
    │   ├── User.test.ts                 (Phase 1)
    │   ├── AuthService.test.ts          (Phase 2)
    │   └── passwordValidator.test.ts    (Phase 2)
    └── integration/
        └── auth-api.test.ts             (Phase 3)

frontend/
└── src/
    ├── pages/
    │   ├── Login.tsx                    (Phase 4)
    │   ├── Signup.tsx                   (Phase 4)
    │   ├── VerifyEmail.tsx              (Phase 4)
    │   ├── ForgotPassword.tsx           (Phase 4)
    │   └── ResetPassword.tsx            (Phase 4)
    ├── components/
    │   ├── Input.tsx                    (Phase 4)
    │   ├── Button.tsx                   (Phase 4)
    │   ├── FormError.tsx                (Phase 4)
    │   └── ProtectedRoute.tsx           (Phase 4)
    ├── contexts/
    │   └── AuthContext.tsx              (Phase 4)
    └── tests/
        └── e2e/
            └── auth-flow.spec.ts        (Phase 4)
```

---

## Appendix

### Related Documents
- Design Mockups: [Figma Link - Authentication Flows](#)
- User Research: [Research Findings - Authentication Preferences](#)
- Security Audit: [Penetration Test Report - Q1 2024](#)

### Glossary
- **bcrypt**: Password hashing algorithm designed to be slow (resistant to brute-force)
- **JWT (JSON Web Token)**: Stateless authentication token containing signed user claims
- **HttpOnly Cookie**: Cookie that cannot be accessed via JavaScript (prevents XSS attacks)
- **CSRF (Cross-Site Request Forgery)**: Attack where malicious site tricks user's browser into making unwanted requests
- **Rate Limiting**: Restricting number of requests per time window to prevent abuse
- **Constant-Time Comparison**: Comparing values in fixed time to prevent timing attacks
- **Salt**: Random data added to password before hashing (prevents rainbow table attacks)

---

## Approval Signatures

| Role | Name | Approval Date | Signature |
|------|------|---------------|-----------|
| Product Manager | Sarah Chen | 2024-01-22 | ✅ |
| Engineering Lead | Marcus Rodriguez | 2024-01-22 | ✅ |
| Design Lead | Emily Thompson | 2024-01-22 | ✅ |
| CTO | David Kim | 2024-01-22 | ✅ |
| Security Lead | Rachel Park | 2024-01-22 | ✅ |
