# Analytics and Tracking

## Event Schema

```javascript
const notificationEvents = {
  NOTIFICATION_SENT: {
    notification_id: 'string',
    user_id: 'string',
    notification_type: 'string',
    channel: 'string', // 'push', 'in-app', 'email'
    campaign_id: 'string',
    sent_at: 'timestamp',
  },

  NOTIFICATION_DELIVERED: {
    notification_id: 'string',
    user_id: 'string',
    delivered_at: 'timestamp',
  },

  NOTIFICATION_OPENED: {
    notification_id: 'string',
    user_id: 'string',
    opened_at: 'timestamp',
    time_to_open: 'number', // seconds since delivery
    deep_link: 'string',
  },

  NOTIFICATION_DISMISSED: {
    notification_id: 'string',
    user_id: 'string',
    dismissed_at: 'timestamp',
  },

  NOTIFICATION_ACTION: {
    notification_id: 'string',
    user_id: 'string',
    action_id: 'string',
    action_at: 'timestamp',
  },

  NOTIFICATION_FAILED: {
    notification_id: 'string',
    user_id: 'string',
    error_code: 'string',
    error_message: 'string',
    failed_at: 'timestamp',
  },
};
```

## Tracking Implementation

```javascript
const analytics = require('./analytics'); // Your analytics SDK

// Track notification sent
async function sendAndTrack(user, notification) {
  const notificationId = generateUUID();

  try {
    await sendNotification(user.token, notification);

    analytics.track('NOTIFICATION_SENT', {
      notification_id: notificationId,
      user_id: user.id,
      notification_type: notification.type,
      channel: 'push',
      campaign_id: notification.campaign_id,
      sent_at: new Date(),
    });

    return notificationId;
  } catch (error) {
    analytics.track('NOTIFICATION_FAILED', {
      notification_id: notificationId,
      user_id: user.id,
      error_code: error.code,
      error_message: error.message,
      failed_at: new Date(),
    });
    throw error;
  }
}

// Track notification opened (client-side)
Notifications.addNotificationResponseReceivedListener((response) => {
  const { notification_id, sent_at } = response.notification.request.content.data;
  const openedAt = new Date();
  const timeToOpen = (openedAt - new Date(sent_at)) / 1000; // seconds

  analytics.track('NOTIFICATION_OPENED', {
    notification_id,
    user_id: getCurrentUserId(),
    opened_at: openedAt,
    time_to_open: timeToOpen,
    deep_link: response.notification.request.content.data.deep_link,
  });
});
```

## Key Metrics

```sql
-- Delivery rate
SELECT
  COUNT(DISTINCT CASE WHEN event = 'DELIVERED' THEN notification_id END) /
  COUNT(DISTINCT CASE WHEN event = 'SENT' THEN notification_id END) * 100 AS delivery_rate
FROM notification_events
WHERE DATE(created_at) = CURRENT_DATE;

-- Open rate
SELECT
  COUNT(DISTINCT CASE WHEN event = 'OPENED' THEN notification_id END) /
  COUNT(DISTINCT CASE WHEN event = 'DELIVERED' THEN notification_id END) * 100 AS open_rate
FROM notification_events
WHERE DATE(created_at) = CURRENT_DATE;

-- Time to open (median)
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY time_to_open) AS median_time_to_open
FROM notification_events
WHERE event = 'OPENED'
  AND DATE(created_at) = CURRENT_DATE;

-- Conversion rate by notification type
SELECT
  notification_type,
  COUNT(DISTINCT CASE WHEN event = 'CONVERSION' THEN user_id END) /
  COUNT(DISTINCT CASE WHEN event = 'OPENED' THEN user_id END) * 100 AS conversion_rate
FROM notification_events
WHERE DATE(created_at) >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY notification_type;
```
