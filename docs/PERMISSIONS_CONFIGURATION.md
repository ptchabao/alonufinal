# Configuration des permissions de géolocalisation

## Android Configuration

### 1. Permissions dans AndroidManifest.xml

Fichier : `android/app/src/main/AndroidManifest.xml`

Ajouter les lignes suivantes dans le bloc `<manifest>` :

```xml
<!-- Permissions for location -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

Exemple complet :
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.alonu_app">

    <!-- Permissions for location -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Autres permissions existantes -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application>
        <!-- Configuration existante -->
    </application>
</manifest>
```

### 2. Permissions à l'exécution (Runtime Permissions)

Pour Android 6.0 (API level 23) et supérieurs, les permissions sont gérées par le package `geolocator` automatiquement.

Le service de localisation (`LocationService`) gère déjà :
- La demande de permission
- La vérification de l'état
- L'affichage des dialogs natifs

## iOS Configuration

### 1. Clés Info.plist

Fichier : `ios/Runner/Info.plist`

Ajouter les clés suivantes :

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>ALONU a besoin de votre localisation pour trouver les artisans à proximité de vous.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>ALONU a besoin de votre localisation pour trouver les artisans à proximité de vous et vous envoyer des notifications pertinentes.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>ALONU a besoin de votre localisation pour trouver les artisans à proximité de vous.</string>
```

Exemple complet minimal :
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>ALONU</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>$(FLUTTER_BUILD_NAME)</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>$(FLUTTER_BUILD_NUMBER)</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	
	<!-- Location permissions -->
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>ALONU a besoin de votre localisation pour trouver les artisans à proximité de vous.</string>
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>ALONU a besoin de votre localisation pour trouver les artisans à proximité de vous et vous envoyer des notifications pertinentes.</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>ALONU a besoin de votre localisation pour trouver les artisans à proximité de vous.</string>
	
	<!-- UIRequiredDeviceCapabilities -->
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>arm64</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UIViewControllerBasedStatusBarAppearance</key>
	<false/>
	<key>CADisableMinimumFrameDurationOnPhone</key>
	<true/>
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
</dict>
</plist>
```

### 2. Configuration Xcode (optionnel mais recommandé)

Pour une meilleure intégration, vous pouvez ouvrir le projet dans Xcode :

```bash
cd ios
open Runner.xcworkspace
```

Puis :
1. Sélectionner le projet "Runner" dans le navigateur
2. Aller à Build Settings
3. Chercher "Location"
4. Vérifier que les permissions sont correctement configurées

## Configuration Web (si applicable)

Pour la prise en charge du web, le package `geolocator` utilise l'API Geolocation du navigateur.

Aucune configuration supplémentaire n'est nécessaire, mais les utilisateurs doivent accepter la demande de permission du navigateur.

## Configuration des capacités (Capabilities)

### Android

Pour Android 12+, si vous distribuez votre app via Google Play :
1. Déclarez la capacité "Approximate location" ou "Precise location" dans la fiche produit

### iOS

Pour iOS 13+, assurez-vous que :
1. L'app a les bonnes clés dans Info.plist
2. Vous avez déployé sur iOS 13 minimum (défini dans pubspec.yaml ou dans Xcode)

## Test des permissions

### Code de test simple

```dart
void testLocationPermissions() async {
  final locationService = LocationService();
  
  try {
    // Test 1: Vérifier si le service est activé
    final isEnabled = await locationService.isLocationServiceEnabled();
    print('Service activé: $isEnabled');
    
    // Test 2: Demander la permission
    final hasPermission = await locationService.requestLocationPermission();
    print('Permission accordée: $hasPermission');
    
    // Test 3: Obtenir la position
    final position = await locationService.getCurrentPosition();
    print('Position: ${position.latitude}, ${position.longitude}');
  } catch (e) {
    print('Erreur: $e');
  }
}
```

## Dépannage

### Problème : La localisation n'est pas activée
**Solution** : Vérifier les permissions dans les paramètres de l'appareil
- Android : Paramètres > Applications > ALONU > Permissions > Localisation
- iOS : Paramètres > Confidentialité > Services de localisation

### Problème : Exception "Permission refusée"
**Solution** : 
- Pour Android 6+, les permissions runtime doivent être accordées
- Pour iOS, s'assurer que les clés NSLocation sont dans Info.plist

### Problème : Timeout lors de la récupération de la position
**Solution** :
- Augmenter le timeout dans `location_service.dart` (actuellement 30s)
- Vérifier la connexion réseau
- Activer le GPS sur l'appareil

### Problème : Position incorrecte
**Solution** :
- En intérieur, utiliser GPS + WiFi (moins précis)
- En plein air, le GPS donne de meilleurs résultats
- Laisser quelques secondes au GPS pour se calibrer

## Ressources

- [Geolocator Package - Configuration](https://pub.dev/packages/geolocator#configuration)
- [Android Permissions Documentation](https://developer.android.com/guide/topics/permissions/overview)
- [iOS Privacy and Security Documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationwhenin_use_usage_description)
- [Flutter Permission Handling Best Practices](https://flutter.dev/docs/development/data-and-backend/firebase)
