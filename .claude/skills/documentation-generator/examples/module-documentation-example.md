# CustomerSearchService

Provides full-text search capabilities for customer records using PostgreSQL trigram indexes.

## Purpose

The CustomerSearchService encapsulates all customer search logic, supporting fuzzy matching by email, name, and order ID. It enforces regional access controls and audit logging for compliance.

## Dependencies

- **Customer Model** (`src/models/Customer.ts`) - Database model for customers
- **AuthMiddleware** (`src/middleware/auth.ts`) - For agent authentication
- **Logger** (`src/utils/logger.ts`) - For audit logging

## API

### search(params: SearchParams): Promise<SearchResult>

Executes a customer search with authorization and audit logging.

**Parameters:**
```typescript
interface SearchParams {
  query: string;           // Search term (1-100 characters)
  searchType: 'email' | 'name' | 'orderId';
  agentId: string;         // Authenticated agent's ID
  agentRegion: string;     // Agent's assigned region
  limit?: number;          // Max results (default: 10, max: 100)
}
```

**Returns:**
```typescript
interface SearchResult {
  results: CustomerDTO[];  // Matching customers
  matchCount: number;      // Total matches (before limit)
  durationMs: number;      // Query execution time
}
```

**Throws:**
- `ValidationError` - If query is empty or too long
- `AuthorizationError` - If agent lacks search permissions
- `DatabaseError` - If database query fails

**Example:**
```typescript
import { customerSearchService } from './services/CustomerSearchService';

const results = await customerSearchService.search({
  query: 'john@example.com',
  searchType: 'email',
  agentId: 'agent-123',
  agentRegion: 'US-WEST',
  limit: 10
});

console.log(results.results); // [{ id: '...', email: 'john@example.com', ... }]
console.log(results.matchCount); // 1
console.log(results.durationMs); // 287
```

---

## Usage Patterns

### Basic Search

```typescript
// Search by email
const emailResults = await customerSearchService.search({
  query: 'alice@example.com',
  searchType: 'email',
  agentId: req.user.id,
  agentRegion: req.user.region
});

// Search by name (fuzzy matching)
const nameResults = await customerSearchService.search({
  query: 'John',
  searchType: 'name',
  agentId: req.user.id,
  agentRegion: req.user.region,
  limit: 20
});
```

### Error Handling

```typescript
try {
  const results = await customerSearchService.search({
    query: searchTerm,
    searchType: 'email',
    agentId: agent.id,
    agentRegion: agent.region
  });
} catch (error) {
  if (error instanceof ValidationError) {
    return res.status(400).json({ error: error.message });
  } else if (error instanceof AuthorizationError) {
    return res.status(403).json({ error: 'Insufficient permissions' });
  } else {
    logger.error('Search failed', { error });
    return res.status(500).json({ error: 'Search failed' });
  }
}
```

---

## Testing

### Unit Tests

```typescript
import { customerSearchService } from './CustomerSearchService';
import { Customer } from '../models/Customer';

describe('CustomerSearchService', () => {
  describe('search', () => {
    it('should return customers matching email', async () => {
      // Setup test data
      await Customer.create({
        email: 'test@example.com',
        name: 'Test User',
        region: 'US-WEST'
      });

      const results = await customerSearchService.search({
        query: 'test@example.com',
        searchType: 'email',
        agentId: 'agent-1',
        agentRegion: 'US-WEST'
      });

      expect(results.results).toHaveLength(1);
      expect(results.results[0].email).toBe('test@example.com');
    });

    it('should enforce regional access controls', async () => {
      await Customer.create({
        email: 'eu-user@example.com',
        region: 'EU'
      });

      const results = await customerSearchService.search({
        query: 'eu-user@example.com',
        searchType: 'email',
        agentId: 'agent-1',
        agentRegion: 'US-WEST' // Different region
      });

      expect(results.results).toHaveLength(0); // Filtered out
    });

    it('should throw ValidationError for empty query', async () => {
      await expect(
        customerSearchService.search({
          query: '',
          searchType: 'email',
          agentId: 'agent-1',
          agentRegion: 'US-WEST'
        })
      ).rejects.toThrow(ValidationError);
    });
  });
});
```

### Performance Tests

```typescript
describe('CustomerSearchService Performance', () => {
  it('should complete search in < 300ms', async () => {
    const start = Date.now();
    
    await customerSearchService.search({
      query: 'test@example.com',
      searchType: 'email',
      agentId: 'agent-1',
      agentRegion: 'US-WEST'
    });
    
    const duration = Date.now() - start;
    expect(duration).toBeLessThan(300);
  });
});
```

---

## Architecture

### Data Flow

```
API Route → SearchController → CustomerSearchService → Customer Model → PostgreSQL
                                        ↓
                                     Logger → CloudWatch
```

1. **API Route** receives HTTP request
2. **SearchController** validates input and extracts auth
3. **CustomerSearchService** applies business logic and regional filtering
4. **Customer Model** queries database with trigram search
5. **Logger** records search event for audit trail
6. Response returned to client

### Dependencies Diagram

```
CustomerSearchService
├── Customer (model)
│   └── PostgreSQL with trigram indexes
├── Logger (audit trail)
└── ValidationUtils
```

---

## Database Schema

### Required Indexes

```sql
-- Trigram indexes for fuzzy search
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_customers_email_trgm ON customers USING gin (email gin_trgm_ops);
CREATE INDEX idx_customers_name_trgm ON customers USING gin (name gin_trgm_ops);

-- Region filtering
CREATE INDEX idx_customers_region ON customers(region);
```

### Query Pattern

```sql
-- Email search
SELECT * FROM customers 
WHERE email ILIKE '%john@example%' 
  AND region = 'US-WEST'
ORDER BY similarity(email, 'john@example.com') DESC
LIMIT 10;
```

---

## Configuration

No specific configuration required. Uses application-wide database connection and logging settings.

---

## Performance Characteristics

- **p95 latency**: 287ms (target: < 300ms)
- **p99 latency**: 450ms (target: < 500ms)
- **Throughput**: 100 searches/second per instance
- **Database queries**: 1 query per search (no N+1)

---

## Security

### Regional Access Control

Customers are filtered by `agentRegion` to enforce data residency:

```typescript
// Only return customers in agent's region
results = results.filter(customer => customer.region === agentRegion);
```

### Audit Logging

All searches are logged for compliance:

```typescript
logger.info('Customer search', {
  agentId,
  query: query.substring(0, 50), // Truncate for privacy
  searchType,
  resultCount: results.length,
  durationMs,
  timestamp: new Date().toISOString()
});
```

---

## Changelog

### v1.2.0 (2024-01-25)
- Added `orderId` search type
- Improved fuzzy matching accuracy with trigram similarity scoring

### v1.1.0 (2024-01-15)
- Added regional access control
- Implemented audit logging for SOC 2 compliance

### v1.0.0 (2024-01-10)
- Initial release with email and name search
