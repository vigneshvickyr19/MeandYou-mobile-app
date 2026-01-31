import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';

class MatchDialog extends StatelessWidget {
  final UserModel user;
  final VoidCallback onSayHello;
  final VoidCallback onKeepSwiping;

  const MatchDialog({
    super.key,
    required this.user,
    required this.onSayHello,
    required this.onKeepSwiping,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Matched Avatars
            SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background hearts
                  ...List.generate(6, (index) {
                    return Positioned(
                      left: (index % 3) * 80.0,
                      top: (index ~/ 3) * 80.0,
                      child: Icon(
                        Icons.favorite,
                        color: const Color(0xFFE85D04).withOpacity(0.3),
                        size: 24,
                      ),
                    );
                  }),
                  // User avatars
                  Positioned(
                    left: 40,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: _buildAvatar(user.profileImageUrl),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    child: Transform.rotate(
                      angle: 0.2,
                      child: _buildAvatar(null), // Current user
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'CONGRATULATIONS',
              style: TextStyle(
                color: Color(0xFFE85D04),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "It's a match, Guy!!",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lorem ipsum dolor sit amet consectetur arcu',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Buttons
            Column(
              children: [
                _buildButton(
                  label: 'Say hello',
                  onTap: onSayHello,
                  isPrimary: true,
                ),
                const SizedBox(height: 12),
                _buildButton(
                  label: 'Keep swiping',
                  onTap: onKeepSwiping,
                  isPrimary: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFE85D04),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE85D04).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white24,
                ),
              ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFFE85D04), Color(0xFFFF8C42)],
                )
              : null,
          color: isPrimary ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(
                  color: AppColors.white.withOpacity(0.3),
                  width: 1,
                ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
