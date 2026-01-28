import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_button.dart';

import '../controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ProfileController(Provider.of<AuthProvider>(context, listen: false)),
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          final authProvider = Provider.of<AuthProvider>(context);

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Profile Page",
                    style: TextStyle(color: AppColors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  if (userId != null || authProvider.currentUser != null) ...[
                    Text(
                      "User ID: ${userId ?? authProvider.currentUser?.id}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  AppButton(
                    text: "Logout",
                    type: AppButtonType.transparent,
                    isLoading: controller.isLoading,
                    onPressed: () => controller.logout(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
