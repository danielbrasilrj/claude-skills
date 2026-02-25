# ARIA Patterns

## Common ARIA Roles

```html
<!-- Navigation -->
<nav role="navigation" aria-label="Main navigation">
  <!-- Search -->
  <div role="search">
    <input type="search" aria-label="Search products" />
  </div>

  <!-- Banner (site header) -->
  <header role="banner">
    <!-- Main content -->
    <main role="main">
      <!-- Complementary content -->
      <aside role="complementary">
        <!-- Content info (footer) -->
        <footer role="contentinfo">
          <!-- Article -->
          <article role="article"></article>
        </footer>
      </aside>
    </main>
  </header>
</nav>
```

## Dialog (Modal)

```jsx
function Modal({ isOpen, onClose, title, children }) {
  useEffect(() => {
    if (isOpen) {
      // Trap focus within modal
      const focusableElements = dialog.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])',
      );
      const firstElement = focusableElements[0];
      const lastElement = focusableElements[focusableElements.length - 1];

      firstElement?.focus();
    }
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="dialog-title"
      onKeyDown={(e) => {
        if (e.key === 'Escape') onClose();
      }}
    >
      <h2 id="dialog-title">{title}</h2>
      {children}
      <button onClick={onClose}>Close</button>
    </div>
  );
}
```

## Accordion

```jsx
function Accordion({ items }) {
  const [expandedIndex, setExpandedIndex] = useState(null);

  return (
    <div className="accordion">
      {items.map((item, index) => (
        <div key={index}>
          <button
            aria-expanded={expandedIndex === index}
            aria-controls={`panel-${index}`}
            id={`accordion-${index}`}
            onClick={() => setExpandedIndex(expandedIndex === index ? null : index)}
          >
            {item.title}
          </button>

          <div
            id={`panel-${index}`}
            role="region"
            aria-labelledby={`accordion-${index}`}
            hidden={expandedIndex !== index}
          >
            {item.content}
          </div>
        </div>
      ))}
    </div>
  );
}
```

## Tabs

```jsx
function Tabs({ tabs }) {
  const [activeTab, setActiveTab] = useState(0);

  return (
    <div>
      <div role="tablist" aria-label="Product information">
        {tabs.map((tab, index) => (
          <button
            key={index}
            role="tab"
            aria-selected={activeTab === index}
            aria-controls={`tabpanel-${index}`}
            id={`tab-${index}`}
            tabIndex={activeTab === index ? 0 : -1}
            onClick={() => setActiveTab(index)}
            onKeyDown={(e) => {
              if (e.key === 'ArrowRight') {
                setActiveTab((activeTab + 1) % tabs.length);
              } else if (e.key === 'ArrowLeft') {
                setActiveTab((activeTab - 1 + tabs.length) % tabs.length);
              }
            }}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {tabs.map((tab, index) => (
        <div
          key={index}
          role="tabpanel"
          id={`tabpanel-${index}`}
          aria-labelledby={`tab-${index}`}
          hidden={activeTab !== index}
          tabIndex={0}
        >
          {tab.content}
        </div>
      ))}
    </div>
  );
}
```
