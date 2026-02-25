# Notification Channels and Categories

## Android Channels

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

## iOS Categories

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
