import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:dart_geohash/dart_geohash.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../domain/usecases/update_location_usecase.dart';
import '../../data/repositories/matching_repository_impl.dart';

class LocationPermissionController {
  final UpdateLocationUseCase _updateLocationUseCase;

  LocationPermissionController({UpdateLocationUseCase? updateLocationUseCase})
      : _updateLocationUseCase = updateLocationUseCase ??
            UpdateLocationUseCase(MatchingRepositoryImpl());

  /// Returns true if permission is granted and location is fetched/saved
  Future<bool> requestLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Location services are disabled. Please enable them in settings.');
      }
      return false;
    }

    // 2. Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Location permission denied.');
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Location permissions are permanently denied. Please enable them in app settings.');
        await Geolocator.openAppSettings();
      }
      return false;
    }

    // 3. Permission granted - get current location
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Update Firestore once successfully
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        final String geohash = GeoHasher().encode(
          position.longitude,
          position.latitude,
          precision: 9, // High precision for storage
        );

        await _updateLocationUseCase(
          userId: authProvider.currentUser!.id,
          latitude: position.latitude,
          longitude: position.longitude,
          geohash: geohash,
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to get location. Please try again.');
      }
      return false;
    }
  }

  /// Check initial location status
  static Future<bool> hasLocationEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    return (permission == LocationPermission.always || 
            permission == LocationPermission.whileInUse);
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
