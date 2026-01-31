import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/providers/auth_provider.dart';
import '../controllers/nearby_controller.dart';
import '../controllers/discover_controller.dart';
import '../widgets/user_avatar.dart';
import '../widgets/profile_preview_card.dart';
import '../../../chat/presentation/pages/chat_detail_page.dart';
import '../../../../data/repositories/chat_repository.dart';
import 'dart:math' as math;

class NearbyTab extends StatefulWidget {
  const NearbyTab({super.key});

  @override
  State<NearbyTab> createState() => _NearbyTabState();
}

class _NearbyTabState extends State<NearbyTab> with SingleTickerProviderStateMixin {
  late NearbyController _controller;
  late DiscoverController _discoverController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _controller = NearbyController();
    _discoverController = DiscoverController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      _controller.loadUsers(authProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _discoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<NearbyController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return Stack(
            children: [
              // Animated Map Background
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: TopographicMapPainter(
                      animationValue: _animationController.value,
                    ),
                  );
                },
              ),
              // User Avatars
              if (controller.users.isNotEmpty)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: List.generate(
                        controller.users.length,
                        (index) {
                          final user = controller.users[index];
                          final position = controller.getUserPosition(
                            index,
                            Size(constraints.maxWidth, constraints.maxHeight),
                          );
                          final distance = controller.getDistance(user);

                          return Positioned(
                            left: position.dx - 40,
                            top: position.dy - 60,
                            child: UserAvatar(
                              user: user,
                              distance: distance,
                              onTap: () => controller.selectUser(user),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              // Profile Preview Card
              if (controller.selectedUser != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ProfilePreviewCard(
                    user: controller.selectedUser!,
                    distance: controller.getDistance(controller.selectedUser!),
                    onClose: () => controller.selectUser(null),
                    onSayHello: () {
                      // Immediate navigation by calculating ID locally
                      final chatRoomId = ChatRepository.getChatRoomId(
                        currentUserId,
                        controller.selectedUser!.id,
                      );
                      
                      // Navigate first for "Direct navigation" feel
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailPage(
                            chatRoomId: chatRoomId,
                            otherUser: controller.selectedUser!,
                          ),
                        ),
                      );

                      // Send "Hello 👋" in logic layer (can be background)
                      _discoverController.sayHello(
                        currentUserId,
                        controller.selectedUser!,
                      );
                    },
                    onViewProfile: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.otherProfile,
                        arguments: {'userId': controller.selectedUser!.id},
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class TopographicMapPainter extends CustomPainter {
  final double animationValue;

  TopographicMapPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A2A2A).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw concentric circles with animation
    for (int i = 0; i < 15; i++) {
      final radius = (i * 40.0) + (animationValue * 40);
      
      // Create wavy path
      final path = Path();
      for (double angle = 0; angle < 2 * math.pi; angle += 0.1) {
        final wave = math.sin(angle * 3 + animationValue * 2 * math.pi) * 10;
        final x = centerX + (radius + wave) * math.cos(angle);
        final y = centerY + (radius + wave) * math.sin(angle);
        
        if (angle == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(TopographicMapPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
