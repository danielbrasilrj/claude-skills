---
name: web-scraping
description: |
  Crawl4AI integration skill for structured web scraping. Covers setting up crawlers, parsing
  structured data, respecting robots.txt, rate limiting, and storing results. Includes
  configurable scraping profiles for different verticals (SaaS, marketplaces, e-commerce).
  Use when extracting structured data from websites, scraping competitor information,
  building data pipelines from web sources, or setting up recurring web crawls.
---

## Purpose

Web Scraping provides structured procedures for extracting data from websites using Crawl4AI. It implements a three-tier extraction strategy (CSS → Regex → LLM) that starts with free methods and escalates only when needed, with built-in compliance for robots.txt and rate limiting.

## When to Use

- Extracting structured data from competitor websites
- Scraping pricing, features, or reviews from SaaS platforms
- Building data pipelines from web sources
- Monitoring competitor changes over time
- Any task requiring structured data extraction from HTML

## Prerequisites

- **Python 3.10+**
- **Crawl4AI**: `pip install crawl4ai`
- **Playwright**: `playwright install` (for JS-rendered pages)
- Optional: Pydantic for schema validation

## Procedures

### 1. Compliance Check (ALWAYS FIRST)

Before scraping any site:
1. Check `robots.txt`: `curl https://example.com/robots.txt`
2. Respect `Crawl-delay` directives
3. Check Terms of Service for scraping restrictions
4. Implement rate limiting (minimum 2 seconds between requests)

### 2. Choose Extraction Strategy

**Tier 1: JsonCssExtractionStrategy (FREE — try first)**
```python
from crawl4ai.extraction_strategy import JsonCssExtractionStrategy

schema = {
    "name": "Products",
    "baseSelector": ".product-card",
    "fields": [
        {"name": "title", "selector": "h3", "type": "text"},
        {"name": "price", "selector": ".price", "type": "text"},
        {"name": "url", "selector": "a", "type": "attribute", "attribute": "href"}
    ]
}
strategy = JsonCssExtractionStrategy(schema)
```

**Tier 2: RegexExtractionStrategy (FREE — for specific patterns)**
```python
from crawl4ai.extraction_strategy import RegexExtractionStrategy
strategy = RegexExtractionStrategy(patterns=[r'\$[\d,]+\.?\d*'])
```

**Tier 3: LLMExtractionStrategy (COSTS TOKENS — last resort)**
```python
from crawl4ai.extraction_strategy import LLMExtractionStrategy
from pydantic import BaseModel

class Product(BaseModel):
    name: str
    price: float
    features: list[str]

strategy = LLMExtractionStrategy(
    provider="openai/gpt-4o-mini",
    schema=Product.model_json_schema(),
    chunk_token_threshold=1200,
    overlap_rate=0.1
)
```

### 3. Execute Crawl

```python
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, CacheMode

config = CrawlerRunConfig(
    extraction_strategy=strategy,
    cache_mode=CacheMode.BYPASS,  # Use ENABLED in production
    wait_for="css:.product-card",  # Wait for JS-rendered content
    page_timeout=30000
)

async with AsyncWebCrawler() as crawler:
    result = await crawler.arun(url=target_url, config=config)
    if result.success:
        data = result.extracted_content
    else:
        print(f"Failed: {result.error_message}")
```

### 4. Rate Limiting

```python
import asyncio

urls = ["https://example.com/page1", "https://example.com/page2"]
for url in urls:
    result = await crawler.arun(url=url, config=config)
    await asyncio.sleep(2)  # Minimum 2 second delay
```

### 5. Store Results

Save as structured JSON for downstream processing:
```python
import json
with open("results.json", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
```

## Templates

- `templates/scraping-profile.yml` — Configurable profiles for different verticals
- `scripts/crawl4ai-template.py` — Ready-to-use scraping script

## Examples

- `examples/competitor-pricing-scrape.md` — Competitor pricing extraction

## Chaining

| Chain With | Purpose |
|---|---|
| `deep-research` | Feed scraped data into research reports |
| `data-analysis` | Analyze scraped datasets |
| `ab-test-generator` | Use competitor data to inform experiments |
| `domain-intelligence` | Check compliance requirements |

## Troubleshooting

| Problem | Solution |
|---|---|
| Empty extraction results | Inspect HTML; verify CSS selectors; try broader baseSelector |
| JS content not loading | Add `wait_for` parameter; ensure Playwright is installed |
| Rate limited / blocked | Increase delay; rotate user agents; respect robots.txt |
| LLM extraction too expensive | Try CSS strategy first; reduce chunk size |
