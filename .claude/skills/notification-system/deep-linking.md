# Deep Linking Strategies

## Universal Links (iOS) + App Links (Android)

**iOS (Associated Domains):**

1. Add domain to Xcode: Capabilities -> Associated Domains -> `applinks:yourdomain.com`

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
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.yourapp.packagename",
      "sha256_cert_fingerprints": ["SHA256_FINGERPRINT"]
    }
  }
]
```

## Custom URL Schemes

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
      Profile: 'profile/:section?',
    },
  },
};

function App() {
  return <NavigationContainer linking={linking}>{/* Your navigator */}</NavigationContainer>;
}

// Handle notification tap
useEffect(() => {
  const subscription = Notifications.addNotificationResponseReceivedListener((response) => {
    const url = response.notification.request.content.data.deep_link;
    if (url) {
      Linking.openURL(url);
    }
  });

  return () => subscription.remove();
}, []);
```

## Attribution with UTM Parameters

Always include tracking params in deep links:

```javascript
function buildDeepLink(path, campaign, source, medium) {
  const baseUrl = 'myapp://';
  const params = new URLSearchParams({
    utm_campaign: campaign,
    utm_source: source,
    utm_medium: medium,
    utm_term: 'push_notification',
  });

  return `${baseUrl}${path}?${params.toString()}`;
}

// Example
const deepLink = buildDeepLink('product/12345', 'flash_sale', 'push', 'notification');
// Result: myapp://product/12345?utm_campaign=flash_sale&utm_source=push&utm_medium=notification&utm_term=push_notification
```
