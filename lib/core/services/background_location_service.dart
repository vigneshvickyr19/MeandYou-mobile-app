import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../features/matching/data/repositories/matching_repository_impl.dart';
import '../../firebase_options.dart';

import 'package:flutter/widgets.dart';

/// Service to handle background location updates for Android and iOS.
///
/// Features:
/// - Android: Uses WorkManager for periodic background tasks (15-30 mins).
/// - iOS: Uses Geolocator significant location changes API.
/// - Frequency: Only syncs to Firestore if moved > 500m or > 30 mins elapsed.
class BackgroundLocationService {
  static const String backgroundTaskName = "com.meandyou.location_sync_task";
  static const String keyLastLat = "last_lat";
  static const String keyLastLng = "last_lng";
  static const String keyLastSyncTime = "last_sync_time";

  static final BackgroundLocationService _instance = BackgroundLocationService._();
  static BackgroundLocationService get instance => _instance;

  BackgroundLocationService._();

  // Guards duplicate starts and holds the iOS stream subscription for cleanup
  bool _isTracking = false;
  StreamSubscription<Position>? _iosLocationSubscription;

  /// Initialize background capabilities.
  /// Should be called in main.dart after Firebase initialization.
  Future<void> initialize() async {
    if (Platform.isAndroid) {
      await Workmanager().initialize(callbackDispatcher);
    }
  }

  /// Start background monitoring.
  /// Typically called after user login and successful permission grants.
  Future<void> startTracking(String userId) async {
    // Prevent starting a second tracking session without stopping the first
    if (_isTracking) return;

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint("BackgroundLocationService: Permissions not granted.");
      return;
    }

    _isTracking = true;

    // Android: Register periodic task
    if (Platform.isAndroid) {
      await Workmanager().registerPeriodicTask(
        "1",
        backgroundTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        inputData: {'userId': userId},
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );
    }

    // iOS: Store the subscription so we can cancel it on stopTracking()
    if (Platform.isIOS) {
      _iosLocationSubscription = Geolocator.getPositionStream(
        locationSettings: AppleSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 500,
          pauseLocationUpdatesAutomatically: true,
          showBackgroundLocationIndicator: false,
          allowBackgroundLocationUpdates: true,
        ),
      ).listen((position) {
        syncLocation(userId, position);
      });
    }
  }

  /// Stop all background tracking (e.g., on logout).
  Future<void> stopTracking() async {
    _isTracking = false;
    if (Platform.isAndroid) {
      await Workmanager().cancelAll();
    }
    // Cancel the stored iOS subscription
    await _iosLocationSubscription?.cancel();
    _iosLocationSubscription = null;
  }

  /// Core logic to determine if Firestore needs a write.
  /// Returns true if successfully synced or no sync needed.
  static Future<bool> syncLocation(String userId, Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final lastLat = prefs.getDouble(keyLastLat);
      final lastLng = prefs.getDouble(keyLastLng);
      final lastSyncTimeMs = prefs.getInt(keyLastSyncTime) ?? 0;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final timeDiffMins = (now - lastSyncTimeMs) / (1000 * 60);

      // Condition 1: Moved significantly (e.g., 500m)
      double distance = 0;
      if (lastLat != null && lastLng != null) {
        distance = Geolocator.distanceBetween(lastLat, lastLng, position.latitude, position.longitude);
      }

      // Condition 2: Check smart thresholds
      bool shouldUpdate = false;
      if (lastLat == null || distance > 500) {
        shouldUpdate = true;
      } else if (timeDiffMins > 30) {
        // Fallback: update every 30 mins even if stationary to keep "active" status
        shouldUpdate = true;
      }

      if (!shouldUpdate) return true;

      final geohash = GeoHasher().encode(position.longitude, position.latitude);
      
      // Perform batch update using Repository
      final repository = MatchingRepositoryImpl();
      await repository.updateLocation(
        userId: userId,
        latitude: position.latitude,
        longitude: position.longitude,
        geohash: geohash,
      );

      // Save local state
      await prefs.setDouble(keyLastLat, position.latitude);
      await prefs.setDouble(keyLastLng, position.longitude);
      await prefs.setInt(keyLastSyncTime, now);

      debugPrint("BackgroundLocationService: Location synced. Distance: ${distance.toStringAsFixed(0)}m, Time: ${timeDiffMins.toStringAsFixed(0)}m");
      return true;
    } catch (e) {
      debugPrint("BackgroundLocationService: Sync failed: $e");
      return false; // WorkManager will retry based on this
    }
  }
}

/// Headless callback for WorkManager.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == BackgroundLocationService.backgroundTaskName) {
      final userId = inputData?['userId'] as String?;
      if (userId == null) return true;

      try {
        // Background isolates need their own Firebase initialization
        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.medium),
        );
        return await BackgroundLocationService.syncLocation(userId, position);
      } catch (e) {
        debugPrint("BackgroundLocationService: Headless task failed: $e");
        return false;
      }
    }
    return true;
  });
}
