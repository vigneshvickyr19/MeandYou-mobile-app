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
    // If it's meandyou:///profile, host is empty and path is '/profile'
    
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
    debugPrint('Processing deep link: $link');

    final uri = Uri.parse(link);
    
    // Only process custom scheme links (meandyou://)
    if (uri.scheme != 'meandyou') {
      debugPrint('Ignoring non-deep-link URL with scheme: ${uri.scheme}');
      return;
    }

    final path = _getPathFromUri(uri);
    debugPrint('Extracted path for routing: $path');

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
    debugPrint('DeepLinkService: Navigating to $route with params $params');
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('DeepLinkService: Navigator context is null');
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

    // Handle profile route
    if (route == AppRoutes.profile) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.profile,
        (route) => false,
      );
      return;
    }

    // Handle chat route
    if (route == AppRoutes.chat) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.chat,
        (route) => false,
      );
      return;
    }

    // Handle likes route
    if (route == AppRoutes.likes) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.likes,
        (route) => false,
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

