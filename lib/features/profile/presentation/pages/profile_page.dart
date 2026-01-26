import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfilePage extends StatelessWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Profile Page",
            style: TextStyle(color: AppColors.white, fontSize: 24),
          ),
          if (userId != null) ...[
            const SizedBox(height: 16),
            Text(
              "User ID: $userId",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}
