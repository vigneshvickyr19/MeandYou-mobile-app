import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/models/user_model.dart';
import '../controllers/profile_controller.dart';
import 'profile_content_widgets.dart';

class OtherProfileView extends StatelessWidget {
  final ProfileModel profile;
  final ProfileController controller;
  final VoidCallback onLike;

  const OtherProfileView({
    super.key,
    required this.profile,
    required this.controller,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final photos = profile.photos ?? [];
    final profilePic = photos.isNotEmpty ? photos[0] : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 60),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AspectRatio(
              aspectRatio: 0.82,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: profilePic != null
                      ? Image.network(profilePic, fit: BoxFit.cover)
                      : Container(color: const Color(0xFF1A1A1A)),
                  ),

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          stops: const [0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 20,
                    right: 20,
                    child: _buildDistanceBadge(profile, controller.user),
                  ),

                  Positioned(
                    bottom: 90,
                    left: 24,
                    right: 24,
                    child: _buildInfoOverlay(),
                  ),

                  if (!controller.isMatched)
                    Positioned(
                      bottom: 24,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleAction(Icons.close_rounded, Colors.white10, () => Navigator.pop(context)),
                          _buildCircleAction(Icons.favorite_rounded, AppColors.primary, onLike),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileContentWidgets.buildAboutMeSection(profile),
                const SizedBox(height: 32),
                ProfileContentWidgets.buildMeetsSection(profile),
                const SizedBox(height: 32),
                ProfileContentWidgets.buildInterestsSection(profile),
                const SizedBox(height: 32),
                _buildQuickStatsSection(),
                const SizedBox(height: 24),
                _buildLifestyleSection(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceBadge(ProfileModel profile, UserModel? user) {
    String distance = "Nearby";
    if (user?.latitude != null && user?.longitude != null) {
      distance = "2.5km"; 
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.near_me_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                distance,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoOverlay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "${profile.fullName}, ${controller.age}",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_rounded, color: Colors.white.withValues(alpha: 0.6), size: 16),
            const SizedBox(width: 4),
            Text(
              profile.city ?? "Nearby",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return ProfileContentWidgets.buildSectionContainer(
      title: "Quick Stats",
      items: [
        ProfileContentWidgets.buildStatTile(Icons.height_rounded, "Height", "${profile.height ?? '-'} cm"),
        ProfileContentWidgets.buildStatTile(Icons.work_outline_rounded, "Job", profile.jobTitle ?? "Add your job"),
        ProfileContentWidgets.buildStatTile(Icons.school_outlined, "Education", profile.education ?? "Add education"),
        ProfileContentWidgets.buildStatTile(Icons.home_outlined, "Hometown", profile.hometown ?? "Add hometown"),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return ProfileContentWidgets.buildSectionContainer(
      title: "Lifestyle",
      items: [
        ProfileContentWidgets.buildStatTile(Icons.local_bar_rounded, "Drinking", profile.drinking ?? "-"),
        ProfileContentWidgets.buildStatTile(Icons.smoke_free_rounded, "Smoking", profile.smoking ?? "-"),
        ProfileContentWidgets.buildStatTile(Icons.fitness_center_rounded, "Exercise", profile.exercise ?? "-"),
        ProfileContentWidgets.buildStatTile(Icons.pets_rounded, "Pets", profile.pets ?? "-"),
        ProfileContentWidgets.buildStatTile(Icons.menu_book_rounded, "Religion", profile.religion ?? "-"),
      ],
    );
  }
}
