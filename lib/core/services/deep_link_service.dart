import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../constants/deep_link_routes.dart';
import '../constants/app_routes.dart';
import '../constants/notification_constants.dart';
import '../models/notification_payload_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'startup_service.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;
  
  NotificationPayloadModel? _pendingPayload;
  bool _isAuthResolved = false;
  bool _isUiReady = false;

  /// Returns true if there is a navigation request waiting for system readiness
  bool get hasPendingNotification => _pendingPayload != null;

  /// Updates authentication stability status. Called by AuthProvider once session is confirmed.
  void setAuthResolved(bool resolved) {
    debugPrint('DeepLinkService: Auth stability set to $resolved');
    _isAuthResolved = resolved;
    _checkAndTriggerNavigation();
  }

  /// Updates UI readiness status. Called by App shell when Home is mounted.
  void setUiReady(bool ready) {
    debugPrint('DeepLinkService: UI readiness set to $ready');
    _isUiReady = ready;
    _checkAndTriggerNavigation();
  }

  /// Entry point to re-evaluate conditions and trigger deferred navigation
  void checkPendingNavigation() => _checkAndTriggerNavigation();

  void _checkAndTriggerNavigation() {
    final isSplashComplete = StartupService.instance.isSplashComplete;
    final context = _navigatorKey?.currentContext;

    // Conditions: Auth stable, App UI rendered, Branding splash finished, Payload exists
    if (_isAuthResolved && _isUiReady && isSplashComplete && _pendingPayload != null && context != null) {
      debugPrint('DeepLinkService: Executing deferred navigation for ${_pendingPayload?.targetRoute}');
      _navigateToPayload(_pendingPayload!);
      _pendingPayload = null;
    }
  }

  /// Primary initialization called on app startup
  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _appLinks = AppLinks();
    _handleIncomingLinks();
    _handleInitialLink();
    _checkAndTriggerNavigation();
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) handleLink(uri.toString());
    } catch (e) {
      debugPrint('DeepLinkService: Error fetching initial link: $e');
    }
  }

  void _handleIncomingLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) => uri != null ? handleLink(uri.toString()) : null,
      onError: (err) => debugPrint('DeepLinkService: Link stream error: $err'),
    );
  }

  /// Entry point for custom scheme links (meandyou://)
  void handleLink(String link) {
    debugPrint('DeepLinkService: Processing link: $link');
    final uri = Uri.parse(link);

    if (uri.scheme != 'meandyou') return;

    final path = _getPathFromUri(uri);
    final params = DeepLinkRoutes.extractParams(path);
    final appRoute = DeepLinkRoutes.getAppRoute(path);

    if (appRoute == null) {
      _navigateToFallback();
      return;
    }

    final Map<String, dynamic> data = {
      NotificationConstants.keyRoute: appRoute,
      ...params,
    };

    // Promotion logic: If we have a chatId but route is generic '/chat', 
    // we set the type to CHAT so NotificationPayloadModel promotes it to chatDetail.
    if (appRoute == AppRoutes.chat && params.containsKey(NotificationConstants.keyChatId)) {
      data[NotificationConstants.keyType] = NotificationConstants.typeChat;
    }

    handleNotificationPayload(data);
  }

  /// Entry point for FCM Push Notification payloads
  void handleNotificationPayload(Map<String, dynamic> data) {
    debugPrint('DeepLinkService: Handling payload: $data');
    final payload = NotificationPayloadModel.fromMap(data);
    
    _pendingPayload = payload;
    _checkAndTriggerNavigation();
  }

  /// Core navigation logic that respects auth state and route types
  void _navigateToPayload(NotificationPayloadModel payload) {
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('DeepLinkService: Navigator context is null, aborting navigation');
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final target = payload.targetRoute;
    final args = payload.targetArguments;

    debugPrint('DeepLinkService: Attempting navigation to $target');
    
    // Auth Guard: Redirect to login if route is protected and user is anonymous
    if (currentUser == null && _isProtectedRoute(target)) {
      debugPrint('DeepLinkService: Guard triggered - redirecting to login');
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
      return;
    }

    try {
      if (target == AppRoutes.home) {
        final tabIndex = (args as Map<String, dynamic>?)?['tabIndex'] ?? 0;
        debugPrint('DeepLinkService: Navigating to Home tab $tabIndex');
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (r) => false,
          arguments: args,
        );
      } else if (_isCleanStackRoute(target)) {
        debugPrint('DeepLinkService: Navigating to clean-stack route $target');
        Navigator.of(context).pushNamedAndRemoveUntil(
          target,
          (r) => false,
          arguments: args,
        );
      } else {
        // For sub-screens (Chat Detail, Profile), we add a tiny delay to ensure 
        // the AuthWrapper has finished switching from Splash to Home logic if needed.
        debugPrint('DeepLinkService: Navigating to detail route $target after micro-delay');
        Future.microtask(() {
          if (_navigatorKey?.currentContext != null) {
            Navigator.of(_navigatorKey!.currentContext!).pushNamed(
              target, 
              arguments: args
            );
          }
        });
      }
    } catch (e) {
      debugPrint('DeepLinkService: Routing error during $target: $e');
      _navigateToFallback();
    }
  }

  bool _isCleanStackRoute(String route) => 
      route == AppRoutes.home || route == AppRoutes.login || route == AppRoutes.getStarted;

  bool _isProtectedRoute(String route) => 
      ![AppRoutes.login, AppRoutes.signUp, AppRoutes.getStarted, AppRoutes.splash].contains(route);

  void _navigateToFallback() {
    final context = _navigatorKey?.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  String _getPathFromUri(Uri uri) {
    if (uri.path.isNotEmpty) return uri.path;
    if (uri.host.isNotEmpty && uri.host != 'meandyou') return '/${uri.host}';
    return '/';
  }

  void dispose() => _linkSubscription?.cancel();
}
