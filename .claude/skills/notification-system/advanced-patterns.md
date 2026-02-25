# Advanced Patterns

## In-App Notification Center

```javascript
// React Native component
import React, { useState, useEffect } from 'react';
import { FlatList, View, Text, TouchableOpacity } from 'react-native';

function NotificationCenter() {
  const [notifications, setNotifications] = useState([]);

  useEffect(() => {
    fetchInAppNotifications();
  }, []);

  async function fetchInAppNotifications() {
    const response = await fetch('/api/notifications/inbox');
    const data = await response.json();
    setNotifications(data);
  }

  async function markAsRead(notificationId) {
    await fetch(`/api/notifications/${notificationId}/read`, { method: 'POST' });
    setNotifications((prev) =>
      prev.map((n) => (n.id === notificationId ? { ...n, read: true } : n)),
    );
  }

  return (
    <FlatList
      data={notifications}
      keyExtractor={(item) => item.id}
      renderItem={({ item }) => (
        <TouchableOpacity
          onPress={() => {
            markAsRead(item.id);
            handleDeepLink(item.deep_link);
          }}
          style={{
            backgroundColor: item.read ? '#fff' : '#f0f8ff',
            padding: 16,
            borderBottomWidth: 1,
            borderColor: '#ddd',
          }}
        >
          <Text style={{ fontWeight: item.read ? 'normal' : 'bold' }}>{item.title}</Text>
          <Text>{item.body}</Text>
          <Text style={{ fontSize: 12, color: '#666' }}>{formatRelativeTime(item.created_at)}</Text>
        </TouchableOpacity>
      )}
    />
  );
}
```

## Frequency Capping

```javascript
// Server-side frequency cap
async function canSendNotification(userId, notificationType) {
  const redis = require('redis').createClient();

  const caps = {
    marketing: { count: 2, period: 86400 }, // 2 per day
    transactional: { count: 10, period: 3600 }, // 10 per hour
    reminder: { count: 5, period: 86400 }, // 5 per day
  };

  const cap = caps[notificationType];
  if (!cap) return true; // No cap defined

  const key = `notification_count:${userId}:${notificationType}`;
  const count = (await redis.get(key)) || 0;

  if (count >= cap.count) {
    return false;
  }

  // Increment and set expiry
  await redis.incr(key);
  await redis.expire(key, cap.period);

  return true;
}
```

## Quiet Hours

```javascript
function isQuietHours(userTimezone) {
  const now = moment.tz(userTimezone);
  const hour = now.hour();

  // Quiet hours: 10 PM to 8 AM
  return hour >= 22 || hour < 8;
}

async function scheduleOrSendNotification(user, notification) {
  if (isQuietHours(user.timezone)) {
    // Schedule for 8 AM user's time
    const sendTime = moment.tz(user.timezone).hour(8).minute(0).second(0);

    if (sendTime.isBefore(moment())) {
      sendTime.add(1, 'day');
    }

    await scheduleNotification(user, notification, sendTime.toDate());
  } else {
    await sendNotification(user.token, notification);
  }
}
```

## Rich Notifications

**iOS:**

```swift
// Notification Service Extension
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        guard let mutableContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            return
        }

        // Download image
        if let imageUrlString = mutableContent.userInfo["image_url"] as? String,
           let imageUrl = URL(string: imageUrlString) {
            downloadImage(from: imageUrl) { attachment in
                if let attachment = attachment {
                    mutableContent.attachments = [attachment]
                }
                contentHandler(mutableContent)
            }
        } else {
            contentHandler(mutableContent)
        }
    }
}
```

**Android:**

```kotlin
val notification = NotificationCompat.Builder(context, channelId)
    .setContentTitle(title)
    .setContentText(body)
    .setSmallIcon(R.drawable.notification_icon)
    .setLargeIcon(largeIconBitmap)
    .setStyle(NotificationCompat.BigPictureStyle()
        .bigPicture(imageBitmap)
        .bigLargeIcon(null)) // Hide large icon when expanded
    .build()
```

## A/B Testing Framework

```javascript
const crypto = require('crypto');

function assignVariant(userId, experimentId, variants) {
  // Deterministic hash-based assignment
  const hash = crypto.createHash('md5').update(`${experimentId}:${userId}`).digest('hex');

  const bucketNumber = parseInt(hash.substring(0, 8), 16) % 100;

  let cumulativeWeight = 0;
  for (const variant of variants) {
    cumulativeWeight += variant.weight; // weight is 0-100
    if (bucketNumber < cumulativeWeight) {
      return variant;
    }
  }

  return variants[0]; // Fallback
}

// Example experiment
const experiment = {
  id: 'notification_title_test',
  variants: [
    {
      name: 'control',
      weight: 50,
      title: 'Your order has shipped',
      body: 'Track your package now',
    },
    {
      name: 'variant_a',
      weight: 50,
      title: 'Great news! Your order is on the way',
      body: 'See when it arrives',
    },
  ],
};

// Usage
async function sendExperimentNotification(user, experimentId) {
  const variant = assignVariant(user.id, experimentId, experiment.variants);

  analytics.track('NOTIFICATION_EXPERIMENT_ASSIGNED', {
    user_id: user.id,
    experiment_id: experimentId,
    variant: variant.name,
  });

  await sendNotification(user.token, {
    title: variant.title,
    body: variant.body,
    data: {
      experiment_id: experimentId,
      variant: variant.name,
    },
  });
}
```
