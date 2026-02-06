import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/pill_tab_switcher.dart';
import 'nearby_tab.dart';
import 'discover_tab.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../widgets/home_notification_icon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update header
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<NotificationController>().listenToNotifications(authProvider.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Get current user's location name
  String _getUserLocationName() {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user?.address != null && user!.address!.isNotEmpty) {
      final parts = user.address!.split(',');
      if (parts.length >= 2) {
        return parts.take(2).join(',').trim();
      }
      return user.address!;
    }
    return '2972 Westheimer Rd';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final isDiscoverTab = _tabController.index == 1;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Full-screen content
          SizedBox(
            width: double.infinity,
            height: screenHeight,
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [NearbyTab(), DiscoverTab()],
            ),
          ),

          // Dynamic floating header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildDynamicHeader(context, isDiscoverTab),
          ),
        ],
      ),
    );
  }

  /// Build dynamic header that changes based on selected tab
  Widget _buildDynamicHeader(BuildContext context, bool isDiscoverTab) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.black.withValues(alpha: 0.8),
            AppColors.black.withValues(alpha: 0.6),
            AppColors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 0.8, 1.0],
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: isDiscoverTab
            ? _buildDiscoverHeader(context)
            : _buildNearbyHeader(context),
      ),
    );
  }

  Widget _buildNearbyHeader(BuildContext context) {
    return Row(
      key: const ValueKey('nearby_header'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Center: Pill Tab Switcher
        Expanded(
          child: Center(
            child: PillTabSwitcher(
              tabs: const ['Nearby', 'Discover'],
              controller: _tabController,
            ),
          ),
        ),

        // Right: Notification Icon
        const HomeNotificationIcon(),
      ],
    );
  }

  Widget _buildDiscoverHeader(BuildContext context) {
    return Row(
      key: const ValueKey('discover_header'),
      children: [
        // Left: Back arrow
        AppBackButton(
          onTap: () => _tabController.animateTo(0), // Go back to Nearby
        ),

        // Center: Location name with "Discover" title
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Discover',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _getUserLocationName(),
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Right: Notification Icon
        const HomeNotificationIcon(),
      ],
    );
  }
}
