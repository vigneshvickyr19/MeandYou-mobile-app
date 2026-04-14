import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/custom_bottom_nav/custom_bottom_nav.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../linkes/presentation/pages/like_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../admin/presentation/pages/admin_panel_page.dart';
import '../controllers/home_navigation_controller.dart';
import 'home_page.dart';
import '../../../../core/providers/location_provider.dart';

class HomeShellPage extends StatefulWidget {
  final int? initialTabIndex;
  final int? initialSubTabIndex;

  const HomeShellPage({super.key, this.initialTabIndex, this.initialSubTabIndex});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage>
    with WidgetsBindingObserver {
  late HomeNavigationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = HomeNavigationController();

    // Set initial tab index from deep link if provided
    if (widget.initialTabIndex != null &&
        widget.initialTabIndex! >= 0 &&
        widget.initialTabIndex! < 4) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.changeTab(widget.initialTabIndex!);
      });
    }

    // Run once after the first frame — guards in each service prevent re-runs on rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Sync FCM token (only writes if changed)
      NotificationService.instance.syncTokenNow();

      // Initialize subscription streams — guarded inside initUser() by _activeUserId
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<SubscriptionController>().initUser(authProvider.currentUser!.id);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check location permission if user returns from the Settings app.
    // We deliberately do NOT re-initialize services or re-fetch data here
    // to avoid redundant API calls on every focus change.
    if (state == AppLifecycleState.resumed) {
      context.read<LocationProvider>().refreshStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<HomeNavigationController>(
        builder: (_, controller, child) {
          return PopScope(
            canPop: controller.index == 0,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (controller.index != 0) {
                controller.changeTab(0);
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.black,
              body: Stack(
                children: [
                  // Full-screen content
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: IndexedStack(
                      index: controller.index,
                      children: [
                        HomePage(initialSubTabIndex: widget.initialSubTabIndex),
                        const LikePage(),
                        const ChatPage(),
                        const ProfilePage(isTab: true),
                        const AdminPanelPage(),
                      ],
                    ),
                  ),

                  // Floating bottom navigation
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildFloatingBottomNav(controller),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingBottomNav(HomeNavigationController controller) {
    final showAdmin =
        context.watch<AuthProvider>().currentUser?.role == 'admin';
    return Container(
      // Add internal SafeArea padding for home indicator
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      // Gradient background for better visibility
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.black.withValues(alpha: 0.95),
            AppColors.black.withValues(alpha: 0.8),
            AppColors.black.withValues(alpha: 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 0.8, 1.0],
        ),
      ),
      child: CustomBottomNav(
        currentIndex: controller.index,
        onChanged: controller.changeTab,
        showAdmin: showAdmin,
      ),
    );
  }
}
