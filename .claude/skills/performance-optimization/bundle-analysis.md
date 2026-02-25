# Bundle Analysis

## Tools

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

## Bundle Optimization Techniques

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

| Heavy Library | Size   | Lightweight Alternative   | Size    | Savings |
| ------------- | ------ | ------------------------- | ------- | ------- |
| moment        | 288 KB | date-fns                  | 78 KB   | -73%    |
| lodash        | 544 KB | lodash-es (tree-shakable) | 24 KB\* | -95%    |
| axios         | 33 KB  | fetch API (native)        | 0 KB    | -100%   |
| react-router  | 44 KB  | wouter                    | 1.5 KB  | -96%    |

\*With tree shaking, importing only needed functions

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

## Bundle Size Budgets

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
