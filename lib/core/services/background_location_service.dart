import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../features/matching/data/repositories/matching_repository_impl.dart';
import '../constants/location_constants.dart';
import '../../firebase_options.dart';

import 'package:flutter/widgets.dart';

/// Service to handle background location updates for Android and iOS.
/// 
/// Also serves as the primary source for location streams in the foreground.
class BackgroundLocationService {
  static const String keyLastLat = "last_lat";
  static const String keyLastLng = "last_lng";
  static const String keyLastSyncTime = "last_sync_time";

  static final BackgroundLocationService _instance = BackgroundLocationService._();
  static BackgroundLocationService get instance => _instance;

  BackgroundLocationService._();

  bool _isTracking = false;
  bool _isInitialized = false;
  StreamSubscription<Position>? _locationSubscription;
  
  // Broadcast stream for other parts of the app to listen to location changes
  final StreamController<Position> _positionController = StreamController<Position>.broadcast();
  Stream<Position> get onLocationChanged => _positionController.stream;

  /// Initialize background capabilities.
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (Platform.isAndroid) {
      await Workmanager().initialize(callbackDispatcher);
    }
    _isInitialized = true;
    debugPrint("BackgroundLocationService: Initialized");
  }

  /// Start background monitoring and foreground stream.
  Future<void> startTracking(String userId) async {
    if (_isTracking) return;

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint("BackgroundLocationService: Permissions not granted.");
      return;
    }

    _isTracking = true;

    // 1. Android: Register periodic task for background when app is killed
    if (Platform.isAndroid) {
      await Workmanager().registerPeriodicTask(
        "1",
        LocationConstants.backgroundTaskName,
        frequency: const Duration(minutes: LocationConstants.androidTaskFrequencyMins),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        inputData: {'userId': userId},
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );
    }

    // 2. Start single shared position stream for foreground & iOS background
    _locationSubscription?.cancel();
    
    final locationSettings = Platform.isIOS 
      ? AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: LocationConstants.distanceFilter,
          pauseLocationUpdatesAutomatically: true,
          showBackgroundLocationIndicator: false,
          allowBackgroundLocationUpdates: true,
        )
      : AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: LocationConstants.distanceFilter,
          // Foreground notification is required for reliable background updates on Android
          // but we rely on WorkManager for the "killed" state.
          // This stream handles the "active/backgrounded but not killed" state.
        );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) {
      // Notify internal listeners
      _positionController.add(position);
      
      // Update Firestore if needed based on thresholds
      syncLocation(userId, position);
    });
    
    debugPrint("BackgroundLocationService: Started tracking for user $userId");
  }

  /// Stop all tracking.
  Future<void> stopTracking() async {
    _isTracking = false;
    if (Platform.isAndroid) {
      await Workmanager().cancelAll();
    }
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    debugPrint("BackgroundLocationService: Stopped tracking");
  }

  /// Core logic to determine if Firestore needs a write.
  static Future<bool> syncLocation(String userId, Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final lastLat = prefs.getDouble(keyLastLat);
      final lastLng = prefs.getDouble(keyLastLng);
      final lastSyncTimeMs = prefs.getInt(keyLastSyncTime) ?? 0;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final timeDiffMins = (now - lastSyncTimeMs) / (1000 * 60);

      double distance = 0;
      if (lastLat != null && lastLng != null) {
        distance = Geolocator.distanceBetween(lastLat, lastLng, position.latitude, position.longitude);
      }

      bool shouldUpdate = false;
      if (lastLat == null || distance > LocationConstants.minDistanceForUpdateInMeters) {
        shouldUpdate = true;
      } else if (timeDiffMins > LocationConstants.minTimeForUpdateInMinutes) {
        shouldUpdate = true;
      }

      if (!shouldUpdate) return true;

      final geohash = GeoHasher().encode(position.longitude, position.latitude);
      
      final repository = MatchingRepositoryImpl();
      await repository.updateLocation(
        userId: userId,
        latitude: position.latitude,
        longitude: position.longitude,
        geohash: geohash,
      );

      await prefs.setDouble(keyLastLat, position.latitude);
      await prefs.setDouble(keyLastLng, position.longitude);
      await prefs.setInt(keyLastSyncTime, now);

      debugPrint("Location synced: ${distance.toStringAsFixed(0)}m, ${timeDiffMins.toStringAsFixed(0)}m elapsed");
      return true;
    } catch (e) {
      debugPrint("BackgroundLocationService: Sync failed: $e");
      return false;
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == LocationConstants.backgroundTaskName) {
      final userId = inputData?['userId'] as String?;
      if (userId == null) return true;

      try {
        WidgetsFlutterBinding.ensureInitialized();
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }

        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
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
