# Provider Setup

## Firebase Cloud Messaging (FCM)

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
messaging().onTokenRefresh(async (token) => {
  await sendTokenToServer(token);
});
```

## Apple Push Notification service (APNs)

**Server Setup (Node.js):**

```javascript
const apn = require('apn');

const options = {
  token: {
    key: './path/to/AuthKey_XXXXX.p8',
    keyId: 'KEY_ID',
    teamId: 'TEAM_ID',
  },
  production: true, // false for sandbox
};

const apnProvider = new apn.Provider(options);

async function sendAPNs(deviceToken, title, body, badge, data) {
  const notification = new apn.Notification();
  notification.alert = {
    title: title,
    body: body,
  };
  notification.badge = badge;
  notification.sound = 'default';
  notification.payload = data;
  notification.topic = 'com.yourapp.bundleid';

  const result = await apnProvider.send(notification, deviceToken);
  return result;
}
```

## OneSignal

**Setup:**

```javascript
// React Native
import OneSignal from 'react-native-onesignal';

OneSignal.setAppId('YOUR_ONESIGNAL_APP_ID');

// Prompt for permission
OneSignal.promptForPushNotificationsWithUserResponse((response) => {
  console.log('Prompt response:', response);
});

// Handle notification opened
OneSignal.setNotificationOpenedHandler((notification) => {
  const data = notification.notification.additionalData;
  // Handle deep link
  handleDeepLink(data.deep_link);
});

// Tag users for segmentation
OneSignal.sendTag('user_type', 'premium');
OneSignal.sendTags({
  user_level: '10',
  subscription_status: 'active',
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
      ios_badgeCount: 1,
    },
    {
      headers: {
        Authorization: 'Basic YOUR_REST_API_KEY',
        'Content-Type': 'application/json',
      },
    },
  );
  return response.data;
}
```

## Expo Notifications

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
