# React/React Native Profiling

## React DevTools Profiler

**Enable profiling:**

```bash
# Development build includes profiler
npm start

# Production profiling build
npm run build -- --profile
npx serve -s build
```

**Profiling workflow:**

1. Open React DevTools -> Profiler tab
2. Click record (red circle)
3. Perform the interaction you want to profile
4. Stop recording
5. Analyze flame graph and ranked chart

**What to look for:**

- Components with long render times (> 16ms for 60fps)
- Components that re-render unnecessarily
- Expensive commits (> 50ms)

## Common React Performance Issues

**1. Unnecessary re-renders**

```jsx
// Bad: Re-creates function on every render
function TodoList({ todos }) {
  return todos.map((todo) => (
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

  return todos.map((todo) => <TodoItem key={todo.id} todo={todo} onDelete={handleDelete} />);
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
  const filteredUsers = users.filter((u) =>
    u.name.toLowerCase().includes(searchTerm.toLowerCase()),
  ); // Runs on EVERY render

  return filteredUsers.map((u) => <UserCard key={u.id} user={u} />);
}

// Good: Memoize expensive computation
function UserList({ users, searchTerm }) {
  const filteredUsers = useMemo(
    () => users.filter((u) => u.name.toLowerCase().includes(searchTerm.toLowerCase())),
    [users, searchTerm], // Only recompute when dependencies change
  );

  return filteredUsers.map((u) => <UserCard key={u.id} user={u} />);
}
```

**3. Large lists without virtualization**

```jsx
// Bad: Renders 10,000 DOM nodes
function HugeList({ items }) {
  return (
    <div>
      {items.map((item) => (
        <ItemRow key={item.id} item={item} />
      ))}
    </div>
  );
}

// Good: Only renders visible items
import { FixedSizeList } from 'react-window';

function HugeList({ items }) {
  return (
    <FixedSizeList height={600} itemCount={items.length} itemSize={50} width="100%">
      {({ index, style }) => (
        <div style={style}>
          <ItemRow item={items[index]} />
        </div>
      )}
    </FixedSizeList>
  );
}
```

## React Native Profiling

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
