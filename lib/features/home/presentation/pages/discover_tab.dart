import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../controllers/discover_controller.dart';
import '../widgets/user_card.dart';
import '../widgets/swipe_card_stack.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  late DiscoverController _controller;
  final SwipeController _swipeController = SwipeController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = DiscoverController();
    
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      _controller.loadUsers(authProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSwipe(int index, bool isRight, String currentUserId) {
    if (index - 1 < _controller.users.length) {
      final user = _controller.users[index - 1];
      if (isRight) {
        _controller.likeUser(currentUserId, user);
      } else {
        _controller.dislikeUser(user);
      }
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<DiscoverController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (controller.users.isEmpty || _currentIndex >= controller.users.length) {
            return _buildEmptyState();
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F0F0F),
                  Color(0xFF1A1A1A),
                ],
              ),
            ),
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: SwipeCardStack(
                  controller: _swipeController,
                  items: controller.users,
                  initialIndex: _currentIndex,
                  onSwipeEnd: (index, isRight) => _handleSwipe(index, isRight, currentUserId),
                  itemBuilder: (context, user) {
                    return UserCard(
                      user: user,
                      distance: controller.getDistance(user),
                      onLike: () => _swipeController.swipeRight(),
                      onDislike: () => _swipeController.swipeLeft(),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: 1.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 64,
                color: AppColors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No users found to swipe',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Check back later for new people nearby',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
                final authProvider = context.read<AuthProvider>();
                if (authProvider.currentUser != null) {
                  _controller.loadUsers(authProvider.currentUser!.id);
                }
              },
              child: const Text(
                'REFRESH',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
