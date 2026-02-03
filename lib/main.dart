import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_setup_provider.dart';
import 'features/notifications/presentation/controllers/notification_controller.dart';
import 'features/linkes/presentation/controllers/like_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase MUST be initialized with options for multiple platforms
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Pre-warmed state check for "Zero-Gap" startup
  // We check the cache immediately to avoid even a single frame of Splash if possible
  final initialUser = FirebaseAuth.instance.currentUser;

  // 3. Optimization: Start NotificationService in parallel (non-blocking)
  NotificationService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        // lazy: false + initialUser makes the first build of AuthWrapper nearly instant
        ChangeNotifierProvider(
          create: (_) => AuthProvider(initialUser: initialUser), 
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => ProfileSetupProvider()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => LikeController()),
      ],
      child: const MyApp(),
    ),
  );
}