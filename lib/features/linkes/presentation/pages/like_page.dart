import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/providers/auth_provider.dart';
import '../controllers/like_controller.dart';
import '../widgets/match_card.dart';
import '../widgets/received_like_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
import '../../../subscription/presentation/widgets/subscription_upsell_sheet.dart';
import '../../../../core/constants/subscription_constants.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild for tab indicator or header updates
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData({bool force = false}) {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      context.read<LikeController>().init(
        authProvider.currentUser!.id,
        force: force,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Dynamic Background Glows
          _buildBackgroundGlows(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [_buildLikesTab(), _buildMatchesTab()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlows() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: 150,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Consumer<LikeController>(
      builder: (context, controller, child) {
        final totalCount =
            controller.receivedLikes.length + controller.matches.length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: const Text(
                      'Links',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  if (totalCount > 0)
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        'You have $totalCount new interactions',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: GestureDetector(
                  onTap: () => _loadData(force: true),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: controller.isLoading
                          ? AppColors.primary
                          : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Consumer<LikeController>(
      builder: (context, controller, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.3),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: [
              _buildTabTitle('Liked You', controller.receivedLikes.length),
              _buildTabTitle('Matches', controller.matches.length),
            ],
          ),
        );
      },
    );
  }

  Tab _buildTabTitle(String title, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLikesTab() {
    return Consumer<LikeController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.receivedLikes.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.receivedLikes.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'No likes yet',
            subtitle: 'Start exploring to get noticed by others!',
          );
        }

        final subController = context.watch<SubscriptionController>();
        final bool canSeeLikes = subController.hasBenefit(SubscriptionBenefits.seeWhoLikedYou);

        return RefreshIndicator(
          onRefresh: () async => _loadData(force: true),
          backgroundColor: const Color(0xFF1E1E1E),
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: controller.receivedLikes.length,
            itemBuilder: (context, index) {
              final item = controller.receivedLikes[index];
              return ReceivedLikeCard(
                index: index,
                user: item.fromUser,
                timeAgo: controller.formatTimeAgo(item.like.createdAt),
                isBlurred: !canSeeLikes,
                onTap: () {
                  if (canSeeLikes) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.otherProfile,
                      arguments: {'userId': item.fromUser.id},
                    );
                  } else {
                    SubscriptionUpsellSheet.show(
                      context,
                      title: 'See Who Liked You',
                      subtitle: 'Upgrade to see all the people who have already liked your profile.',
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMatchesTab() {
    return Consumer<LikeController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.matches.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.matches.isEmpty) {
          return _buildEmptyState(
            icon: Icons.bolt_rounded,
            title: 'No matches yet',
            subtitle: 'Matches appear when you both like each other.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(force: true),
          backgroundColor: const Color(0xFF1E1E1E),
          color: AppColors.primary,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.72,
            ),
            itemCount: controller.matches.length,
            itemBuilder: (context, index) {
              final item = controller.matches[index];
              return MatchCard(
                index: index,
                user: item.otherUser,
                matchDate: controller.formatTimeAgo(item.match.createdAt),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.otherProfile,
                    arguments: {'userId': item.otherUser.id},
                  );
                },
                onChatTap: () async {
                  final currentUserId = context
                      .read<AuthProvider>()
                      .currentUser
                      ?.id;
                  if (currentUserId != null) {
                    try {
                      final chatRoomId = await controller.getOrCreateChat(
                        currentUserId,
                        item.otherUser.id,
                      );
                      if (context.mounted) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.chatDetail,
                          arguments: {
                            'chatRoomId': chatRoomId,
                            'otherUser': item.otherUser,
                          },
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        _showErrorSnackBar('Error starting chat: $e');
                      }
                    }
                  }
                },
              );
            },
          ),
        );
      },
    );
  }


  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Syncing your connections...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    AppSnackbar.show(
      context,
      message: message,
      type: SnackbarType.error,
    );
  }

}
