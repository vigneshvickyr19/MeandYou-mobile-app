import 'package:flutter/material.dart';
import 'dart:math' as math;

class PremiumAnimatedAvatar extends StatefulWidget {
  final String? imageUrl;
  final double size;

  const PremiumAnimatedAvatar({super.key, this.imageUrl, this.size = 100});

  @override
  State<PremiumAnimatedAvatar> createState() => _PremiumAnimatedAvatarState();
}

class _PremiumAnimatedAvatarState extends State<PremiumAnimatedAvatar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseController,
        _rotationController,
        _glowController,
      ]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size * 2.5,
          height: widget.size * 2.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 2. Pulsing Outer Rings
              ...List.generate(1, (index) => _buildPulseRing(index)),

              // 4. Main Glow
              _buildMainGlow(),

              // 5. The Avatar itself
              _buildAvatar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundGlow() {
    return Container(
      width: widget.size * 2.2,
      height: widget.size * 2.2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFE85D04).withOpacity(0.15 * _glowController.value),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildPulseRing(int index) {
    final delay = index * 0.5;
    final progress = (_pulseController.value + delay) % 1.0;
    final size = widget.size * (1.1 + progress * 0.8);
    final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE85D04).withOpacity(opacity),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildRotatingRing() {
    return Transform.rotate(
      angle: _rotationController.value * 2 * math.pi,
      child: Container(
        width: widget.size * 1.2,
        height: widget.size * 1.2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.transparent, width: 3),
        ),
        child: CustomPaint(
          painter: GradientRingPainter(
            gradientColors: [
              const Color(0xFFE85D04),
              const Color(0xFFFF8C42),
              const Color(0xFFE85D04).withOpacity(0.2),
            ],
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildMainGlow() {
    final glowSize = widget.size * (1.1 + _glowController.value * 0.05);
    return Container(
      width: glowSize,
      height: glowSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE85D04).withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.imageUrl != null
                ? Image.network(
                    widget.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFE85D04).withOpacity(0.3),
                    Colors.transparent,
                    const Color(0xFF000000).withOpacity(0.4),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.overlay,
              child: Container(color: Colors.transparent),
            ),
            _buildTopLight(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopLight() {
    return Positioned(
      top: -10,
      left: 0,
      right: 0,
      child: Container(
        height: widget.size * 0.4,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              const Color(0xFFFF8C42).withOpacity(0.4),
              Colors.transparent,
            ],
            radius: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Icon(
        Icons.person,
        color: Colors.white.withOpacity(0.2),
        size: widget.size * 0.5,
      ),
    );
  }
}

class GradientRingPainter extends CustomPainter {
  final List<Color> gradientColors;
  final double strokeWidth;

  GradientRingPainter({
    required this.gradientColors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: 0,
        endAngle: 2 * math.pi,
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
