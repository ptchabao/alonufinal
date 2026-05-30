Google Maps setup

This document explains how to configure Google Maps for Android and iOS in this project.

Provided API key (received from user):

- API key: `YOUR_GOOGLE_MAPS_API_KEY_HERE`

Android

1. The project already includes the API key in `android/app/src/main/AndroidManifest.xml` as a meta-data entry:

   <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY" />

2. Recommended (safer): store the key in `android/gradle.properties` or local environment and reference it in `AndroidManifest.xml` using a manifest placeholder.

   Example (in `android/gradle.properties` - do NOT commit this file if it contains secrets):

   MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY_HERE

   Then in `android/app/build.gradle`:

   android {
     defaultConfig {
       manifestPlaceholders = [com.google.android.geo.API_KEY: "${MAPS_API_KEY}"]
     }
   }

iOS

1. The project includes the API key in `ios/Runner/Info.plist` under the `GMSApiKey` key.

2. Recommended: set the key using an environment variable or Xcode configuration and avoid committing the key in plaintext.

Notes

- Restrict the key in Google Cloud Console (Android package name + SHA-1, and iOS bundle id) to reduce abuse.
- If you prefer, I can apply the safer approach (use `gradle.properties` and Xcode config) instead of committing the key. Tell me which approach you prefer.
