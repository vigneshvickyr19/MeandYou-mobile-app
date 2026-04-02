import 'package:flutter/material.dart';
import '../../../../core/models/admin_settings_model.dart';

import '../../../../core/services/admin_service.dart';
import '../../../../core/services/notification_api_service.dart';
import '../../../../core/constants/app_routes.dart';

class AdminController extends ChangeNotifier {
  final AdminService _adminService = AdminService.instance;

  AdminSettings? _settings;
  List<Map<String, dynamic>> _helpContent = [];
  List<Announcement> _announcements = [];
  bool _isLoading = false;

  AdminSettings? get settings => _settings;
  List<Map<String, dynamic>> get helpContent => _helpContent;
  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;

  void init() {
    _loadSettings();
    _loadHelpContent();
    _loadAnnouncements();
  }

  void _loadSettings() {
    _adminService.streamSettings().listen((settings) {
      _settings = settings;
      notifyListeners();
    });
  }

  void _loadHelpContent() {
    _adminService.streamHelpContent().listen((content) {
      _helpContent = content;
      notifyListeners();
    });
  }

  void _loadAnnouncements() {
    _adminService.streamAnnouncements().listen((list) {
      _announcements = list;
      notifyListeners();
    });
  }

  Future<void> updateLikeLimits(int male, int female) async {
    if (_settings == null) return;
    _setLoading(true);
    try {
      final updated = AdminSettings(
        maleFreeLikes: male,
        femaleFreeLikes: female,
        nearbyRadiusInKm: _settings?.nearbyRadiusInKm ?? 10.0,
        updatedAt: DateTime.now(),
      );
      await _adminService.updateSettings(updated);
    } catch (e) {
      debugPrint('AdminController: Error updating limits: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateNearbyRadius(double radius) async {
    if (_settings == null) return;
    _setLoading(true);
    try {
      final updated = AdminSettings(
        maleFreeLikes: _settings?.maleFreeLikes ?? 5,
        femaleFreeLikes: _settings?.femaleFreeLikes ?? 10,
        nearbyRadiusInKm: radius,
        updatedAt: DateTime.now(),
      );
      await _adminService.updateSettings(updated);
    } catch (e) {
      debugPrint('AdminController: Error updating radius: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }



  Future<void> createAnnouncement(
    String title,
    String message,
    String type,
    String targetAudience,
  ) async {
    _setLoading(true);
    try {
      final ann = Announcement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        targetAudience: targetAudience,
        createdAt: DateTime.now(),
      );
      await _adminService.createAnnouncement(ann);

      // Trigger Push Notification Broadcast
      String audience = 'all'; // Default to all
      if (targetAudience == 'male') audience = 'male';
      if (targetAudience == 'female') audience = 'female';

      await NotificationApiService.instance.sendBroadcastNotification(
        title: title,
        body: message,
        targetAudience: audience,
        data: {'route': AppRoutes.home, 'type': 'BROADCAST'},
      );
    } catch (e) {
      debugPrint('AdminController: Error creating announcement: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addHelpItem(String title, String content) async {
    _setLoading(true);
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await _adminService.updateHelpItem(id, {
        'title': title,
        'content': content,
        'index': _helpContent.length,
      });
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
