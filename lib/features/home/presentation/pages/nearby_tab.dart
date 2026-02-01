import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../matching/presentation/controllers/nearby_controller.dart';
import '../../../chat/presentation/pages/chat_detail_page.dart';
import '../../../../core/models/user_model.dart';
import '../widgets/profile_preview_card.dart';
import '../widgets/premium_animated_avatar.dart';
import '../../../matching/domain/entities/nearby_match_entity.dart';
import '../../../../data/repositories/chat_repository.dart';
import 'dart:math' as math;

class NearbyTab extends StatefulWidget {
  const NearbyTab({super.key});

  @override
  State<NearbyTab> createState() => _NearbyTabState();
}

class _NearbyTabState extends State<NearbyTab> with TickerProviderStateMixin {
  late NearbyController _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _controller = NearbyController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        _controller.loadUsers(authProvider.currentUser!);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<NearbyController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Stack(
            children: [
              // 1. Topographic Wave Background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: TopographicWavePainter(
                        animationValue: _animationController.value,
                      ),
                    );
                  },
                ),
              ),

              // 2. Connection Lines
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final center = Offset(
                      constraints.maxWidth / 2,
                      constraints.maxHeight / 2,
                    );
                    return CustomPaint(
                      painter: ConnectionLinesPainter(
                        center: center,
                        users: controller.users,
                        selectedMatch: controller.selectedMatch,
                        animationValue: _animationController.value,
                        constraints: constraints,
                        controller: controller,
                      ),
                    );
                  },
                ),
              ),

              // 3. Central Pulse (Current User)
              Center(
                child: GestureDetector(
                  onTap: () => controller.closeSelectedUser(),
                  child: _buildCentralUser(currentUser),
                ),
              ),

              // 4. Radial Nearby Matches
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: List.generate(controller.users.length, (index) {
                        final match = controller.users[index];
                        final pos = controller.getUserPosition(
                          index,
                          constraints.biggest,
                        );

                        return AnimatedPositioned(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutBack,
                          left: pos.dx - 30,
                          top: pos.dy - 64,
                          child: _buildNearbyUserAvatar(match, index),
                        );
                      }),
                    );
                  },
                ),
              ),

              // 5. Profile Preview Overlay (Target Card)
              if (controller.selectedMatch != null)
                Positioned(
                  bottom: 110,
                  left: 20,
                  right: 20,
                  child: ProfilePreviewCard(
                    match: controller.selectedMatch!,
                    onClose: () => controller.closeSelectedUser(),
                    onViewProfile: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.otherProfile,
                        arguments: {'userId': controller.selectedMatch!.id},
                      );
                    },
                    onSayHello: () async {
                      final authProvider = context.read<AuthProvider>();
                      if (authProvider.currentUser == null) return;

                      // Use ChatRepository to get or create a real room ID
                      final chatRepository = ChatRepository();
                      final chatRoomId = await chatRepository
                          .getOrCreateChatRoom(
                            authProvider.currentUser!.id,
                            controller.selectedMatch!.id,
                          );

                      final otherUser = UserModel(
                        id: controller.selectedMatch!.id,
                        email: '',
                        fullName: controller.selectedMatch!.fullName,
                        profileImageUrl:
                            controller.selectedMatch!.profileImageUrl,
                      );

                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailPage(
                              chatRoomId: chatRoomId,
                              otherUser: otherUser,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),

              // 6. Empty State
              if (!controller.isLoading && controller.users.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Searching for people nearby...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCentralUser(UserModel? user) {
    return PremiumAnimatedAvatar(imageUrl: user?.profileImageUrl, size: 80);
  }

  Widget _buildNearbyUserAvatar(NearbyMatchEntity match, int index) {
    return GestureDetector(
      onTap: () => _controller.selectUser(match),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: -3,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A2A),
              border: Border.all(
                color: _controller.selectedMatch?.id == match.id
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.12),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: ClipOval(
              child: match.profileImageUrl != null
                  ? Image.network(match.profileImageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white24,
                        size: 25,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopographicWavePainter extends CustomPainter {
  final double animationValue;

  TopographicWavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Full-screen black background
    final bgPaint = Paint()..color = const Color(0xFF050505);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Animated Radial Gradients (Cinematic Lighting)
    _drawRadialGlow(
      canvas,
      size,
      0.4,
      const Color(0xFFE85D04).withOpacity(0.08),
    );
    _drawRadialGlow(
      canvas,
      size,
      -0.3,
      const Color(0xFF3B82F6).withOpacity(0.05),
    );

    // 3. Gradient colors for the waves
    final gradientColors = [
      const Color(0xFF10B981), // Green
      const Color(0xFFFBBF24), // Yellow
      const Color(0xFFE85D04), // Orange
      const Color(0xFF3B82F6), // Blue
    ];

    // 4. Draw flowing topographic contour lines
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Create multiple wave layers
    const int numLayers = 50;
    const double baseSpacing = 18.0;

    for (int layer = 0; layer < numLayers; layer++) {
      final progress = layer / numLayers;
      final animOffset = animationValue * 100;

      final colorIndex =
          (layer / (numLayers / gradientColors.length)).floor() %
          gradientColors.length;
      final nextColorIndex = (colorIndex + 1) % gradientColors.length;
      final colorProgress =
          (layer % (numLayers / gradientColors.length)) /
          (numLayers / gradientColors.length);

      final color = Color.lerp(
        gradientColors[colorIndex],
        gradientColors[nextColorIndex],
        colorProgress,
      )!;

      paint.color = color.withOpacity(0.08 + (progress * 0.05));

      final path = Path();
      bool firstPoint = true;

      for (double x = -50; x <= size.width + 50; x += 10) {
        final y1 = math.sin((x + animOffset) * 0.006 + layer * 0.3) * 35;
        final y2 = math.sin((x - animOffset * 0.4) * 0.01 + layer * 0.2) * 25;

        final baseY = (layer * baseSpacing) + (size.height * 0.05);
        final y = baseY + y1 + y2;

        if (firstPoint) {
          path.moveTo(x, y);
          firstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawRadialGlow(
    Canvas canvas,
    Size size,
    double offsetMult,
    Color color,
  ) {
    final center = Offset(
      size.width / 2 +
          math.sin(animationValue * 2 * math.pi * 0.5 + offsetMult) *
              size.width *
              0.2,
      size.height / 2 +
          math.cos(animationValue * 2 * math.pi * 0.3 + offsetMult) *
              size.height *
              0.2,
    );

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
        radius: 1.5,
      ).createShader(Rect.fromCircle(center: center, radius: size.width));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(TopographicWavePainter oldDelegate) => true;
}

class ConnectionLinesPainter extends CustomPainter {
  final Offset center;
  final List<NearbyMatchEntity> users;
  final NearbyMatchEntity? selectedMatch;
  final double animationValue;
  final BoxConstraints constraints;
  final NearbyController controller;

  ConnectionLinesPainter({
    required this.center,
    required this.users,
    required this.selectedMatch,
    required this.animationValue,
    required this.constraints,
    required this.controller,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      final target = controller.getUserPosition(i, size);
      final isSelected = selectedMatch?.id == user.id;

      if (isSelected) {
        _drawSelectedLine(
          canvas,
          center,
          target,
          controller.getDistanceString(user),
        );
      } else {
        final paint = Paint()
          ..color = Colors.white.withValues(alpha: 0.03)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
        canvas.drawLine(center, target, paint);
      }
    }
  }

  void _drawSelectedLine(Canvas canvas, Offset p1, Offset p2, String distance) {
    final paint = Paint()
      ..color = const Color(0xFFE85D04).withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    const double dashWidth = 6;
    const double dashSpace = 4;
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double totalDistance = math.sqrt(dx * dx + dy * dy);
    final double angle = math.atan2(dy, dx);

    double currentDist = 20;
    while (currentDist < totalDistance - 15) {
      canvas.drawLine(
        Offset(
          p1.dx + math.cos(angle) * currentDist,
          p1.dy + math.sin(angle) * currentDist,
        ),
        Offset(
          p1.dx + math.cos(angle) * (currentDist + dashWidth),
          p1.dy + math.sin(angle) * (currentDist + dashWidth),
        ),
        paint,
      );
      currentDist += dashWidth + dashSpace;
    }

    final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    _drawDistanceLabel(canvas, midPoint, distance, angle);
  }

  void _drawDistanceLabel(
    Canvas canvas,
    Offset center,
    String text,
    double angle,
  ) {
    double textRotation = angle;
    if (angle > math.pi / 2 || angle < -math.pi / 2) textRotation += math.pi;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(textRotation);

    // Orange pill-shaped badge
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: textPainter.width + 20,
        height: textPainter.height + 10,
      ),
      const Radius.circular(16),
    );

    // Orange gradient background
    final gradient = LinearGradient(
      colors: [const Color(0xFFE85D04), const Color(0xFFFF8C42)],
    );

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: textPainter.width + 20,
      height: textPainter.height + 10,
    );

    final paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawRRect(rrect, paint);

    // Draw text
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ConnectionLinesPainter oldDelegate) => true;
}
