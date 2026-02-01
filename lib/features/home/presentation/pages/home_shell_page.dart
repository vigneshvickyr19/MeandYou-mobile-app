import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_bottom_nav/custom_bottom_nav.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../linkes/presentation/pages/like_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../controllers/home_navigation_controller.dart';
import 'home_page.dart';

class HomeShellPage extends StatefulWidget {
  final int? initialTabIndex;

  const HomeShellPage({super.key, this.initialTabIndex});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  late HomeNavigationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeNavigationController();

    // Set initial tab index from deep link if provided
    if (widget.initialTabIndex != null &&
        widget.initialTabIndex! >= 0 &&
        widget.initialTabIndex! < 4) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.changeTab(widget.initialTabIndex!);
      });
    }
  }

  @override
  void dispose() {
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
              // Use Stack to overlay bottom nav on content
              body: Stack(
                children: [
                  // Full-screen content (100% height, renders behind bottom nav)
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: IndexedStack(
                      index: controller.index,
                      children: const [
                        HomePage(),
                        LikePage(),
                        ChatPage(),
                        ProfilePage(isTab: true),
                      ],
                    ),
                  ),
                  
                  // Floating bottom navigation (absolute positioned at bottom)
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
    return Container(
      // Add internal SafeArea padding for home indicator
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
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
      ),
    );
  }
}
