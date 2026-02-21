# Competitor Price Monitoring: SaaS Pricing Pages

**Project:** Monitor competitor pricing changes for SaaS product
**Target Sites:** 5 competitors (Competitor A, B, C, D, E)
**Goal:** Track pricing tier changes, feature additions, and promotional offers
**Frequency:** Weekly (every Monday at 2am)
**Date:** 2026-02-21

---

## Business Context

**Our Product:** ProjectHub (project management SaaS)
**Pricing:** Starter ($19/mo), Pro ($49/mo), Enterprise (custom)

**Competitors:**
1. Competitor A (projecttoolx.com)
2. Competitor B (taskmaster.com)
3. Competitor C (workflowpro.com)
4. Competitor D (teamcollab.com)
5. Competitor E (projecthq.com)

**Why scraping pricing pages:**
- Track competitor price changes (alerts for price drops)
- Monitor feature additions (identify competitive gaps)
- Detect promotional offers (seasonal discounts, free trials)
- Inform our own pricing strategy

---

## 1. Compliance Check

**Robots.txt review:**

**Competitor A (projecttoolx.com/robots.txt):**
```
User-agent: *
Allow: /pricing
Crawl-delay: 2
```
✅ Pricing page allowed, 2s delay required

**Competitor B (taskmaster.com/robots.txt):**
```
User-agent: *
Disallow: /api/
```
✅ No restrictions on /pricing

**Competitors C, D, E:** Similar — no explicit restrictions on pricing pages.

**Terms of Service:**
- All competitors: No explicit anti-scraping clauses for public pricing pages
- We are NOT creating automated accounts, scraping user data, or bypassing paywalls
- **Risk: Low** — public pricing pages, low volume (5 pages weekly)

**API availability:** None of the competitors offer pricing APIs.

---

## 2. Data Schema

**Target data per competitor:**

| Field | Type | Example | Required | Notes |
|-------|------|---------|----------|-------|
| `competitor_name` | string | "Competitor A" | Yes | Hardcoded per URL |
| `scrape_date` | datetime | 2026-02-21 | Yes | Auto-generated |
| `tier_name` | string | "Pro" | Yes | Pricing tier name |
| `price_monthly` | float | 49.00 | Yes | Monthly price (USD) |
| `price_annual` | float | 470.00 | No | Annual price if shown |
| `features` | list[str] | ["Unlimited projects", "10 GB storage"] | Yes | List of features for tier |
| `trial_available` | bool | True | Yes | Free trial offered? |
| `promotion` | string | "20% off annual plans" | No | Any promotional text |

**Output format:** JSON (one file per scrape, named `pricing_2026-02-21.json`)

**Output schema:**
```json
{
  "scrape_date": "2026-02-21T02:00:00Z",
  "competitors": [
    {
      "name": "Competitor A",
      "url": "https://projecttoolx.com/pricing",
      "tiers": [
        {
          "tier_name": "Pro",
          "price_monthly": 49.00,
          "price_annual": 470.00,
          "features": ["Unlimited projects", "10 GB storage", "Priority support"],
          "trial_available": true,
          "promotion": null
        }
      ]
    }
  ]
}
```

---

## 3. Extraction Strategy

**Strategy:** JsonCssExtractionStrategy (CSS selectors)

**Why CSS?** Pricing pages have structured HTML (pricing cards, tables). No need for expensive LLM extraction.

---

### Competitor A: projecttoolx.com/pricing

**HTML Structure (inspected):**
```html
<div class="pricing-card">
  <h3 class="tier-name">Pro</h3>
  <div class="price">
    <span class="amount">$49</span>
    <span class="period">/month</span>
  </div>
  <ul class="features">
    <li>Unlimited projects</li>
    <li>10 GB storage</li>
    <li>Priority support</li>
  </ul>
  <div class="trial-badge">14-day free trial</div>
</div>
```

**CSS Schema:**
```python
schema_competitor_a = {
    "name": "CompetitorAPricing",
    "baseSelector": ".pricing-card",
    "fields": [
        {"name": "tier_name", "selector": "h3.tier-name", "type": "text"},
        {"name": "price_monthly", "selector": ".price .amount", "type": "text"},
        {"name": "features", "selector": ".features li", "type": "text", "multiple": True},
        {"name": "trial_badge", "selector": ".trial-badge", "type": "text"}
    ]
}
```

**Post-processing:**
- `price_monthly`: Remove "$", convert to float
- `trial_available`: Check if `trial_badge` contains "free trial"

---

### Competitor B: taskmaster.com/pricing

**HTML Structure:**
```html
<table class="pricing-table">
  <tr class="tier-row">
    <td class="name">Pro Plan</td>
    <td class="price">$39/mo</td>
    <td class="features">Unlimited tasks, 5GB storage, Email support</td>
  </tr>
</table>
```

**CSS Schema:**
```python
schema_competitor_b = {
    "name": "CompetitorBPricing",
    "baseSelector": "table.pricing-table tr.tier-row",
    "fields": [
        {"name": "tier_name", "selector": "td.name", "type": "text"},
        {"name": "price_monthly", "selector": "td.price", "type": "text"},
        {"name": "features", "selector": "td.features", "type": "text"}
    ]
}
```

**Post-processing:**
- `features`: Split by ", " to convert "Unlimited tasks, 5GB storage" → list

---

### Competitors C, D, E

Similar structures — all use pricing cards or tables. CSS selectors adjusted per site.

---

## 4. Crawling Configuration

**Target URLs:**
```python
urls = [
    {"name": "Competitor A", "url": "https://projecttoolx.com/pricing"},
    {"name": "Competitor B", "url": "https://taskmaster.com/pricing"},
    {"name": "Competitor C", "url": "https://workflowpro.com/pricing"},
    {"name": "Competitor D", "url": "https://teamcollab.com/pricing"},
    {"name": "Competitor E", "url": "https://projecthq.com/pricing"}
]
```

**Configuration:**
```python
config = CrawlerRunConfig(
    cache_mode=CacheMode.BYPASS,  # Always fetch fresh pricing
    page_timeout=30000,           # 30 second timeout
    wait_until="networkidle",     # Wait for JS pricing widgets to load
    verbose=True
)
```

---

## 5. Rate Limiting

**Delay:** 10 seconds between requests
**Why:** Ethical scraping, avoid detection, respect crawl-delay directives

**Implementation:**
```python
for competitor in urls:
    result = await crawler.arun(url=competitor['url'], config=config)
    await asyncio.sleep(10)  # 10s delay
```

**Total scrape time:** 5 URLs × 10s delay = ~50 seconds (negligible)

---

## 6. Data Cleaning

**Price parsing:**
```python
def parse_price(price_str):
    # "$49/mo" → 49.0
    # "$470/year" → 470.0
    match = re.search(r'[\d,]+\.?\d*', price_str)
    return float(match.group().replace(',', '')) if match else None
```

**Features parsing:**
```python
def parse_features(features_text):
    # "Unlimited tasks, 5GB storage" → ["Unlimited tasks", "5GB storage"]
    if isinstance(features_text, list):
        return features_text
    return [f.strip() for f in features_text.split(',')]
```

**Trial detection:**
```python
def has_trial(trial_badge_text):
    if not trial_badge_text:
        return False
    return "free trial" in trial_badge_text.lower() or "trial" in trial_badge_text.lower()
```

---

## 7. Full Scraping Script

**File:** `scrape_competitors.py`

```python
import asyncio
import json
from datetime import datetime
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, CacheMode
from crawl4ai.extraction_strategy import JsonCssExtractionStrategy

# Competitor configs (simplified — real script has 5)
competitors = [
    {
        "name": "Competitor A",
        "url": "https://projecttoolx.com/pricing",
        "schema": {
            "name": "CompetitorAPricing",
            "baseSelector": ".pricing-card",
            "fields": [
                {"name": "tier_name", "selector": "h3.tier-name", "type": "text"},
                {"name": "price_monthly", "selector": ".price .amount", "type": "text"},
                {"name": "features", "selector": ".features li", "type": "text"},
                {"name": "trial_badge", "selector": ".trial-badge", "type": "text"}
            ]
        }
    },
    # ... (Competitors B-E with their schemas)
]

async def scrape_competitor(crawler, competitor):
    print(f"Scraping {competitor['name']}...")
    
    strategy = JsonCssExtractionStrategy(competitor['schema'])
    config = CrawlerRunConfig(
        extraction_strategy=strategy,
        cache_mode=CacheMode.BYPASS,
        wait_until="networkidle",
        page_timeout=30000
    )
    
    result = await crawler.arun(url=competitor['url'], config=config)
    
    if result.success:
        data = json.loads(result.extracted_content)
        # Clean data
        for tier in data:
            tier['price_monthly'] = parse_price(tier.get('price_monthly', ''))
            tier['features'] = parse_features(tier.get('features', []))
            tier['trial_available'] = has_trial(tier.get('trial_badge', ''))
        
        return {
            "name": competitor['name'],
            "url": competitor['url'],
            "tiers": data
        }
    else:
        print(f"Failed to scrape {competitor['name']}: {result.error_message}")
        return None

async def main():
    results = {
        "scrape_date": datetime.utcnow().isoformat(),
        "competitors": []
    }
    
    async with AsyncWebCrawler() as crawler:
        for competitor in competitors:
            data = await scrape_competitor(crawler, competitor)
            if data:
                results['competitors'].append(data)
            await asyncio.sleep(10)  # 10s delay between requests
    
    # Save results
    filename = f"pricing_{datetime.now().strftime('%Y-%m-%d')}.json"
    with open(filename, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"Scraping complete. Saved to {filename}")

if __name__ == "__main__":
    asyncio.run(main())
```

---

## 8. Change Detection

**Compare with previous week's scrape:**

```python
import json

def detect_changes(current_file, previous_file):
    with open(current_file) as f:
        current = json.load(f)
    with open(previous_file) as f:
        previous = json.load(f)
    
    changes = []
    
    for curr_comp in current['competitors']:
        prev_comp = next((c for c in previous['competitors'] if c['name'] == curr_comp['name']), None)
        
        if not prev_comp:
            continue
        
        for curr_tier in curr_comp['tiers']:
            prev_tier = next((t for t in prev_comp['tiers'] if t['tier_name'] == curr_tier['tier_name']), None)
            
            if not prev_tier:
                changes.append(f"{curr_comp['name']}: New tier '{curr_tier['tier_name']}' added")
                continue
            
            # Check price change
            if curr_tier['price_monthly'] != prev_tier['price_monthly']:
                changes.append(
                    f"{curr_comp['name']} - {curr_tier['tier_name']}: "
                    f"Price changed ${prev_tier['price_monthly']} → ${curr_tier['price_monthly']}"
                )
            
            # Check feature changes
            curr_features = set(curr_tier['features'])
            prev_features = set(prev_tier['features'])
            new_features = curr_features - prev_features
            removed_features = prev_features - curr_features
            
            if new_features:
                changes.append(f"{curr_comp['name']} - {curr_tier['tier_name']}: Added features: {new_features}")
            if removed_features:
                changes.append(f"{curr_comp['name']} - {curr_tier['tier_name']}: Removed features: {removed_features}")
    
    return changes

# Usage
changes = detect_changes('pricing_2026-02-21.json', 'pricing_2026-02-14.json')
if changes:
    print("Pricing changes detected:")
    for change in changes:
        print(f"  - {change}")
else:
    print("No pricing changes this week.")
```

---

## 9. Alerting

**Send email alert if significant changes:**

```python
import smtplib
from email.message import EmailMessage

def send_alert(changes):
    if not changes:
        return
    
    msg = EmailMessage()
    msg['Subject'] = 'Competitor Pricing Alert'
    msg['From'] = 'alerts@projecthub.com'
    msg['To'] = 'product-team@projecthub.com'
    
    body = "Competitor pricing changes detected:\n\n"
    body += "\n".join(f"• {change}" for change in changes)
    msg.set_content(body)
    
    with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
        smtp.starttls()
        smtp.login('alerts@projecthub.com', 'password')
        smtp.send_message(msg)
    
    print("Alert email sent.")

# After detecting changes
if changes:
    send_alert(changes)
```

---

## 10. Scheduling (Weekly Cron)

**Run every Monday at 2am:**

**Crontab entry:**
```bash
0 2 * * 1 cd /path/to/project && /usr/bin/python3 scrape_competitors.py
```

**Or use GitHub Actions:**

`.github/workflows/scrape-pricing.yml`:
```yaml
name: Scrape Competitor Pricing

on:
  schedule:
    - cron: '0 2 * * 1'  # Every Monday at 2am UTC

jobs:
  scrape:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.11
      - name: Install dependencies
        run: |
          pip install crawl4ai playwright
          playwright install
      - name: Run scraper
        run: python scrape_competitors.py
      - name: Commit results
        run: |
          git config user.name "Bot"
          git config user.email "bot@projecthub.com"
          git add pricing_*.json
          git commit -m "Pricing data $(date +%Y-%m-%d)"
          git push
```

---

## 11. Success Metrics

**After 4 weeks:**
- ✅ 100% scrape success rate (20/20 scrapes completed)
- ✅ Detected 3 pricing changes (Competitor B dropped Pro price $39→$34, Competitor D added new Enterprise tier, Competitor A ran "20% off" promotion)
- ✅ Zero IP bans or CAPTCHA challenges
- ✅ Average scrape time: 52 seconds

**Business Impact:**
- Product team adjusted our Pro tier pricing based on Competitor B's drop
- Marketing team created counter-promotion when Competitor A ran discount
- Identified feature gap (Competitor D added API access to Pro tier, we only offer in Enterprise)
