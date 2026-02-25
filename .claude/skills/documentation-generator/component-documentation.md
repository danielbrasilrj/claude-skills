# Component/Module Documentation

## Module Documentation Template

For each significant module or service:

````markdown
# UserService

Handles all user-related operations including creation, retrieval, updating, and deletion (CRUD).

## Purpose

The UserService encapsulates business logic for user management, providing a clean interface for controllers and other services to interact with user data without directly accessing the database.

## Dependencies

- **User Model** (`src/models/User.ts`) - Database model for users
- **EmailService** (`src/services/EmailService.ts`) - For sending verification emails
- **Logger** (`src/utils/logger.ts`) - For logging events

## API

### createUser(data: CreateUserData): Promise<User>

Creates a new user account.

**Parameters:**

- `data.email` (string, required) - User's email address (must be unique)
- `data.name` (string, required) - User's full name
- `data.role` (string, optional) - User's role (default: 'user')

**Returns:**
Promise resolving to the created User object.

**Throws:**

- `ValidationError` - If email is invalid or name is too short
- `ConflictError` - If email is already registered
- `DatabaseError` - If database operation fails

**Example:**

```typescript
const user = await userService.createUser({
  email: 'alice@example.com',
  name: 'Alice Johnson',
  role: 'admin',
});
```
````

### findUserById(userId: string): Promise<User | null>

Retrieves a user by their unique ID.

**Parameters:**

- `userId` (string, required) - UUID of the user

**Returns:**
Promise resolving to User object if found, null otherwise.

**Example:**

```typescript
const user = await userService.findUserById('123e4567-e89b-12d3-a456-426614174000');
if (user) {
  console.log(user.email);
}
```

## Usage Patterns

### Basic CRUD Operations

```typescript
import { userService } from './services/UserService';

// Create
const newUser = await userService.createUser({
  email: 'alice@example.com',
  name: 'Alice Johnson',
});

// Read
const user = await userService.findUserById(newUser.id);

// Update
const updated = await userService.updateUser(user.id, { name: 'Alice Smith' });

// Delete
await userService.deleteUser(user.id);
```

### Error Handling

```typescript
try {
  const user = await userService.createUser({ email: 'invalid-email', name: 'Test' });
} catch (error) {
  if (error instanceof ValidationError) {
    console.error('Invalid input:', error.message);
  } else if (error instanceof ConflictError) {
    console.error('Email already exists');
  } else {
    console.error('Unexpected error:', error);
  }
}
```

## Testing

### Unit Tests

```typescript
import { userService } from './UserService';
import { User } from '../models/User';

describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid data', async () => {
      const user = await userService.createUser({
        email: 'test@example.com',
        name: 'Test User',
      });

      expect(user.email).toBe('test@example.com');
      expect(user.name).toBe('Test User');
      expect(user.role).toBe('user'); // default
    });

    it('should throw ValidationError for invalid email', async () => {
      await expect(userService.createUser({ email: 'invalid', name: 'Test' })).rejects.toThrow(
        ValidationError,
      );
    });
  });
});
```

## Architecture

### Data Flow

```
Controller -> UserService -> User Model -> PostgreSQL
                |
          EmailService -> SendGrid
```

1. Controller receives HTTP request
2. UserService validates business logic
3. User Model persists to database
4. EmailService sends verification email (async)
5. Response returned to controller

### Dependencies Diagram

```
UserService
|-- User (model)
|-- EmailService
|-- Logger
+-- ValidationUtils
```

## Configuration

No specific configuration required. Uses application-wide database and email settings.

## Changelog

### v1.2.0 (2024-01-15)

- Added `findUsersByRole()` method
- Improved error messages for validation failures

### v1.1.0 (2024-01-10)

- Added soft delete functionality
- Deprecated `deleteUser()` in favor of `softDeleteUser()`

### v1.0.0 (2024-01-01)

- Initial release with basic CRUD operations

```

```
