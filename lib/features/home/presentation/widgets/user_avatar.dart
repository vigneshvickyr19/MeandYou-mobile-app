import 'package:flutter/material.dart';
import '../../../../core/services/presence_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import 'distance_badge.dart';

class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double distance;
  final VoidCallback onTap;
  final double size;

  const UserAvatar({
    super.key,
    required this.user,
    required this.distance,
    required this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Distance Badge
          DistanceBadge(
            distance: distance,
            showIcon: false,
          ),
          const SizedBox(height: 8),
          // Avatar
          Stack(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE85D04),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE85D04).withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                      ? Image.network(
                          user.profileImageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: Icon(
                            Icons.person,
                            size: size * 0.6,
                            color: Colors.white24,
                          ),
                        ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: StreamBuilder<Map<String, dynamic>?>(
                  stream: PresenceService.instance.streamUserStatus(user.id),
                  builder: (context, snapshot) {
                    final isOnline = snapshot.data?['state'] == 'online';
                    return Container(
                      width: size * 0.22,
                      height: size * 0.22,
                      decoration: BoxDecoration(
                        color: isOnline ? const Color(0xFF4CAF50) : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.black,
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
