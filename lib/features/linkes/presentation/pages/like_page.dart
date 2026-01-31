import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../chat/presentation/pages/chat_detail_page.dart';
import '../controllers/like_controller.dart';
import '../widgets/like_card.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  late LikeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LikeController();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      _controller.loadLikesReceived(authProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          elevation: 0,
          title: const Text(
            'Likes',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<LikeController>(
          builder: (context, controller, _) {
            if (controller.isLoading && controller.likedItems.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (controller.likedItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_outline,
                        size: 64,
                        color: AppColors.white.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No users liked you yet',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.6),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.likedItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = controller.likedItems[index];
                final like = item['like'];
                final user = item['user'];

                return LikeCard(
                  user: user,
                  likeTime: controller.formatTimeAgo(like.createdAt),
                  onSayHello: () async {
                    final chatRoomId = await controller.sayHello(currentUserId, user);
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailPage(
                            chatRoomId: chatRoomId,
                            otherUser: user,
                          ),
                        ),
                      );
                    }
                  },
                  onViewProfile: () async {
                    await controller.viewProfile(currentUserId, user.id);
                    if (mounted) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.otherProfile,
                        arguments: {'userId': user.id},
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
