import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../constants/deep_link_routes.dart';
import '../constants/app_routes.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;

  // Initialize deep link service with navigator key
  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _appLinks = AppLinks();
    _handleIncomingLinks();
    _handleInitialLink();
  }

  // Handle initial link when app is opened via deep link
  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _processDeepLink(uri.toString());
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
          _processDeepLink(uri.toString());
        }
      },
      onError: (err) {
        debugPrint('Error listening to link stream: $err');
      },
    );
  }

  // Process deep link and navigate to appropriate route
  void _processDeepLink(String link) {
    debugPrint('Processing deep link: $link');

    final uri = Uri.parse(link);
    
    // Only process custom scheme links (meandyou://)
    // Ignore http/https URLs (web platform localhost, etc.)
    if (uri.scheme != 'meandyou') {
      debugPrint('Ignoring non-deep-link URL with scheme: ${uri.scheme}');
      return;
    }

    final path = uri.path;

    // Extract parameters from the path
    final params = DeepLinkRoutes.extractParams(path);
    
    // Get the app route
    final appRoute = DeepLinkRoutes.getAppRoute(path);

    if (appRoute == null) {
      debugPrint('Unknown deep link path: $path');
      _navigateToFallback();
      return;
    }

    // Navigate based on the route
    _navigateToRoute(appRoute, params);
  }

  // Navigate to the specified route with parameters
  void _navigateToRoute(String route, Map<String, String> params) {
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('Navigator context is null');
      return;
    }

    // Handle home route with tab index
    if (route == AppRoutes.home && params.containsKey('tabIndex')) {
      final tabIndex = int.tryParse(params['tabIndex'] ?? '0') ?? 0;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
        arguments: {'tabIndex': tabIndex},
      );
      return;
    }

    // Handle profile route with userId
    if (route == AppRoutes.profile && params.containsKey('userId')) {
      Navigator.of(context).pushNamed(
        AppRoutes.profile,
        arguments: {'userId': params['userId']},
      );
      return;
    }

    // Handle chat route with chatId
    if (route == AppRoutes.chat && params.containsKey('chatId')) {
      Navigator.of(context).pushNamed(
        AppRoutes.chat,
        arguments: {'chatId': params['chatId']},
      );
      return;
    }

    // For routes without parameters or special handling
    // Navigate and clear stack for main routes
    if (_isMainRoute(route)) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        route,
        (route) => false,
      );
    } else {
      Navigator.of(context).pushNamed(route);
    }
  }

  // Check if route is a main route that should clear the stack
  bool _isMainRoute(String route) {
    return route == AppRoutes.home ||
        route == AppRoutes.login ||
        route == AppRoutes.getStarted;
  }

  // Navigate to fallback route for invalid links
  void _navigateToFallback() {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  // Dispose the service
  void dispose() {
    _linkSubscription?.cancel();
  }
}

