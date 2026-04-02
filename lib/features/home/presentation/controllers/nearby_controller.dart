import 'package:flutter/material.dart';
import '../../data/services/home_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/admin_service.dart';
import 'dart:async';

class NearbyController extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  List<UserModel> _users = [];
  bool _isLoading = false;
  UserModel? _selectedUser;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  UserModel? get selectedUser => _selectedUser;

  final DatabaseService _databaseService = DatabaseService();

  StreamSubscription? _usersSubscription;

  void loadUsers(String currentUserId) async {
    _isLoading = true;
    notifyListeners();

    // 1. Get Admin Settings for Radius
    final settings = await AdminService.instance.getSettings();
    final radius = settings.nearbyRadiusInKm;

    // 2. Get Current User Location
    final currentUser = await _databaseService.getUserById(currentUserId);
    final userLat = currentUser?.latitude;
    final userLng = currentUser?.longitude;

    _usersSubscription?.cancel();
    _usersSubscription = _homeService
        .getUsersNearby(
          currentUserId,
          maxDistance: radius,
          userLat: userLat,
          userLng: userLng,
        )
        .listen((users) {
      _users = users;
      _isLoading = false;

      // Background sync for users with missing names
      for (var user in users) {
        if (user.fullName == null || user.fullName!.isEmpty) {
          _databaseService.getUserById(user.id);
        }
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }

  void selectUser(UserModel? user) {
    _selectedUser = user;
    notifyListeners();
  }

  Future<double> getDistance(String currentUserId, UserModel otherUser) async {
    if (otherUser.latitude == null || otherUser.longitude == null) return 0.0;
    
    final currentUser = await _databaseService.getUserById(currentUserId);
    if (currentUser?.latitude == null || currentUser?.longitude == null) return 0.0;

    return _homeService.calculateDistance(
      currentUser!.latitude!,
      currentUser.longitude!,
      otherUser.latitude!,
      otherUser.longitude!,
    );
  }

  // Get position for user avatar on map (UI only for now)
  Offset getUserPosition(int index, Size screenSize) {
    // Distribute users across the screen in a visually pleasing way
    final positions = [
      Offset(screenSize.width * 0.2, screenSize.height * 0.25),
      Offset(screenSize.width * 0.7, screenSize.height * 0.15),
      Offset(screenSize.width * 0.5, screenSize.height * 0.4),
      Offset(screenSize.width * 0.3, screenSize.height * 0.6),
      Offset(screenSize.width * 0.8, screenSize.height * 0.5),
      Offset(screenSize.width * 0.15, screenSize.height * 0.75),
    ];

    if (index < positions.length) {
      return positions[index];
    }

    // For additional users, generate random positions
    return Offset(
      screenSize.width * (0.2 + (index * 0.15) % 0.6),
      screenSize.height * (0.2 + (index * 0.2) % 0.6),
    );
  }
}
