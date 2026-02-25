# Rate Limiting and Politeness

## Why Rate Limit?

**Ethical reasons:**

- Respect server resources
- Avoid overloading small sites

**Practical reasons:**

- Avoid IP bans
- Avoid CAPTCHA challenges
- Comply with robots.txt

**Legal reasons:**

- Violating ToS can lead to legal action (rare, but possible)

## Rate Limiting Implementation

**Method 1: asyncio.sleep (Simple)**

```python
import asyncio

urls = ["https://example.com/page1", "https://example.com/page2"]

async with AsyncWebCrawler() as crawler:
    for url in urls:
        result = await crawler.arun(url=url, config=config)
        await asyncio.sleep(2)  # 2 second delay between requests
```

**Method 2: aiohttp-throttle (Advanced)**

```python
from aiohttp_throttle import Throttler

throttler = Throttler(rate_limit=10, period=60)  # 10 requests per 60 seconds

async with AsyncWebCrawler() as crawler:
    for url in urls:
        async with throttler:
            result = await crawler.arun(url=url, config=config)
```

**Recommended Delays:**

| Site Type                 | Delay | Requests/Min |
| ------------------------- | ----- | ------------ |
| Large site (Amazon, eBay) | 1-2s  | 30-60        |
| Medium site               | 2-5s  | 12-30        |
| Small site                | 5-10s | 6-12         |
| Unknown site              | 10s   | 6            |

**Rule of thumb:** Start conservative (10s), monitor for blocks, reduce if safe.

## Robots.txt Compliance

**Check robots.txt BEFORE scraping:**

```bash
curl https://example.com/robots.txt
```

**Example robots.txt:**

```
User-agent: *
Disallow: /admin/
Disallow: /api/
Crawl-delay: 5

User-agent: Googlebot
Disallow: /private/
```

**Interpretation:**

- `User-agent: *` -- applies to all bots
- `Disallow: /admin/` -- don't scrape /admin/\* paths
- `Crawl-delay: 5` -- wait 5 seconds between requests

**Python library to parse robots.txt:**

```python
from urllib.robotparser import RobotFileParser

rp = RobotFileParser()
rp.set_url("https://example.com/robots.txt")
rp.read()

if rp.can_fetch("*", "https://example.com/products"):
    print("Allowed to scrape")
else:
    print("Disallowed by robots.txt")
```
