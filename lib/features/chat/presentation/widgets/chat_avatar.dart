import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/presence_service.dart';
import '../../../../core/widgets/app_cached_image.dart';

class ChatAvatar extends StatelessWidget {
  final String? imageUrl;
  final int? imageVersion;
  final bool isOnline; // Static fallback
  final double size;
  final bool showOnlineIndicator;
  final String? userId; // Added for real-time presence

  const ChatAvatar({
    super.key,
    this.imageUrl,
    this.imageVersion,
    this.isOnline = false,
    this.size = 50,
    this.showOnlineIndicator = true,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[800],
          ),
          child: AppCachedImage(
            imageUrl: imageUrl,
            imageVersion: imageVersion,
            width: size,
            height: size,
            isRound: true,
          ),
        ),
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: userId != null
                ? StreamBuilder<Map<String, dynamic>?>(
                    stream: PresenceService.instance.streamUserStatus(userId!),
                    builder: (context, snapshot) {
                      final online = snapshot.data?['state'] == 'online';
                      return _buildIndicator(online);
                    },
                  )
                : _buildIndicator(isOnline),
          ),
      ],
    );
  }

  Widget _buildIndicator(bool online) {
    return Container(
      width: size * 0.25,
      height: size * 0.25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: online ? const Color(0xFF4CAF50) : Colors.grey[600],
        border: Border.all(
          color: AppColors.black,
          width: 2,
        ),
      ),
    );
  }
}
