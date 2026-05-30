# ALONU App - Build Guide

## Project Structure

```
alonu_app/
├── lib/                    # Dart source code
│   ├── main.dart
│   ├── core/              # Core utilities, theme, constants
│   ├── data/              # Data layer (datasources, models, repositories)
│   ├── domain/            # Business logic (entities, repositories, usecases)
│   └── presentation/      # UI layer (pages, providers, widgets)
├── android/               # Android native configuration
├── ios/                   # iOS native configuration
├── pubspec.yaml           # Dependencies
└── analysis_options.yaml  # Lint rules
```

## Architecture

This project follows **Clean Architecture** with **Riverpod** for state management:

- **Presentation Layer**: UI screens, providers, and widgets
- **Domain Layer**: Entities, repositories interfaces, and use cases
- **Data Layer**: Models, datasources, and repository implementations

## Prerequisites

- Flutter SDK: 3.11.0 or higher
- Dart SDK: 3.11.0 or higher
- Android SDK: API 21+ (for Android build)
- Xcode: 14+ (for iOS build)
- CocoaPods (for iOS dependencies)

## Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Code
```bash
# Generate JSON serialization files
flutter pub run build_runner build --delete-conflicting-outputs

# Or use the newer command:
dart run build_runner build --delete-conflicting-outputs
```

### 3. Configure Environment

Create a `.env` file based on `.env.example`:
```bash
cp .env.example .env
```

Update the API base URL and other settings as needed.

## Building

### Android Release Build

#### Setup Signing Key (First time only)

```bash
# Generate a keystore file
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias alonu_release_key

# Move it to the android directory
mv ~/key.jks android/app/
```

#### Build APK
```bash
flutter build apk --release
```

#### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

### iOS Release Build

#### Build Release App
```bash
flutter build ios --release
```

#### Using Xcode
```bash
open ios/Runner.xcworkspace
```

Then select **Product > Archive** in Xcode for App Store submission.

## Code Quality

### Run Linting Analysis
```bash
flutter analyze
```

### Format Code
```bash
flutter format lib/
```

### Run Tests
```bash
flutter test
```

## Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app:
   - Package name: `com.alonu.alonu_app`
   - SHA-1: Get from `keytool -list -v -keystore ~/key.jks`
3. Add iOS app:
   - Bundle ID: `com.alonu.alonuApp`
4. Download configuration files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

## API Integration

The app uses Dio for HTTP requests with:
- Automatic token management via `AuthInterceptor`
- Logging via `LoggingInterceptor`
- Error handling via `Failure` classes

API base URL can be configured in:
- `lib/core/constants/app_constants.dart`
- `.env` file (if env configuration is added)

## State Management (Riverpod)

Providers are organized by feature:
- `auth_provider.dart`: Authentication state
- `artisan_provider.dart`: Artisan data
- `order_provider.dart`: Order data
- `cart_order_provider.dart`: Shopping cart

Example usage:
```dart
final authState = ref.watch(authProvider);
await ref.read(authProvider.notifier).login(email, password);
```

## Navigation

Navigation uses `GoRouter` with deep linking support:
- Splash screen → Onboarding → Login/Register → Home
- Home screen has bottom navigation with nested routes

## Localization

French (fr) and English (en) are supported:
- `lib/core/localization/app_en.arb`
- `lib/core/localization/app_fr.arb`

## Troubleshooting

### Build Issues
- Run `flutter clean`
- Delete `pubspec.lock` and run `flutter pub get`
- Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Android Issues
- Accept licenses: `flutter doctor --android-licenses`
- Update Android SDK tools via Android Studio

### iOS Issues
- Update CocoaPods: `sudo gem install cocoapods`
- Clean pods: `cd ios && rm -rf Pods && pod install`

## Deployment Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Run code analysis: `flutter analyze`
- [ ] Run tests: `flutter test`
- [ ] Build release APK/AAB
- [ ] Test on real devices
- [ ] Update app store metadata
- [ ] Configure app signing keys
- [ ] Set up Firebase
- [ ] Configure API endpoints for production
- [ ] Test all critical user flows
- [ ] Verify permissions and capabilities
- [ ] Submit to app stores

## Documentation

- **Architecture**: See `docs/architecture.md`
- **API Documentation**: See `docs/api.md`
- **Contributing**: See `CONTRIBUTING.md`

## Support

For issues or questions, contact: support@alonu.com
