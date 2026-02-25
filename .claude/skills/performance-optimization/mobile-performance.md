# Mobile Performance

## React Native Performance

**1. Hermes JavaScript Engine**

Hermes reduces:

- App size: -50% to -75%
- Memory usage: -30% to -50%
- TTI (Time to Interactive): -50%

**Enable Hermes:**

```gradle
// android/app/build.gradle
project.ext.react = [
    enableHermes: true
]
```

```ruby
# ios/Podfile
use_react_native!(
  :path => config[:reactNativePath],
  :hermes_enabled => true
)
```

**2. RAM bundles (inline requires)**

```javascript
// metro.config.js
module.exports = {
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: true, // Enable inline requires
      },
    }),
  },
};
```

**3. FlatList optimization**

```jsx
// Bad: Slow with 1000+ items
<ScrollView>
  {items.map(item => <ItemCard key={item.id} item={item} />)}
</ScrollView>

// Good: Virtualized list
<FlatList
  data={items}
  renderItem={({ item }) => <ItemCard item={item} />}
  keyExtractor={item => item.id}

  // Performance optimizations
  removeClippedSubviews={true}
  maxToRenderPerBatch={10}
  updateCellsBatchingPeriod={50}
  initialNumToRender={10}
  windowSize={5}

  // Use memo for items
  ItemSeparatorComponent={Separator}
  getItemLayout={(data, index) => ({
    length: ITEM_HEIGHT,
    offset: ITEM_HEIGHT * index,
    index,
  })}
/>
```

**4. Image optimization**

```jsx
// Use FastImage instead of Image
import FastImage from 'react-native-fast-image';

<FastImage
  source={{
    uri: 'https://example.com/image.jpg',
    priority: FastImage.priority.high,
    cache: FastImage.cacheControl.immutable,
  }}
  resizeMode={FastImage.resizeMode.cover}
  style={{ width: 200, height: 200 }}
/>;
```

**5. Avoid unnecessary re-renders**

```jsx
// Use React.memo for pure components
const ItemCard = React.memo(({ item, onPress }) => {
  return (
    <TouchableOpacity onPress={() => onPress(item.id)}>
      <Text>{item.title}</Text>
    </TouchableOpacity>
  );
});

// Memoize callbacks
function ItemList({ items }) {
  const handlePress = useCallback(
    (id) => {
      navigation.navigate('Detail', { id });
    },
    [navigation],
  );

  return items.map((item) => <ItemCard key={item.id} item={item} onPress={handlePress} />);
}
```

## Android-Specific Optimizations

**1. Enable Proguard (minification)**

```gradle
// android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

**2. Enable Multidex (if needed)**

```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}
```

**3. Reduce APK size**

```gradle
android {
    splits {
        abi {
            enable true
            reset()
            include 'armeabi-v7a', 'arm64-v8a'
            universalApk false
        }
    }
}
```

## iOS-Specific Optimizations

**1. Enable Bitcode (if not using Hermes)**

```ruby
# ios/Podfile
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'YES'
    end
  end
end
```

**2. Optimize images with Xcode**

- Use Asset Catalogs
- Enable "Compress PNG Files"
- Use @1x, @2x, @3x image sets

**3. Reduce IPA size**

- Enable "Dead Code Stripping"
- Enable "Strip Debug Symbols"
- Use "Smallest" code optimization level for Release builds
