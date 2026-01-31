import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final double distance;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const UserCard({
    super.key,
    required this.user,
    required this.distance,
    required this.onLike,
    required this.onDislike,
  });

  int _calculateAge() {
    return 20 + (user.id.hashCode % 10);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      width: screenSize.width * 0.9,
      height: screenSize.height * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'user_image_${user.id}',
              child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                  ? Image.network(
                      user.profileImageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: const Color(0xFF1A1A1A),
                      child: const Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.white10,
                      ),
                    ),
            ),
            
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.2, 0.6, 1.0],
                ),
              ),
            ),

            Positioned(
              top: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${distance.toStringAsFixed(1)} km away',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 120,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          user.fullName ?? 'Unknown user',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${_calculateAge()}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: user.isOnline ? const Color(0xFF4CAF50) : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Exploring life, looking for meaningful connections and great conversations.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Action Buttons
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Dislike Button
                  _buildActionButton(
                    icon: Icons.close_rounded,
                    color: Colors.white,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
                    ),
                    onTap: onDislike,
                    size: 64,
                  ),
                  // Like Button
                  _buildActionButton(
                    icon: Icons.favorite_rounded,
                    color: Colors.white,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE85D04), Color(0xFFFF8C42)],
                    ),
                    onTap: onLike,
                    size: 74,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: gradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.45,
        ),
      ),
    );
  }
}
