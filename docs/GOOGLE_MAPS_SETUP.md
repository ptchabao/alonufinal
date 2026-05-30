Google Maps setup

This document explains how to configure Google Maps for Android and iOS in this project.

Provided API key (received from user):

- API key: `YOUR_GOOGLE_MAPS_API_KEY_HERE`

Android

1. The project uses a manifest placeholder in `AndroidManifest.xml` and reads the value from a project property named `MAPS_API_KEY`.

2. Recommended (safer): create a local `android/gradle.properties` file (keep it out of git) and add your key there:

  android/gradle.properties:

  MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY_HERE

  The `android/app/build.gradle.kts` is configured to forward `MAPS_API_KEY` into the manifest placeholders so the meta-data tag in `AndroidManifest.xml` will be populated at build time.

  A sample file is provided at `android/gradle.properties.sample` (do not commit your real key).

iOS

1. The project now reads the key from the Xcode build setting `GMS_API_KEY` (the `GMSApiKey` entry in `Info.plist` uses the variable `$(GMS_API_KEY)`).

2. Recommended: create a local Xcode config file `ios/Runner/Config.xcconfig` (do not commit it) with:

  GMS_API_KEY = YOUR_GOOGLE_MAPS_API_KEY_HERE

  A sample file is provided at `ios/Runner/Config.xcconfig.sample`.

Notes

- Restrict the key in Google Cloud Console (Android package name + SHA-1, and iOS bundle id) to reduce abuse.
- If you prefer, I can apply the safer approach (use `gradle.properties` and Xcode config) instead of committing the key. Tell me which approach you prefer.
 - Restrict the key in Google Cloud Console (Android package name + SHA-1, and iOS bundle id) to reduce abuse.
 - The project now includes `android/gradle.properties.sample` and `ios/Runner/Config.xcconfig.sample`—copy them locally and replace the placeholder with your real key, then ensure the real files are ignored by git.
