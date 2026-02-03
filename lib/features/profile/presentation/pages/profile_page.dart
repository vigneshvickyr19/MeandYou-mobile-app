import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_gallery.dart';
import '../widgets/profile_skeleton.dart';
import '../../../home/presentation/controllers/home_navigation_controller.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;
  final bool isTab;

  const ProfilePage({super.key, this.userId, this.isTab = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(context.read<AuthProvider>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const ProfileSkeleton();
          }

          final profile = controller.profile;
          if (profile == null) {
            return Scaffold(
              backgroundColor: AppColors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: const Center(child: AppBackButton()),
              ),
              body: const Center(
                child: Text(
                  "Profile not found",
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.black,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    stretch: true,
                    backgroundColor: AppColors.black,
                    automaticallyImplyLeading: false,
                    leading: Center(
                      child: AppBackButton(
                        onTap: widget.isTab
                          ? () => context.read<HomeNavigationController>().changeTab(0)
                          : null,
                      ),
                    ),
                    title: innerBoxIsScrolled
                        ? const Text(
                            "Profile",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner, color: AppColors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: AppColors.white),
                        onPressed: () => _showMoreMenu(context, controller),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Cover Image
                          _buildCoverImage(profile.photos),
                          // Overlay Gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                          // Initial "Profile" text
                          if (!innerBoxIsScrolled)
                            const Positioned(
                              top: 60,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Text(
                                  "Profile",
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          // Profile Image Overlap
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: _buildProfileImage(profile.photos),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Name and Age
                    Text(
                      "${profile.fullName ?? 'User'}, ${controller.age ?? ''}",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.white.withValues(alpha: 0.6),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          [profile.city, profile.state, profile.country]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(', ')
                                  .isEmpty
                              ? 'Location not set'
                              : [profile.city, profile.state, profile.country]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(', '),
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(height: 32),
                    // Photo Gallery
                    ProfileGallery(photos: profile.photos ?? []),
                    const SizedBox(height: 24),
                    // About Me
                    _buildAboutMeSection(profile),
                    const SizedBox(height: 24),
                    // Quick Stats
                    _buildQuickStatsSection(profile),
                    const SizedBox(height: 24),
                    // Lifestyle Preferences
                    _buildLifestyleSection(profile),
                    const SizedBox(height: 24),
                    // Dating Preferences
                    _buildDatingSection(profile),
                    const SizedBox(height: 24),
                    // Interests
                    _buildInterestsSection(profile),
                    const SizedBox(height: 24),
                    // Verification
                    _buildVerificationSection(profile, controller),
                    const SizedBox(height: 100), // Extra space for bottom nav
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoverImage(List<String>? photos) {
    if (photos != null && photos.length > 1) {
      return Image.network(photos[1], fit: BoxFit.cover);
    }
    return Container(
      color: Colors.grey[900],
      child: const Icon(Icons.image, color: Colors.white10, size: 64),
    );
  }

  Widget _buildProfileImage(List<String>? photos) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.black, width: 4),
                image: photos != null && photos.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(photos[0]),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[800],
              ),
              child: photos == null || photos.isEmpty
                  ? const Icon(Icons.person, color: Colors.white24, size: 60)
                  : null,
            ),
            Container(
              margin: const EdgeInsets.only(right: 8, bottom: 8),
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.info,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.white, size: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutMeSection(ProfileModel profile) {
    return ProfileInfoSection(
      title: "About Me",
      items: [
        ProfileInfoItem(
          title: "Bio Section",
          value: profile.bio ?? "Short intro about myself...",
        ),
      ],
    );
  }

  Widget _buildQuickStatsSection(ProfileModel profile) {
    return ProfileInfoSection(
      title: "Quick Stats",
      items: [
        ProfileInfoItem(
          title: "Height",
          value: "${profile.height ?? '-'} cm",
        ),
        ProfileInfoItem(
          title: "Job Title",
          value: profile.jobTitle ?? "Add your job",
        ),
        ProfileInfoItem(
          title: "Company",
          value: "Add company",
        ),
        ProfileInfoItem(
          title: "Education",
          value: profile.education ?? "Add education",
        ),
        ProfileInfoItem(
          title: "Hometown",
          value: profile.hometown ?? "Add hometown",
        ),
      ],
    );
  }

  Widget _buildLifestyleSection(ProfileModel profile) {
    return ProfileInfoSection(
      title: "Lifestyle Preferences",
      items: [
        ProfileInfoItem(
          title: "Drinking",
          value: profile.drinking ?? "-",
        ),
        ProfileInfoItem(
          title: "Smoking",
          value: profile.smoking ?? "-",
        ),
        ProfileInfoItem(
          title: "Exercise",
          value: profile.exercise ?? "-",
        ),
        ProfileInfoItem(
          title: "Diet",
          value: profile.diet ?? "-",
        ),
        ProfileInfoItem(
          title: "Pets",
          value: profile.pets ?? "-",
        ),
        ProfileInfoItem(
          title: "Religion",
          value: profile.religion ?? "-",
        ),
        ProfileInfoItem(
          title: "Language",
          value: profile.language ?? "-",
        ),
      ],
    );
  }

  Widget _buildDatingSection(ProfileModel profile) {
    return ProfileInfoSection(
      title: "Dating Preferences",
      items: [
        ProfileInfoItem(
          title: "Looking for",
          value: profile.lookingFor ?? "-",
        ),
        ProfileInfoItem(
          title: "Age Range",
          value: "${profile.minAge ?? 18} - ${profile.maxAge ?? 50}",
        ),
        ProfileInfoItem(
          title: "Distance",
          value: "Up to ${profile.distance ?? 50} km",
        ),
      ],
    );
  }

  Widget _buildInterestsSection(ProfileModel profile) {
    final List<String> interests = profile.interests ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Text(
            "Interests",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      interest,
                      style: const TextStyle(color: AppColors.white, fontSize: 13),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationSection(ProfileModel profile, ProfileController controller) {
    return ProfileInfoSection(
      title: "Verification",
      items: [
        ProfileInfoItem(
          title: "Identity Verification",
          value: "",
          isVerified: true,
        ),
        ProfileInfoItem(
          title: "Phone Number",
          value: controller.user?.phoneNumber ?? "Not provided",
        ),
        ProfileInfoItem(
          title: "Email",
          value: controller.user?.email ?? "Not provided",
        ),
        ProfileInfoItem(
          title: "Linkedin",
          value: profile.linkedin ?? "Not linked",
        ),
        ProfileInfoItem(
          title: "Instagram",
          value: profile.instagram ?? "Not linked",
        ),
        ProfileInfoItem(
          title: "Facebook",
          value: profile.facebook ?? "Not linked",
        ),
        ProfileInfoItem(
          title: "X",
          value: profile.x ?? "Not linked",
        ),
      ],
    );
  }

  void _showMoreMenu(BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.settings, color: AppColors.white),
                title: const Text("Settings", style: TextStyle(color: AppColors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text("Logout", style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  controller.logout(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
