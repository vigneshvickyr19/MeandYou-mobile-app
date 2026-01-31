import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/models/user_model.dart';
import 'distance_badge.dart';

class ProfilePreviewCard extends StatelessWidget {
  final UserModel user;
  final double distance;
  final VoidCallback onClose;
  final VoidCallback onSayHello;
  final VoidCallback onViewProfile;

  const ProfilePreviewCard({
    super.key,
    required this.user,
    required this.distance,
    required this.onClose,
    required this.onSayHello,
    required this.onViewProfile,
  });

  int _calculateAge() {
    // TODO: Calculate from user.dateOfBirth when available
    return 26; // Placeholder
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Profile Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE85D04),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                  ? Image.network(
                      user.profileImageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white24,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Online Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: user.isOnline ? const Color(0xFF4CAF50) : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                user.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Name and Age
          Text(
            '${user.fullName ?? 'Unknown'}, ${_calculateAge()}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Distance
          DistanceBadge(distance: distance),
          const SizedBox(height: 12),
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.white.withOpacity(0.6),
                size: 16,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Near to Westbourne, Woodholme',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Address
          Text(
            '2972 Westheimer Rd. Santa Ana, Illinois 85486',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.4),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  label: 'Say Hello',
                  onTap: onSayHello,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildButton(
                  label: 'View Profile',
                  onTap: onViewProfile,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 14),
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
