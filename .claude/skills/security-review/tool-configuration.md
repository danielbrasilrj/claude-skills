# Security Tool Configuration

## Semgrep

```yaml
# .semgrep.yml -- security-focused configuration
rules:
  - id: hardcoded-secret
    patterns:
      - pattern: $KEY = "..."
      - metavariable-regex:
          metavariable: $KEY
          regex: (?i)(password|secret|token|api.?key|private.?key)
    message: Potential hardcoded secret found
    severity: ERROR

  - id: sql-injection
    pattern: |
      $QUERY = "..." + $INPUT
    message: Potential SQL injection via string concatenation
    severity: ERROR
```

## gitleaks

```toml
# .gitleaks.toml
[allowlist]
  paths = [
    '''test/''',
    '''.*_test\.go''',
    '''.*\.test\.(ts|js)''',
  ]

[[rules]]
  id = "generic-api-key"
  description = "Generic API Key"
  regex = '''(?i)(api[_-]?key|apikey)\s*[:=]\s*['"][a-zA-Z0-9]{16,}['"]'''
  severity = "high"
```

## MobSF Docker Setup

```bash
# Pull and run MobSF
docker pull opensecurity/mobile-security-framework-mobsf:latest
docker run -it --rm -p 8000:8000 opensecurity/mobile-security-framework-mobsf:latest

# Access at http://localhost:8000
# Default API key displayed in console output
```

## Frida Scripts

```javascript
// bypass-ssl-pinning.js -- For testing only
Java.perform(function () {
  var TrustManagerImpl = Java.use('com.android.org.conscrypt.TrustManagerImpl');
  TrustManagerImpl.verifyChain.implementation = function () {
    return Java.use('java.util.ArrayList').$new();
  };
});

// detect-root.js -- Check root detection implementation
Java.perform(function () {
  var RootBeer = Java.use('com.scottyab.rootbeer.RootBeer');
  RootBeer.isRooted.implementation = function () {
    console.log('[*] RootBeer.isRooted() called');
    return this.isRooted();
  };
});
```
