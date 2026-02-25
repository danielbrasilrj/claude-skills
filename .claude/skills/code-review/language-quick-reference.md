# Language-Specific Quick Reference

## JavaScript/TypeScript

**Common Issues**

- Implicit `any` types (enable `strict` in tsconfig)
- Missing null checks (use optional chaining `?.`)
- Mutation of props or state
- Missing `key` prop in lists
- `useEffect` missing dependencies

**Best Practices**

- Enable `strict`, `noUncheckedIndexedAccess` in tsconfig
- Use `const` by default, `let` when reassignment needed
- Prefer `??` over `||` for default values
- Use `unknown` instead of `any` when type is truly unknown

## Python

**Common Issues**

- Mutable default arguments
- Bare `except` clauses
- Not using context managers for resources
- Modifying list while iterating
- Implicit string concatenation in loops

**Best Practices**

- Use type hints (PEP 484)
- Use f-strings for formatting
- Follow PEP 8 style guide
- Use `pathlib` instead of `os.path`

## Go

**Common Issues**

- Ignoring errors (`_`)
- Not closing resources (missing `defer`)
- Goroutine leaks (no context cancellation)
- Pointer to loop variable in goroutine
- Unhandled panics

**Best Practices**

- Always handle errors explicitly
- Use `defer` for cleanup
- Pass context to goroutines
- Use `errgroup` for managing goroutines
- Avoid naked returns

## Further Reading

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Google Engineering Practices](https://google.github.io/eng-practices/review/)
- [Conventional Comments](https://conventionalcomments.org/)
