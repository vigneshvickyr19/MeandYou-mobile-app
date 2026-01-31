import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';

class LikeCard extends StatefulWidget {
  final UserModel user;
  final String likeTime;
  final VoidCallback onSayHello;
  final VoidCallback onViewProfile;

  const LikeCard({
    super.key,
    required this.user,
    required this.likeTime,
    required this.onSayHello,
    required this.onViewProfile,
  });

  @override
  State<LikeCard> createState() => _LikeCardState();
}

class _LikeCardState extends State<LikeCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isExpanded ? AppColors.primary.withOpacity(0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Left: Profile Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: widget.user.profileImageUrl != null && widget.user.profileImageUrl!.isNotEmpty
                          ? Image.network(
                              widget.user.profileImageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.person, color: Colors.white24),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Center: User name, Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.fullName ?? 'Unknown',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: AppColors.white.withOpacity(0.5),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Nearby', // Placeholder for actual location
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.5),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Right: Time when user liked
                  Text(
                    widget.likeTime,
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Expanded content: Action buttons
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.center,
                heightFactor: _isExpanded ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: 'Say Hello',
                          onTap: widget.onSayHello,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          label: 'View Profile',
                          onTap: widget.onViewProfile,
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFFE85D04), Color(0xFFFF8C42)],
                )
              : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: Colors.white10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
