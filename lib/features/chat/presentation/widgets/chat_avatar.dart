import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ChatAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool isOnline;
  final double size;
  final bool showOnlineIndicator;

  const ChatAvatar({
    super.key,
    this.imageUrl,
    this.isOnline = false,
    this.size = 50,
    this.showOnlineIndicator = true,
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
            image: imageUrl != null && imageUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl == null || imageUrl!.isEmpty
              ? Icon(
                  Icons.person,
                  color: Colors.white24,
                  size: size * 0.6,
                )
              : null,
        ),
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? const Color(0xFF4CAF50) : Colors.grey[600],
                border: Border.all(
                  color: AppColors.black,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
