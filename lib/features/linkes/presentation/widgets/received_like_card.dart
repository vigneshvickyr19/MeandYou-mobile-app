import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/premium_gated_image.dart';

class ReceivedLikeCard extends StatelessWidget {
  final UserModel user;
  final String timeAgo;
  final VoidCallback onTap;
  final bool isBlurred;
  final int index;

  const ReceivedLikeCard({
    super.key,
    required this.user,
    required this.timeAgo,
    required this.onTap,
    required this.isBlurred,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: 80 * index),
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                _buildProfileImage(),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderRow(),
                      const SizedBox(height: 4),
                      _buildStatusText(),
                      const SizedBox(height: 18),
                      _buildActionButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: PremiumGatedImage(
        imageUrl: user.profileImageUrl,
        isGated: isBlurred,
        blurSigma: 20.0,
        borderRadius: 24.0,
        showLockIcon: false,
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            isBlurred ? 'Someone' : '${user.fullName}${user.age != null ? ', ${user.age}' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          timeAgo,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusText() {
    return Text(
      isBlurred ? 'Unlock to see who liked you' : 'Liked your profile',
      style: TextStyle(
        color: isBlurred ? AppColors.secondary : AppColors.primary.withValues(alpha: 0.8),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildActionButton() {
    final label = isBlurred ? 'Upgrade to View' : 'View Profile';
    final isPrimary = isBlurred;

    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              )
            : null,
        color: isPrimary ? null : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: isPrimary ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
