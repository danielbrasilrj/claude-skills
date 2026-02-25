# WCAG 2.1 AA Checklist (POUR Principles)

## Perceivable

Information and user interface components must be presentable to users in ways they can perceive.

### 1.1 Text Alternatives

**1.1.1 Non-text Content (A)**

- [ ] All images have alt text
- [ ] Decorative images have empty alt (`alt=""`)
- [ ] Complex images (charts, diagrams) have detailed descriptions
- [ ] Form inputs have associated labels
- [ ] Icon buttons have accessible names

```html
<!-- Good examples -->
<img src="photo.jpg" alt="Woman presenting at conference" />
<img src="decorative-border.svg" alt="" role="presentation" />
<button aria-label="Close dialog"><CloseIcon /></button>

<!-- Complex image with detailed description -->
<img src="sales-chart.png" alt="Q4 sales chart" aria-describedby="chart-desc" />
<div id="chart-desc">
  Sales increased 25% in Q4 compared to Q3, with highest growth in November (+40%).
</div>
```

### 1.2 Time-based Media

**1.2.1 Audio-only and Video-only (A)**

- [ ] Pre-recorded audio has text transcript
- [ ] Pre-recorded video has audio description or transcript

**1.2.2 Captions (A)**

- [ ] Pre-recorded video has captions
- [ ] Captions include all dialogue and important sounds

**1.2.3 Audio Description or Media Alternative (A)**

- [ ] Pre-recorded video has audio description or full text alternative

**1.2.4 Captions (Live) (AA)**

- [ ] Live audio has captions

**1.2.5 Audio Description (AA)**

- [ ] Pre-recorded video has audio description

### 1.3 Adaptable

**1.3.1 Info and Relationships (A)**

- [ ] Semantic HTML used (`<header>`, `<nav>`, `<main>`, `<article>`, `<aside>`, `<footer>`)
- [ ] Headings follow logical hierarchy (h1 -> h2 -> h3, no skipping)
- [ ] Lists use `<ul>`, `<ol>`, `<li>` elements
- [ ] Tables use proper markup (`<table>`, `<th>`, `<caption>`)
- [ ] Form fields grouped with `<fieldset>` and `<legend>`

```html
<!-- Good heading hierarchy -->
<h1>Product Page</h1>
<h2>Product Details</h2>
<h3>Specifications</h3>
<h3>Materials</h3>
<h2>Customer Reviews</h2>
<h3>Most Helpful</h3>

<!-- Bad: skips from h1 to h3 -->
<h1>Product Page</h1>
<h3>Product Details</h3>
<!-- Skipped h2 -->
```

**1.3.2 Meaningful Sequence (A)**

- [ ] Content order makes sense when CSS is disabled
- [ ] Reading order matches visual order
- [ ] Tab order is logical

**1.3.3 Sensory Characteristics (A)**

- [ ] Instructions don't rely solely on shape, size, location, or sound
- [ ] Example: "Click the green button on the right" -> "Click the Submit button"

**1.3.4 Orientation (AA) - Mobile**

- [ ] Content not locked to single orientation (portrait/landscape)
- [ ] Both orientations supported unless essential

**1.3.5 Identify Input Purpose (AA)**

- [ ] Form inputs use autocomplete attributes when collecting user data

```html
<input type="email" name="email" autocomplete="email" aria-label="Email address" />

<input type="tel" name="phone" autocomplete="tel" aria-label="Phone number" />
```

### 1.4 Distinguishable

**1.4.1 Use of Color (A)**

- [ ] Color not the only visual means of conveying information
- [ ] Links distinguishable from text (underline, icon, or other indicator)

```html
<!-- Bad: only color indicates required -->
<label style="color: red;">Name</label>

<!-- Good: asterisk + color -->
<label> Name <span style="color: red;" aria-label="required">*</span> </label>
```

**1.4.2 Audio Control (A)**

- [ ] Auto-playing audio has pause/stop control
- [ ] Auto-play limited to 3 seconds OR user can control

**1.4.3 Contrast (Minimum) (AA)**

- [ ] Normal text: 4.5:1 contrast ratio
- [ ] Large text (18pt+ or 14pt+ bold): 3:1 contrast ratio
- [ ] UI components and graphics: 3:1 contrast ratio

**Color contrast testing:**

```
Foreground: #666666
Background: #FFFFFF
Ratio: 5.74:1 -- Passes AA for normal text

Foreground: #999999
Background: #FFFFFF
Ratio: 2.85:1 -- Fails AA (too light)
```

**1.4.4 Resize Text (AA)**

- [ ] Text can be resized to 200% without loss of content or functionality
- [ ] No horizontal scrolling at 200% zoom (on desktop)

**1.4.5 Images of Text (AA)**

- [ ] Text not presented as images unless essential (logos, etc.)
- [ ] Use actual text with CSS styling instead

**1.4.10 Reflow (AA)**

- [ ] Content reflows at 320px width without horizontal scrolling
- [ ] No loss of information when zoomed to 400%

```css
/* Ensure content reflows */
.container {
  max-width: 100%;
  overflow-wrap: break-word;
}

/* Avoid fixed widths that prevent reflow */
.bad {
  width: 800px; /* Requires horizontal scroll on small screens */
}
```

**1.4.11 Non-text Contrast (AA)**

- [ ] UI components have 3:1 contrast against adjacent colors
- [ ] Graphical objects (icons, charts) have 3:1 contrast

**1.4.12 Text Spacing (AA)**

- [ ] Content readable with modified text spacing:
  - Line height: 1.5x font size
  - Paragraph spacing: 2x font size
  - Letter spacing: 0.12x font size
  - Word spacing: 0.16x font size

**1.4.13 Content on Hover or Focus (AA)**

- [ ] Hover/focus content is dismissible (Esc key)
- [ ] Hover/focus content is hoverable (pointer can move to it)
- [ ] Hover/focus content persists until dismissed

---

## Operable

User interface components and navigation must be operable.

### 2.1 Keyboard Accessible

**2.1.1 Keyboard (A)**

- [ ] All functionality available via keyboard
- [ ] No keyboard traps
- [ ] Tab order is logical

```jsx
// Good: Custom component with keyboard support
function CustomButton({ onClick, children }) {
  return (
    <div
      role="button"
      tabIndex={0}
      onClick={onClick}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          onClick();
        }
      }}
    >
      {children}
    </div>
  );
}
```

**2.1.2 No Keyboard Trap (A)**

- [ ] Focus can move away from component using only keyboard
- [ ] Modal dialogs have escape hatch (Esc key or visible close button)

**2.1.4 Character Key Shortcuts (A)**

- [ ] Single character shortcuts can be turned off, remapped, or only active on focus

### 2.2 Enough Time

**2.2.1 Timing Adjustable (A)**

- [ ] Time limits can be turned off, adjusted, or extended
- [ ] User warned before time expires

**2.2.2 Pause, Stop, Hide (A)**

- [ ] Moving, blinking, scrolling content can be paused, stopped, or hidden
- [ ] Auto-updating content can be paused, stopped, or user can control frequency

### 2.3 Seizures and Physical Reactions

**2.3.1 Three Flashes or Below Threshold (A)**

- [ ] No content flashes more than 3 times per second
- [ ] Flashing kept below general flash and red flash thresholds

### 2.4 Navigable

**2.4.1 Bypass Blocks (A)**

- [ ] Skip-to-main-content link present
- [ ] Skip navigation links for repetitive content

```html
<body>
  <a href="#main" class="skip-link">Skip to main content</a>

  <header>
    <!-- Navigation -->
  </header>

  <main id="main">
    <!-- Main content -->
  </main>
</body>

<style>
  .skip-link {
    position: absolute;
    top: -40px;
    left: 0;
    background: #000;
    color: #fff;
    padding: 8px;
    z-index: 100;
  }

  .skip-link:focus {
    top: 0;
  }
</style>
```

**2.4.2 Page Titled (A)**

- [ ] Pages have descriptive titles
- [ ] Title describes page purpose

**2.4.3 Focus Order (A)**

- [ ] Focus order preserves meaning and operability
- [ ] Tab order matches visual order

**2.4.4 Link Purpose (A)**

- [ ] Link text describes destination
- [ ] Avoid "click here", "read more" without context

```html
<!-- Bad: no context -->
<a href="/article">Read more</a>

<!-- Good: descriptive -->
<a href="/article">Read more about accessibility best practices</a>

<!-- Good: context from surrounding text -->
<h2>Accessibility Best Practices</h2>
<p>Learn how to make your website accessible...</p>
<a href="/article">Read more<span class="sr-only"> about accessibility best practices</span></a>
```

**2.4.5 Multiple Ways (AA)**

- [ ] Multiple ways to find pages (navigation, search, sitemap)

**2.4.6 Headings and Labels (AA)**

- [ ] Headings and labels are descriptive
- [ ] Headings identify sections clearly

**2.4.7 Focus Visible (AA)**

- [ ] Keyboard focus indicator is visible
- [ ] Focus indicator has sufficient contrast

```css
/* Good: visible focus indicator */
button:focus {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

/* Bad: removes focus indicator */
button:focus {
  outline: none; /* Never do this */
}
```

### 2.5 Input Modalities

**2.5.1 Pointer Gestures (A)**

- [ ] Multi-point or path-based gestures have single-pointer alternative
- [ ] Example: Pinch-to-zoom also has +/- buttons

**2.5.2 Pointer Cancellation (A)**

- [ ] Single-pointer actions can be aborted or undone
- [ ] Up-event completes action (not down-event)

**2.5.3 Label in Name (A)**

- [ ] Visible label text is included in accessible name

```html
<!-- Good: accessible name includes visible label -->
<button aria-label="Search products">Search</button>

<!-- Bad: accessible name doesn't match visible text -->
<button aria-label="Submit">Search</button>
<!-- Confusing -->
```

**2.5.4 Motion Actuation (A)**

- [ ] Functionality triggered by motion can also be triggered via UI
- [ ] Example: Shake-to-undo also has undo button

---

## Understandable

Information and the operation of user interface must be understandable.

### 3.1 Readable

**3.1.1 Language of Page (A)**

- [ ] Page language is specified

```html
<html lang="en"></html>
```

**3.1.2 Language of Parts (AA)**

- [ ] Language changes are marked

```html
<p>The French phrase <span lang="fr">plus ca change</span> means...</p>
```

### 3.2 Predictable

**3.2.1 On Focus (A)**

- [ ] Receiving focus doesn't trigger unexpected context change
- [ ] No auto-submit on focus

**3.2.2 On Input (A)**

- [ ] Changing settings doesn't cause unexpected context change
- [ ] User warned before context change

**3.2.3 Consistent Navigation (AA)**

- [ ] Navigation menus in consistent order across pages

**3.2.4 Consistent Identification (AA)**

- [ ] Components with same functionality labeled consistently

### 3.3 Input Assistance

**3.3.1 Error Identification (A)**

- [ ] Form errors are clearly identified
- [ ] Error messages are descriptive

```html
<input type="email" aria-invalid="true" aria-describedby="email-error" />
<span id="email-error" role="alert"> Please enter a valid email address </span>
```

**3.3.2 Labels or Instructions (A)**

- [ ] Form fields have labels or instructions
- [ ] Required fields are indicated

**3.3.3 Error Suggestion (AA)**

- [ ] Error messages suggest how to fix the error
- [ ] Example: "Email must include @" not just "Invalid email"

**3.3.4 Error Prevention (AA)**

- [ ] Submissions are reversible, verified, or confirmed
- [ ] Important actions (delete, purchase) require confirmation

---

## Robust

Content must be robust enough to be interpreted reliably by assistive technologies.

### 4.1 Compatible

**4.1.1 Parsing (A) - Deprecated in WCAG 2.2**

- [ ] HTML is valid and well-formed

**4.1.2 Name, Role, Value (A)**

- [ ] All UI components have accessible name and role
- [ ] States and properties are programmatically determinable

**4.1.3 Status Messages (AA)**

- [ ] Status messages can be determined by assistive technology
- [ ] Use ARIA live regions for dynamic updates

```html
<!-- Success message -->
<div role="status" aria-live="polite">Item added to cart</div>

<!-- Error alert -->
<div role="alert" aria-live="assertive">Payment failed. Please try again.</div>
```
