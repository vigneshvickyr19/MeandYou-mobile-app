import 'dart:async';
import 'package:flutter/material.dart';
import 'package:me_and_you/features/notifications/data/models/notification_model.dart';
import 'package:me_and_you/features/notifications/data/services/notification_storage_service.dart';

class NotificationController extends ChangeNotifier {
  final NotificationStorageService _service = NotificationStorageService();
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  bool _isDisposed = false;
  StreamSubscription? _subscription;

  // Tracks which user we're currently streaming for to prevent duplicate listeners
  String? _activeUserId;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void listenToNotifications(String userId) {
    if (userId.isEmpty || _isDisposed) return;

    // Already streaming for this user — don't attach another listener
    if (_activeUserId == userId && _subscription != null) return;

    _activeUserId = userId;
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.getNotifications(userId).listen((notifications) {
      if (_isDisposed) return;
      _notifications = notifications;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      if (_isDisposed) return;
      _isLoading = false;
      debugPrint('Error listening to notifications: $error');
      notifyListeners();
    });
  }

  /// Call on logout to clear state and allow re-initialization for the next user
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _activeUserId = null;
    _notifications = [];
    _isLoading = false;
  }

  Future<void> markAsRead(String notificationId) async {
    await _service.markAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _service.markAllAsRead(userId);
  }

  Future<void> deleteNotification(String notificationId) async {
    await _service.deleteNotification(notificationId);
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
