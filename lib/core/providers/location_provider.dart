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

  /// Call this when app resumes to re-check if user fixed settings
  Future<void> refreshStatus() async {
    await checkPermissionStatus();
  }
}
