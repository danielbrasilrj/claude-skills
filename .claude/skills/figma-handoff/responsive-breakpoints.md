# Responsive Breakpoint Documentation

## Standard Breakpoints

| Name   | Min Width | Max Width | Common Devices              | Layout Type                    |
| ------ | --------- | --------- | --------------------------- | ------------------------------ |
| **xs** | 0px       | 319px     | Small phones (portrait)     | Single column, full-width      |
| **sm** | 320px     | 767px     | Phones (portrait)           | Single column, mobile baseline |
| **md** | 768px     | 1023px    | Tablets, phones (landscape) | 2-column or tabs               |
| **lg** | 1024px    | 1439px    | Desktop, laptops            | Multi-column, desktop baseline |
| **xl** | 1440px    | infinity  | Large desktop, ultra-wide   | Max-width container (1280px)   |

---

## Breakpoint Behavior Documentation Template

For each component, document how it changes at each breakpoint:

### Button Example

| Breakpoint | Layout              | Size | Spacing            | Other               |
| ---------- | ------------------- | ---- | ------------------ | ------------------- |
| **xs-sm**  | Full-width          | md   | padding: 12px      | Stacked if multiple |
| **md**     | Inline (auto-width) | md   | padding: 12px 16px | Side-by-side        |
| **lg-xl**  | Inline              | lg   | padding: 14px 20px | Side-by-side        |

### Card Grid Example

| Breakpoint | Columns   | Gap  | Card Width   | Max Width        |
| ---------- | --------- | ---- | ------------ | ---------------- |
| **xs-sm**  | 1 column  | 16px | 100%         | --               |
| **md**     | 2 columns | 24px | 50% - gap    | --               |
| **lg**     | 3 columns | 24px | 33.33% - gap | --               |
| **xl**     | 3 columns | 32px | 33.33% - gap | 1280px container |

---

## Responsive Design Patterns

### 1. Stacking Pattern

**Description:** Horizontal layouts become vertical on mobile

**Example:** Navigation menu

- **lg-xl:** Horizontal nav bar with inline links
- **sm-md:** Hamburger menu -> vertical drawer

---

### 2. Column Collapse Pattern

**Description:** Multi-column grids reduce to fewer columns or single column

**Example:** Product grid

- **xl:** 4 columns
- **lg:** 3 columns
- **md:** 2 columns
- **sm:** 1 column

---

### 3. Content Reflow Pattern

**Description:** Sidebar content moves below main content on mobile

**Example:** Article + sidebar layout

- **lg-xl:** 2 columns (70% article, 30% sidebar)
- **sm-md:** Single column (article stacked above sidebar)

---

### 4. Typography Scaling Pattern

**Description:** Font sizes reduce on smaller screens

**Example:** Heading sizes

```
font-heading-xl:
  lg-xl: 48px
  md: 36px
  sm: 28px
```

---

### 5. Visibility Toggle Pattern

**Description:** Show/hide elements based on screen size

**Example:** Data table

- **lg-xl:** Full table with all columns
- **md:** Hide less important columns
- **sm:** Card view (stack rows vertically)

---

## Container Queries (Modern Approach)

**Container queries** (CSS `@container`) allow components to adapt based on their parent container width, not viewport width.

**Example:**

```css
/* Card adapts based on its container, not viewport */
.card {
  container-type: inline-size;
}

@container (min-width: 400px) {
  .card-content {
    display: flex; /* Side-by-side layout */
  }
}

@container (max-width: 399px) {
  .card-content {
    display: block; /* Stacked layout */
  }
}
```

**When to use:**

- Component must work in multiple contexts (sidebar, modal, grid)
- Parent width varies independently of viewport
