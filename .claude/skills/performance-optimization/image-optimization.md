# Image Optimization

## Image Formats Comparison

| Format | Compression | Transparency | Animation | Browser Support | Best For                     |
| ------ | ----------- | ------------ | --------- | --------------- | ---------------------------- |
| JPEG   | Lossy       | No           | No        | 100%            | Photos                       |
| PNG    | Lossless    | Yes          | No        | 100%            | Graphics, logos              |
| WebP   | Both        | Yes          | Yes       | 97%             | All images (modern browsers) |
| AVIF   | Lossy       | Yes          | Yes       | 90%             | Photos (best compression)    |
| SVG    | Lossless    | Yes          | Yes       | 100%            | Icons, logos, illustrations  |

## Optimization Strategies

**1. Use modern formats with fallbacks**

```html
<picture>
  <!-- AVIF: Best compression (30% smaller than WebP) -->
  <source srcset="image.avif" type="image/avif" />

  <!-- WebP: Good compression, wider support -->
  <source srcset="image.webp" type="image/webp" />

  <!-- JPEG: Fallback for old browsers -->
  <img src="image.jpg" alt="Description" />
</picture>
```

**2. Responsive images**

```html
<img
  src="image-800.jpg"
  srcset="image-400.jpg 400w, image-800.jpg 800w, image-1200.jpg 1200w, image-1600.jpg 1600w"
  sizes="(max-width: 640px) 100vw,
         (max-width: 1024px) 50vw,
         800px"
  alt="Description"
  loading="lazy"
/>

<!-- Browser calculates:
  - Mobile (360px wide): Downloads image-400.jpg
  - Tablet (768px wide, image takes 50% = 384px): Downloads image-400.jpg
  - Desktop (1920px wide, image takes 800px): Downloads image-800.jpg
-->
```

**3. Lazy loading**

```html
<!-- Native lazy loading (95% browser support) -->
<img src="image.jpg" loading="lazy" alt="Description" />

<!-- Eager load for above-the-fold images -->
<img src="hero.jpg" loading="eager" fetchpriority="high" alt="Hero" />
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
/>

<!-- Parameters:
  w_800: Resize to 800px width
  f_auto: Automatic format (WebP, AVIF)
  q_auto: Automatic quality optimization
-->
```
