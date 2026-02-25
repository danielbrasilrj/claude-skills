# Brazilian Local SEO Specifics

## 1. Google Meu Negocio (GMN)

Google Business Profile in Brazil is called "Google Meu Negocio."

**Differences:**

- Interface is in Portuguese (but backend is identical)
- Localization: Use `pt-BR` hreflang and schema
- Phone format: +55 (country code) + area code + number
  - Example: +55 11 98765-4321 (Sao Paulo mobile)

---

## 2. Local Directories (Brazil)

**Top Brazilian directories:**

1. **Apontador** (https://apontador.com.br) -- Brazilian Yelp
2. **Tripadvisor Brasil** (for restaurants, tourism)
3. **Reclame Aqui** (reviews + complaints platform)
4. **OLX** (classifieds, but has business listings)
5. **Paginas Amarelas** (Brazilian Yellow Pages)

**Citation format:**

```
Name: [Business Name]
Address: Rua [Street], [Number], [Bairro], [City] - [State], [CEP]
Phone: +55 [Area Code] [Number]
```

**Example:**

```
Name: Consultorio Odontologico Sorriso
Address: Rua Augusta, 1234, Consolacao, Sao Paulo - SP, 01304-001
Phone: +55 11 3456-7890
```

---

## 3. Hreflang for Brazilian Portuguese

If you have multilingual site (English + Portuguese), implement hreflang.

**Example:**

```html
<link rel="alternate" hreflang="en" href="https://example.com/en/" />
<link rel="alternate" hreflang="pt-BR" href="https://example.com/pt-br/" />
<link rel="alternate" hreflang="x-default" href="https://example.com/" />
```

**Rules:**

- Use `pt-BR` (not just `pt` -- Portugal Portuguese is `pt-PT`)
- Tags must be bidirectional (EN page links to PT-BR, PT-BR links back to EN)
- `x-default` = fallback for unmatched languages

**Validation:** Google Search Console -> International Targeting -> Hreflang tags report

---

## 4. Local Keywords (Brazilian Search Behavior)

**Near-me queries in Portuguese:**

- "perto de mim" (near me)
- "proximo" (nearby)
- "em [cidade]" (in [city])

**Examples:**

- "dentista perto de mim"
- "pizzaria proximo"
- "advogado em Sao Paulo"

**Long-tail geo-modifiers:**

- "[Service] em [Bairro]" (neighborhood-level)
  - "pet shop em Pinheiros"
  - "academia em Copacabana"

**Optimize for neighborhood names, not just city.** Sao Paulo has 96 neighborhoods; "dentista em Pinheiros" is more specific than "dentista em Sao Paulo."

---

## 5. Review Platforms (Brazil-Specific)

**Reclame Aqui** is huge in Brazil (45M monthly users). It's primarily a complaint platform, but affects reputation.

**Strategy:**

1. Claim your company profile (https://empresas.reclameaqui.com.br)
2. Respond to ALL complaints within 24 hours
3. Resolve issues to get "RA Resolvido" badge
4. Monitor reputation score (0-10 scale)

**Other platforms:**

- **TripAdvisor** (restaurants, tourism)
- **iFood** (food delivery reviews)
- **Google Meu Negocio** (still #1 for most businesses)
