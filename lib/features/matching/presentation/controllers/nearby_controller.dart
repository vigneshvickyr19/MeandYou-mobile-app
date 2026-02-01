import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:dart_geohash/dart_geohash.dart';
import '../../domain/entities/nearby_match_entity.dart';
import '../../domain/usecases/get_nearby_matches_usecase.dart';
import '../../domain/usecases/update_location_usecase.dart';
import '../../../../core/models/user_model.dart';
import '../../domain/usecases/get_current_user_profile_usecase.dart';
import '../../data/repositories/matching_repository_impl.dart';

class NearbyController extends ChangeNotifier {
  final GetNearbyMatchesUseCase _getNearbyMatchesUseCase;
  final UpdateLocationUseCase _updateLocationUseCase;
  final GetCurrentUserProfileUseCase _getCurrentUserProfileUseCase;

  NearbyController({
    GetNearbyMatchesUseCase? getNearbyMatchesUseCase,
    UpdateLocationUseCase? updateLocationUseCase,
    GetCurrentUserProfileUseCase? getCurrentUserProfileUseCase,
  })  : _getNearbyMatchesUseCase = getNearbyMatchesUseCase ?? GetNearbyMatchesUseCase(MatchingRepositoryImpl()),
        _updateLocationUseCase = updateLocationUseCase ?? UpdateLocationUseCase(MatchingRepositoryImpl()),
        _getCurrentUserProfileUseCase = getCurrentUserProfileUseCase ?? GetCurrentUserProfileUseCase();

  List<NearbyMatchEntity> _users = [];
  List<NearbyMatchEntity> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  NearbyMatchEntity? _selectedMatch;
  NearbyMatchEntity? get selectedMatch => _selectedMatch;

  StreamSubscription? _matchesSubscription;
  StreamSubscription? _locationSubscription;
  
  UserModel? _currentUser;
  Position? _lastPosition;

  Future<void> loadUsers(UserModel currentUser) async {
    _currentUser = currentUser;
    _isLoading = true;
    notifyListeners();

    // 1. Get full profile from profileSetup
    _currentUser = await _getCurrentUserProfileUseCase(currentUser);
    
    _startMatchesSubscription();
    _startLocationUpdates(_currentUser!.id);
  }

  void _startMatchesSubscription() {
    if (_currentUser == null) {
      return;
    }
    
    _matchesSubscription?.cancel();
    _matchesSubscription = _getNearbyMatchesUseCase(
      currentUser: _currentUser!,
      radiusInKm: 10.0,
    ).listen((matches) {
      _users = matches;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading nearby matches: $error');
    });
  }

  void _startLocationUpdates(String userId) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _locationSubscription?.cancel();
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    ).listen((Position position) {
      _onLocationChanged(userId, position);
    });
  }

  void _onLocationChanged(String userId, Position position) {
    if (_lastPosition != null) {
      final double distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      
      if (distance < 500) return;
    }

    _lastPosition = position;
    final String geohash = GeoHasher().encode(position.longitude, position.latitude);

    // Update local user and restart subscription
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        geohash: geohash,
      );
      _startMatchesSubscription();
    }

    _updateLocationUseCase(
      userId: userId,
      latitude: position.latitude,
      longitude: position.longitude,
      geohash: geohash,
    );
  }

  void selectUser(NearbyMatchEntity match) {
    _selectedMatch = match;
    notifyListeners();
  }

  void closeSelectedUser() {
    _selectedMatch = null;
    notifyListeners();
  }

  Offset getUserPosition(int index, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    
    // Distribute users in a radial pattern
    final double radius = (size.width * 0.25) + (index % 3 * 30);
    final double angle = (index * (2 * math.pi / 5)) + (math.pi / 6);
    
    return Offset(
      centerX + radius * math.cos(angle),
      centerY + radius * math.sin(angle),
    );
  }

  String getDistanceString(NearbyMatchEntity user) {
    if (user.distance < 1) {
      return '${(user.distance * 1000).toInt()}m';
    }
    return '${user.distance.toStringAsFixed(1)}km';
  }

  @override
  void dispose() {
    _matchesSubscription?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }
}
