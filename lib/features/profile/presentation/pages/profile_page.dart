import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_skeleton.dart';
import '../widgets/own_profile_view.dart';
import '../widgets/other_profile_view.dart';
import 'edit_profile_page.dart';
import '../../../home/presentation/controllers/home_navigation_controller.dart';
import '../../../../core/services/like_action_service.dart';
import '../../../home/presentation/widgets/heart_flow_overlay.dart';
import '../../../../core/widgets/subscription_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  final String? userId;
  final bool isTab;

  const ProfilePage({super.key, this.userId, this.isTab = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileController _controller;
  final ScrollController _scrollController = ScrollController();
  final StreamController<void> _heartTriggerController = StreamController<void>.broadcast();
  double _appBarOpacity = 0;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(context.read<AuthProvider>());
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadProfile(widget.userId);
    });
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    double newOpacity = (offset / 200).clamp(0, 1);
    if (newOpacity != _appBarOpacity) {
      setState(() {
        _appBarOpacity = newOpacity;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heartTriggerController.close();
    super.dispose();
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
            return _buildNotFound();
          }

          final isOwnProfile = widget.userId == null;

          return Scaffold(
            backgroundColor: AppColors.black,
            extendBodyBehindAppBar: true,
            appBar: _buildAppBar(profile, isOwnProfile),
            body: Stack(
              children: [
                isOwnProfile 
                    ? OwnProfileView(
                        profile: profile,
                        controller: controller,
                        scrollController: _scrollController,
                      )
                    : OtherProfileView(
                        profile: profile,
                        controller: controller,
                        onLike: () => _handleLike(context, profile.userId),
                      ),
                if (!isOwnProfile)
                  HeartFlowOverlay(triggerStream: _heartTriggerController.stream),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ProfileModel profile, bool isOwnProfile) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isOwnProfile ? 15 * _appBarOpacity : 0,
            sigmaY: isOwnProfile ? 15 * _appBarOpacity : 0,
          ),
          child: AppBar(
            backgroundColor: isOwnProfile 
                ? AppColors.black.withValues(alpha: 0.5 * _appBarOpacity)
                : AppColors.black,
            elevation: 0,
            leading: Center(
              child: AppBackButton(
                onTap: widget.isTab
                    ? () => context.read<HomeNavigationController>().changeTab(0)
                    : null,
              ),
            ),
            centerTitle: !isOwnProfile,
            titleSpacing: isOwnProfile ? 0 : null,
            title: isOwnProfile 
              ? Opacity(
                  opacity: _appBarOpacity,
                  child: Text(
                    "${profile.fullName}${_controller.age != null ? ', ${_controller.age}' : ''}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                )
              : Text(
                  "${profile.fullName}${_controller.age != null ? ', ${_controller.age}' : ''}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            actions: [
              if (isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () => _showMoreMenu(context, _controller),
                )
              else
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  onPressed: () => _showUserOptions(context),
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const Center(child: AppBackButton()),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_rounded, size: 64, color: Colors.white10),
            SizedBox(height: 16),
            Text(
              "Profile not found",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.white),
                title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );

                  if (result == true) {
                    controller.loadProfile(widget.userId);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: Colors.white),
                title: const Text("Privacy Settings", style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text("Logout", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  controller.logout(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showUserOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report_gmailerrorred_rounded, color: Colors.orange),
              title: const Text("Report User", style: TextStyle(color: Colors.orange)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block_flipped, color: AppColors.error),
              title: const Text("Block User", style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLike(BuildContext context, String targetUserId) async {
    try {
      // Trigger Animation & Haptics (Discover Style)
      _heartTriggerController.add(null);
      HapticFeedback.mediumImpact();

      await LikeActionService.instance.handleLike(targetUserId);
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile Liked!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Brief delay to show animation before navigating back
      await Future.delayed(const Duration(milliseconds: 1000));
      if (context.mounted) {
        Navigator.pop(context);
      }
    } on LikeLimitReachedException {
      if (!context.mounted) return;
      HapticFeedback.vibrate();
      SubscriptionBottomSheet.show(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error liking profile. Please try again.')),
      );
    }
  }
}
