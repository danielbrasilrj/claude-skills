# Local Schema Markup

Schema markup is structured data (JSON-LD) that tells Google exactly what your business is, what you do, and where you operate.

## LocalBusiness Schema (Required)

**Base template:**

```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "Green Valley Dental",
  "image": "https://example.com/logo.png",
  "telephone": "+1-512-555-0100",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "123 Main Street",
    "addressLocality": "Austin",
    "addressRegion": "TX",
    "postalCode": "78701",
    "addressCountry": "US"
  },
  "geo": {
    "@type": "GeoCoordinates",
    "latitude": "30.2672",
    "longitude": "-97.7431"
  },
  "url": "https://greenvalleydental.com",
  "openingHoursSpecification": [
    {
      "@type": "OpeningHoursSpecification",
      "dayOfWeek": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
      "opens": "08:00",
      "closes": "17:00"
    }
  ],
  "priceRange": "$$"
}
```

**Specific business types (use instead of generic LocalBusiness):**

- **Dentist**, **Restaurant**, **Store**, **Attorney**, **RealEstateAgent**, **Electrician**, **Plumber**, **HairSalon**, **AutoRepair**

**Example for Dentist:**

```json
{
  "@context": "https://schema.org",
  "@type": "Dentist",
  "name": "Green Valley Dental",
  ...
}
```

**Advanced properties:**

- `priceRange`: "$", "$$", "$$$", "$$$$"
- `paymentAccepted`: "Cash, Credit Card, Insurance"
- `currenciesAccepted`: "USD", "BRL"
- `areaServed`: "Austin, TX" or ["Austin", "Round Rock", "Cedar Park"]

---

## Multi-Location Schema

If you have multiple locations, use **@id** to create unique entities:

```json
{
  "@context": "https://schema.org",
  "@type": "Dentist",
  "@id": "https://example.com/locations/austin",
  "name": "Green Valley Dental - Austin",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "123 Main St",
    "addressLocality": "Austin",
    "addressRegion": "TX",
    "postalCode": "78701"
  }
}
```

**Each location needs:**

- Unique `@id` (URL of location page)
- Unique `name` (include location in name)
- Unique `address`

---

## FAQ Schema (High-Value)

FAQ schema creates rich snippets in search results (expandable Q&A boxes).

**Template:**

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do you accept dental insurance?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, we accept all major dental insurance plans including Aetna, Cigna, Delta Dental, and MetLife. We also offer affordable payment plans for uninsured patients."
      }
    },
    {
      "@type": "Question",
      "name": "Do you offer emergency dental services?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, we provide same-day emergency dental care for toothaches, broken teeth, and dental injuries. Call us at 512-555-0100 for immediate assistance."
      }
    }
  ]
}
```

**Best practices:**

- Add 3-10 FAQs per page
- Answer questions users actually ask (check Google Search Console "queries" for ideas)
- Keep answers under 300 characters for snippet optimization
