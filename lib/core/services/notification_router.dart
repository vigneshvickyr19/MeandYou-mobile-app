import 'package:flutter/material.dart';
import '../models/notification_payload_model.dart';
import 'deep_link_service.dart';

/// Service to handle the logic of where to route the user
/// after tapping a notification or deep link.
class NotificationRouter {
  static final NotificationRouter _instance = NotificationRouter._internal();
  factory NotificationRouter() => _instance;
  NotificationRouter._internal();

  /// Logic to determine navigation based on payload
  void routeToPayload(BuildContext context, NotificationPayloadModel payload) {
    debugPrint('NotificationRouter: Routing to ${payload.targetRoute}');
    
    // We delegate the actual navigation to DeepLinkService which already has 
    // unified logic for protected routes and stack management.
    DeepLinkService().handleNotificationPayload(payload.originalData);
  }

  /// Helper to check if we should override the default splash/initial flow
  bool hasPendingNotification() {
    return DeepLinkService().hasPendingNotification;
  }
}
