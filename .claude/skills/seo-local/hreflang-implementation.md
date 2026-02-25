# Hreflang Implementation (Detailed)

## When to Use Hreflang

**Use hreflang if:**

- You have multiple language versions of same content
- You serve different countries with localized content
- You have country-specific TLDs (.com, .com.br, .co.uk)

**Don't use if:**

- Single language, single country site
- Content is not translated (hreflang is for equivalent pages)

---

## Hreflang Syntax

**Format:**

```html
<link rel="alternate" hreflang="[language]-[region]" href="[URL]" />
```

**Language codes:** ISO 639-1 (en, pt, es, fr, de)
**Region codes:** ISO 3166-1 Alpha 2 (US, BR, GB, MX)

**Examples:**

- `en-US` = English, United States
- `en-GB` = English, United Kingdom
- `pt-BR` = Portuguese, Brazil
- `pt-PT` = Portuguese, Portugal
- `es-MX` = Spanish, Mexico
- `es-ES` = Spanish, Spain

**Language-only (no region):**

- `en` = English (any region)
- `pt` = Portuguese (any region)

**Use language-only when content is not region-specific.**

---

## Implementation Methods

### 1. HTML `<link>` Tags (Recommended)

Add to `<head>` section of each page:

```html
<link rel="alternate" hreflang="en-US" href="https://example.com/en/page" />
<link rel="alternate" hreflang="pt-BR" href="https://example.com/pt-br/page" />
<link rel="alternate" hreflang="es-MX" href="https://example.com/es/page" />
<link rel="alternate" hreflang="x-default" href="https://example.com/" />
```

**Rules:**

- Every page must reference itself + all language versions
- Must be bidirectional (EN page links to PT-BR, PT-BR links back)
- Include `x-default` for fallback (users with unmatched language)

---

### 2. XML Sitemap (Alternative)

Add hreflang to sitemap instead of HTML:

```xml
<url>
  <loc>https://example.com/en/page</loc>
  <xhtml:link
    rel="alternate"
    hreflang="pt-BR"
    href="https://example.com/pt-br/page" />
  <xhtml:link
    rel="alternate"
    hreflang="en-US"
    href="https://example.com/en/page" />
  <xhtml:link
    rel="alternate"
    hreflang="x-default"
    href="https://example.com/" />
</url>
```

**Use when:** Large site with 1000+ pages (sitemap is easier to maintain than HTML tags).

---

### 3. HTTP Headers (Rare)

For non-HTML files (PDFs, etc.):

```
Link: <https://example.com/en/file.pdf>; rel="alternate"; hreflang="en",
      <https://example.com/pt-br/file.pdf>; rel="alternate"; hreflang="pt-BR"
```

---

## Common Hreflang Mistakes

1. **Non-reciprocal links:** EN page links to PT-BR, but PT-BR doesn't link back to EN.
   - **Fix:** Ensure all pages reference all versions (including themselves).

2. **Wrong language codes:** Using `en-UK` instead of `en-GB`, or `pt` instead of `pt-BR`.
   - **Fix:** Use correct ISO codes (https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes).

3. **Missing self-referential tag:** EN page must include `hreflang="en-US" href="[itself]"`.
   - **Fix:** Always include self-reference.

4. **Forgetting x-default:** No fallback for unmatched languages.
   - **Fix:** Add `x-default` pointing to default language version.

5. **Relative URLs:** `hreflang="/pt-br/page"` instead of `https://example.com/pt-br/page`.
   - **Fix:** Always use absolute URLs.

---

## Validation

**Google Search Console:**

1. Navigate to "International Targeting" -> "Language"
2. Check for hreflang errors
3. Fix errors and request reindex

**Third-party tools:**

- **Merkle Hreflang Validator** (https://technicalseo.com/tools/hreflang/)
- **Aleyda's Hreflang Checker** (https://www.aleydasolis.com/english/international-seo-tools/hreflang-tags-generator/)
