import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.instance.initialize();
  
  // Initialize Notifications
  await NotificationService.instance.initialize();

  runApp(const MyApp());
}
