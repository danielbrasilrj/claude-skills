# Proxy Rotation and Anti-Detection

## When to Use Proxies

**Use proxies if:**

- Scraping large volume (100+ pages/day)
- Site has aggressive anti-bot measures
- Your IP gets blocked frequently
- You need geo-specific data (scraping from different countries)

**Don't use if:**

- Small scraping job (<100 pages)
- Site allows scraping (per robots.txt)
- You have API access (always prefer API)

## Proxy Setup with Crawl4AI

```python
config = CrawlerRunConfig(
    proxy="http://username:password@proxy-server.com:8080"
)

# Or with proxy rotation
proxies = [
    "http://proxy1.com:8080",
    "http://proxy2.com:8080",
    "http://proxy3.com:8080"
]

async with AsyncWebCrawler() as crawler:
    for i, url in enumerate(urls):
        proxy = proxies[i % len(proxies)]  # Rotate proxies
        config = CrawlerRunConfig(proxy=proxy)
        result = await crawler.arun(url=url, config=config)
```

**Proxy Services:**

| Service        | Type        | Cost                      | Use Case                          |
| -------------- | ----------- | ------------------------- | --------------------------------- |
| **BrightData** | Residential | $5/GB                     | High-quality, rarely blocked      |
| **Smartproxy** | Residential | $7/GB                     | Good balance of price/quality     |
| **Oxylabs**    | Datacenter  | $1/GB                     | Cheap, higher block rate          |
| **ScraperAPI** | Managed     | $49/month (100k requests) | Handles proxies + CAPTCHA solving |

## User Agent Rotation

Vary user agents to avoid fingerprinting:

```python
import random

user_agents = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/605.1.15",
    "Mozilla/5.0 (X11; Linux x86_64) Firefox/121.0"
]

config = CrawlerRunConfig(
    user_agent=random.choice(user_agents)
)
```
