# Core Web Vitals Deep Dive

## Overview

Core Web Vitals are three metrics that measure real-world user experience:

| Metric                              | What It Measures    | Good     | Poor    | Weight in Lighthouse |
| ----------------------------------- | ------------------- | -------- | ------- | -------------------- |
| **LCP** (Largest Contentful Paint)  | Loading performance | <= 2.5s  | > 4.0s  | 25%                  |
| **INP** (Interaction to Next Paint) | Responsiveness      | <= 200ms | > 500ms | 25%                  |
| **CLS** (Cumulative Layout Shift)   | Visual stability    | <= 0.1   | > 0.25  | 15%                  |

**Additional metrics:**

- **FCP** (First Contentful Paint): When first content appears (good: <= 1.8s)
- **TTFB** (Time to First Byte): Server response time (good: <= 600ms)
- **TBT** (Total Blocking Time): Main thread blocking time (good: <= 200ms)

---

## LCP (Largest Contentful Paint)

**What counts as LCP element:**

- `<img>` elements
- `<image>` inside `<svg>`
- `<video>` poster images
- Background images loaded via `url()`
- Block-level text elements

**Common causes of slow LCP:**

1. **Slow server response times (TTFB > 600ms)**

   ```bash
   # Measure TTFB
   curl -w "\n\nTime to First Byte: %{time_starttransfer}s\n" -o /dev/null -s https://example.com
   ```

   **Solutions:**
   - Use a CDN (Cloudflare, Vercel Edge, AWS CloudFront)
   - Enable server-side caching (Redis, Memcached)
   - Optimize database queries (see Database Ops skill)
   - Use HTTP/2 or HTTP/3
   - Implement server-side rendering (SSR) or static site generation (SSG)

2. **Render-blocking JavaScript and CSS**

   ```html
   <!-- Bad: Blocks rendering -->
   <script src="analytics.js"></script>
   <link rel="stylesheet" href="styles.css" />

   <!-- Good: Non-blocking -->
   <script src="analytics.js" defer></script>
   <link
     rel="preload"
     href="styles.css"
     as="style"
     onload="this.onload=null;this.rel='stylesheet'"
   />
   <noscript><link rel="stylesheet" href="styles.css" /></noscript>
   ```

3. **Large images without optimization**

   ```html
   <!-- Bad: Large unoptimized image -->
   <img src="hero-4000x3000.jpg" alt="Hero" />

   <!-- Good: Responsive with modern formats -->
   <picture>
     <source srcset="hero-800.avif 800w, hero-1200.avif 1200w" type="image/avif" />
     <source srcset="hero-800.webp 800w, hero-1200.webp 1200w" type="image/webp" />
     <img
       src="hero-1200.jpg"
       srcset="hero-800.jpg 800w, hero-1200.jpg 1200w"
       sizes="(max-width: 768px) 100vw, 50vw"
       alt="Hero"
       loading="eager"
       fetchpriority="high"
     />
   </picture>
   ```

4. **Client-side rendering delays**

   ```jsx
   // Bad: Everything renders client-side
   function App() {
     const [data, setData] = useState(null);
     useEffect(() => {
       fetch('/api/data')
         .then((r) => r.json())
         .then(setData);
     }, []);
     return data ? <Hero data={data} /> : <Spinner />;
   }

   // Good: Server-side render or static generation
   export async function getServerSideProps() {
     const data = await fetchData();
     return { props: { data } };
   }

   export default function App({ data }) {
     return <Hero data={data} />;
   }
   ```

**LCP optimization checklist:**

- [ ] TTFB < 600ms (use CDN, optimize server)
- [ ] LCP resource starts loading within first 2.5s
- [ ] LCP element doesn't require JavaScript to render
- [ ] Critical CSS inlined (< 14KB)
- [ ] Preload LCP image: `<link rel="preload" as="image" href="hero.jpg">`
- [ ] Use modern image formats (WebP, AVIF)
- [ ] Compress images (target < 100KB for hero images)

---

## INP (Interaction to Next Paint)

Replaced FID (First Input Delay) in 2024. Measures responsiveness across ALL interactions.

**What INP measures:**

- Click interactions
- Tap interactions (mobile)
- Keyboard interactions
- Time from user input -> visual feedback

**INP breakdown:**

```
INP = Input delay + Processing time + Presentation delay

Input delay: Time waiting for main thread
Processing time: Event handler execution
Presentation delay: Browser rendering the update
```

**Common causes of high INP:**

1. **Long JavaScript tasks (> 50ms)**

   ```javascript
   // Bad: Blocks main thread for 500ms
   function processLargeDataset(items) {
     return items.map((item) => expensiveOperation(item));
   }

   // Good: Break into chunks with scheduler
   async function processLargeDataset(items) {
     const results = [];
     for (let i = 0; i < items.length; i++) {
       results.push(expensiveOperation(items[i]));

       // Yield to main thread every 50 items
       if (i % 50 === 0) {
         await scheduler.yield(); // or await new Promise(r => setTimeout(r, 0))
       }
     }
     return results;
   }
   ```

2. **Heavy event handlers**

   ```javascript
   // Bad: Expensive operation on every keystroke
   <input
     onChange={(e) => {
       const filtered = largeArray.filter((item) =>
         item.name.toLowerCase().includes(e.target.value.toLowerCase()),
       );
       setResults(filtered);
     }}
   />;

   // Good: Debounce expensive operations
   import { useDebouncedCallback } from 'use-debounce';

   const handleSearch = useDebouncedCallback((value) => {
     const filtered = largeArray.filter((item) =>
       item.name.toLowerCase().includes(value.toLowerCase()),
     );
     setResults(filtered);
   }, 300);

   <input onChange={(e) => handleSearch(e.target.value)} />;
   ```

3. **Layout thrashing**

   ```javascript
   // Bad: Forced synchronous layout (thrashing)
   elements.forEach((el) => {
     const height = el.offsetHeight; // Read (forces layout)
     el.style.height = height * 2 + 'px'; // Write
   });

   // Good: Batch reads then writes
   const heights = elements.map((el) => el.offsetHeight); // Batch reads
   elements.forEach((el, i) => {
     el.style.height = heights[i] * 2 + 'px'; // Batch writes
   });
   ```

4. **Third-party scripts**

   ```html
   <!-- Bad: Blocking third-party script -->
   <script src="https://analytics.example.com/script.js"></script>

   <!-- Good: Load after page is interactive -->
   <script>
     window.addEventListener('load', () => {
       const script = document.createElement('script');
       script.src = 'https://analytics.example.com/script.js';
       document.head.appendChild(script);
     });
   </script>
   ```

**INP optimization checklist:**

- [ ] No JavaScript tasks > 50ms (use Chrome DevTools Performance panel)
- [ ] Debounce/throttle expensive event handlers
- [ ] Use Web Workers for CPU-intensive tasks
- [ ] Code-split non-critical JavaScript
- [ ] Defer third-party scripts
- [ ] Use `content-visibility: auto` for long lists

---

## CLS (Cumulative Layout Shift)

Measures visual stability. Every unexpected layout shift hurts CLS.

**How CLS is calculated:**

```
CLS = sum(Impact Fraction x Distance Fraction)

Impact Fraction: % of viewport affected
Distance Fraction: Distance moved / viewport height
```

**Common causes of layout shifts:**

1. **Images without dimensions**

   ```html
   <!-- Bad: No dimensions specified -->
   <img src="photo.jpg" alt="Photo" />

   <!-- Good: Dimensions prevent layout shift -->
   <img src="photo.jpg" alt="Photo" width="800" height="600" />

   <!-- Better: Aspect ratio with CSS -->
   <img src="photo.jpg" alt="Photo" style="aspect-ratio: 4/3; width: 100%; height: auto;" />
   ```

2. **Web fonts causing FOIT/FOUT**

   ```css
   /* Bad: Flash of invisible text */
   @font-face {
     font-family: 'CustomFont';
     src: url('font.woff2');
   }

   /* Good: Font display swap prevents invisible text */
   @font-face {
     font-family: 'CustomFont';
     src: url('font.woff2');
     font-display: swap; /* or optional */
   }
   ```

   ```html
   <!-- Preload critical fonts -->
   <link rel="preload" href="font.woff2" as="font" type="font/woff2" crossorigin />
   ```

3. **Ads and embeds without reserved space**

   ```css
   /* Reserve space for ad slot */
   .ad-slot {
     min-height: 250px; /* Prevents layout shift when ad loads */
     background: #f0f0f0; /* Placeholder background */
   }
   ```

4. **Dynamic content injection**

   ```javascript
   // Bad: Injecting content without reserving space
   fetch('/api/banner').then((data) => {
     document.querySelector('.header').innerHTML = data.html;
   });

   // Good: Pre-allocate space or use skeleton
   <div class="header" style="min-height: 80px;">
     <div class="skeleton"></div> {/* Replaced by actual content */}
   </div>;
   ```

5. **Animations not using transform/opacity**

   ```css
   /* Bad: Causes layout shifts */
   .box {
     transition: width 0.3s;
   }
   .box:hover {
     width: 300px; /* Triggers layout */
   }

   /* Good: Composited animations */
   .box {
     transition: transform 0.3s;
   }
   .box:hover {
     transform: scaleX(1.5); /* No layout */
   }
   ```

**CLS optimization checklist:**

- [ ] All images have width/height or aspect-ratio
- [ ] Reserve space for ads, embeds, late-loading content
- [ ] Use `font-display: swap` or `optional` for web fonts
- [ ] Preload critical fonts
- [ ] Avoid inserting content above existing content (use skeleton loaders)
- [ ] Animate only `transform` and `opacity`
- [ ] Use `content-visibility: auto` for offscreen content
