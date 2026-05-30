import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  /// Demande la permission de localisation à l'utilisateur
  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      throw LocationException('Permission de localisation refusée');
    } else if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Permission de localisation refusée de façon permanente. '
        'Veuillez activer la localisation dans les paramètres.',
      );
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Vérifie si la localisation est activée sur l'appareil
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Demande à l'utilisateur d'activer le GPS dans les paramètres système.
  Future<void> enableLocationService() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      final reopenedServiceEnabled = await isLocationServiceEnabled();
      if (!reopenedServiceEnabled) {
        throw LocationException(
          'Veuillez activer le GPS pour continuer. '
          'Ouvrez les paramètres et activez la localisation.',
        );
      }
    }
  }

  /// Obtient la position actuelle de l'utilisateur
  Future<Position> getCurrentPosition() async {
    try {
      // Vérifie si le service de localisation est activé
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        await enableLocationService();
      }

      // Demande la permission
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw LocationException('Permission de localisation refusée');
      }

      // Obtient la position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return position;
    } on LocationException {
      rethrow;
    } catch (e) {
      throw LocationException(
        'Erreur lors de la récupération de la localisation: $e',
      );
    }
  }

  /// Calcule la distance entre deux points en kilomètres
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Formule de Haversine
    const R = 6371; // Rayon de la Terre en km

    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  static double _toRad(double degree) {
    return degree * math.pi / 180;
  }

  /// Obtient l'adresse approximative à partir des coordonnées
  /// (Cette fonction pourrait être implémentée avec une API de géocodage)
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // Note: Pour implémenter la géo-inversion, utiliser le package 'geocoding'
    // Cette fonctionnalité peut être ajoutée plus tard si nécessaire
    return '$latitude, $longitude';
  }
}
