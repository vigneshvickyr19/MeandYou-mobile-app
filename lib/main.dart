import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'core/services/startup_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_setup_provider.dart';
import 'core/providers/location_provider.dart';
import 'core/providers/app_state_provider.dart';
import 'features/notifications/presentation/controllers/notification_controller.dart';
import 'features/linkes/presentation/controllers/like_controller.dart';
import 'features/admin/presentation/controllers/admin_controller.dart';
import 'package:me_and_you/features/subscription/presentation/controllers/subscription_controller.dart';
import 'core/services/background_location_service.dart';

void main() {
  // 1. Minimum sync setup
  WidgetsFlutterBinding.ensureInitialized();

  // Create AuthProvider early to pass into the hierarchy
  final authProvider = AuthProvider();

  // 2. Start the app IMMEDIATELY
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => LocationProvider(), lazy: false),

        ChangeNotifierProxyProvider2<
          AuthProvider,
          LocationProvider,
          AppStateProvider
        >(
          create: (context) => AppStateProvider(
            authProvider: authProvider,
            locationProvider: context.read<LocationProvider>(),
          ),
          update: (context, auth, location, previous) =>
              previous ??
              AppStateProvider(authProvider: auth, locationProvider: location),
          lazy: false,
        ),

        ChangeNotifierProvider(create: (_) => ProfileSetupProvider()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => LikeController()),
        ChangeNotifierProvider(create: (_) => AdminController()),
        ChangeNotifierProvider(create: (_) => SubscriptionController()),
      ],
      child: const MyApp(),
    ),
  );

  // 3. Heavy initialization happens COMPLETELY in background
  _initializeServicesInBackground(authProvider);
}

/// Initialize all services in the background
Future<void> _initializeServicesInBackground(AuthProvider authProvider) async {
  try {
    debugPrint('Starting background initialization...');

    // 1. Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized');

    // 2. Now that Firebase is ready, initialize Auth logic
    authProvider.initialize();
    debugPrint('AuthProvider initialized');

    // 3. Initialize other services
    await NotificationService.instance.initialize();
    debugPrint('NotificationService initialized');

    await StartupService.instance.initialize();
    debugPrint('StartupService initialized');

    // 4. Initialize Background Location
    await BackgroundLocationService.instance.initialize();
    debugPrint('BackgroundLocationService initialized');
  } catch (e) {
    debugPrint('Error during background initialization: $e');
  }
}
