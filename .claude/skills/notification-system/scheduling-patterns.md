# Scheduling Patterns

## Optimal Send Times

**By Time Zone:**

```javascript
const moment = require('moment-timezone');

async function scheduleNotificationByTimezone(users, notification, targetHour) {
  const batches = {};

  // Group users by timezone
  users.forEach((user) => {
    const tz = user.timezone || 'America/New_York';
    if (!batches[tz]) {
      batches[tz] = [];
    }
    batches[tz].push(user);
  });

  // Schedule for each timezone
  for (const [timezone, batchUsers] of Object.entries(batches)) {
    const sendTime = moment.tz(timezone).hour(targetHour).minute(0).second(0);

    if (sendTime.isBefore(moment())) {
      sendTime.add(1, 'day');
    }

    await scheduleNotificationBatch(batchUsers, notification, sendTime.toDate());
  }
}
```

**Engagement-Based Scheduling:**

```javascript
// Send when user is most likely to engage
function getUserOptimalSendTime(userId) {
  const engagementHistory = getEngagementHistory(userId);

  // Calculate most common engagement hour
  const hourCounts = engagementHistory.reduce((acc, event) => {
    const hour = new Date(event.timestamp).getHours();
    acc[hour] = (acc[hour] || 0) + 1;
    return acc;
  }, {});

  const optimalHour = Object.entries(hourCounts).sort(([, a], [, b]) => b - a)[0]?.[0] || 10; // Default to 10am

  return parseInt(optimalHour);
}
```

## Rate Limiting Implementation

```javascript
const Queue = require('bull');
const notificationQueue = new Queue('notifications', 'redis://localhost:6379');

// Configure rate limiting
async function enqueueNotifications(users, notification) {
  const batchSize = users.length < 10000 ? users.length : users.length < 100000 ? 2000 : 5000;

  const delayBetweenBatches = users.length < 10000 ? 0 : users.length < 100000 ? 6000 : 12000; // ms

  for (let i = 0; i < users.length; i += batchSize) {
    const batch = users.slice(i, i + batchSize);
    const delay = (i / batchSize) * delayBetweenBatches;

    await notificationQueue.add(
      { users: batch, notification },
      { delay, attempts: 3, backoff: { type: 'exponential', delay: 5000 } },
    );
  }
}

// Process queue
notificationQueue.process(async (job) => {
  const { users, notification } = job.data;
  const results = await sendBatchNotifications(users, notification);
  return results;
});
```

## Recurring Notifications

```javascript
// Daily reminder at user's preferred time
async function scheduleRecurringReminder(userId, reminderType, preferredHour) {
  const user = await getUser(userId);
  const timezone = user.timezone;

  const cron = require('node-cron');

  // Schedule daily at preferred hour
  cron.schedule(
    `0 ${preferredHour} * * *`,
    async () => {
      const now = moment.tz(timezone);
      if (now.hour() === preferredHour) {
        await sendNotification(user.token, {
          title: getReminderTitle(reminderType),
          body: getReminderBody(reminderType, user),
          data: { type: reminderType },
        });
      }
    },
    {
      timezone: timezone,
    },
  );
}
```
