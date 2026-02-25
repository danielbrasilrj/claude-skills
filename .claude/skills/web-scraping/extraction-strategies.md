# Extraction Strategies (Tier System)

## Tier 1: JsonCssExtractionStrategy (FREE)

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

| Type        | Description             | Example                                   |
| ----------- | ----------------------- | ----------------------------------------- |
| `text`      | Extract text content    | `<h3>Title</h3>` -> "Title"               |
| `attribute` | Extract attribute value | `<a href="/page">` -> "/page"             |
| `html`      | Extract raw HTML        | `<div><b>Bold</b></div>` -> "<b>Bold</b>" |

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

## Tier 2: RegexExtractionStrategy (FREE)

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

| Pattern                      | Matches      | Example                  |
| ---------------------------- | ------------ | ------------------------ |
| `r'\$[\d,]+\.?\d*'`          | Prices       | $100, $1,234.56          |
| `r'[\w.-]+@[\w.-]+\.\w+'`    | Emails       | user@example.com         |
| `r'\(\d{3}\)\s*\d{3}-\d{4}'` | US phones    | (555) 123-4567           |
| `r'\d{5}(-\d{4})?'`          | US ZIP codes | 12345, 12345-6789        |
| `r'https?://[^\s]+'`         | URLs         | https://example.com/page |
| `r'#[A-Fa-f0-9]{6}'`         | Hex colors   | #FF5733                  |

**Output Format:**
Returns list of dictionaries with `pattern` and `match` keys:

```python
[
  {"pattern": r'\$[\d,]+\.?\d*', "match": "$1,299.99"},
  {"pattern": r'\$[\d,]+\.?\d*', "match": "$499.00"}
]
```

## Tier 3: LLMExtractionStrategy (COSTS TOKENS)

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

| Provider  | Model Example                 | Cost (per 1M tokens)       |
| --------- | ----------------------------- | -------------------------- |
| OpenAI    | `openai/gpt-4o-mini`          | $0.15 input, $0.60 output  |
| OpenAI    | `openai/gpt-4o`               | $2.50 input, $10.00 output |
| Anthropic | `anthropic/claude-3-5-sonnet` | $3.00 input, $15.00 output |
| Groq      | `groq/llama-3.1-70b`          | Free (rate limited)        |

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

1. **Start with CSS strategy** -- try Tier 1 first
2. **Reduce chunk size** -- smaller chunks = fewer tokens, but more API calls
3. **Use cheaper models** -- gpt-4o-mini vs gpt-4o saves 15x
4. **Filter HTML** -- remove ads, navigation, footer before LLM extraction
