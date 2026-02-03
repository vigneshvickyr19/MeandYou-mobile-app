import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../constants/deep_link_routes.dart';
import '../constants/app_routes.dart';
import '../constants/notification_constants.dart';
import '../models/notification_payload_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;
  NotificationPayloadModel? _pendingPayload;
  final bool _isHandlingInitialTarget = false;
  bool _isAuthResolved = false;
  bool _isUiReady = false;

  bool get hasPendingNotification => _pendingPayload != null || _isHandlingInitialTarget;

  /// Signal that auth has been resolved (either logged in or confirmed logged out)
  void setAuthResolved(bool resolved) {
    debugPrint('DeepLinkService: Auth resolution set to $resolved');
    _isAuthResolved = resolved;
    _checkAndTriggerNavigation();
  }

  /// Signal that the UI (Home Screen) is rendered and ready for navigation
  void setUiReady(bool ready) {
    debugPrint('DeepLinkService: UI Ready set to $ready');
    _isUiReady = ready;
    _checkAndTriggerNavigation();
  }

  void _checkAndTriggerNavigation() {
    if (_isAuthResolved && _isUiReady && _pendingPayload != null && _navigatorKey?.currentContext != null) {
      debugPrint('DeepLinkService: All conditions met, triggering pending navigation');
      _navigateToPayload(_pendingPayload!);
      _pendingPayload = null;
    }
  }

  // Initialize deep link service with navigator key
  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _appLinks = AppLinks();
    _handleIncomingLinks();
    _handleInitialLink();

    // Check for conditions
    _checkAndTriggerNavigation();
  }

  // Handle initial link when app is opened via deep link
  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        handleLink(uri.toString());
      }
    } catch (e) {
      debugPrint('Error handling initial link: $e');
    }
  }

  // Listen to incoming links while app is running
  void _handleIncomingLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          handleLink(uri.toString());
        }
      },
      onError: (err) {
        debugPrint('Error listening to link stream: $err');
      },
    );
  }

  // Helper to extract path from URI consistently
  String _getPathFromUri(Uri uri) {
    // If it's meandyou://profile, host is 'profile' and path is empty

    if (uri.path.isNotEmpty) {
      return uri.path;
    }

    // Fallback to host if path is empty (e.g. meandyou://profile)
    if (uri.host.isNotEmpty && uri.host != 'meandyou') {
      return '/${uri.host}';
    }

    return '/';
  }

  // Process deep link and navigate to appropriate route
  void handleLink(String link) {
    debugPrint('DeepLinkService: Processing deep link: $link');

    final uri = Uri.parse(link);

    // Only process custom scheme links (meandyou://)
    if (uri.scheme != 'meandyou') {
      debugPrint('Ignoring non-deep-link URL with scheme: ${uri.scheme}');
      return;
    }

    final path = _getPathFromUri(uri);
    debugPrint('Extracted path for routing: $path');

    // Extract parameters using existing helper
    final params = DeepLinkRoutes.extractParams(path);
    final appRoute = DeepLinkRoutes.getAppRoute(path);

    if (appRoute == null) {
      debugPrint('Unknown deep link path: $path');
      _navigateToFallback();
      return;
    }

    // Construct a payload model for consistency
    final Map<String, dynamic> data = {
      NotificationConstants.keyRoute: appRoute,
      ...params,
    };

    // Standardize param keys for our model if needed (mapped in DeepLinkRoutes or here)
    // For example if params has 'id', we determine if it's userId or chatId based on route
    if (appRoute == AppRoutes.otherProfile && params.containsKey('id')) {
      data[NotificationConstants.keyProfileId] = params['id'];
    } else if (appRoute == AppRoutes.chat && params.containsKey('id')) {
      data[NotificationConstants.keyChatId] = params['id'];
      data[NotificationConstants.keyRoomId] = params['id'];
    }

    final payload = NotificationPayloadModel.fromMap(data);
    _navigateToPayload(payload);
  }

  /// Handle a notification payload (Push Notification)
  void handleNotificationPayload(Map<String, dynamic> data) {
    debugPrint('DeepLinkService: Handling notification payload: $data');
    final payload = NotificationPayloadModel.fromMap(data);
    
    // If navigator, auth, or UI is not yet ready, we store this as pending
    if (_navigatorKey == null || _navigatorKey?.currentContext == null || !_isAuthResolved || !_isUiReady) {
      _pendingPayload = payload;
      debugPrint('DeepLinkService: Deferring notification (Navigator/Auth/UI not ready)');
    } else {
      _navigateToPayload(payload);
    }
  }

  // Unified navigation using Payload Model
  void _navigateToPayload(NotificationPayloadModel payload) {
    debugPrint(
      'DeepLinkService: Navigating to ${payload.targetRoute} with args ${payload.targetArguments}',
    );
    final context = _navigatorKey?.currentContext;

    if (context == null) {
      debugPrint('DeepLinkService: Navigator context is null, queuing payload');
      _pendingPayload = payload;
      return;
    }

    // Ensure user is authenticated for protected routes
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null && _isProtectedRoute(payload.targetRoute)) {
      debugPrint('DeepLinkService: User not logged in, redirecting to login');
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
      return;
    }

    try {
      if (payload.targetRoute == AppRoutes.home) {
        // Handle home tab index if present
        int tabIndex = 0;
        if (payload.originalData.containsKey('tabIndex')) {
          tabIndex =
              int.tryParse(payload.originalData['tabIndex'].toString()) ?? 0;
        }
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (r) => false,
          arguments: {'tabIndex': tabIndex},
        );
      } else if (_isCleanStackRoute(payload.targetRoute)) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          payload.targetRoute,
          (r) => false,
          arguments: payload.targetArguments,
        );
      } else {
        Navigator.of(
          context,
        ).pushNamed(payload.targetRoute, arguments: payload.targetArguments);
      }
    } catch (e) {
      debugPrint('DeepLinkService: Navigation error: $e');
      _navigateToFallback();
    }
  }

  // Check if route is a main route that should clear the stack
  bool _isCleanStackRoute(String route) {
    return route == AppRoutes.home ||
        route == AppRoutes.login ||
        route == AppRoutes.getStarted;
  }

  bool _isProtectedRoute(String route) {
    return route != AppRoutes.login &&
        route != AppRoutes.signUp &&
        route != AppRoutes.getStarted &&
        route != AppRoutes.splash;
  }

  // Navigate to fallback route for invalid links
  void _navigateToFallback() {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  // Dispose the service
  void dispose() {
    _linkSubscription?.cancel();
  }
}
