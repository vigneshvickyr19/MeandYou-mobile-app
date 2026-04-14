class DeepLinkRoutes {
  // Deep link path patterns
  static const String home = '/home';
  static const String profile = '/profile';
  static const String profileWithId = '/profile/:userId';
  static const String chat = '/chat';
  static const String chatWithId = '/chat/:chatId';
  static const String likes = '/likes';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String getStarted = '/get-started';
  static const String forgotPassword = '/forgot-password';
  static const String verifyCode = '/verify-code';
  static const String createPassword = '/create-password';
  static const String profileSetup = '/profile-setup';
  static const String discover = '/discover';
  static const String nearby = '/nearby';

  // Map deep link paths to app routes
  static Map<String, String> get pathToRoute => {
        home: '/home',
        profile: '/profile',
        chat: '/chat',
        likes: '/likes',
        login: '/login',
        signUp: '/sign-up',
        getStarted: '/get-started',
        forgotPassword: '/forgot-password',
        verifyCode: '/verify-code',
        createPassword: '/create-password',
        profileSetup: '/profile-setup',
        discover: '/home',
        nearby: '/home',
      };

  // Extract route parameters from path
  static Map<String, String> extractParams(String path) {
    final params = <String, String>{};
    
    // Extract userId from profile path
    final profileRegex = RegExp(r'^/profile/([^/]+)$');
    final profileMatch = profileRegex.firstMatch(path);
    if (profileMatch != null) {
      params['userId'] = profileMatch.group(1)!;
      params['route'] = '/other_profile'; // Maps to AppRoutes.otherProfile
      return params;
    }

    // Extract chatId from chat path
    final chatRegex = RegExp(r'^/chat/([^/]+)$');
    final chatMatch = chatRegex.firstMatch(path);
    if (chatMatch != null) {
      params['chatId'] = chatMatch.group(1)!;
      params['route'] = '/chat'; // Maps to AppRoutes.chat (NotificationPayloadModel will promote to chatDetail)
      return params;
    }

    // Extract tab index from home path with tab parameter
    final homeTabRegex = RegExp(r'^/home/tab/(\d+)$');
    final homeTabMatch = homeTabRegex.firstMatch(path);
    if (homeTabMatch != null) {
      params['tabIndex'] = homeTabMatch.group(1)!;
      params['route'] = '/home';
      return params;
    }

    // Handle /discover and /nearby
    if (path == '/discover') {
      params['screen'] = 'DISCOVER';
      params['route'] = '/home';
      return params;
    }
    if (path == '/nearby') {
      params['screen'] = 'NEARBY';
      params['route'] = '/home';
      return params;
    }

    return params;
  }

  // Get app route from deep link path
  static String? getAppRoute(String path) {
    // Check for exact match first
    if (pathToRoute.containsKey(path)) {
      return pathToRoute[path];
    }

    // Check for parameterized routes
    final params = extractParams(path);
    if (params.containsKey('route')) {
      return params['route'];
    }

    return null;
  }
}
