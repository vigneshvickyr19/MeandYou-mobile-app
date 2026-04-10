import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/profile_model.dart';
import '../controllers/profile_controller.dart';
import 'profile_gallery.dart';
import 'profile_content_widgets.dart';
import '../pages/help_center_page.dart';
import '../../../subscription/presentation/widgets/subscription_upsell_sheet.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../subscription/domain/entities/user_subscription_entity.dart';

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
                    const SizedBox(height: 24),
                    _buildSubscriptionSection(context),
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
                    const SizedBox(height: 32),
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

  Widget _buildSubscriptionSection(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, subController, child) {
        final isPremium = subController.isPremium;
        final sub = subController.userSubscription;
        
        String expiryText = '';
        if (isPremium && sub != null) {
          expiryText = 'Expires on ${DateFormat('MMM dd, yyyy').format(sub.expiryDate)}';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPremium 
                ? [const Color(0xFFD4AF37), const Color(0xFF8A6E2F)] // Gold variant
                : [AppColors.white.withValues(alpha: 0.05), AppColors.white.withValues(alpha: 0.02)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPremium ? Colors.white.withValues(alpha: 0.1) : AppColors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Animated Icon Container
                  ZoomIn(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPremium 
                            ? Colors.white.withValues(alpha: 0.2) 
                            : AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        boxShadow: isPremium ? [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ] : [],
                      ),
                      child: Icon(
                        isPremium ? Icons.star_rounded : Icons.workspace_premium_rounded,
                        color: isPremium ? Colors.white : AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPremium ? 'Premium Plan Active' : 'Upgrade to Premium',
                          style: TextStyle(
                            color: isPremium ? Colors.white : AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isPremium 
                              ? expiryText 
                              : 'Unlock unlimited likes, see who likes you and more',
                          style: TextStyle(
                            color: isPremium 
                                ? Colors.white.withValues(alpha: 0.8) 
                                : AppColors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                   Expanded(
                    child: ElevatedButton(
                      onPressed: () => SubscriptionUpsellSheet.show(
                        context,
                        title: isPremium ? 'Manage Subscription' : 'Unlock Premium',
                        subtitle: isPremium ? 'Upgrade or renew your plan' : 'Upgrade to experience the best of our app',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPremium ? Colors.white.withValues(alpha: 0.2) : AppColors.primary,
                        foregroundColor: isPremium ? Colors.white : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        side: isPremium ? const BorderSide(color: Colors.white24) : null,
                      ),
                      child: Text(
                        isPremium ? 'UPGRADE / MANAGE' : 'UPGRADE NOW',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800, 
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  if (isPremium) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        // History functionality
                        _showHistoryDialog(context, subController);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Icon(Icons.history_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  void _showHistoryDialog(BuildContext context, SubscriptionController subController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Subscription History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: subController.subscriptionHistory.isEmpty
                  ? Center(
                      child: Text(
                        'No history found',
                        style: TextStyle(color: Colors.white38),
                      ),
                    )
                  : ListView.builder(
                      itemCount: subController.subscriptionHistory.length,
                      itemBuilder: (context, index) {
                        final history = subController.subscriptionHistory[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 18),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Plan: ${history.planId}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${DateFormat('MMM dd, yyyy').format(history.startDate)} - ${DateFormat('MMM dd, yyyy').format(history.expiryDate)}',
                                      style: TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                history.status.name.toUpperCase(),
                                style: TextStyle(
                                  color: history.status == SubscriptionStatus.active ? Colors.green : Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
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
