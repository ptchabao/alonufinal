Google Maps setup

This document explains how to configure Google Maps for Android and iOS in this project.

> ⚠️ Une clé Google Maps réelle a été committée par erreur dans une ancienne version de ce
> fichier et dans `android/gradle.properties.sample`. Si vous utilisez encore cette clé,
> révoquez-la et générez-en de nouvelles (une par plateforme, restreintes) dans la Google
> Cloud Console avant la mise en production.

Android

1. The project uses a manifest placeholder in `AndroidManifest.xml` and reads the value from a project property named `MAPS_API_KEY`.

2. Create a local `android/gradle.properties` file (kept out of git) and add your key there:

  android/gradle.properties:

  MAPS_API_KEY=YOUR_ANDROID_MAPS_API_KEY_HERE

  `android/app/build.gradle.kts` forwards `MAPS_API_KEY` into the manifest placeholders so the
  meta-data tag in `AndroidManifest.xml` is populated at build time.

  A sample file is provided at `android/gradle.properties.sample` (do not commit your real key).

iOS

1. The project reads the key from the Xcode build setting `GMS_API_KEY` (the `GMSApiKey` entry
   in `Info.plist` uses the variable `$(GMS_API_KEY)`). `ios/Flutter/Debug.xcconfig` and
   `ios/Flutter/Release.xcconfig` — the config files actually loaded by the Xcode project —
   optionally include `ios/Runner/Config.xcconfig` for this value.

2. `AppDelegate.swift` calls `GMSServices.provideAPIKey(...)` at launch using the value read
   from `Info.plist`, so no manual `import GoogleMaps` wiring is needed beyond `pod install`.

3. Create a local `ios/Runner/Config.xcconfig` (gitignored, never commit it) with:

  GMS_API_KEY = YOUR_IOS_MAPS_API_KEY_HERE

  A sample file is provided at `ios/Runner/Config.xcconfig.sample`.

Notes

- Restrict each key in Google Cloud Console: the Android key to your package name + SHA-1
  fingerprint, the iOS key to your bundle id (`com.alonu.alonuApp`).
- Use two separate keys (one per platform) rather than sharing a single unrestricted key.
- Never commit `android/gradle.properties` or `ios/Runner/Config.xcconfig` — only their
  `.sample` counterparts belong in git.
