import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/profile_model.dart';
import '../controllers/profile_controller.dart';
import 'profile_gallery.dart';
import 'profile_content_widgets.dart';
import '../pages/help_center_page.dart';

class OwnProfileView extends StatelessWidget {
  final ProfileModel profile;
  final ProfileController controller;
  final ScrollController scrollController;

  const OwnProfileView({
    super.key,
    required this.profile,
    required this.controller,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 200,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
          ),
        ),

        SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeroSection(),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildNameAge(),
                    const SizedBox(height: 8),
                    _buildLocation(),
                    const SizedBox(height: 32),
                    
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: ProfileGallery(photos: profile.photos ?? []),
                    ),
                    
                    const SizedBox(height: 32),
                    ProfileContentWidgets.buildAboutMeSection(profile),
                    const SizedBox(height: 24),
                    _buildQuickStatsSection(),
                    const SizedBox(height: 24),
                    _buildLifestyleSection(),
                    const SizedBox(height: 24),
                    _buildDatingSection(),
                    const SizedBox(height: 24),
                    ProfileContentWidgets.buildInterestsSection(profile),
                    const SizedBox(height: 24),
                    _buildVerificationSection(context),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    final photos = profile.photos ?? [];
    final profilePic = photos.isNotEmpty ? photos[0] : null;

    return SizedBox(
      height: 440,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: profilePic != null
                ? Image.network(profilePic, fit: BoxFit.cover)
                : Container(color: const Color(0xFF1A1A1A)),
          ),
          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                    AppColors.black,
                  ],
                  stops: const [0, 0.4, 0.8, 1],
                ),
              ),
            ),
          ),

          if (photos.length > 1)
            Positioned(
              top: 100,
              right: 16,
              child: Column(
                children: List.generate(
                  photos.length.clamp(0, 5),
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    width: 4,
                    height: index == 0 ? 20 : 6,
                    decoration: BoxDecoration(
                      color: index == 0 ? AppColors.primary : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameAge() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            profile.fullName ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          if (controller.age != null) ...[
            const SizedBox(width: 8),
            Text(
              "${controller.age}",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 30,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    final locationText = [profile.city, profile.state, profile.country]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');

    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on_rounded,
            color: AppColors.primary.withValues(alpha: 0.8),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            locationText.isEmpty ? 'Location not set' : locationText,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

  Widget _buildDatingSection() {
    return ProfileContentWidgets.buildSectionContainer(
      title: "Dating Preferences",
      items: [
        ProfileContentWidgets.buildStatTile(Icons.search_rounded, "Looking for", profile.lookingFor ?? "-"),
        ProfileContentWidgets.buildStatTile(Icons.people_outline_rounded, "Age Range", "${profile.minAge ?? 18} - ${profile.maxAge ?? 50}"),
        ProfileContentWidgets.buildStatTile(Icons.map_outlined, "Distance", "Up to ${profile.distance ?? 50} km"),
      ],
    );
  }

  Widget _buildVerificationSection(BuildContext context) {
    return ProfileContentWidgets.buildSectionContainer(
      title: "App Support",
      items: [
        ProfileContentWidgets.buildStatTile(
          Icons.help_center_outlined, 
          "Help Center", 
          "FAQs & Support",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpCenterPage()),
          ),
        ),
        ProfileContentWidgets.buildStatTile(Icons.verified_user_outlined, "Safety", "Verified Profile"),
        ProfileContentWidgets.buildStatTile(Icons.phone_iphone_rounded, "Phone", controller.user?.phoneNumber ?? "Not provided"),
        ProfileContentWidgets.buildStatTile(Icons.alternate_email_rounded, "Email", controller.user?.email ?? "Not provided"),
      ],
    );
  }
}
