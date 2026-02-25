# Crawl4AI Configuration

## AsyncWebCrawler Setup

**Basic Setup:**

```python
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig

async with AsyncWebCrawler() as crawler:
    config = CrawlerRunConfig(
        cache_mode=CacheMode.ENABLED,
        page_timeout=30000,
        verbose=True
    )
    result = await crawler.arun(url="https://example.com", config=config)
```

**Configuration Options:**

| Parameter             | Type      | Default            | Description                                                            |
| --------------------- | --------- | ------------------ | ---------------------------------------------------------------------- |
| `cache_mode`          | CacheMode | ENABLED            | ENABLED (use cache), BYPASS (ignore cache), WRITE_ONLY, READ_ONLY      |
| `page_timeout`        | int       | 30000              | Page load timeout in milliseconds                                      |
| `wait_for`            | str       | None               | CSS selector to wait for before extraction (e.g., "css:.product-card") |
| `wait_until`          | str       | "domcontentloaded" | "load", "domcontentloaded", "networkidle"                              |
| `js_code`             | str       | None               | Custom JavaScript to execute before extraction                         |
| `extraction_strategy` | Strategy  | None               | JsonCss, Regex, or LLM extraction strategy                             |
| `verbose`             | bool      | False              | Enable debug logging                                                   |
| `user_agent`          | str       | Chrome UA          | Custom user agent string                                               |
| `headers`             | dict      | {}                 | Custom HTTP headers                                                    |
| `screenshot`          | bool      | False              | Capture screenshot after page load                                     |
| `pdf`                 | bool      | False              | Save page as PDF                                                       |

## CacheMode Options

**CacheMode.ENABLED (Default):**

- Checks cache first, fetches from web if miss
- Saves successful crawls to cache
- Best for: Development, testing, recurring crawls

**CacheMode.BYPASS:**

- Ignores cache completely
- Always fetches fresh from web
- Does NOT save to cache
- Best for: Real-time data, one-off scrapes

**CacheMode.WRITE_ONLY:**

- Ignores cache on read
- Saves to cache after fetch
- Best for: Rebuilding cache

**CacheMode.READ_ONLY:**

- Only reads from cache, never fetches web
- Fails if cache miss
- Best for: Offline testing

## Wait Strategies (JS-Rendered Pages)

Many modern sites use JavaScript to load content. Crawl4AI won't see content until JS executes.

**wait_for (CSS Selector):**
Wait until specific element appears on page.

```python
config = CrawlerRunConfig(
    wait_for="css:.product-card",  # Wait for products to load
    page_timeout=30000             # Fail after 30 seconds
)
```

**wait_until (Load State):**

| State              | When to Use             | Description                                                     |
| ------------------ | ----------------------- | --------------------------------------------------------------- |
| `load`             | Heavy pages with images | Waits for full page load (images, CSS, all resources)           |
| `domcontentloaded` | Fast scraping           | Waits for HTML parsing complete (default)                       |
| `networkidle`      | Dynamic content         | Waits until network is idle for 500ms (best for JS-heavy sites) |

```python
config = CrawlerRunConfig(
    wait_until="networkidle",  # Wait for all AJAX calls to finish
    page_timeout=60000         # Increase timeout for slow sites
)
```

**Custom JavaScript Execution:**
Execute custom JS before extraction (e.g., scroll to load infinite scroll).

```python
config = CrawlerRunConfig(
    js_code="""
    // Scroll to bottom to trigger lazy loading
    window.scrollTo(0, document.body.scrollHeight);
    await new Promise(r => setTimeout(r, 2000));  // Wait 2s
    """
)
```
