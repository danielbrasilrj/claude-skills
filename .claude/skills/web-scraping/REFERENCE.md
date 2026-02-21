# Web Scraping Reference Guide

## Crawl4AI Deep Dive

### AsyncWebCrawler Configuration

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

**Advanced Configuration Options:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `cache_mode` | CacheMode | ENABLED | ENABLED (use cache), BYPASS (ignore cache), WRITE_ONLY, READ_ONLY |
| `page_timeout` | int | 30000 | Page load timeout in milliseconds |
| `wait_for` | str | None | CSS selector to wait for before extraction (e.g., "css:.product-card") |
| `wait_until` | str | "domcontentloaded" | "load", "domcontentloaded", "networkidle" |
| `js_code` | str | None | Custom JavaScript to execute before extraction |
| `extraction_strategy` | Strategy | None | JsonCss, Regex, or LLM extraction strategy |
| `verbose` | bool | False | Enable debug logging |
| `user_agent` | str | Chrome UA | Custom user agent string |
| `headers` | dict | {} | Custom HTTP headers |
| `screenshot` | bool | False | Capture screenshot after page load |
| `pdf` | bool | False | Save page as PDF |

---

### CacheMode Options

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

---

### Extraction Strategies (Tier System)

#### Tier 1: JsonCssExtractionStrategy (FREE)

**When to use:** Structured HTML with consistent selectors (90% of cases)

**Schema Structure:**
```python
schema = {
    "name": "Products",              # Schema name
    "baseSelector": ".product-card", # Container element (repeated)
    "fields": [
        {
            "name": "title",         # Field name in output JSON
            "selector": "h3.title",  # CSS selector (relative to baseSelector)
            "type": "text"           # text, attribute, html
        },
        {
            "name": "price",
            "selector": ".price",
            "type": "text"
        },
        {
            "name": "url",
            "selector": "a.product-link",
            "type": "attribute",
            "attribute": "href"      # Extract href attribute
        },
        {
            "name": "image",
            "selector": "img",
            "type": "attribute",
            "attribute": "src"
        }
    ]
}

strategy = JsonCssExtractionStrategy(schema)
```

**Field Types:**

| Type | Description | Example |
|------|-------------|---------|
| `text` | Extract text content | `<h3>Title</h3>` → "Title" |
| `attribute` | Extract attribute value | `<a href="/page">` → "/page" |
| `html` | Extract raw HTML | `<div><b>Bold</b></div>` → "<b>Bold</b>" |

**Nested Selectors:**
```python
schema = {
    "name": "Articles",
    "baseSelector": "article",
    "fields": [
        {
            "name": "author",
            "selector": ".author-info .name",  # Nested selector
            "type": "text"
        }
    ]
}
```

**Common Pitfalls:**
- **Empty results:** baseSelector too specific or doesn't exist
  - Fix: Inspect HTML, verify selector with `document.querySelectorAll('.selector')`
- **Missing fields:** Relative selector wrong
  - Fix: Test selector relative to baseSelector element
- **Duplicate data:** baseSelector matches too broadly
  - Fix: Make baseSelector more specific

---

#### Tier 2: RegexExtractionStrategy (FREE)

**When to use:** Extracting specific patterns (prices, emails, phone numbers) from unstructured text

**Basic Usage:**
```python
from crawl4ai.extraction_strategy import RegexExtractionStrategy

# Extract all prices ($100, $1,234.56)
strategy = RegexExtractionStrategy(patterns=[r'\$[\d,]+\.?\d*'])

# Extract all email addresses
strategy = RegexExtractionStrategy(patterns=[r'\b[\w.-]+@[\w.-]+\.\w+\b'])

# Extract multiple patterns
strategy = RegexExtractionStrategy(patterns=[
    r'\$[\d,]+\.?\d*',           # Prices
    r'\(\d{3}\) \d{3}-\d{4}',   # Phone numbers (123) 456-7890
    r'\b\d{5}(-\d{4})?\b'        # ZIP codes
])
```

**Useful Patterns:**

| Pattern | Matches | Example |
|---------|---------|---------|
| `r'\$[\d,]+\.?\d*'` | Prices | $100, $1,234.56 |
| `r'[\w.-]+@[\w.-]+\.\w+'` | Emails | user@example.com |
| `r'\(\d{3}\)\s*\d{3}-\d{4}'` | US phones | (555) 123-4567 |
| `r'\d{5}(-\d{4})?'` | US ZIP codes | 12345, 12345-6789 |
| `r'https?://[^\s]+'` | URLs | https://example.com/page |
| `r'#[A-Fa-f0-9]{6}'` | Hex colors | #FF5733 |

**Output Format:**
Returns list of dictionaries with `pattern` and `match` keys:
```python
[
  {"pattern": r'\$[\d,]+\.?\d*', "match": "$1,299.99"},
  {"pattern": r'\$[\d,]+\.?\d*', "match": "$499.00"}
]
```

---

#### Tier 3: LLMExtractionStrategy (COSTS TOKENS)

**When to use:** Unstructured data, complex extraction logic, or when CSS/Regex fail

**Requires:** Pydantic models for schema definition

**Setup:**
```python
from crawl4ai.extraction_strategy import LLMExtractionStrategy
from pydantic import BaseModel, Field

# Define data model
class Product(BaseModel):
    name: str = Field(description="Product name")
    price: float = Field(description="Price in USD")
    features: list[str] = Field(description="List of product features")
    in_stock: bool = Field(description="Whether product is in stock")

# Create strategy
strategy = LLMExtractionStrategy(
    provider="openai/gpt-4o-mini",              # Model to use
    schema=Product.model_json_schema(),          # Pydantic schema
    instruction="Extract product details from the page",
    chunk_token_threshold=1200,                  # Max tokens per chunk
    overlap_rate=0.1                             # Overlap between chunks (10%)
)
```

**Supported Providers:**

| Provider | Model Example | Cost (per 1M tokens) |
|----------|---------------|----------------------|
| OpenAI | `openai/gpt-4o-mini` | $0.15 input, $0.60 output |
| OpenAI | `openai/gpt-4o` | $2.50 input, $10.00 output |
| Anthropic | `anthropic/claude-3-5-sonnet` | $3.00 input, $15.00 output |
| Groq | `groq/llama-3.1-70b` | Free (rate limited) |

**Chunking Strategy:**
Large pages are split into chunks to stay within token limits.

- `chunk_token_threshold`: Max tokens per chunk (default: 1200)
- `overlap_rate`: Overlap between chunks to avoid cutting mid-entity (default: 0.1 = 10%)

**Example with overlap:**
```
Page: 5000 tokens
Chunk size: 1200 tokens
Overlap: 10% (120 tokens)

Chunk 1: tokens 0-1200
Chunk 2: tokens 1080-2280  (overlaps 120 tokens from chunk 1)
Chunk 3: tokens 2160-3360
...
```

**Cost Optimization:**
1. **Start with CSS strategy** — try Tier 1 first
2. **Reduce chunk size** — smaller chunks = fewer tokens, but more API calls
3. **Use cheaper models** — gpt-4o-mini vs gpt-4o saves 15×
4. **Filter HTML** — remove ads, navigation, footer before LLM extraction

---

### Wait Strategies (JS-Rendered Pages)

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

| State | When to Use | Description |
|-------|-------------|-------------|
| `load` | Heavy pages with images | Waits for full page load (images, CSS, all resources) |
| `domcontentloaded` | Fast scraping | Waits for HTML parsing complete (default) |
| `networkidle` | Dynamic content | Waits until network is idle for 500ms (best for JS-heavy sites) |

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

---

## Rate Limiting and Politeness

### Why Rate Limit?

**Ethical reasons:**
- Respect server resources
- Avoid overloading small sites

**Practical reasons:**
- Avoid IP bans
- Avoid CAPTCHA challenges
- Comply with robots.txt

**Legal reasons:**
- Violating ToS can lead to legal action (rare, but possible)

---

### Rate Limiting Implementation

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

| Site Type | Delay | Requests/Min |
|-----------|-------|--------------|
| Large site (Amazon, eBay) | 1-2s | 30-60 |
| Medium site | 2-5s | 12-30 |
| Small site | 5-10s | 6-12 |
| Unknown site | 10s | 6 |

**Rule of thumb:** Start conservative (10s), monitor for blocks, reduce if safe.

---

### Robots.txt Compliance

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
- `User-agent: *` — applies to all bots
- `Disallow: /admin/` — don't scrape /admin/* paths
- `Crawl-delay: 5` — wait 5 seconds between requests

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

---

## Proxy Rotation and Anti-Detection

### When to Use Proxies

**Use proxies if:**
- Scraping large volume (100+ pages/day)
- Site has aggressive anti-bot measures
- Your IP gets blocked frequently
- You need geo-specific data (scraping from different countries)

**Don't use if:**
- Small scraping job (<100 pages)
- Site allows scraping (per robots.txt)
- You have API access (always prefer API)

---

### Proxy Setup with Crawl4AI

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

| Service | Type | Cost | Use Case |
|---------|------|------|----------|
| **BrightData** | Residential | $5/GB | High-quality, rarely blocked |
| **Smartproxy** | Residential | $7/GB | Good balance of price/quality |
| **Oxylabs** | Datacenter | $1/GB | Cheap, higher block rate |
| **ScraperAPI** | Managed | $49/month (100k requests) | Handles proxies + CAPTCHA solving |

---

### User Agent Rotation

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

---

## Data Cleaning and Post-Processing

### Common Cleaning Tasks

**Remove whitespace:**
```python
import re

def clean_text(text):
    text = re.sub(r'\s+', ' ', text)  # Replace multiple whitespace with single space
    return text.strip()

# Example
raw = "  Product    Title\n\n  "
clean = clean_text(raw)  # "Product Title"
```

**Parse prices:**
```python
def parse_price(price_str):
    # "$1,234.56" → 1234.56
    cleaned = re.sub(r'[^\d.]', '', price_str)
    return float(cleaned) if cleaned else None

parse_price("$1,299.99")  # 1299.99
parse_price("R$ 1.299,99")  # 1299.99 (Brazilian format)
```

**Parse dates:**
```python
from dateutil.parser import parse

date_str = "January 15, 2026"
date_obj = parse(date_str)  # datetime(2026, 1, 15)
```

---

### Data Validation with Pydantic

```python
from pydantic import BaseModel, HttpUrl, validator

class Product(BaseModel):
    name: str
    price: float
    url: HttpUrl
    in_stock: bool

    @validator('price')
    def price_must_be_positive(cls, v):
        if v <= 0:
            raise ValueError('Price must be positive')
        return v

# Validate scraped data
try:
    product = Product(
        name="Laptop",
        price=1299.99,
        url="https://example.com/laptop",
        in_stock=True
    )
except ValidationError as e:
    print(f"Invalid data: {e}")
```

---

## Storage Options

### JSON (Simple, Portable)
```python
import json

data = [{"name": "Product 1", "price": 99.99}, ...]

with open("products.json", "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
```

### CSV (Excel-Compatible)
```python
import csv

with open("products.csv", "w", newline='', encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["name", "price", "url"])
    writer.writeheader()
    writer.writerows(data)
```

### SQLite (Queryable)
```python
import sqlite3

conn = sqlite3.connect("products.db")
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY,
    name TEXT,
    price REAL,
    url TEXT
)
""")

for product in data:
    cursor.execute("INSERT INTO products (name, price, url) VALUES (?, ?, ?)",
                   (product['name'], product['price'], product['url']))

conn.commit()
conn.close()
```

---

## Troubleshooting Common Issues

| Problem | Cause | Solution |
|---------|-------|----------|
| **Empty extracted_content** | CSS selectors don't match | Inspect HTML, verify selectors with browser DevTools |
| **JavaScript content not loading** | Page not waiting for JS | Add `wait_for` or `wait_until="networkidle"` |
| **403 Forbidden / 429 Rate Limit** | Too many requests | Increase delay, use proxies, check robots.txt |
| **CAPTCHA challenges** | Bot detected | Use residential proxies, rotate user agents, add delays |
| **Slow scraping** | Cache disabled | Enable `CacheMode.ENABLED` for development |
| **Timeout errors** | Page too slow | Increase `page_timeout` or use `wait_until="domcontentloaded"` |
| **LLM extraction too expensive** | Large pages, many chunks | Try CSS strategy first, reduce HTML before LLM |
