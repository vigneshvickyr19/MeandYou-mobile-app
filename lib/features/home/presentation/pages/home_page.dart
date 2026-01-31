import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/pill_tab_switcher.dart';
import 'nearby_tab.dart';
import 'discover_tab.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    
    return Scaffold(
      backgroundColor: AppColors.black,
      // Remove SafeArea to allow full-screen content
      body: Stack(
        children: [
          // Full-screen content (100% height, renders behind overlays)
          SizedBox(
            width: double.infinity,
            height: screenHeight,
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                NearbyTab(),
                DiscoverTab(),
              ],
            ),
          ),
          
          // Floating header overlay (absolute positioned at top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFloatingHeader(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader(BuildContext context) {
    return Container(
      // Add internal SafeArea padding for notch/status bar
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      // Gradient background for better visibility over content
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center: Pill Tab Switcher
          Center(
            child: PillTabSwitcher(
              tabs: const ['Nearby', 'Discover'],
              controller: _tabController,
            ),
          ),
          
          // Right: Notification Icon
          Positioned(
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.white.withValues(alpha: 0.9),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
