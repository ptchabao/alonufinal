# ALONU App - Deployment Guide

## Pre-Deployment Checklist

- [ ] All features implemented and tested
- [ ] Code reviewed and merged to main branch
- [ ] No active console errors or warnings
- [ ] Version bumped in pubspec.yaml
- [ ] Release notes prepared
- [ ] API endpoints configured for production
- [ ] Firebase configured for production
- [ ] App signing certificates configured
- [ ] All permissions declared in manifests
- [ ] Tested on real devices

## Version Management

### Update Version

```bash
# In pubspec.yaml
version: 1.0.0+1
```

Format: `major.minor.patch+buildNumber`

Example progression:
- Development: `1.0.0+1`
- Beta: `1.0.0-beta.1+2`
- Release: `1.0.0+3`

## Android Deployment

### Play Store Requirements

1. **Setup Google Play Developer Account**
   - Cost: $25 one-time fee
   - Create project in Google Play Console

2. **Prepare Signing Key**
   ```bash
   keytool -genkey -v -keystore key.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias alonu_release_key
   ```

3. **Configure Signing** in `android/app/build.gradle.kts`:
   ```kotlin
   signingConfigs {
       release {
           keyAlias = "alonu_release_key"
           keyPassword = System.getenv("KEY_PASSWORD") ?: ""
           storeFile = file("key.jks")
           storePassword = System.getenv("STORE_PASSWORD") ?: ""
       }
   }
   ```

4. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```

5. **Upload to Play Store**
   - Go to Google Play Console
   - Create new release
   - Upload `app-release.aab`
   - Add store listing information
   - Set pricing and distribution
   - Submit for review

### Store Listing

**Title**: ALONU - Artisans Platform

**Description**:
```
ALONU connects you with skilled artisans for all your home service needs.
Find plumbers, electricians, carpenters, and more in your area.

Features:
- Browse local artisans
- View services and pricing
- Book services easily
- Secure payment
- Track orders in real-time
```

**Screenshots**: 5-8 screenshots showing key features

**Category**: Lifestyle

**Content Rating**: 
- Violence: None
- Sexual content: None
- Profanity: Mild
- Alcohol/Tobacco: None

## iOS Deployment

### App Store Requirements

1. **Enroll in Apple Developer Program**
   - Cost: $99 per year
   - Requires Apple ID

2. **Create App ID**
   - Bundle ID: `com.alonu.alonuApp`
   - Capabilities: Push Notifications, Location

3. **Create Provisioning Profiles**
   - Development profile for testing
   - Distribution profile for App Store

4. **Configure in Xcode**
   ```
   Signing & Capabilities:
   - Team ID: [Your Team ID]
   - Bundle ID: com.alonu.alonuApp
   - Deployment Target: iOS 12.0+
   ```

5. **Archive App**
   ```bash
   flutter build ios --release
   open ios/Runner.xcworkspace
   # In Xcode: Product > Archive
   ```

6. **Upload via App Store Connect**
   - Use Transporter app
   - Or use Xcode's automatic upload

### Store Listing

Same as Android with iOS-specific screenshots.

## Configuration for Production

### Update API Endpoints

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const String apiBaseUrl = 'https://api.alonu.com';
  // ... other constants
}
```

### Configure Firebase

1. Create Firebase project for production
2. Download `google-services.json` (Android)
3. Download `GoogleService-Info.plist` (iOS)
4. Place in respective directories

### Environment Setup

Create `.env.production`:
```
API_BASE_URL=https://api.alonu.com
FIREBASE_PROJECT_ID=alonu-production
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
LOG_LEVEL=error
```

## Testing Before Deployment

### Local Testing

```bash
# Run app in release mode
flutter run --release

# Run tests
flutter test

# Analyze code
flutter analyze
```

### Device Testing

- Test on Android 8+ devices
- Test on iOS 12+ devices
- Test core user flows:
  - Login/Register
  - Browse artisans
  - Place order
  - Make payment
  - Track order

### Beta Testing

1. **Android Beta**
   - Google Play Console > Internal Testing
   - Add testers' Google accounts
   - Share internal test link

2. **iOS Beta**
   - TestFlight in App Store Connect
   - Add up to 10,000 external testers
   - Share beta link

## Monitoring After Deployment

### Analytics
- Track user signups
- Monitor feature usage
- Check crash reports

### Error Tracking
- Use Firebase Crashlytics
- Monitor API errors
- Track performance metrics

### Performance
- Monitor app launch time
- Track API response times
- Monitor battery usage

## Hotfix Deployment

For urgent fixes:

1. Create hotfix branch: `git checkout -b hotfix/v1.0.1`
2. Fix the issue
3. Update version to `1.0.1`
4. Test thoroughly
5. Merge to main
6. Rebuild and redeploy

## Rollback Procedure

If critical issues arise:

1. **Android**:
   - Go to Google Play Console
   - Create new release with previous version
   - Submit for review

2. **iOS**:
   - Submit new build to App Store
   - Use TestFlight for staging
   - Promote to production after verification

## Post-Deployment Tasks

- [ ] Announce release on social media
- [ ] Send email to users
- [ ] Monitor crash reports
- [ ] Respond to user feedback
- [ ] Plan next release
- [ ] Document lessons learned

## Release Schedule

Recommended cadence:
- **Major** (x.0.0): Every 3-6 months
- **Minor** (1.x.0): Every 2-4 weeks
- **Patch** (1.0.x): As needed for hotfixes

## Contacts and Resources

- **Google Play Console**: https://play.google.com/console
- **App Store Connect**: https://appstoreconnect.apple.com
- **Firebase Console**: https://console.firebase.google.com
- **Apple Developer**: https://developer.apple.com
- **Google Play Policies**: https://play.google.com/about/developer-content-policy/

## Support

For deployment issues:
- Check Flutter documentation: https://flutter.dev
- Check platform-specific docs
- Contact app support team
