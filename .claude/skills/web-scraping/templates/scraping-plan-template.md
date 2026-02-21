# Web Scraping Project Plan

**Project Name:** [Descriptive name]
**Target Site(s):** [URLs]
**Data Goal:** [What data are you extracting and why?]
**Frequency:** [One-time / Daily / Weekly / Monthly]
**Date:** [YYYY-MM-DD]

---

## 1. Compliance Check

**Before scraping, verify:**

- [ ] **Robots.txt reviewed:** [URL/robots.txt]
  - Allowed paths: [List paths you can scrape]
  - Disallowed paths: [Paths to avoid]
  - Crawl-delay directive: [X seconds, or "None"]

- [ ] **Terms of Service reviewed:** [Link to ToS]
  - Scraping explicitly allowed: Yes / No / Unclear
  - Restrictions noted: [Any specific restrictions]

- [ ] **API available?** Yes / No
  - If yes: [Why not using API? Cost, rate limits, missing data?]

- [ ] **Legal review needed?** Yes / No
  - If scraping competitor data, consult legal team

**Risk Assessment:** [Low / Medium / High]
**Mitigation plan:** [How will you minimize risk? Rate limiting, attribution, etc.]

---

## 2. Target Data Schema

**What data are you extracting?**

| Field Name | Data Type | Example | Required? | Notes |
|------------|-----------|---------|-----------|-------|
| [field1] | string | [example value] | Yes / No | [Selector location, format notes] |
| [field2] | float | [example value] | Yes / No | [How to parse, cleaning needed?] |
| [field3] | list[str] | [example list] | Yes / No | [Multiple values, how extracted?] |
| [field4] | datetime | [example date] | Yes / No | [Date format, timezone] |

**Output format:** JSON / CSV / Database
**Output location:** [File path or database connection string]

---

## 3. Extraction Strategy

**Chosen strategy:** JsonCss / Regex / LLM
**Why this strategy?** [Explain choice]

### CSS Selectors (if using JsonCss)

**Base selector:** `[CSS selector for repeated container]`
Example: `.product-card`, `article.listing`, `tr.item-row`

**Field selectors (relative to base):**

| Field | CSS Selector | Type | Notes |
|-------|--------------|------|-------|
| [field1] | `h3.title` | text | [Any special handling?] |
| [field2] | `.price` | text | [Need to parse? Remove $, commas?] |
| [field3] | `a.link` | attribute (href) | [Relative or absolute URL?] |
| [field4] | `img` | attribute (src) | [Image URL] |

**Test selectors in browser:**
```javascript
// Paste in browser console to verify
document.querySelectorAll('[baseSelector]').length  // Should return count of items
document.querySelector('[baseSelector] [fieldSelector]').textContent  // Test field extraction
```

---

### Regex Patterns (if using Regex)

| Field | Pattern | Example Match | Notes |
|-------|---------|---------------|-------|
| [field1] | `r'\$[\d,]+\.?\d*'` | $1,299.99 | [Price extraction] |
| [field2] | `r'[\w.-]+@[\w.-]+\.\w+'` | user@example.com | [Email extraction] |

---

### LLM Extraction (if using LLM)

**Model:** [e.g., openai/gpt-4o-mini]
**Pydantic schema:** [Link to schema definition file]
**Estimated cost per page:** [Calculate: tokens × price]
**Budget:** [Max pages × cost = total]

**Why LLM needed?** [Explain why CSS/Regex insufficient]

---

## 4. Crawling Configuration

**Page timeout:** [X ms] (default: 30000)
**Wait strategy:**
- [ ] `wait_for`: `[CSS selector]` — wait for specific element
- [ ] `wait_until`: `load` / `domcontentloaded` / `networkidle`
- [ ] Custom JS: [If executing custom JavaScript before extraction]

**Cache mode:** ENABLED / BYPASS
- Use ENABLED for development/testing
- Use BYPASS for production fresh data

**User agent:** [Custom UA string, or "Default Chrome"]
**Proxy:** [Proxy server URL, or "None"]

---

## 5. Rate Limiting

**Delay between requests:** [X seconds]
**Max requests per minute:** [X]
**Max requests per hour:** [X]

**Rationale:** [Why this rate? Based on robots.txt, site size, ethics]

**Implementation:**
```python
await asyncio.sleep([X])  # Delay in seconds
```

---

## 6. Target URLs

**URL pattern:** [Describe URL structure]
Example: `https://example.com/products?page=1`, `https://example.com/category/item-123`

**Total pages to scrape:** [X]

**URL generation strategy:**

- [ ] **Pagination:** Loop through page numbers 1-N
  ```python
  urls = [f"https://example.com/products?page={i}" for i in range(1, 51)]
  ```

- [ ] **Sitemap:** Parse sitemap.xml
  ```python
  sitemap_url = "https://example.com/sitemap.xml"
  # Parse XML, extract <loc> tags
  ```

- [ ] **Manual list:** Predefined list of URLs
  ```python
  urls = ["https://example.com/page1", "https://example.com/page2", ...]
  ```

- [ ] **Crawl links:** Extract links from pages dynamically
  ```python
  # Extract all <a href> links, filter by pattern
  ```

---

## 7. Data Cleaning Plan

**Post-processing steps:**

- [ ] **Trim whitespace:** Remove leading/trailing spaces
- [ ] **Parse prices:** Remove $, commas → convert to float
- [ ] **Parse dates:** Convert "Jan 15, 2026" → datetime object
- [ ] **Deduplicate:** Remove duplicate entries (by URL, ID, etc.)
- [ ] **Validate:** Use Pydantic to validate schema
- [ ] **Handle missing data:** [How to handle null/empty fields? Default values?]

**Cleaning functions:**
```python
def clean_price(price_str):
    # "$1,299.99" → 1299.99
    return float(re.sub(r'[^\d.]', '', price_str))

def clean_text(text):
    # Remove extra whitespace
    return re.sub(r'\s+', ' ', text).strip()
```

---

## 8. Error Handling

**What to do if:**

| Error | Cause | Action |
|-------|-------|--------|
| 404 Not Found | Page deleted | Skip, log URL |
| 403 Forbidden | IP blocked | Stop, use proxy, increase delay |
| 429 Rate Limited | Too many requests | Exponential backoff, wait 60s |
| Timeout | Slow page load | Retry 3x, then skip |
| Empty extraction | Selector wrong / page changed | Alert, inspect HTML |
| CAPTCHA | Bot detected | Manual solve, or use CAPTCHA solver |

**Retry logic:**
```python
max_retries = 3
for attempt in range(max_retries):
    try:
        result = await crawler.arun(url=url, config=config)
        if result.success:
            break
    except Exception as e:
        if attempt == max_retries - 1:
            print(f"Failed after {max_retries} attempts: {url}")
        await asyncio.sleep(10 * (attempt + 1))  # Exponential backoff
```

---

## 9. Monitoring and Logging

**Log file location:** [Path to log file]

**What to log:**
- [ ] Timestamp of each request
- [ ] URL attempted
- [ ] Success / Failure status
- [ ] Error message (if failed)
- [ ] Items extracted count
- [ ] Response time

**Sample log format:**
```
2026-02-21 10:15:32 | SUCCESS | https://example.com/page1 | 12 items | 1.2s
2026-02-21 10:15:45 | FAILURE | https://example.com/page2 | 403 Forbidden | 0.5s
```

**Progress tracking:**
```python
from tqdm import tqdm

for url in tqdm(urls, desc="Scraping"):
    result = await crawler.arun(url=url, config=config)
```

---

## 10. Storage Plan

**Storage format:** [JSON / CSV / SQLite / PostgreSQL / MongoDB]

**File naming:** [e.g., `products_2026-02-21.json`, `competitors_page1.csv`]

**Schema version:** [v1.0 — increment when schema changes]

**Backup strategy:** [How often? Where stored?]

**Retention policy:** [How long to keep data? 30 days, 1 year, forever?]

---

## 11. Scheduling (Recurring Scrapes)

**Applicable?** Yes / No

**If yes:**

**Frequency:** [Daily at 2am / Weekly on Sundays / Monthly on 1st]

**Scheduler:** [cron / Airflow / GitHub Actions / Manual]

**Cron expression:** `[e.g., 0 2 * * * for daily 2am]`

**Change detection:**
- [ ] Compare with previous scrape
- [ ] Alert on significant changes (e.g., price drop >10%)
- [ ] Store delta (changes only) vs full snapshot

---

## 12. Success Criteria

**What defines success?**

- [ ] [X%] of target URLs successfully scraped (Target: 95%+)
- [ ] [X] total items extracted
- [ ] Data passes validation (no null required fields)
- [ ] No IP bans / CAPTCHA challenges
- [ ] Scraping completes within [X hours]

**Quality checks:**
- [ ] Spot-check 10 random items for accuracy
- [ ] Verify prices match website (manual check)
- [ ] Confirm no duplicate entries

---

## 13. Budget and Resources

**Time estimate:** [X hours development + Y hours per run]

**Compute resources:**
- Local machine / Cloud (AWS EC2, GCP, etc.)
- Estimated memory: [X GB]
- Estimated storage: [X GB]

**Costs (if using paid services):**
- Proxy service: $[X]/month
- LLM API calls: $[X] per scrape
- Cloud hosting: $[X]/month

**Total monthly cost:** $[X]

---

## 14. Implementation Checklist

- [ ] Install dependencies (`pip install crawl4ai playwright`)
- [ ] Run Playwright install (`playwright install`)
- [ ] Check robots.txt and ToS
- [ ] Write extraction schema (CSS selectors / Pydantic model)
- [ ] Write scraping script
- [ ] Test on 5-10 sample pages
- [ ] Verify data quality
- [ ] Implement rate limiting
- [ ] Implement error handling and retries
- [ ] Set up logging
- [ ] Run full scrape
- [ ] Clean and validate data
- [ ] Store results
- [ ] Set up scheduling (if recurring)
- [ ] Document for future maintenance

---

## 15. Maintenance Plan

**How often to review?**
- [ ] Weekly: Check for site structure changes
- [ ] Monthly: Review scraping performance (success rate, errors)
- [ ] Quarterly: Update selectors if site redesigned

**What to monitor:**
- Scraping success rate (should be >95%)
- Extraction accuracy (spot-check samples)
- Site changes (subscribe to site changelog if available)

**Contact for issues:** [Your email / team Slack channel]
