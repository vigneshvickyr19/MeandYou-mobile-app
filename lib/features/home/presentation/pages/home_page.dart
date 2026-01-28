import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSaveLocation();
    });
  }

  Future<void> _checkAndSaveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    } 

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
         final authProvider = Provider.of<AuthProvider>(context, listen: false);
         await authProvider.updateLocation(position.latitude, position.longitude);
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            "Welcome to the App! dating App",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "This is your home page after signing in. You can add more content here.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          AppButton(
            text: "Test Notification",
            onPressed: () {
              NotificationService.instance.showTestNotification();
            },
            isEnabled: true,
            type: AppButtonType.transparent,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: "Log Out",
            onPressed: () {
              // Ensure we pop to the first route to clear stack or use navigator properly
              // Usually auth wrapper handles state change, so logout calls authProvider.signOut()
               final authProvider = Provider.of<AuthProvider>(context, listen: false);
               authProvider.signOut();
               // The auth wrapper will redirect to login page automatically if it listens to auth state
            },
            isEnabled: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
