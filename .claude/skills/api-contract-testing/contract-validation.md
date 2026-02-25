# Contract Validation in CI

## Spectral (OpenAPI Linter)

**Installation**

```bash
npm install @stoplight/spectral-cli --save-dev
```

**Basic Linting**

```bash
npx spectral lint openapi.yaml
```

**Custom Rules**

```yaml
# .spectral.yaml
extends: [[spectral:oas, all]]
rules:
  operation-operationId: error
  operation-summary: error
  operation-description: warn
  operation-tags: error
  oas3-examples-value-or-externalValue: error

  # Custom rule: require error responses
  require-error-responses:
    message: All operations must define 400 and 500 responses
    given: $.paths.*[get,post,put,patch,delete]
    severity: error
    then:
      - field: responses
        function: schema
        functionOptions:
          schema:
            type: object
            required: ['400', '500']
```

**Run in CI**

```yaml
# .github/workflows/api-contract.yml
- name: Validate OpenAPI Spec
  run: npx spectral lint openapi.yaml --fail-severity warn
```

## Prism Proxy (Runtime Validation)

Validate actual API responses against spec:

```bash
# Run API server on :3000, proxy through Prism
npx prism proxy openapi.yaml http://localhost:3000 --errors
```

**In CI**

```yaml
- name: Start API Server
  run: npm start &

- name: Validate API Responses
  run: |
    npx prism proxy openapi.yaml http://localhost:3000 --errors &
    PRISM_PID=$!
    npm run test:integration
    kill $PRISM_PID
```

## Contract Tests with Dredd

**Installation**

```bash
npm install dredd --save-dev
```

**Configuration**

```yaml
# dredd.yml
dry-run: null
hookfiles: null
language: nodejs
sandbox: false
server: npm start
server-wait: 3
init: false
custom: {}
names: false
only: []
reporter: []
output: []
header: []
sorted: false
user: null
inline-errors: false
details: false
method: []
color: true
level: info
timestamp: false
silent: false
path: []
blueprint: openapi.yaml
endpoint: http://localhost:3000/api/v1
```

**Run Tests**

```bash
npx dredd
```

**Hooks for Setup/Teardown**

```javascript
// hooks.js
const hooks = require('hooks');

hooks.before('Users > Get User', (transaction, done) => {
  // Create test user before request
  done();
});

hooks.after('Users > Delete User', (transaction, done) => {
  // Clean up after test
  done();
});
```

## Contract Drift Detection

### Automated Drift Detection

**Strategy**: Generate types on every build and fail if Git diff detected

```json
// package.json
{
  "scripts": {
    "generate:types": "openapi-typescript ./openapi.yaml -o ./src/api/schema.d.ts",
    "check:contract": "npm run generate:types && git diff --exit-code src/api/schema.d.ts"
  }
}
```

**In CI**

```yaml
- name: Check Contract Drift
  run: |
    npm run generate:types
    if ! git diff --exit-code src/api/schema.d.ts; then
      echo "Contract has changed but types were not regenerated!"
      echo "Run 'npm run generate:types' and commit the changes."
      exit 1
    fi
```

### Prevent Breaking Changes

Use `optic` to detect breaking changes:

```bash
npm install @useoptic/openapi-utilities --save-dev
```

```bash
npx optic diff openapi.yaml --base main --check
```

**Breaking Changes Detected**

- Removed endpoints
- Removed required fields
- Changed field types
- Removed enum values
- Changed response status codes
