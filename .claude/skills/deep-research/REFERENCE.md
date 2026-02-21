# Deep Research -- Reference

## Crawl4AI Full API Reference

### AsyncWebCrawler

The primary crawling interface. Always use as an async context manager.

```python
from crawl4ai import AsyncWebCrawler, BrowserConfig, CrawlerRunConfig

browser_config = BrowserConfig(
    headless=True,
    browser_type="chromium",  # "chromium", "firefox", "webkit"
    viewport_width=1280,
    viewport_height=720,
    user_agent="custom-agent-string",
    proxy="http://proxy:port",  # Optional
)

run_config = CrawlerRunConfig(
    # Content filtering
    word_count_threshold=10,          # Min words per block
    exclude_external_links=False,
    remove_overlay_elements=True,

    # Waiting strategies
    wait_for="css:.main-content",     # Wait for CSS selector
    delay_before_return_html=2.0,     # Seconds to wait after page load

    # Extraction
    extraction_strategy=None,         # Set to strategy instance

    # Caching
    cache_mode="enabled",             # "enabled", "disabled", "bypass"

    # Screenshots
    screenshot=False,
    pdf=False,
)

async with AsyncWebCrawler(config=browser_config) as crawler:
    result = await crawler.arun(url="https://example.com", config=run_config)
```

### CrawlResult Object

```python
result.success          # bool - Whether crawl succeeded
result.url              # str - Final URL (after redirects)
result.html             # str - Raw HTML
result.cleaned_html     # str - Cleaned HTML
result.markdown         # str - Markdown conversion of page
result.extracted_content # str - JSON string from extraction strategy
result.links            # dict - {"internal": [...], "external": [...]}
result.media            # dict - {"images": [...], "videos": [...]}
result.metadata         # dict - Page metadata (title, description, etc.)
result.error_message    # str - Error details if success is False
result.status_code      # int - HTTP status code
```

### Extraction Strategies

#### JsonCssExtractionStrategy (Free, No LLM)

Best for pages with consistent HTML structure. No API costs.

```python
from crawl4ai.extraction_strategy import JsonCssExtractionStrategy

schema = {
    "name": "SchemaName",
    "baseSelector": "article.post",  # Repeating container element
    "fields": [
        {
            "name": "title",
            "selector": "h2.title",
            "type": "text"            # "text", "attribute", "html", "list"
        },
        {
            "name": "link",
            "selector": "a.read-more",
            "type": "attribute",
            "attribute": "href"
        },
        {
            "name": "tags",
            "selector": "span.tag",
            "type": "list"
        },
        {
            "name": "nested_data",
            "selector": "div.details",
            "type": "nested",
            "fields": [
                {"name": "author", "selector": ".author", "type": "text"},
                {"name": "date", "selector": ".date", "type": "text"}
            ]
        }
    ]
}

strategy = JsonCssExtractionStrategy(schema)
```

#### LLMExtractionStrategy (Costs Tokens)

Use when CSS selectors are unreliable or content is unstructured. Requires an LLM API key.

```python
from crawl4ai.extraction_strategy import LLMExtractionStrategy

strategy = LLMExtractionStrategy(
    provider="openai/gpt-4o-mini",   # or "ollama/llama3"
    api_token="your-api-key",
    instruction="Extract all product names, prices, and feature lists from this page.",
    schema={                          # Optional Pydantic-compatible schema
        "type": "object",
        "properties": {
            "products": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "name": {"type": "string"},
                        "price": {"type": "string"},
                        "features": {"type": "array", "items": {"type": "string"}}
                    }
                }
            }
        }
    },
    chunk_token_threshold=2000,
    overlap_rate=0.1,
)
```

### Multi-URL Crawling

```python
urls = [
    "https://example.com/page1",
    "https://example.com/page2",
    "https://example.com/page3",
]

async with AsyncWebCrawler() as crawler:
    results = await crawler.arun_many(urls, config=run_config)
    for result in results:
        if result.success:
            process(result)
```

### Session-Based Crawling (Multi-Page Flows)

```python
config_page1 = CrawlerRunConfig(
    session_id="my_session",
    js_code="document.querySelector('#load-more').click();",
    wait_for="css:.new-content",
)

config_page2 = CrawlerRunConfig(
    session_id="my_session",  # Same session continues
    js_code="document.querySelector('#next-page').click();",
    wait_for="css:.page-2-content",
)

async with AsyncWebCrawler() as crawler:
    result1 = await crawler.arun(url=start_url, config=config_page1)
    result2 = await crawler.arun(url=start_url, config=config_page2)
```

## Research Methodology Reference

### Source Credibility Scoring

| Score | Criteria | Examples |
|-------|----------|----------|
| 5 - Authoritative | Official docs, peer-reviewed, primary data | Company websites, academic papers, official APIs |
| 4 - Reliable | Major publications, established experts | TechCrunch, Gartner, well-known industry blogs |
| 3 - Moderate | Community-driven, generally accurate | Stack Overflow (high-vote), Wikipedia, dev.to |
| 2 - Variable | Individual blogs, forums, unverified | Personal blogs, Reddit threads, Quora |
| 1 - Low | Anonymous, outdated, known bias | SEO content farms, undated articles |

### Research Depth Levels

**Surface** (15-30 min equivalent):
- 3-5 sources
- Key facts and high-level overview
- No deep extraction needed
- Use: Quick briefings, initial scoping

**Moderate** (1-2 hr equivalent):
- 5-10 sources
- Structured comparisons
- Some Crawl4AI extraction
- Use: Technology evaluations, market overviews

**Deep** (4-8 hr equivalent):
- 10-20+ sources
- Full competitive analysis
- Heavy Crawl4AI extraction with custom schemas
- Cross-referencing and validation
- Use: Strategic decisions, investment research, comprehensive evaluations

### Competitive Analysis Framework

1. **Product Features**: Core offering, differentiators, limitations
2. **Pricing**: Plans, tiers, enterprise pricing signals
3. **Market Position**: Target audience, positioning, messaging
4. **Technology**: Stack, integrations, API availability
5. **Traction**: Funding, team size, growth signals, community size
6. **Sentiment**: Reviews, social mentions, developer experience reports

### SWOT Template

```
Strengths:
- [Internal positive factors]

Weaknesses:
- [Internal negative factors]

Opportunities:
- [External positive factors]

Threats:
- [External negative factors]
```

## Perplexity MCP Tool Selection Guide

| Tool | When to Use | Cost |
|------|-------------|------|
| `mcp__perplexity__search` | Simple factual queries, quick lookups | Low |
| `mcp__perplexity__reason` | Complex analysis, multi-step reasoning, comparisons | Medium |
| `mcp__perplexity__deep_research` | Comprehensive investigation, full reports | High |

**Remember**: Always ask user permission before using Perplexity MCP tools.

## Output Formatting Conventions

### Citations
Use inline markdown links: `According to [Source Name](https://url), ...`

### Data Tables
Use markdown tables with alignment:

```markdown
| Metric       | Company A | Company B | Company C |
|:-------------|----------:|----------:|----------:|
| Revenue      |     $10M  |     $25M  |      $5M  |
| Employees    |       50  |      120  |       20  |
| Growth (YoY) |      30%  |      15%  |      80%  |
```

### Confidence Indicators
- **High Confidence**: Multiple authoritative sources agree
- **Medium Confidence**: Limited sources or minor discrepancies
- **Low Confidence**: Single source, unverified, or conflicting data
