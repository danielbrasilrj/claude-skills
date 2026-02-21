# Performance Audit Example: E-Commerce Product Page

## Executive Summary

**Audit Date:** 2026-02-21  
**Auditor:** Performance Team  
**Application:** ShopFast E-Commerce  
**Environment:** Production  
**URL:** https://shopfast.example.com/products/wireless-headphones

**Overall Performance Score:** 42/100

**Status:** 🔴 Critical - Requires Immediate Attention

**Key Findings:**
- LCP of 5.2s caused by unoptimized hero image (target: ≤ 2.5s)
- Bundle size of 847 KB exceeds budget by 447 KB
- 15 unnecessary re-renders on product image carousel
- No HTTP caching strategy implemented

**Estimated Impact:**
- Load time improvement: 60% (5.2s → 2.1s)
- Bundle size reduction: 447 KB (847 KB → 400 KB)
- User experience impact: High (expected 15% increase in conversion rate)

---

## Performance Metrics Baseline

### Web Performance (Core Web Vitals)

**Measurement Tool:** Lighthouse CLI + WebPageTest  
**Test Location:** New York, USA  
**Network:** 4G (throttled)  
**Device:** Moto G4 (mobile)

| Metric | Current | Target | Status | Notes |
|--------|---------|--------|--------|-------|
| **LCP** (Largest Contentful Paint) | 5.2s | ≤ 2.5s | 🔴 | Hero image (2400×1800 JPEG, 1.2 MB) |
| **INP** (Interaction to Next Paint) | 340ms | ≤ 200ms | 🟡 | Image carousel interactions |
| **CLS** (Cumulative Layout Shift) | 0.28 | ≤ 0.1 | 🔴 | Product reviews load without reserved space |
| **FCP** (First Contentful Paint) | 2.1s | ≤ 1.8s | 🟡 | Render-blocking CSS |
| **TTFB** (Time to First Byte) | 890ms | ≤ 600ms | 🔴 | No CDN, slow server response |
| **TBT** (Total Blocking Time) | 820ms | ≤ 200ms | 🔴 | Heavy JavaScript execution |

**Lighthouse Score Breakdown:**
- Performance: 42/100 🔴
- Accessibility: 87/100 🟢
- Best Practices: 79/100 🟡
- SEO: 92/100 🟢

### Bundle Size Analysis

**Total Bundle Size:** 847 KB (gzipped: 312 KB)  
**Budget:** 400 KB  
**Over Budget:** +447 KB (112% over budget)

| File | Size | Gzipped | % of Total | Notes |
|------|------|---------|------------|-------|
| `main.js` | 524 KB | 187 KB | 62% | Contains entire Lodash library |
| `vendor.js` | 298 KB | 112 KB | 35% | Moment.js (288 KB) for date formatting |
| `styles.css` | 25 KB | 13 KB | 3% | Unused Tailwind classes |
| **Total** | 847 KB | 312 KB | 100% | |

**Largest Dependencies:**
1. `moment` - 288 KB - Used only for "2 days ago" formatting
2. `lodash` - 544 KB - Only 3 functions used (debounce, throttle, cloneDeep)
3. `react-slick` - 47 KB - Product image carousel (includes jQuery dependency)

---

## Detailed Findings

### 🔴 Critical Issues

#### Issue #1: Unoptimized Hero Image Causing Slow LCP

**Severity:** Critical  
**Impact:** High  
**Metric Affected:** LCP  
**Current Value:** 5.2s  
**Expected Value:** ≤ 2.5s

**Description:**
The largest contentful paint element is the product hero image, which is a 2400×1800 JPEG weighing 1.2 MB. This image is loaded at full resolution regardless of device size, and no modern image formats (WebP, AVIF) are provided. The image is also not preloaded, causing it to start loading only after CSS and JavaScript are parsed.

**Evidence:**
```
Network Waterfall:
├─ HTML (index.html) - 0-250ms
├─ CSS (styles.css) - 250-600ms
├─ JS (main.js) - 250-1200ms
└─ Image (hero.jpg) - 1200-5200ms ← LCP element
```

**Reproduction Steps:**
1. Navigate to https://shopfast.example.com/products/wireless-headphones
2. Open Chrome DevTools → Performance panel
3. Record page load
4. Observe LCP element is hero image at 5.2s

**Root Cause:**
- Image not optimized for web (exported at print quality 100%)
- No responsive images (same 1.2 MB image served to mobile and desktop)
- No modern formats (WebP/AVIF could reduce size by 60%)
- No preload hint to prioritize image loading
- Image loaded via `<img>` without fetchpriority="high"

**Recommended Solution:**

1. Generate responsive images in modern formats:
```bash
# Install sharp for image optimization
npm install sharp

# Generate responsive images
const sharp = require('sharp');

// AVIF (best compression)
await sharp('hero-original.jpg')
  .resize(800, 600)
  .avif({ quality: 75 })
  .toFile('hero-800.avif');

await sharp('hero-original.jpg')
  .resize(1200, 900)
  .avif({ quality: 75 })
  .toFile('hero-1200.avif');

// WebP (fallback)
await sharp('hero-original.jpg')
  .resize(800, 600)
  .webp({ quality: 85 })
  .toFile('hero-800.webp');

await sharp('hero-original.jpg')
  .resize(1200, 900)
  .webp({ quality: 85 })
  .toFile('hero-1200.webp');

// JPEG (final fallback)
await sharp('hero-original.jpg')
  .resize(1200, 900)
  .jpeg({ quality: 85, progressive: true })
  .toFile('hero-1200.jpg');
```

2. Update HTML to use responsive images with preload:

**Code Example:**
```html
<!-- Before (problematic code) -->
<img src="/images/products/hero.jpg" alt="Wireless Headphones">

<!-- After (optimized code) -->
<head>
  <!-- Preload LCP image -->
  <link rel="preload" 
        as="image" 
        href="/images/products/hero-800.avif"
        imagesrcset="/images/products/hero-800.avif 800w, /images/products/hero-1200.avif 1200w"
        imagesizes="(max-width: 768px) 100vw, 50vw"
        type="image/avif">
</head>

<body>
  <picture>
    <!-- AVIF: 60% smaller than WebP -->
    <source srcset="/images/products/hero-800.avif 800w,
                    /images/products/hero-1200.avif 1200w"
            sizes="(max-width: 768px) 100vw, 50vw"
            type="image/avif">
    
    <!-- WebP: Fallback for older browsers -->
    <source srcset="/images/products/hero-800.webp 800w,
                    /images/products/hero-1200.webp 1200w"
            sizes="(max-width: 768px) 100vw, 50vw"
            type="image/webp">
    
    <!-- JPEG: Final fallback -->
    <img src="/images/products/hero-1200.jpg"
         srcset="/images/products/hero-800.jpg 800w,
                 /images/products/hero-1200.jpg 1200w"
         sizes="(max-width: 768px) 100vw, 50vw"
         alt="Wireless Headphones - Black over-ear headphones with noise cancellation"
         width="1200"
         height="900"
         loading="eager"
         fetchpriority="high">
  </picture>
</body>
```

**Size Comparison:**
```
Before: hero.jpg - 1,200 KB
After:  hero-800.avif - 45 KB (mobile)
        hero-1200.avif - 95 KB (desktop)

Savings: -92% on mobile, -92% on desktop
```

**Estimated Impact:**
- LCP improvement: 5.2s → 1.8s (65% faster)
- Transfer size reduction: -1,105 KB on mobile
- Performance score: +25 points
- User experience: Users see product 3.4s sooner

**Priority:** P0 - Immediate (blocks launch)  
**Effort:** Low (2-3 hours: image generation + HTML update)

---

#### Issue #2: Massive JavaScript Bundle with Unused Dependencies

**Severity:** Critical  
**Impact:** High  
**Metric Affected:** TBT, FCP, Bundle Size  
**Current Value:** 847 KB bundle (312 KB gzipped)  
**Expected Value:** ≤ 400 KB

**Description:**
The main JavaScript bundle includes the entire Lodash library (544 KB) despite using only 3 functions, and Moment.js (288 KB) for basic date formatting. This causes 820ms of total blocking time during page load as the browser parses and executes unnecessary code.

**Evidence:**
```bash
# Bundle analysis output
npx source-map-explorer dist/main.js

Top modules by size:
1. lodash - 544 KB (64.2%)
   └─ Used functions: debounce, throttle, cloneDeep
2. moment - 288 KB (34.0%)
   └─ Used for: "2 days ago" relative time
3. Application code - 15 KB (1.8%)
```

**Root Cause:**
- CommonJS imports prevent tree shaking: `const _ = require('lodash')`
- Moment.js includes all locales (200 KB of unused locale data)
- No code splitting (entire app in single bundle)

**Recommended Solution:**

1. Replace Lodash with tree-shakable imports or native alternatives:

```javascript
// Before (problematic code)
const _ = require('lodash');

function handleSearch(query) {
  const debouncedSearch = _.debounce(() => {
    fetch(`/api/search?q=${query}`);
  }, 300);
  return debouncedSearch();
}

const copy = _.cloneDeep(product);

// After (optimized code)
// Option 1: Use lodash-es with tree shaking
import debounce from 'lodash-es/debounce';

function handleSearch(query) {
  const debouncedSearch = debounce(() => {
    fetch(`/api/search?q=${query}`);
  }, 300);
  return debouncedSearch();
}

// Option 2: Native implementation
function debounce(fn, delay) {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}

// For cloneDeep: Use structuredClone (native, no library needed)
const copy = structuredClone(product);

// Savings: 544 KB → 0 KB (lodash-es/debounce is only 2 KB)
```

2. Replace Moment.js with date-fns or native Intl:

```javascript
// Before (problematic code)
import moment from 'moment';

const relativeTime = moment(product.createdAt).fromNow();
// Output: "2 days ago"

// After (optimized code)
// Option 1: date-fns (78 KB, tree-shakable)
import { formatDistanceToNow } from 'date-fns';

const relativeTime = formatDistanceToNow(new Date(product.createdAt), { 
  addSuffix: true 
});

// Option 2: Native Intl.RelativeTimeFormat (0 KB, built into browser)
const rtf = new Intl.RelativeTimeFormat('en', { numeric: 'auto' });
const daysDiff = Math.round((new Date(product.createdAt) - new Date()) / (1000 * 60 * 60 * 24));
const relativeTime = rtf.format(daysDiff, 'day');

// Savings: 288 KB → 0 KB (native) or 78 KB (date-fns)
```

3. Implement code splitting for routes:

```javascript
// Before (problematic code)
import ProductPage from './pages/ProductPage';
import CartPage from './pages/CartPage';
import CheckoutPage from './pages/CheckoutPage';

function App() {
  return (
    <Routes>
      <Route path="/product/:id" element={<ProductPage />} />
      <Route path="/cart" element={<CartPage />} />
      <Route path="/checkout" element={<CheckoutPage />} />
    </Routes>
  );
}

// After (optimized code)
import { lazy, Suspense } from 'react';

const ProductPage = lazy(() => import('./pages/ProductPage'));
const CartPage = lazy(() => import('./pages/CartPage'));
const CheckoutPage = lazy(() => import('./pages/CheckoutPage'));

function App() {
  return (
    <Suspense fallback={<PageLoader />}>
      <Routes>
        <Route path="/product/:id" element={<ProductPage />} />
        <Route path="/cart" element={<CartPage />} />
        <Route path="/checkout" element={<CheckoutPage />} />
      </Routes>
    </Suspense>
  );
}

// Savings: Main bundle reduced by ~150 KB
```

**Bundle Size After Optimizations:**
```
Before: 847 KB (312 KB gzipped)
After:  245 KB (89 KB gzipped)

Savings: -602 KB (-71%)
```

**Estimated Impact:**
- Bundle size reduction: -602 KB (-71%)
- TBT reduction: 820ms → 180ms (78% faster)
- FCP improvement: 2.1s → 1.2s
- Performance score: +30 points

**Priority:** P0 - Immediate  
**Effort:** Medium (3-5 days: dependency replacement + testing)

---

#### Issue #3: Layout Shifts from Product Reviews Section

**Severity:** Critical  
**Impact:** High  
**Metric Affected:** CLS  
**Current Value:** 0.28  
**Expected Value:** ≤ 0.1

**Description:**
The product reviews section loads asynchronously via API call after page render, causing a 300px layout shift as the content is injected below the product details. This affects CLS significantly and creates a jarring user experience.

**Evidence:**
```
Layout Shift Timeline:
├─ 0ms: Page renders with product details
├─ 1200ms: Reviews API response received
└─ 1250ms: Reviews injected → 300px layout shift
            Impact: 0.28 CLS score
```

**Root Cause:**
- No skeleton loader or reserved space for reviews section
- Reviews container has no min-height set
- Content injected using `innerHTML` without transition

**Recommended Solution:**

1. Reserve space with skeleton loader:

```css
/* Add to styles.css */
.reviews-skeleton {
  min-height: 400px; /* Average height of 3 reviews */
  background: linear-gradient(
    90deg,
    #f0f0f0 25%,
    #e0e0e0 50%,
    #f0f0f0 75%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 8px;
}

@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}
```

```jsx
// Before (problematic code)
function ProductPage() {
  const [reviews, setReviews] = useState([]);
  
  useEffect(() => {
    fetch('/api/reviews').then(r => r.json()).then(setReviews);
  }, []);
  
  return (
    <div>
      <ProductDetails />
      {reviews.length > 0 && (
        <div className="reviews">
          {reviews.map(r => <Review key={r.id} {...r} />)}
        </div>
      )}
    </div>
  );
}

// After (optimized code)
function ProductPage() {
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    fetch('/api/reviews')
      .then(r => r.json())
      .then(data => {
        setReviews(data);
        setLoading(false);
      });
  }, []);
  
  return (
    <div>
      <ProductDetails />
      
      {/* Reserve space even while loading */}
      <div className="reviews-container" style={{ minHeight: '400px' }}>
        {loading ? (
          <div className="reviews-skeleton" />
        ) : (
          <div className="reviews">
            {reviews.map(r => <Review key={r.id} {...r} />)}
          </div>
        )}
      </div>
    </div>
  );
}
```

2. Even better: Server-side render reviews:

```jsx
// app/products/[id]/page.tsx (Next.js App Router)
export default async function ProductPage({ params }) {
  // Fetch reviews on server (no layout shift!)
  const reviews = await fetchReviews(params.id);
  
  return (
    <div>
      <ProductDetails />
      <div className="reviews">
        {reviews.map(r => <Review key={r.id} {...r} />)}
      </div>
    </div>
  );
}
```

**Estimated Impact:**
- CLS improvement: 0.28 → 0.03 (89% better)
- Performance score: +15 points
- User experience: No unexpected jumps while reading

**Priority:** P0 - Immediate  
**Effort:** Low (4 hours: skeleton loader + testing)

---

### 🟡 Medium Priority Issues

#### Issue #4: Carousel Re-renders on Every Interaction

**Severity:** Medium  
**Impact:** Medium  
**Metric Affected:** INP  
**Current Value:** 340ms  
**Expected Value:** ≤ 200ms

**Description:**
The product image carousel re-renders the entire component (15 images) on every click, including images not visible in the viewport. This causes 340ms interaction latency when users click next/prev buttons.

**Evidence:**
```javascript
// React DevTools Profiler output
Component: ImageCarousel
Re-renders: 15 components
Render duration: 285ms
Cause: Parent state change triggers all children
```

**Root Cause:**
- No memoization of carousel items
- State stored in parent component causes all children to re-render
- react-slick library not optimized for large image sets

**Recommended Solution:**

```jsx
// Before (problematic code)
function ImageCarousel({ images }) {
  const [currentIndex, setCurrentIndex] = useState(0);
  
  return (
    <div>
      {images.map((img, idx) => (
        <img 
          key={idx} 
          src={img} 
          className={idx === currentIndex ? 'active' : ''}
        />
      ))}
      <button onClick={() => setCurrentIndex(i => i + 1)}>Next</button>
    </div>
  );
}

// After (optimized code)
import { memo, useCallback } from 'react';

const CarouselImage = memo(({ src, isActive }) => (
  <img 
    src={src} 
    className={isActive ? 'active' : ''}
    loading="lazy"
  />
));

function ImageCarousel({ images }) {
  const [currentIndex, setCurrentIndex] = useState(0);
  
  const handleNext = useCallback(() => {
    setCurrentIndex(i => (i + 1) % images.length);
  }, [images.length]);
  
  return (
    <div>
      {/* Only render current + adjacent images */}
      {images.slice(
        Math.max(0, currentIndex - 1),
        Math.min(images.length, currentIndex + 2)
      ).map((img, idx) => (
        <CarouselImage 
          key={img} 
          src={img} 
          isActive={idx === 1}
        />
      ))}
      <button onClick={handleNext}>Next</button>
    </div>
  );
}
```

**Estimated Impact:**
- INP improvement: 340ms → 145ms (57% faster)
- Re-renders reduced: 15 → 3 components
- User experience: Instant carousel navigation

**Priority:** P1 - High  
**Effort:** Low (1 day)

---

### 🟢 Low Priority Issues

#### Issue #5: No HTTP Caching Strategy

**Severity:** Low  
**Impact:** Medium (affects repeat visitors)  
**Metric Affected:** TTFB, LCP (repeat visits)  
**Current Value:** No cache headers  
**Expected Value:** Proper cache-control headers

**Description:**
Static assets (JS, CSS, images) are served without cache-control headers, forcing browsers to revalidate every resource on repeat visits. This wastes bandwidth and slows down returning users.

**Recommended Solution:**

```nginx
# nginx.conf
location /assets/ {
  # Static assets with hashed filenames: cache forever
  add_header Cache-Control "public, max-age=31536000, immutable";
}

location ~* \.(jpg|jpeg|png|gif|svg|webp|avif)$ {
  # Images: cache for 1 year with revalidation
  add_header Cache-Control "public, max-age=31536000, must-revalidate";
}

location / {
  # HTML: revalidate on every request
  add
API Error: Claude's response exceeded the 32000 output token maximum. To configure this behavior, set the CLAUDE_CODE_MAX_OUTPUT_TOKENS environment variable.
I'll continue from where I left off and complete the remaining enrichment files.

---

===FILE: /Users/danielcarmo/Env/Projects/personal/claude_skills/claude_skills/.claude/skills/performance-optimization/examples/web-performance-audit-example.md===
(Continuing from Issue #5...)

```nginx
location / {
  # HTML: revalidate on every request
  add_header Cache-Control "no-cache, must-revalidate";
}
```

**Estimated Impact:**
- Repeat visit load time: -60% (resources loaded from cache)
- Bandwidth savings: ~800 KB per repeat visit
- Server load reduction: -40% for repeat visitors

**Priority:** P2 - Medium  
**Effort:** Low (1 hour: nginx config update)

---

## Implementation Roadmap

### Phase 1: Quick Wins (Week 1)

**Goal:** Achieve 40% performance improvement with minimal effort

**Tasks:**
- [x] Optimize hero image (Issue #1)
  - Owner: Frontend Team
  - Deadline: 2026-02-23
  - Expected impact: LCP 5.2s → 1.8s

- [x] Add skeleton loader for reviews (Issue #3)
  - Owner: Frontend Team
  - Deadline: 2026-02-24
  - Expected impact: CLS 0.28 → 0.03

- [x] Add HTTP caching headers (Issue #5)
  - Owner: DevOps Team
  - Deadline: 2026-02-24
  - Expected impact: Repeat visits 60% faster

**Success Metrics:**
- LCP: 5.2s → 1.8s
- CLS: 0.28 → 0.03
- Performance score: 42 → 70

### Phase 2: High-Impact Optimizations (Weeks 2-3)

**Goal:** Fix critical performance bottlenecks

**Tasks:**
- [ ] Replace Lodash and Moment.js (Issue #2)
  - Owner: Frontend Team
  - Deadline: 2026-03-07
  - Expected impact: Bundle -602 KB

- [ ] Implement code splitting (Issue #2)
  - Owner: Frontend Team
  - Deadline: 2026-03-10
  - Expected impact: Initial bundle -150 KB

- [ ] Optimize carousel re-renders (Issue #4)
  - Owner: Frontend Team
  - Deadline: 2026-03-05
  - Expected impact: INP 340ms → 145ms

**Success Metrics:**
- Performance score: 70 → 90+
- All Core Web Vitals in "Good" range
- Bundle size: 847 KB → 245 KB

### Phase 3: Monitoring & Prevention (Week 4+)

**Goal:** Establish performance monitoring and prevent regressions

**Tasks:**
- [ ] Set up Lighthouse CI
- [ ] Implement performance budgets in CI/CD
- [ ] Add Real User Monitoring (RUM)
- [ ] Document performance best practices

**Success Metrics:**
- Performance regression alerts in place
- Bundle size budget enforced
- Monthly performance reports automated

---

## Testing and Validation Plan

### Pre-Deployment Testing

**Completed:**
- [x] Local testing (Lighthouse score: 89/100)
- [x] Staging environment validation
- [x] Cross-browser testing (Chrome, Safari, Firefox, Edge)
- [x] Mobile device testing (iPhone 13, Samsung Galaxy S21)
- [x] Network throttling tests (Fast 3G, Slow 4G)

**Results:**
```
Environment: Staging
LCP: 1.9s (was 5.2s) ✅
INP: 150ms (was 340ms) ✅
CLS: 0.04 (was 0.28) ✅
Bundle: 258 KB (was 847 KB) ✅
```

### Post-Deployment Monitoring

**Week 1 Results (Real User Monitoring):**
- 75th percentile LCP: 2.1s ✅
- 75th percentile INP: 165ms ✅
- 75th percentile CLS: 0.06 ✅
- Average load time: 2.3s (was 5.8s)
- Bounce rate: 32% (was 45%)
- Conversion rate: +18% improvement

---

## Lessons Learned

**What Worked Well:**
- Image optimization had biggest impact for least effort
- Skeleton loaders completely eliminated layout shifts
- Code splitting was easier than expected with React.lazy()

**Challenges Faced:**
- Replacing Moment.js required updating 15 date formatting instances
- Some team members unfamiliar with modern image formats
- Lighthouse scores varied between local and production (CDN differences)

**Recommendations for Future:**
- Establish performance budgets before starting new features
- Require Lighthouse CI checks on all PRs
- Provide training on modern web performance techniques
- Consider using Next.js for automatic optimizations

---

## Sign-Off

**Audit Completed By:** Sarah Johnson, Performance Engineer  
**Date:** 2026-02-21  
**Reviewed By:** Mike Chen, Tech Lead  
**Approved By:** Emily Rodriguez, Engineering Manager  

**Next Audit Date:** 2026-05-21 (quarterly review)
