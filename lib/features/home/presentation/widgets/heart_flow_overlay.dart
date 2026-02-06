import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class HeartFlowOverlay extends StatefulWidget {
  final Stream<void> triggerStream;
  const HeartFlowOverlay({super.key, required this.triggerStream});

  @override
  State<HeartFlowOverlay> createState() => _HeartFlowOverlayState();
}

class _HeartFlowOverlayState extends State<HeartFlowOverlay> {
  final List<_HeartParticle> _hearts = [];
  late final StreamSubscription _subscription;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _subscription = widget.triggerStream.listen((_) {
      _spawnHearts();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _spawnHearts() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < 15; i++) {
        _hearts.add(_HeartParticle(
          id: DateTime.now().microsecondsSinceEpoch + i,
          angle: _random.nextDouble() * 2 * math.pi,
          speed: 2.0 + _random.nextDouble() * 4.0,
          size: 15.0 + _random.nextDouble() * 25.0,
          opacity: 0.8 + _random.nextDouble() * 0.2,
          color: Colors.redAccent.withValues(alpha: 0.8 + _random.nextDouble() * 0.2),
          startTime: DateTime.now(),
        ));
      }
    });

    // Clean up hearts after animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _hearts.removeWhere((h) => 
            DateTime.now().difference(h.startTime).inMilliseconds > 1500);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        final centerY = constraints.maxHeight / 2;

        return IgnorePointer(
          child: Stack(
            children: _hearts.map((heart) {
              return _AnimatedHeart(
                heart: heart,
                centerX: centerX,
                centerY: centerY,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _HeartParticle {
  final int id;
  final double angle;
  final double speed;
  final double size;
  final double opacity;
  final Color color;
  final DateTime startTime;

  _HeartParticle({
    required this.id,
    required this.angle,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.color,
    required this.startTime,
  });
}

class _AnimatedHeart extends StatefulWidget {
  final _HeartParticle heart;
  final double centerX;
  final double centerY;

  const _AnimatedHeart({
    required this.heart,
    required this.centerX,
    required this.centerY,
  });

  @override
  State<_AnimatedHeart> createState() => _AnimatedHeartState();
}

class _AnimatedHeartState extends State<_AnimatedHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _positionAnim = Tween<double>(begin: 0, end: 300).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuint),
    );

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: widget.heart.opacity), weight: 20),
      TweenSequenceItem(tween: Tween(begin: widget.heart.opacity, end: 0.0), weight: 80),
    ]).animate(_controller);

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.8), weight: 70),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double dist = _positionAnim.value;
        final double x = math.cos(widget.heart.angle) * dist;
        final double y = math.sin(widget.heart.angle) * dist;

        return Positioned(
          left: widget.centerX + x - (widget.heart.size / 2),
          top: widget.centerY + y - (widget.heart.size / 2),
          child: Opacity(
            opacity: _opacityAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: Icon(
                Icons.favorite,
                color: widget.heart.color,
                size: widget.heart.size,
              ),
            ),
          ),
        );
      },
    );
  }
}
