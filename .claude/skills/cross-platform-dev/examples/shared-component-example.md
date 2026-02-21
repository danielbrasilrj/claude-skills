# Example: Adaptive Card Component

This example shows a complete adaptive component that works across iOS, Android, and Web with platform-appropriate behavior.

## Shared Component (Default)

```typescript
// src/shared/components/Card/Card.tsx
import React from 'react';
import { View, StyleSheet, Pressable, ViewStyle } from 'react-native';
import { useResponsive } from '../../hooks/useResponsive';
import { tokens } from '../../theme/tokens';

interface CardProps {
  children: React.ReactNode;
  onPress?: () => void;
  variant?: 'elevated' | 'outlined' | 'filled';
  style?: ViewStyle;
  testID?: string;
  accessibilityLabel?: string;
}

export function Card({
  children,
  onPress,
  variant = 'elevated',
  style,
  testID,
  accessibilityLabel,
}: CardProps) {
  const { breakpoint } = useResponsive();
  const cardStyle = [
    styles.base,
    styles[variant],
    breakpoint === 'desktop' && styles.desktopPadding,
    style,
  ];

  if (onPress) {
    return (
      <Pressable
        onPress={onPress}
        style={({ pressed }) => [
          ...cardStyle,
          pressed && styles.pressed,
        ]}
        testID={testID}
        accessibilityLabel={accessibilityLabel}
        accessibilityRole="button"
      >
        {children}
      </Pressable>
    );
  }

  return (
    <View style={cardStyle} testID={testID} accessibilityLabel={accessibilityLabel}>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  base: {
    borderRadius: tokens.borderRadius.md,
    padding: tokens.spacing.md,
    marginBottom: tokens.spacing.sm,
  },
  elevated: {
    backgroundColor: tokens.color.surface,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  outlined: {
    backgroundColor: tokens.color.surface,
    borderWidth: 1,
    borderColor: tokens.color.border,
  },
  filled: {
    backgroundColor: tokens.color.surfaceVariant,
  },
  pressed: {
    opacity: 0.85,
  },
  desktopPadding: {
    padding: tokens.spacing.lg,
  },
});
```

## Web Override (with hover support)

```typescript
// src/shared/components/Card/Card.web.tsx
import React, { useState } from 'react';
import { View, StyleSheet, Pressable, ViewStyle } from 'react-native';
import { useResponsive } from '../../hooks/useResponsive';
import { tokens } from '../../theme/tokens';

interface CardProps {
  children: React.ReactNode;
  onPress?: () => void;
  variant?: 'elevated' | 'outlined' | 'filled';
  style?: ViewStyle;
  testID?: string;
  accessibilityLabel?: string;
}

export function Card({
  children,
  onPress,
  variant = 'elevated',
  style,
  testID,
  accessibilityLabel,
}: CardProps) {
  const [isHovered, setIsHovered] = useState(false);
  const { breakpoint } = useResponsive();

  const cardStyle = [
    styles.base,
    styles[variant],
    breakpoint === 'desktop' && styles.desktopPadding,
    isHovered && onPress && styles.hovered,
    style,
  ];

  const hoverProps = onPress
    ? {
        onMouseEnter: () => setIsHovered(true),
        onMouseLeave: () => setIsHovered(false),
      }
    : {};

  if (onPress) {
    return (
      <Pressable
        onPress={onPress}
        style={cardStyle}
        testID={testID}
        accessibilityLabel={accessibilityLabel}
        accessibilityRole="button"
        // @ts-expect-error -- web-only props
        {...hoverProps}
      >
        {children}
      </Pressable>
    );
  }

  return (
    <View style={cardStyle} testID={testID} accessibilityLabel={accessibilityLabel}>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  base: {
    borderRadius: tokens.borderRadius.md,
    padding: tokens.spacing.md,
    marginBottom: tokens.spacing.sm,
    // Web: smooth transitions
    // @ts-expect-error -- web-only
    transition: 'box-shadow 0.2s ease, transform 0.2s ease',
    cursor: 'default',
  },
  elevated: {
    backgroundColor: tokens.color.surface,
    // @ts-expect-error -- web-only
    boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)',
  },
  outlined: {
    backgroundColor: tokens.color.surface,
    borderWidth: 1,
    borderColor: tokens.color.border,
  },
  filled: {
    backgroundColor: tokens.color.surfaceVariant,
  },
  hovered: {
    // @ts-expect-error -- web-only
    boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
    transform: [{ translateY: -2 }],
    cursor: 'pointer',
  },
  desktopPadding: {
    padding: tokens.spacing.lg,
  },
});
```

## Usage in a Feature Screen

```typescript
// src/features/products/ui/ProductListScreen.tsx
import React from 'react';
import { FlatList, Text, Image } from 'react-native';
import { Card } from '../../../shared/components/Card/Card';
import { useProductStore } from '../../../shared/state/product.store';
import { useNavigation } from '../../../shared/navigation/useNavigation';

export function ProductListScreen() {
  const { products, isLoading } = useProductStore();
  const navigation = useNavigation();

  return (
    <FlatList
      data={products}
      keyExtractor={(item) => item.id}
      renderItem={({ item }) => (
        <Card
          onPress={() => navigation.navigate('products/detail', { id: item.id })}
          accessibilityLabel={`View ${item.name}, priced at ${item.price}`}
          testID={`product-card-${item.id}`}
        >
          <Image
            source={{ uri: item.imageUrl }}
            style={{ width: '100%', height: 200, borderRadius: 8 }}
            accessibilityLabel={item.name}
          />
          <Text style={{ fontSize: 18, fontWeight: '600', marginTop: 8 }}>
            {item.name}
          </Text>
          <Text style={{ fontSize: 14, color: '#666', marginTop: 4 }}>
            ${item.price.toFixed(2)}
          </Text>
        </Card>
      )}
    />
  );
}
```

## Key Takeaways

1. **Shared by default**: The base `Card.tsx` works on all platforms.
2. **Web override**: `Card.web.tsx` adds hover states and CSS transitions that only make sense on web.
3. **No iOS/Android override needed**: The base component uses RN primitives that work well on both mobile platforms.
4. **Accessibility built in**: `accessibilityLabel` and `accessibilityRole` are set in the shared component.
5. **Responsive**: The component adapts padding based on breakpoint.
6. **Testable**: `testID` enables E2E testing on all platforms.
