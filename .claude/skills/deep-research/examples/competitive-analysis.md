# Example: Competitive Analysis -- AI Code Assistants (2025)

This example demonstrates the deep-research skill applied to a competitive analysis of AI code assistant tools.

## Research Setup

```
Research Question: How do the top AI code assistants compare in features, pricing, and developer experience?
Sources Required: 10+
Depth Level: deep
Output Format: report
```

## Step 1: Source Discovery

### Web Search Queries

```
"AI code assistant comparison 2025"
"GitHub Copilot vs Cursor vs Claude Code features"
"AI coding tools pricing plans 2025"
"developer experience AI code completion review"
```

### Perplexity Reasoning Query (with user permission)

```
Compare GitHub Copilot, Cursor, and Claude Code across these dimensions:
code completion accuracy, multi-file editing, terminal integration,
pricing tiers, IDE support, and language coverage. Include recent
updates from 2025.
```

### Crawl4AI Extraction -- Pricing Pages

```python
import asyncio
import json
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig
from crawl4ai.extraction_strategy import JsonCssExtractionStrategy

pricing_schema = {
    "name": "PricingPlans",
    "baseSelector": ".pricing-card, .plan-card, [class*='pricing']",
    "fields": [
        {"name": "plan_name", "selector": "h2, h3, .plan-name", "type": "text"},
        {"name": "price", "selector": ".price, .amount, [class*='price']", "type": "text"},
        {"name": "period", "selector": ".period, .billing", "type": "text"},
        {"name": "features", "selector": "ul li, .feature-list li", "type": "list"},
        {"name": "cta_text", "selector": "a.btn, button", "type": "text"},
    ]
}

urls = [
    "https://github.com/features/copilot#pricing",
    "https://cursor.com/pricing",
]

async def extract_pricing():
    config = CrawlerRunConfig(
        extraction_strategy=JsonCssExtractionStrategy(pricing_schema),
        wait_for="css:.pricing-card",
        delay_before_return_html=2.0,
    )
    async with AsyncWebCrawler() as crawler:
        results = await crawler.arun_many(urls, config=config)
        for result in results:
            if result.success:
                print(f"\n--- {result.url} ---")
                data = json.loads(result.extracted_content)
                print(json.dumps(data, indent=2))
            else:
                print(f"FAILED: {result.url} -- {result.error_message}")

asyncio.run(extract_pricing())
```

### Format Extracted Data

```bash
python scripts/format-crawl4ai-output.py \
    --input pricing_raw.json \
    --format table \
    --output pricing_comparison.md
```

## Step 2: Synthesized Report (Abbreviated)

### Comparative Analysis

| Dimension          | GitHub Copilot       | Cursor              | Claude Code          |
|:-------------------|:---------------------|:--------------------|:---------------------|
| **Pricing (Ind.)** | $10/mo               | $20/mo              | Usage-based          |
| **Pricing (Biz.)** | $19/user/mo          | $40/user/mo         | API pricing          |
| **IDE Support**    | VS Code, JetBrains, Neovim | Fork of VS Code | Terminal (any editor) |
| **Multi-file Edit**| Limited              | Yes (Composer)      | Yes (native)         |
| **Model Access**   | GPT-4o, Claude       | Multiple models     | Claude Opus/Sonnet   |
| **Terminal**       | CLI (preview)        | Built-in terminal   | Terminal-native       |
| **Context Window** | Repository-level     | Codebase indexing   | Full repo context    |

### Key Findings

**Finding 1: Terminal-native approaches are gaining traction**

Confidence: High

Both Claude Code and emerging tools prioritize terminal-based workflows over IDE plugins. This reflects a shift toward editor-agnostic tooling. Sources: [Anthropic Blog](https://anthropic.com/blog), [Developer Survey 2025](https://survey.stackoverflow.co).

**Finding 2: Multi-file editing is the new baseline**

Confidence: High

All major tools now support multi-file editing. Single-file autocomplete alone is no longer a differentiator. The competitive frontier has moved to whole-project understanding and autonomous task completion.

**Finding 3: Pricing models are diverging**

Confidence: Medium

Subscription-based (Copilot, Cursor) vs. usage-based (Claude Code) pricing creates different value propositions. Usage-based appeals to power users; subscriptions appeal to teams wanting predictable costs.

### Recommendations

1. **For individual developers**: Evaluate based on primary editor and workflow preferences
2. **For teams**: Consider IDE lock-in implications and per-seat costs at scale
3. **For enterprises**: Prioritize data privacy policies and self-hosting options

## Step 3: Confidence Assessment

| Finding | Confidence | Basis |
|:--------|:-----------|:------|
| Terminal-native trend | High | Multiple sources, official announcements |
| Multi-file as baseline | High | Feature pages of all three products |
| Pricing divergence | Medium | Pricing pages current but may change |

## Sources Used

1. GitHub Copilot Features Page -- Credibility: 5
2. Cursor Pricing Page -- Credibility: 5
3. Anthropic Claude Code Docs -- Credibility: 5
4. Stack Overflow Developer Survey 2025 -- Credibility: 4
5. Various tech blog reviews -- Credibility: 3

---

*This example demonstrates the full research flow. Actual URLs, data, and findings are illustrative.*
