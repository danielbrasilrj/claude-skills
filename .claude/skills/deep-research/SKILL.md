---
name: deep-research
description: Multi-source research combining web search, Perplexity MCP, and Crawl4AI web crawling. Supports competitive analysis, market research, technology evaluations, and trend reports with structured output.
---

# Deep Research

## Purpose

Conduct thorough, multi-source research by orchestrating web searches, Perplexity reasoning, and Crawl4AI structured crawling. Produces well-sourced research reports with citations, comparisons, and actionable insights.

## When to Use

- Competitive analysis across multiple companies or products
- Market research requiring data from many web sources
- Technology evaluation comparing frameworks, libraries, or platforms
- Trend analysis pulling data from blogs, docs, and news
- Due diligence research aggregating public information
- Any task requiring structured extraction from multiple websites

## When NOT to Use

- Simple factual lookups (use WebSearch directly)
- Internal codebase questions (use code search tools)
- Tasks where a single source suffices

## Prerequisites

- **WebSearch / WebFetch**: Available by default in Claude Code
- **Perplexity MCP**: Must be configured; always ask user permission before use per global rules
- **Crawl4AI**: Python package for structured web crawling (`pip install crawl4ai`)
- **Python 3.10+**: Required for Crawl4AI scripts

## Procedures

### 1. Define Research Scope

Before starting, establish:

```
Research Question: [Clear, specific question]
Sources Required: [Minimum number of sources, default 5-10]
Depth Level: surface | moderate | deep
Output Format: report | comparison-table | brief | raw-notes
Deadline Constraint: [If any]
```

### 2. Source Discovery Phase

Execute searches across multiple channels in parallel where possible:

**Step 2a: Web Search** -- Use WebSearch for broad discovery.

```
Query 1: [Primary research question]
Query 2: [Alternative phrasing or related angle]
Query 3: [Specific sub-topic]
```

**Step 2b: Perplexity Reasoning** -- Ask user permission first. Use `mcp__perplexity__reason` for complex multi-step analysis, or `mcp__perplexity__search` for quick factual lookups.

**Step 2c: Crawl4AI Structured Extraction** -- For pages needing structured data extraction, use the Crawl4AI script. See REFERENCE.md for full API details.

```python
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig
from crawl4ai.extraction_strategy import JsonCssExtractionStrategy

schema = {
    "name": "CompetitorInfo",
    "baseSelector": ".pricing-card",
    "fields": [
        {"name": "plan_name", "selector": "h3", "type": "text"},
        {"name": "price", "selector": ".price", "type": "text"},
        {"name": "features", "selector": "ul li", "type": "list"}
    ]
}

config = CrawlerRunConfig(
    extraction_strategy=JsonCssExtractionStrategy(schema)
)

async with AsyncWebCrawler() as crawler:
    result = await crawler.arun(url=target_url, config=config)
    if result.success:
        data = result.extracted_content
    else:
        pass  # Handle failure: check result.error_message
```

### 3. Source Validation

For each source, verify:
- **Recency**: Is the information current enough for the research question?
- **Authority**: Is the source reputable? (official docs, major publications, known experts)
- **Consistency**: Do multiple sources corroborate the claim?
- **Bias Check**: Does the source have an obvious commercial or ideological bias?

### 4. Synthesis and Report Generation

Combine findings into the research report template (see `templates/research-report.md`):

1. Write the executive summary last, after all sections are complete
2. Use inline citations: `[Source Name](URL)` for every factual claim
3. Flag conflicting information explicitly with both perspectives
4. Separate facts from analysis/opinion clearly
5. Include a confidence rating for each major finding (High / Medium / Low)

### 5. Format Crawl4AI Output

Use the formatting script to normalize raw Crawl4AI output:

```bash
python scripts/format-crawl4ai-output.py --input raw_crawl.json --output formatted.md
```

## Templates

- `templates/research-report.md` -- Standard research report structure

## Examples

- `examples/competitive-analysis.md` -- Full competitive analysis walkthrough

## Chaining

| Chain With | Purpose |
|---|---|
| `domain-intelligence` | Check organizational constraints before recommending tools |
| `data-analysis` | Quantitative analysis of research data (pricing, metrics) |
| `prd-driven-development` | Feed research into product requirements |
| `documentation-generator` | Turn research into polished documentation |

## Troubleshooting

| Problem | Solution |
|---|---|
| Crawl4AI returns `result.success = False` | Check URL accessibility; try adding `wait_for` parameter for JS-heavy pages; verify CSS selectors |
| Perplexity rate limited | Fall back to WebSearch + WebFetch; wait and retry |
| WebSearch returns stale results | Add current year to query; use date-specific search terms |
| Extraction schema returns empty | Inspect page HTML to verify selectors; try broader `baseSelector`; use `LLMExtractionStrategy` as fallback (costs tokens) |
| Too many sources to process | Prioritize by authority score; batch Crawl4AI calls; summarize incrementally |
| Conflicting data across sources | Flag in report with confidence levels; prefer primary sources over aggregators |
