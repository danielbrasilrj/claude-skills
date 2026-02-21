# Notification System Reference

Comprehensive reference for implementing push notifications and in-app messaging across mobile and web platforms.

## Table of Contents

- [Provider Deep Dive](#provider-deep-dive)
- [Notification Channels and Categories](#notification-channels-and-categories)
- [Deep Linking Strategies](#deep-linking-strategies)
- [Scheduling Patterns](#scheduling-patterns)
- [Analytics and Tracking](#analytics-and-tracking)
- [Advanced Patterns](#advanced-patterns)
- [Platform-Specific Setup](#platform-specific-setup)

---

## Provider Deep Dive

### Firebase Cloud Messaging (FCM)

**Setup:**
```javascript
// Install dependencies
npm install firebase-admin

// Initialize Admin SDK (server-side)
const admin = require('firebase-admin');
const serviceAccount = require('./path/to/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Send notification
async function sendNotification(token, title, body, data) {
  const message = {
    token: token,
    notification: {
      title: title,
      body: body
    },
    data: data, // Custom key-value pairs
    android: {
      priority: 'high',
      notification: {
        channelId: 'default',
        sound: 'default'
      }
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1
        }
      }
    }
  };
  
  const response = await admin.messaging().send(message);
  return response;
}
```

**Token Registration (React Native):**
```javascript
import messaging from '@react-native-firebase/messaging';

async function registerForPushNotifications() {
  const authStatus = await messaging().requestPermission();
  const enabled =
    authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
    authStatus === messaging.AuthorizationStatus.PROVISIONAL;

  if (enabled) {
    const token = await messaging().getToken();
    // Send token to your server
    await sendTokenToServer(token);
  }
}

// Handle token refresh
messaging().onTokenRefresh(async token => {
  await sendTokenToServer(token);
});
```

### Apple Push Notification service (APNs)

**Server Setup (Node.js):**
```javascript
const apn = require('apn');

const options = {
  token: {
    key: './path/to/AuthKey_XXXXX.p8',
    keyId: 'KEY_ID',
    teamId: 'TEAM_ID'
  },
  production: true // false for sandbox
};

const apnProvider = new apn.Provider(options);

async function sendAPNs(deviceToken, title, body, badge, data) {
  const notification = new apn.Notification();
  notification.alert = {
    title: title,
    body: body
  };
  notification.badge = badge;
  notification.sound = 'default';
  notification.payload = data;
  notification.topic = 'com.yourapp.bundleid';

  const result = await apnProvider.send(notification, deviceToken);
  return result;
}
```

### OneSignal

**Setup:**
```javascript
// React Native
import OneSignal from 'react-native-onesignal';

OneSignal.setAppId('YOUR_ONESIGNAL_APP_ID');

// Prompt for permission
OneSignal.promptForPushNotificationsWithUserResponse(response => {
  console.log("Prompt response:", response);
});

// Handle notification opened
OneSignal.setNotificationOpenedHandler(notification => {
  const data = notification.notification.additionalData;
  // Handle deep link
  handleDeepLink(data.deep_link);
});

// Tag users for segmentation
OneSignal.sendTag('user_type', 'premium');
OneSignal.sendTags({
  user_level: '10',
  subscription_status: 'active'
});
```

**Server-side API:**
```javascript
const axios = require('axios');

async function sendOneSignalNotification(playerIds, title, body, data) {
  const response = await axios.post(
    'https://onesignal.com/api/v1/notifications',
    {
      app_id: 'YOUR_APP_ID',
      include_player_ids: playerIds,
      headings: { en: title },
      contents: { en: body },
      data: data,
      ios_badgeType: 'Increase',
      ios_badgeCount: 1
    },
    {
      headers: {
        'Authorization': 'Basic YOUR_REST_API_KEY',
        'Content-Type': 'application/json'
      }
    }
  );
  return response.data;
}
```

### Expo Notifications

**Setup:**
```javascript
import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

async function registerForPushNotificationsAsync() {
  let token;
  
  if (Device.isDevice) {
    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;
    
    if (existingStatus !== 'granted') {
      const { status } = await Notifications.requestPermissionsAsync();
      finalStatus = status;
    }
    
    if (finalStatus !== 'granted') {
      alert('Failed to get push token for push notification!');
      return;
    }
    
    token = (await Notifications.getExpoPushTokenAsync()).data;
  } else {
    alert('Must use physical device for Push Notifications');
  }

  return token;
}

// Configure notification channel (Android)
if (Platform.OS === 'android') {
  Notifications.setNotificationChannelAsync('default', {
    name: 'default',
    importance: Notifications.AndroidImportance.MAX,
    vibrationPattern: [0, 250, 250, 250],
    lightColor: '#FF231F7C',
  });
}
```

---

## Notification Channels and Categories

### Android Channels

Channels group notifications by type and allow users to control settings per channel.

```kotlin
// Kotlin (Android)
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

fun createNotificationChannels(context: Context) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Transactional channel (high importance)
        val transactionalChannel = NotificationChannel(
            "transactional",
            "Order Updates",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Order confirmations, shipping updates"
            enableLights(true)
            lightColor = Color.BLUE
            enableVibration(true)
        }
        
        // Marketing channel (default importance)
        val marketingChannel = NotificationChannel(
            "marketing",
            "Promotions",
            NotificationManager.IMPORTANCE_DEFAULT
        ).apply {
            description = "Sales, new arrivals, exclusive offers"
        }
        
        // Reminder channel (high importance)
        val reminderChannel = NotificationChannel(
            "reminders",
            "Reminders",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Appointment reminders, task notifications"
            setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION), null)
        }
        
        notificationManager.createNotificationChannels(
            listOf(transactionalChannel, marketingChannel, reminderChannel)
        )
    }
}
```

### iOS Categories

Categories define notification types and available actions.

```swift
// Swift (iOS)
import UserNotifications

func setupNotificationCategories() {
    let center = UNUserNotificationCenter.current()
    
    // Order category with actions
    let viewAction = UNNotificationAction(
        identifier: "VIEW_ORDER",
        title: "View Order",
        options: [.foreground]
    )
    let trackAction = UNNotificationAction(
        identifier: "TRACK_SHIPMENT",
        title: "Track Shipment",
        options: [.foreground]
    )
    let orderCategory = UNNotificationCategory(
        identifier: "ORDER_UPDATE",
        actions: [viewAction, trackAction],
        intentIdentifiers: [],
        options: []
    )
    
    // Message category with reply
    let replyAction = UNTextInputNotificationAction(
        identifier: "REPLY_MESSAGE",
        title: "Reply",
        options: [],
        textInputButtonTitle: "Send",
        textInputPlaceholder: "Type your message"
    )
    let messageCategory = UNNotificationCategory(
        identifier: "MESSAGE",
        actions: [replyAction],
        intentIdentifiers: [],
        options: []
    )
    
    center.setNotificationCategories([orderCategory, messageCategory])
}
```

---

## Deep Linking Strategies

### Universal Links (iOS) + App Links (Android)

**iOS (Associated Domains):**

1. Add domain to Xcode: Capabilities → Associated Domains → `applinks:yourdomain.com`

2. Host apple-app-site-association file at `https://yourdomain.com/.well-known/apple-app-site-association`:
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.yourapp.bundleid",
        "paths": ["/order/*", "/product/*", "/profile/*"]
      }
    ]
  }
}
```

3. Handle in AppDelegate:
```swift
func application(_ application: UIApplication,
                 continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL else {
        return false
    }
    
    // Handle URL: https://yourdomain.com/order/12345
    handleDeepLink(url)
    return true
}
```

**Android (App Links):**

1. Add intent filter in AndroidManifest.xml:
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="yourdomain.com"
        android:pathPrefix="/order" />
</intent-filter>
```

2. Host assetlinks.json at `https://yourdomain.com/.well-known/assetlinks.json`:
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.yourapp.packagename",
    "sha256_cert_fingerprints": ["SHA256_FINGERPRINT"]
  }
}]
```

### Custom URL Schemes

**React Native (react-navigation):**
```javascript
import { Linking } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';

const linking = {
  prefixes: ['myapp://', 'https://yourdomain.com'],
  config: {
    screens: {
      Home: '',
      Order: 'order/:orderId',
      Product: 'product/:productId',
      Profile: 'profile/:section?'
    }
  }
};

function App() {
  return (
    <NavigationContainer linking={linking}>
      {/* Your navigator */}
    </NavigationContainer>
  );
}

// Handle notification tap
useEffect(() => {
  const subscription = Notifications.addNotificationResponseReceivedListener(response => {
    const url = response.notification.request.content.data.deep_link;
    if (url) {
      Linking.openURL(url);
    }
  });
  
  return () => subscription.remove();
}, []);
```

### Attribution with UTM Parameters

Always include tracking params in deep links:
```javascript
function buildDeepLink(path, campaign, source, medium) {
  const baseUrl = 'myapp://';
  const params = new URLSearchParams({
    utm_campaign: campaign,
    utm_source: source,
    utm_medium: medium,
    utm_term: 'push_notification'
  });
  
  return `${baseUrl}${path}?${params.toString()}`;
}

// Example
const deepLink = buildDeepLink(
  'product/12345',
  'flash_sale',
  'push',
  'notification'
);
// Result: myapp://product/12345?utm_campaign=flash_sale&utm_source=push&utm_medium=notification&utm_term=push_notification
```

---

## Scheduling Patterns

### Optimal Send Times

**By Time Zone:**
```javascript
const moment = require('moment-timezone');

async function scheduleNotificationByTimezone(users, notification, targetHour) {
  const batches = {};
  
  // Group users by timezone
  users.forEach(user => {
    const tz = user.timezone || 'America/New_York';
    if (!batches[tz]) {
      batches[tz] = [];
    }
    batches[tz].push(user);
  });
  
  // Schedule for each timezone
  for (const [timezone, batchUsers] of Object.entries(batches)) {
    const sendTime = moment.tz(timezone)
      .hour(targetHour)
      .minute(0)
      .second(0);
    
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
  
  const optimalHour = Object.entries(hourCounts)
    .sort(([, a], [, b]) => b - a)[0]?.[0] || 10; // Default to 10am
  
  return parseInt(optimalHour);
}
```

### Rate Limiting Implementation

```javascript
const Queue = require('bull');
const notificationQueue = new Queue('notifications', 'redis://localhost:6379');

// Configure rate limiting
async function enqueueNotifications(users, notification) {
  const batchSize = users.length < 10000 ? users.length : 
                    users.length < 100000 ? 2000 : 5000;
  
  const delayBetweenBatches = users.length < 10000 ? 0 :
                              users.length < 100000 ? 6000 : 12000; // ms
  
  for (let i = 0; i < users.length; i += batchSize) {
    const batch = users.slice(i, i + batchSize);
    const delay = (i / batchSize) * delayBetweenBatches;
    
    await notificationQueue.add(
      { users: batch, notification },
      { delay, attempts: 3, backoff: { type: 'exponential', delay: 5000 } }
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

### Recurring Notifications

```javascript
// Daily reminder at user's preferred time
async function scheduleRecurringReminder(userId, reminderType, preferredHour) {
  const user = await getUser(userId);
  const timezone = user.timezone;
  
  const cron = require('node-cron');
  
  // Schedule daily at preferred hour
  cron.schedule(`0 ${preferredHour} * * *`, async () => {
    const now = moment.tz(timezone);
    if (now.hour() === preferredHour) {
      await sendNotification(user.token, {
        title: getReminderTitle(reminderType),
        body: getReminderBody(reminderType, user),
        data: { type: reminderType }
      });
    }
  }, {
    timezone: timezone
  });
}
```

---

## Analytics and Tracking

### Event Schema

```javascript
const notificationEvents = {
  NOTIFICATION_SENT: {
    notification_id: 'string',
    user_id: 'string',
    notification_type: 'string',
    channel: 'string', // 'push', 'in-app', 'email'
    campaign_id: 'string',
    sent_at: 'timestamp'
  },
  
  NOTIFICATION_DELIVERED: {
    notification_id: 'string',
    user_id: 'string',
    delivered_at: 'timestamp'
  },
  
  NOTIFICATION_OPENED: {
    notification_id: 'string',
    user_id: 'string',
    opened_at: 'timestamp',
    time_to_open: 'number', // seconds since delivery
    deep_link: 'string'
  },
  
  NOTIFICATION_DISMISSED: {
    notification_id: 'string',
    user_id: 'string',
    dismissed_at: 'timestamp'
  },
  
  NOTIFICATION_ACTION: {
    notification_id: 'string',
    user_id: 'string',
    action_id: 'string',
    action_at: 'timestamp'
  },
  
  NOTIFICATION_FAILED: {
    notification_id: 'string',
    user_id: 'string',
    error_code: 'string',
    error_message: 'string',
    failed_at: 'timestamp'
  }
};
```

### Tracking Implementation

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
      sent_at: new Date()
    });
    
    return notificationId;
  } catch (error) {
    analytics.track('NOTIFICATION_FAILED', {
      notification_id: notificationId,
      user_id: user.id,
      error_code: error.code,
      error_message: error.message,
      failed_at: new Date()
    });
    throw error;
  }
}

// Track notification opened (client-side)
Notifications.addNotificationResponseReceivedListener(response => {
  const { notification_id, sent_at } = response.notification.request.content.data;
  const openedAt = new Date();
  const timeToOpen = (openedAt - new Date(sent_at)) / 1000; // seconds
  
  analytics.track('NOTIFICATION_OPENED', {
    notification_id,
    user_id: getCurrentUserId(),
    opened_at: openedAt,
    time_to_open: timeToOpen,
    deep_link: response.notification.request.content.data.deep_link
  });
});
```

### Key Metrics

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

---

## Advanced Patterns

### In-App Notification Center

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
    setNotifications(prev => 
      prev.map(n => n.id === notificationId ? { ...n, read: true } : n)
    );
  }
  
  return (
    <FlatList
      data={notifications}
      keyExtractor={item => item.id}
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
            borderColor: '#ddd'
          }}
        >
          <Text style={{ fontWeight: item.read ? 'normal' : 'bold' }}>
            {item.title}
          </Text>
          <Text>{item.body}</Text>
          <Text style={{ fontSize: 12, color: '#666' }}>
            {formatRelativeTime(item.created_at)}
          </Text>
        </TouchableOpacity>
      )}
    />
  );
}
```

### Frequency Capping

```javascript
// Server-side frequency cap
async function canSendNotification(userId, notificationType) {
  const redis = require('redis').createClient();
  
  const caps = {
    marketing: { count: 2, period: 86400 }, // 2 per day
    transactional: { count: 10, period: 3600 }, // 10 per hour
    reminder: { count: 5, period: 86400 } // 5 per day
  };
  
  const cap = caps[notificationType];
  if (!cap) return true; // No cap defined
  
  const key = `notification_count:${userId}:${notificationType}`;
  const count = await redis.get(key) || 0;
  
  if (count >= cap.count) {
    return false;
  }
  
  // Increment and set expiry
  await redis.incr(key);
  await redis.expire(key, cap.period);
  
  return true;
}
```

### Quiet Hours

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
    const sendTime = moment.tz(user.timezone)
      .hour(8)
      .minute(0)
      .second(0);
    
    if (sendTime.isBefore(moment())) {
      sendTime.add(1, 'day');
    }
    
    await scheduleNotification(user, notification, sendTime.toDate());
  } else {
    await sendNotification(user.token, notification);
  }
}
```

### Rich Notifications

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

---

## Platform-Specific Setup

### React Native (Full Setup)

```bash
# Install dependencies
npm install @react-native-firebase/app @react-native-firebase/messaging
npx pod-install # iOS only

# iOS: Add GoogleService-Info.plist to ios/ folder
# Android: Add google-services.json to android/app/ folder
```

**iOS configuration (AppDelegate.m):**
```objc
#import <Firebase.h>
#import <UserNotifications/UserNotifications.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [FIRApp configure];
  [UNUserNotificationCenter currentNotificationCenter].delegate = self;
  return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  // Required for Firebase
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
  completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

@end
```

**Android configuration (AndroidManifest.xml):**
```xml
<manifest>
  <application>
    <meta-data
      android:name="com.google.firebase.messaging.default_notification_channel_id"
      android:value="default" />
      
    <service
      android:name=".MyFirebaseMessagingService"
      android:exported="false">
      <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
      </intent-filter>
    </service>
  </application>
</manifest>
```

### Expo (Managed Workflow)

```json
// app.json
{
  "expo": {
    "plugins": [
      [
        "expo-notifications",
        {
          "icon": "./assets/notification-icon.png",
          "color": "#ffffff",
          "sounds": ["./assets/notification-sound.wav"]
        }
      ]
    ],
    "notification": {
      "icon": "./assets/notification-icon.png",
      "color": "#000000",
      "androidMode": "default",
      "androidCollapsedTitle": "#{unread_notifications} new notifications"
    }
  }
}
```

### Web (Service Worker)

```javascript
// firebase-messaging-sw.js (public folder)
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "YOUR_API_KEY",
  projectId: "YOUR_PROJECT_ID",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/firebase-logo.png',
    data: payload.data
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.openWindow(event.notification.data.url)
  );
});
```

---

## A/B Testing Framework

```javascript
const crypto = require('crypto');

function assignVariant(userId, experimentId, variants) {
  // Deterministic hash-based assignment
  const hash = crypto
    .createHash('md5')
    .update(`${experimentId}:${userId}`)
    .digest('hex');
  
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
      body: 'Track your package now'
    },
    {
      name: 'variant_a',
      weight: 50,
      title: '📦 Great news! Your order is on the way',
      body: 'See when it arrives'
    }
  ]
};

// Usage
async function sendExperimentNotification(user, experimentId) {
  const variant = assignVariant(user.id, experimentId, experiment.variants);
  
  analytics.track('NOTIFICATION_EXPERIMENT_ASSIGNED', {
    user_id: user.id,
    experiment_id: experimentId,
    variant: variant.name
  });
  
  await sendNotification(user.token, {
    title: variant.title,
    body: variant.body,
    data: {
      experiment_id: experimentId,
      variant: variant.name
    }
  });
}
```

---

This reference provides comprehensive implementation details for all major notification providers, platforms, and patterns. Refer to SKILL.md for high-level procedures and use this document for deep technical implementation guidance.
