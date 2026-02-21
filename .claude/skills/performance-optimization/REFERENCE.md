# Performance Optimization Reference Guide

## Table of Contents
1. [Core Web Vitals Deep Dive](#core-web-vitals-deep-dive)
2. [React/React Native Profiling](#reactreact-native-profiling)
3. [Bundle Analysis](#bundle-analysis)
4. [Image Optimization](#image-optimization)
5. [Caching Strategies](#caching-strategies)
6. [Mobile Performance](#mobile-performance)

---

## Core Web Vitals Deep Dive

### Overview

Core Web Vitals are three metrics that measure real-world user experience:

| Metric | What It Measures | Good | Poor | Weight in Lighthouse |
|--------|------------------|------|------|---------------------|
| **LCP** (Largest Contentful Paint) | Loading performance | ≤ 2.5s | > 4.0s | 25% |
| **INP** (Interaction to Next Paint) | Responsiveness | ≤ 200ms | > 500ms | 25% |
| **CLS** (Cumulative Layout Shift) | Visual stability | ≤ 0.1 | > 0.25 | 15% |

**Additional metrics:**
- **FCP** (First Contentful Paint): When first content appears (good: ≤ 1.8s)
- **TTFB** (Time to First Byte): Server response time (good: ≤ 600ms)
- **TBT** (Total Blocking Time): Main thread blocking time (good: ≤ 200ms)

---

### LCP (Largest Contentful Paint)

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
   <link rel="stylesheet" href="styles.css">
   
   <!-- Good: Non-blocking -->
   <script src="analytics.js" defer></script>
   <link rel="preload" href="styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
   <noscript><link rel="stylesheet" href="styles.css"></noscript>
   ```

3. **Large images without optimization**
   ```html
   <!-- Bad: Large unoptimized image -->
   <img src="hero-4000x3000.jpg" alt="Hero">
   
   <!-- Good: Responsive with modern formats -->
   <picture>
     <source srcset="hero-800.avif 800w, hero-1200.avif 1200w" type="image/avif">
     <source srcset="hero-800.webp 800w, hero-1200.webp 1200w" type="image/webp">
     <img src="hero-1200.jpg" 
          srcset="hero-800.jpg 800w, hero-1200.jpg 1200w"
          sizes="(max-width: 768px) 100vw, 50vw"
          alt="Hero"
          loading="eager"
          fetchpriority="high">
   </picture>
   ```

4. **Client-side rendering delays**
   ```jsx
   // Bad: Everything renders client-side
   function App() {
     const [data, setData] = useState(null);
     useEffect(() => {
       fetch('/api/data').then(r => r.json()).then(setData);
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

### INP (Interaction to Next Paint)

Replaced FID (First Input Delay) in 2024. Measures responsiveness across ALL interactions.

**What INP measures:**
- Click interactions
- Tap interactions (mobile)
- Keyboard interactions
- Time from user input → visual feedback

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
     return items.map(item => expensiveOperation(item));
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
   <input onChange={(e) => {
     const filtered = largeArray.filter(item => 
       item.name.toLowerCase().includes(e.target.value.toLowerCase())
     );
     setResults(filtered);
   }} />
   
   // Good: Debounce expensive operations
   import { useDebouncedCallback } from 'use-debounce';
   
   const handleSearch = useDebouncedCallback((value) => {
     const filtered = largeArray.filter(item => 
       item.name.toLowerCase().includes(value.toLowerCase())
     );
     setResults(filtered);
   }, 300);
   
   <input onChange={(e) => handleSearch(e.target.value)} />
   ```

3. **Layout thrashing**
   ```javascript
   // Bad: Forced synchronous layout (thrashing)
   elements.forEach(el => {
     const height = el.offsetHeight; // Read (forces layout)
     el.style.height = height * 2 + 'px'; // Write
   });
   
   // Good: Batch reads then writes
   const heights = elements.map(el => el.offsetHeight); // Batch reads
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

### CLS (Cumulative Layout Shift)

Measures visual stability. Every unexpected layout shift hurts CLS.

**How CLS is calculated:**
```
CLS = Σ(Impact Fraction × Distance Fraction)

Impact Fraction: % of viewport affected
Distance Fraction: Distance moved / viewport height
```

**Common causes of layout shifts:**

1. **Images without dimensions**
   ```html
   <!-- Bad: No dimensions specified -->
   <img src="photo.jpg" alt="Photo">
   
   <!-- Good: Dimensions prevent layout shift -->
   <img src="photo.jpg" alt="Photo" width="800" height="600">
   
   <!-- Better: Aspect ratio with CSS -->
   <img src="photo.jpg" alt="Photo" style="aspect-ratio: 4/3; width: 100%; height: auto;">
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
   <link rel="preload" href="font.woff2" as="font" type="font/woff2" crossorigin>
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
   fetch('/api/banner').then(data => {
     document.querySelector('.header').innerHTML = data.html;
   });
   
   // Good: Pre-allocate space or use skeleton
   <div class="header" style="min-height: 80px;">
     <div class="skeleton"></div> {/* Replaced by actual content */}
   </div>
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

---

## React/React Native Profiling

### React DevTools Profiler

**Enable profiling:**
```bash
# Development build includes profiler
npm start

# Production profiling build
npm run build -- --profile
npx serve -s build
```

**Profiling workflow:**

1. Open React DevTools → Profiler tab
2. Click record (red circle)
3. Perform the interaction you want to profile
4. Stop recording
5. Analyze flame graph and ranked chart

**What to look for:**
- Components with long render times (> 16ms for 60fps)
- Components that re-render unnecessarily
- Expensive commits (> 50ms)

### Common React Performance Issues

**1. Unnecessary re-renders**

```jsx
// Bad: Re-creates function on every render
function TodoList({ todos }) {
  return todos.map(todo => (
    <TodoItem 
      key={todo.id} 
      todo={todo} 
      onDelete={() => deleteTodo(todo.id)} // New function every render
    />
  ));
}

// Good: Memoize callback
function TodoList({ todos }) {
  const handleDelete = useCallback((id) => {
    deleteTodo(id);
  }, []);
  
  return todos.map(todo => (
    <TodoItem 
      key={todo.id} 
      todo={todo} 
      onDelete={handleDelete}
    />
  ));
}

// Even better: Use React.memo to prevent re-renders
const TodoItem = React.memo(({ todo, onDelete }) => {
  return (
    <div>
      {todo.text}
      <button onClick={() => onDelete(todo.id)}>Delete</button>
    </div>
  );
});
```

**2. Expensive computations on every render**

```jsx
// Bad: Filters on every render
function UserList({ users, searchTerm }) {
  const filteredUsers = users.filter(u => 
    u.name.toLowerCase().includes(searchTerm.toLowerCase())
  ); // Runs on EVERY render
  
  return filteredUsers.map(u => <UserCard key={u.id} user={u} />);
}

// Good: Memoize expensive computation
function UserList({ users, searchTerm }) {
  const filteredUsers = useMemo(() => 
    users.filter(u => 
      u.name.toLowerCase().includes(searchTerm.toLowerCase())
    ),
    [users, searchTerm] // Only recompute when dependencies change
  );
  
  return filteredUsers.map(u => <UserCard key={u.id} user={u} />);
}
```

**3. Large lists without virtualization**

```jsx
// Bad: Renders 10,000 DOM nodes
function HugeList({ items }) {
  return (
    <div>
      {items.map(item => <ItemRow key={item.id} item={item} />)}
    </div>
  );
}

// Good: Only renders visible items
import { FixedSizeList } from 'react-window';

function HugeList({ items }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>
          <ItemRow item={items[index]} />
        </div>
      )}
    </FixedSizeList>
  );
}
```

### React Native Profiling

**Enable Hermes (if not already enabled):**

```javascript
// android/app/build.gradle
project.ext.react = [
    enableHermes: true  // Enable Hermes engine
]
```

```ruby
# ios/Podfile
use_react_native!(
  :path => config[:reactNativePath],
  :hermes_enabled => true
)
```

**Profile with Hermes:**

```bash
# Generate Hermes profile
# 1. Run app on device
# 2. Perform actions to profile
# 3. Download profile:
adb pull /data/data/com.yourapp/cache/index.cpuprofile

# Open in Chrome DevTools
# 1. Open chrome://inspect
# 2. Click "Open dedicated DevTools for Node"
# 3. Go to Profiler tab
# 4. Load index.cpuprofile
```

**React Native Performance Monitor:**

```javascript
// Enable in-app performance monitor
import { DevSettings } from 'react-native';

// Shows FPS, JS frame rate, UI frame rate
DevSettings.showDevTools();
```

**Target metrics:**
- **JS frame rate:** 60 FPS (16.67ms per frame)
- **UI thread:** 60 FPS
- **RAM usage:** < 200MB for simple apps, < 500MB for complex apps

---

## Bundle Analysis

### Tools

**Vite/Rollup:**
```bash
npm install --save-dev rollup-plugin-visualizer

# vite.config.js
import { visualizer } from 'rollup-plugin-visualizer';

export default {
  plugins: [
    visualizer({
      open: true,
      gzipSize: true,
      brotliSize: true,
    })
  ]
};

# Generates stats.html treemap
npm run build
```

**Webpack:**
```bash
npm install --save-dev webpack-bundle-analyzer

# webpack.config.js
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

module.exports = {
  plugins: [
    new BundleAnalyzerPlugin()
  ]
};

npm run build
```

**Source Map Explorer (any bundler):**
```bash
npx source-map-explorer dist/main.js dist/main.js.map
```

### Bundle Optimization Techniques

**1. Tree shaking (requires ES modules)**

```javascript
// Bad: CommonJS import (no tree shaking)
const _ = require('lodash');
const result = _.debounce(fn, 300);

// Good: ES module import (tree shaking works)
import { debounce } from 'lodash-es';
const result = debounce(fn, 300);

// Even better: Direct import (no lodash at all)
import debounce from 'lodash-es/debounce';
```

**2. Code splitting by route**

```jsx
// Bad: All routes in main bundle
import Home from './pages/Home';
import Dashboard from './pages/Dashboard';
import Settings from './pages/Settings';

function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/settings" element={<Settings />} />
    </Routes>
  );
}

// Good: Routes loaded on demand
import { lazy, Suspense } from 'react';

const Home = lazy(() => import('./pages/Home'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

**3. Replace heavy libraries**

| Heavy Library | Size | Lightweight Alternative | Size | Savings |
|--------------|------|------------------------|------|---------|
| moment | 288 KB | date-fns | 78 KB | -73% |
| lodash | 544 KB | lodash-es (tree-shakable) | 24 KB* | -95% |
| axios | 33 KB | fetch API (native) | 0 KB | -100% |
| react-router | 44 KB | wouter | 1.5 KB | -96% |

*With tree shaking, importing only needed functions

**4. Dynamic imports for heavy features**

```javascript
// Bad: Chart library in main bundle
import Chart from 'chart.js/auto';

function Analytics() {
  return <Chart data={data} />;
}

// Good: Load chart library only when needed
function Analytics() {
  const [ChartComponent, setChartComponent] = useState(null);
  
  useEffect(() => {
    import('chart.js/auto').then(({ default: Chart }) => {
      setChartComponent(() => Chart);
    });
  }, []);
  
  if (!ChartComponent) return <Loading />;
  return <ChartComponent data={data} />;
}
```

**5. Remove unused dependencies**

```bash
# Find unused dependencies
npx depcheck

# Or use knip (more accurate)
npx knip

# Remove unused deps
npm uninstall unused-package
```

### Bundle Size Budgets

**Performance budget template:**

```json
{
  "budgets": [
    {
      "path": "dist/main.*.js",
      "maxSize": "200 KB",
      "warningSize": "150 KB"
    },
    {
      "path": "dist/vendor.*.js",
      "maxSize": "300 KB",
      "warningSize": "250 KB"
    },
    {
      "path": "dist/**/*.css",
      "maxSize": "50 KB"
    }
  ]
}
```

**Enforce in CI with size-limit:**

```bash
npm install --save-dev size-limit @size-limit/file

# package.json
{
  "size-limit": [
    {
      "path": "dist/main.*.js",
      "limit": "200 KB"
    }
  ],
  "scripts": {
    "size": "size-limit"
  }
}

# Run in CI
npm run size
```

---

## Image Optimization

### Image Formats Comparison

| Format | Compression | Transparency | Animation | Browser Support | Best For |
|--------|-------------|--------------|-----------|-----------------|----------|
| JPEG | Lossy | No | No | 100% | Photos |
| PNG | Lossless | Yes | No | 100% | Graphics, logos |
| WebP | Both | Yes | Yes | 97% | All images (modern browsers) |
| AVIF | Lossy | Yes | Yes | 90% | Photos (best compression) |
| SVG | Lossless | Yes | Yes | 100% | Icons, logos, illustrations |

### Optimization Strategies

**1. Use modern formats with fallbacks**

```html
<picture>
  <!-- AVIF: Best compression (30% smaller than WebP) -->
  <source srcset="image.avif" type="image/avif">
  
  <!-- WebP: Good compression, wider support -->
  <source srcset="image.webp" type="image/webp">
  
  <!-- JPEG: Fallback for old browsers -->
  <img src="image.jpg" alt="Description">
</picture>
```

**2. Responsive images**

```html
<img 
  src="image-800.jpg"
  srcset="image-400.jpg 400w,
          image-800.jpg 800w,
          image-1200.jpg 1200w,
          image-1600.jpg 1600w"
  sizes="(max-width: 640px) 100vw,
         (max-width: 1024px) 50vw,
         800px"
  alt="Description"
  loading="lazy"
>

<!-- Browser calculates:
  - Mobile (360px wide): Downloads image-400.jpg
  - Tablet (768px wide, image takes 50% = 384px): Downloads image-400.jpg
  - Desktop (1920px wide, image takes 800px): Downloads image-800.jpg
-->
```

**3. Lazy loading**

```html
<!-- Native lazy loading (95% browser support) -->
<img src="image.jpg" loading="lazy" alt="Description">

<!-- Eager load for above-the-fold images -->
<img src="hero.jpg" loading="eager" fetchpriority="high" alt="Hero">
```

**4. Compression targets**

```bash
# Install sharp for Node.js image processing
npm install sharp

# Optimize JPEG
sharp('input.jpg')
  .jpeg({ quality: 85, progressive: true })
  .toFile('output.jpg');

# Convert to WebP
sharp('input.jpg')
  .webp({ quality: 85 })
  .toFile('output.webp');

# Convert to AVIF
sharp('input.jpg')
  .avif({ quality: 75 })
  .toFile('output.avif');
```

**Size targets:**
- Hero images: < 100 KB
- Content images: < 50 KB
- Thumbnails: < 20 KB
- Icons: Use SVG (< 5 KB) or icon fonts

**5. Image CDN**

Use an image CDN (Cloudinary, Imgix, Cloudflare Images) for automatic optimization:

```html
<!-- Cloudinary example -->
<img 
  src="https://res.cloudinary.com/demo/image/upload/w_800,f_auto,q_auto/sample.jpg"
  alt="Sample"
>

<!-- Parameters:
  w_800: Resize to 800px width
  f_auto: Automatic format (WebP, AVIF)
  q_auto: Automatic quality optimization
-->
```

---

## Caching Strategies

### HTTP Caching Headers

**Cache-Control directives:**

```nginx
# Static assets (hashed filenames): Cache forever
location /assets/ {
  add_header Cache-Control "public, max-age=31536000, immutable";
}

# HTML: No cache (always revalidate)
location / {
  add_header Cache-Control "no-cache, must-revalidate";
}

# API responses: Cache with revalidation
location /api/ {
  add_header Cache-Control "public, max-age=300, stale-while-revalidate=60";
}
```

**Directives explained:**
- `public`: Can be cached by browsers and CDNs
- `private`: Only browser cache (not CDN)
- `max-age=N`: Cache for N seconds
- `immutable`: Never revalidate (use with hashed filenames)
- `no-cache`: Revalidate before using cached version
- `no-store`: Never cache (sensitive data)
- `stale-while-revalidate=N`: Serve stale content while fetching fresh

### Service Worker Caching

**Cache strategies:**

1. **Cache First (for static assets)**
   ```javascript
   self.addEventListener('fetch', (event) => {
     event.respondWith(
       caches.match(event.request).then((cachedResponse) => {
         return cachedResponse || fetch(event.request);
       })
     );
   });
   ```

2. **Network First (for API requests)**
   ```javascript
   self.addEventListener('fetch', (event) => {
     event.respondWith(
       fetch(event.request).catch(() => {
         return caches.match(event.request);
       })
     );
   });
   ```

3. **Stale While Revalidate (for images)**
   ```javascript
   self.addEventListener('fetch', (event) => {
     event.respondWith(
       caches.open('images').then((cache) => {
         return cache.match(event.request).then((cachedResponse) => {
           const fetchPromise = fetch(event.request).then((networkResponse) => {
             cache.put(event.request, networkResponse.clone());
             return networkResponse;
           });
           return cachedResponse || fetchPromise;
         });
       })
     );
   });
   ```

### Application-Level Caching

**React Query (TanStack Query):**

```javascript
import { useQuery } from '@tanstack/react-query';

function UserProfile({ userId }) {
  const { data, isLoading } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
    staleTime: 5 * 60 * 1000, // Consider fresh for 5 minutes
    cacheTime: 10 * 60 * 1000, // Keep in cache for 10 minutes
  });
  
  if (isLoading) return <Loading />;
  return <Profile user={data} />;
}
```

**Redis caching (backend):**

```javascript
import Redis from 'ioredis';
const redis = new Redis();

async function getUserProfile(userId) {
  // Check cache first
  const cached = await redis.get(`user:${userId}`);
  if (cached) return JSON.parse(cached);
  
  // Fetch from database
  const user = await db.users.findById(userId);
  
  // Cache for 5 minutes
  await redis.setex(`user:${userId}`, 300, JSON.stringify(user));
  
  return user;
}
```

---

## Mobile Performance

### React Native Performance

**1. Hermes JavaScript Engine**

Hermes reduces:
- App size: -50% to -75%
- Memory usage: -30% to -50%
- TTI (Time to Interactive): -50%

**Enable Hermes:**

```gradle
// android/app/build.gradle
project.ext.react = [
    enableHermes: true
]
```

```ruby
# ios/Podfile
use_react_native!(
  :path => config[:reactNativePath],
  :hermes_enabled => true
)
```

**2. RAM bundles (inline requires)**

```javascript
// metro.config.js
module.exports = {
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: true, // Enable inline requires
      },
    }),
  },
};
```

**3. FlatList optimization**

```jsx
// Bad: Slow with 1000+ items
<ScrollView>
  {items.map(item => <ItemCard key={item.id} item={item} />)}
</ScrollView>

// Good: Virtualized list
<FlatList
  data={items}
  renderItem={({ item }) => <ItemCard item={item} />}
  keyExtractor={item => item.id}
  
  // Performance optimizations
  removeClippedSubviews={true}
  maxToRenderPerBatch={10}
  updateCellsBatchingPeriod={50}
  initialNumToRender={10}
  windowSize={5}
  
  // Use memo for items
  ItemSeparatorComponent={Separator}
  getItemLayout={(data, index) => ({
    length: ITEM_HEIGHT,
    offset: ITEM_HEIGHT * index,
    index,
  })}
/>
```

**4. Image optimization**

```jsx
// Use FastImage instead of Image
import FastImage from 'react-native-fast-image';

<FastImage
  source={{
    uri: 'https://example.com/image.jpg',
    priority: FastImage.priority.high,
    cache: FastImage.cacheControl.immutable,
  }}
  resizeMode={FastImage.resizeMode.cover}
  style={{ width: 200, height: 200 }}
/>
```

**5. Avoid unnecessary re-renders**

```jsx
// Use React.memo for pure components
const ItemCard = React.memo(({ item, onPress }) => {
  return (
    <TouchableOpacity onPress={() => onPress(item.id)}>
      <Text>{item.title}</Text>
    </TouchableOpacity>
  );
});

// Memoize callbacks
function ItemList({ items }) {
  const handlePress = useCallback((id) => {
    navigation.navigate('Detail', { id });
  }, [navigation]);
  
  return items.map(item => (
    <ItemCard key={item.id} item={item} onPress={handlePress} />
  ));
}
```

### Android-Specific Optimizations

**1. Enable Proguard (minification)**

```gradle
// android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

**2. Enable Multidex (if needed)**

```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}
```

**3. Reduce APK size**

```gradle
android {
    splits {
        abi {
            enable true
            reset()
            include 'armeabi-v7a', 'arm64-v8a'
            universalApk false
        }
    }
}
```

### iOS-Specific Optimizations

**1. Enable Bitcode (if not using Hermes)**

```ruby
# ios/Podfile
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'YES'
    end
  end
end
```

**2. Optimize images with Xcode**

- Use Asset Catalogs
- Enable "Compress PNG Files"
- Use @1x, @2x, @3x image sets

**3. Reduce IPA size**

- Enable "Dead Code Stripping"
- Enable "Strip Debug Symbols"
- Use "Smallest" code optimization level for Release builds
