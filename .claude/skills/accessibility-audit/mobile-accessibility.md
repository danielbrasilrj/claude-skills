# Mobile Accessibility (iOS/Android)

## iOS Accessibility Features

**Touch Target Sizes:**

- Minimum: 44x44 points
- Recommended: 48x48 points or larger

```swift
// SwiftUI
Button("Action") {
    // Action
}
.frame(minWidth: 44, minHeight: 44)

// UIKit
button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
```

**Accessibility Labels:**

```swift
Image("star")
    .accessibilityLabel("Favorite")
    .accessibilityHint("Double tap to add to favorites")

Button(action: {}) {
    Image(systemName: "trash")
}
.accessibilityLabel("Delete item")
```

**Dynamic Type Support:**

```swift
Text("Hello World")
    .font(.body)
    .dynamicTypeSize(.xSmall ... .xxxLarge)
```

## Android Accessibility Features

**Touch Target Sizes:**

- Minimum: 48x48 dp
- Material Design: 48x48 dp minimum

```xml
<Button
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:minWidth="48dp"
    android:minHeight="48dp"
    android:text="Action" />
```

**Content Descriptions:**

```xml
<ImageButton
    android:src="@drawable/ic_favorite"
    android:contentDescription="Add to favorites" />
```

```kotlin
// Programmatically
imageButton.contentDescription = "Add to favorites"
```

**Text Scaling:**

```xml
<TextView
    android:text="Hello World"
    android:textSize="16sp" /> <!-- Use sp for text, not dp -->
```

## React Native Accessibility

```jsx
// Touch target size
<TouchableOpacity
  style={{ minWidth: 48, minHeight: 48 }}
  accessible={true}
  accessibilityLabel="Add to cart"
  accessibilityHint="Double tap to add this item to your cart"
  accessibilityRole="button"
>
  <CartIcon />
</TouchableOpacity>;

// Screen reader announcements
import { AccessibilityInfo } from 'react-native';

AccessibilityInfo.announceForAccessibility('Item added to cart');

// Focus management
const buttonRef = useRef(null);

AccessibilityInfo.setAccessibilityFocus(findNodeHandle(buttonRef.current));
```
