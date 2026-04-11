import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  bool _isPermissionGranted = false;
  bool _isServiceEnabled = false;
  bool _isBackgroundEnabled = false;
  bool _isChecking = true;

  bool get isPermissionGranted => _isPermissionGranted;
  bool get isBackgroundEnabled => _isBackgroundEnabled;
  bool get isServiceEnabled => _isServiceEnabled;
  bool get isChecking => _isChecking;
  bool get hasEffectiveLocation => _isPermissionGranted && _isServiceEnabled;

  LocationProvider() {
    checkPermissionStatus();
  }

  Future<void> checkPermissionStatus() async {
    _isChecking = true;
    notifyListeners();

    try {
      _isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      
      _isPermissionGranted = (permission == LocationPermission.always || 
                             permission == LocationPermission.whileInUse);
      
      // Also track if background specifically is enabled
      _isBackgroundEnabled = (permission == LocationPermission.always);
    } catch (e) {
      debugPrint('Error checking location status: $e');
      _isPermissionGranted = false;
      _isServiceEnabled = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Silent background refresh called on app resume / window focus change.
  ///
  /// Deliberately does NOT set [_isChecking] = true so [AppStateProvider.shouldShowSplash]
  /// never flips back to true mid-session, which would cause the visible blink/flash.
  /// Listeners are only notified when the permission state actually changes.
  Future<void> refreshStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();

      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      final backgroundEnabled = permission == LocationPermission.always;

      // Only rebuild the widget tree if something actually changed
      if (_isServiceEnabled != serviceEnabled ||
          _isPermissionGranted != granted ||
          _isBackgroundEnabled != backgroundEnabled) {
        _isServiceEnabled = serviceEnabled;
        _isPermissionGranted = granted;
        _isBackgroundEnabled = backgroundEnabled;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing location status: $e');
    }
  }
}
