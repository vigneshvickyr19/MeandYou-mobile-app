import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_setup_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.instance.initialize();
  
  // Initialize Notifications
  await NotificationService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileSetupProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
