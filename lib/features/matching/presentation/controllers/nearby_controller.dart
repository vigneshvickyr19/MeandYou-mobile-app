import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:dart_geohash/dart_geohash.dart';
import '../../domain/entities/nearby_match_entity.dart';
import '../../domain/usecases/get_nearby_matches_usecase.dart';
import '../../../../core/models/user_model.dart';
import '../../domain/usecases/get_current_user_profile_usecase.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/location_formatter.dart';
import '../../data/repositories/matching_repository_impl.dart';
import '../../../../features/home/data/services/home_service.dart';
import '../../../../core/services/admin_service.dart';
import '../../../../core/services/background_location_service.dart';
import '../../../../core/constants/location_constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class NearbyController extends ChangeNotifier {
  final GetNearbyMatchesUseCase _getNearbyMatchesUseCase;
  final GetCurrentUserProfileUseCase _getCurrentUserProfileUseCase;

  NearbyController({
    GetNearbyMatchesUseCase? getNearbyMatchesUseCase,
    GetCurrentUserProfileUseCase? getCurrentUserProfileUseCase,
  }) : _getNearbyMatchesUseCase =
            getNearbyMatchesUseCase ??
            GetNearbyMatchesUseCase(MatchingRepositoryImpl()),
        _getCurrentUserProfileUseCase =
            getCurrentUserProfileUseCase ?? GetCurrentUserProfileUseCase();

  List<NearbyMatchEntity> _users = [];
  List<NearbyMatchEntity> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadMore = false;
  bool get isLoadMore => _isLoadMore;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  DocumentSnapshot? _lastDoc;

  bool _isLocationLoading = false;
  bool get isLocationLoading => _isLocationLoading;

  NearbyMatchEntity? _selectedMatch;
  NearbyMatchEntity? get selectedMatch => _selectedMatch;

  double _radius = LocationConstants.defaultRadiusInKm;
  int _fetchLimit = LocationConstants.defaultFetchLimit;
  double get radius => _radius;

  StreamSubscription? _settingsSubscription;
  StreamSubscription? _locationSubscription;

  UserModel? _currentUser;
  Position? _lastPosition;
  String? _lastGeohash;
  bool _isDisposed = false;
  bool _isInitialized = false;

  /// Load users (Initial fetch)
  Future<void> loadUsers(UserModel currentUser, {bool isRefresh = false}) async {
    // Prevent unneeded re-fetches if nothing changed
    if (!isRefresh && 
        _isInitialized &&
        _currentUser?.id == currentUser.id && 
        _lastGeohash == currentUser.geohash && 
        _users.isNotEmpty) {
      return;
    }

    if (_isLoading && !isRefresh) return;

    _currentUser = currentUser;
    _lastGeohash = currentUser.geohash;
    _isInitialized = true;
    _resetPagination();
    
    // Fetch initial settings to avoid using hardcoded default
    final initialSettings = await AdminService.instance.getSettings();
    _radius = initialSettings.nearbyRadiusInKm;
    _fetchLimit = initialSettings.maxUsersPerFetch;

    // Listen to admin settings dynamically for future changes
    _settingsSubscription?.cancel();
    _settingsSubscription = AdminService.instance.streamSettings().listen((settings) {
      bool changed = false;
      if (settings.nearbyRadiusInKm != _radius) {
        _radius = settings.nearbyRadiusInKm;
        changed = true;
      }
      if (settings.maxUsersPerFetch != _fetchLimit) {
        _fetchLimit = settings.maxUsersPerFetch;
        changed = true;
      }
      if (changed) _fetchMatches(isInitial: true);
    });

    if (_currentUser?.latitude != null && _currentUser?.geohash != null) {
      await _fetchMatches(isInitial: true);
      _setupLocationListener(_currentUser!.id);
      return;
    }

    _isLoading = true;
    notifyListeners();

    _currentUser = await _getCurrentUserProfileUseCase(currentUser);
    await _fetchMatches(isInitial: true);
    _setupLocationListener(_currentUser!.id);
  }

  /// Load more users for infinite scroll
  Future<void> loadMore() async {
    if (_isLoadMore || !_hasMore || _currentUser == null) return;

    _isLoadMore = true;
    notifyListeners();

    await _fetchMatches(isInitial: false);

    _isLoadMore = false;
    notifyListeners();
  }

  void _resetPagination() {
    _users = [];
    _lastDoc = null;
    _hasMore = true;
    _isLoading = false;
    _isLoadMore = false;
  }

  Future<void> _fetchMatches({required bool isInitial}) async {
    if (_currentUser == null) return;

    if (isInitial) {
      _isLoading = true;
      _lastDoc = null;
      _hasMore = true;
      notifyListeners();
    }

    try {
      final HomeService homeService = HomeService();
      final matchedIds = await homeService.getMatchedUserIds(_currentUser!.id);

      final result = await _getNearbyMatchesUseCase.executeWithPagination(
        currentUser: _currentUser!,
        radiusInKm: _radius,
        limit: _fetchLimit,
        lastDoc: _lastDoc,
        excludedIds: matchedIds,
      );

      if (isInitial) {
        _users = result.matches;
      } else {
        final newMatches = result.matches.where((m) => !_users.any((u) => u.id == m.id)).toList();
        _users.addAll(newMatches);
      }

      _lastDoc = result.lastDoc;
      _hasMore = result.hasMore;
      
    } catch (error) {
      debugPrint('Error loading nearby matches: $error');
    } finally {
      if (isInitial) _isLoading = false;
      notifyListeners();
    }
  }

  void _setupLocationListener(String userId) {
    // Only one listener per controller instance
    _locationSubscription?.cancel();
    
    // Listen to the central location stream from BackgroundLocationService
    _locationSubscription = BackgroundLocationService.instance.onLocationChanged.listen((position) {
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

      // Only re-fetch if moved significantly (e.g. 100m)
      if (distance < LocationConstants.distanceFilter) return;
    }

    _lastPosition = position;
    final String geohash = GeoHasher().encode(
      position.longitude,
      position.latitude,
    );

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        geohash: geohash,
      );
      _lastGeohash = geohash;
      _fetchMatches(isInitial: true);
    }
    
    // Firestore sync is ALREADY handled by BackgroundLocationService
  }

  Future<void> likeUser(String currentUserId, NearbyMatchEntity match) async {
    final HomeService homeService = HomeService();
    try {
      await homeService.likeUser(currentUserId, match.id);
    } catch (e) {
      debugPrint('Error liking user: $e');
    }
  }

  Future<void> dislikeUser(NearbyMatchEntity match) async {
    _users.removeWhere((m) => m.id == match.id);
    notifyListeners();
  }

  Future<void> fetchLocationForMatch(NearbyMatchEntity match) async {
    if ((match.area != null && match.area!.isNotEmpty) ||
        (match.landmark != null && match.landmark!.isNotEmpty)) {
      return;
    }

    try {
      final locationData = await LocationService.getReadableLocation(
        match.latitude,
        match.longitude,
      );

      final index = _users.indexWhere((m) => m.id == match.id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          landmark: locationData['landmark'],
          area: locationData['area'],
          fullAddress: locationData['fullAddress'],
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching location for match: $e');
    }
  }

  void selectUser(NearbyMatchEntity match) async {
    _selectedMatch = match;
    notifyListeners();

    if (match.landmark == null || match.area == null) {
      _isLocationLoading = true;
      notifyListeners();

      final locationData = await LocationService.getReadableLocation(
        match.latitude,
        match.longitude,
      );

      _isLocationLoading = false;

      if (_selectedMatch?.id == match.id) {
        _selectedMatch = _selectedMatch!.copyWith(
          landmark: locationData['landmark'],
          area: locationData['area'],
          fullAddress: locationData['fullAddress'],
        );

        final index = _users.indexWhere((u) => u.id == match.id);
        if (index != -1) {
          _users[index] = _selectedMatch!;
        }

        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  void closeSelectedUser() {
    _selectedMatch = null;
    notifyListeners();
  }

  Offset getUserPosition(int index, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final double radius = (size.width * 0.25) + (index % 3 * 30);
    final double angle = (index * (2 * math.pi / 5)) + (math.pi / 6);

    return Offset(
      centerX + radius * math.cos(angle),
      centerY + radius * math.sin(angle),
    );
  }

  String getDistanceString(NearbyMatchEntity user) {
    return LocationFormatter.getDistanceString(user.distance);
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationSubscription?.cancel();
    _settingsSubscription?.cancel();
    super.dispose();
  }
}
