# Mobile CI/CD Patterns

## EAS Build (Expo)

**Installation:**

```bash
npm install -g eas-cli
eas login
eas build:configure
```

**eas.json:**

```json
{
  "cli": {
    "version": ">= 5.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": true
      }
    },
    "preview": {
      "distribution": "internal",
      "channel": "preview"
    },
    "production": {
      "autoIncrement": true,
      "channel": "production"
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "your@email.com",
        "ascAppId": "1234567890",
        "appleTeamId": "ABCD123456"
      },
      "android": {
        "serviceAccountKeyPath": "./google-play-key.json",
        "track": "internal"
      }
    }
  }
}
```

**GitHub Actions Workflow:**

```yaml
name: EAS Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Setup EAS
        uses: expo/expo-github-action@v8
        with:
          eas-version: latest
          token: ${{ secrets.EXPO_TOKEN }}

      - name: Install dependencies
        run: npm ci

      - name: Build iOS (production)
        run: eas build --platform ios --profile production --non-interactive

      - name: Build Android (production)
        run: eas build --platform android --profile production --non-interactive
```

**Cost Optimization:**

```yaml
# Only build iOS on main branch (expensive macOS runner)
- name: Build iOS
  if: github.ref == 'refs/heads/main'
  run: eas build --platform ios --profile production --non-interactive

# Build Android on all branches (cheap Linux runner)
- name: Build Android
  run: eas build --platform android --profile production --non-interactive
```

## Fastlane (Native React Native)

**Installation:**

```bash
cd ios
bundle install
bundle exec fastlane init
```

**Fastfile (ios/fastlane/Fastfile):**

```ruby
default_platform(:ios)

platform :ios do
  desc "Build and deploy to TestFlight"
  lane :beta do
    # Increment build number
    increment_build_number(xcodeproj: "MyApp.xcodeproj")

    # Match certificates (code signing)
    match(type: "appstore", readonly: true)

    # Build app
    build_app(
      scheme: "MyApp",
      export_method: "app-store"
    )

    # Upload to TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )

    # Commit version bump
    commit_version_bump(xcodeproj: "MyApp.xcodeproj")
  end

  desc "Deploy to App Store"
  lane :release do
    match(type: "appstore", readonly: true)
    build_app(scheme: "MyApp")
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false,
      force: true,
      precheck_include_in_app_purchases: false
    )
  end
end
```

**GitHub Actions:**

```yaml
name: iOS Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: macos-14 # M1 runner (faster)
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install dependencies
        run: npm ci

      - name: Install Pods
        run: cd ios && pod install

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
          working-directory: ios

      - name: Build and deploy to TestFlight
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          FASTLANE_USER: ${{ secrets.APPLE_ID }}
          FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD: ${{ secrets.APP_STORE_CONNECT_KEY }}
        run: |
          cd ios
          bundle exec fastlane beta
```

## Android (Gradle)

**GitHub Actions:**

```yaml
name: Android Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}

      - name: Build Release APK
        run: cd android && ./gradlew assembleRelease

      - name: Sign APK
        uses: r0adkll/sign-android-release@v1
        with:
          releaseDirectory: android/app/build/outputs/apk/release
          signingKeyBase64: ${{ secrets.SIGNING_KEY }}
          alias: ${{ secrets.KEY_ALIAS }}
          keyStorePassword: ${{ secrets.KEY_STORE_PASSWORD }}
          keyPassword: ${{ secrets.KEY_PASSWORD }}

      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: com.example.app
          releaseFiles: android/app/build/outputs/apk/release/*.apk
          track: internal
```
