# Caching Strategies

## HTTP Caching Headers

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

## Service Worker Caching

**Cache strategies:**

1. **Cache First (for static assets)**

   ```javascript
   self.addEventListener('fetch', (event) => {
     event.respondWith(
       caches.match(event.request).then((cachedResponse) => {
         return cachedResponse || fetch(event.request);
       }),
     );
   });
   ```

2. **Network First (for API requests)**

   ```javascript
   self.addEventListener('fetch', (event) => {
     event.respondWith(
       fetch(event.request).catch(() => {
         return caches.match(event.request);
       }),
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
       }),
     );
   });
   ```

## Application-Level Caching

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
