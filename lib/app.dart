import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/notification_service.dart';
import 'core/providers/auth_provider.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final DeepLinkService _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize services after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkService.initialize(_navigatorKey);
      NotificationService.instance.setNavigatorKey(_navigatorKey);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkService.setUiReady(false);
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      if (state == AppLifecycleState.resumed) {
        authProvider.setOnlineStatus(true);
      } else if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.detached) {
        authProvider.setOnlineStatus(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      home: const AuthWrapper(),
      theme: AppTheme.darkTheme,
      routes: AppRouter.routes,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
