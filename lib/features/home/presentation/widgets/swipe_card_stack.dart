import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class SwipeController {
  _SwipeCardStackState? _state;
  void swipeLeft() => _state?._swipeLeft();
  void swipeRight() => _state?._swipeRight();
}

class SwipeCardStack<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback? onSwipeStart;
  final Function(int index, bool isRight)? onSwipeEnd;
  final int initialIndex;
  final SwipeController? controller;

  const SwipeCardStack({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onSwipeStart,
    this.onSwipeEnd,
    this.initialIndex = 0,
    this.controller,
  });

  @override
  State<SwipeCardStack<T>> createState() => _SwipeCardStackState<T>();
}

class _SwipeCardStackState<T> extends State<SwipeCardStack<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Physics-based animations
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _rotationAnimation;

  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  bool _isAnimatingOut = false;
  bool _lastSwipeIsRight = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    widget.controller?._state = this;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _resetAnimations();
    // ... rest

    _controller.addListener(() {
      if (_controller.isAnimating) {
        setState(() {
          _dragOffset = _offsetAnimation.value;
        });
      }
    });
  }

  void _resetAnimations() {
    _offsetAnimation = _controller.drive(
      Tween<Offset>(begin: Offset.zero, end: Offset.zero),
    );
    _rotationAnimation = _controller.drive(
      Tween<double>(begin: 0, end: 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeCardStack<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  void _swipeLeft() {
    if (_currentIndex >= widget.items.length || _isAnimatingOut) return;
    _runExitAnimation(const Offset(-1000, 0));
  }

  void _swipeRight() {
    if (_currentIndex >= widget.items.length || _isAnimatingOut) return;
    _runExitAnimation(const Offset(1000, 0));
  }

  void _onCardExited() {
    if (!mounted) return;
    final nextIndex = _currentIndex + 1;
    final swipedRight = _lastSwipeIsRight;
    setState(() {
      _currentIndex = nextIndex;
      _dragOffset = Offset.zero;
      _isAnimatingOut = false;
      _controller.value = 0;
      _resetAnimations();
    });
    widget.onSwipeEnd?.call(nextIndex, swipedRight);
  }

  void _onPanStart(DragStartDetails details) {
    if (_currentIndex >= widget.items.length || _isAnimatingOut) return;
    _controller.stop();
    setState(() {
      _isDragging = true;
    });
    widget.onSwipeStart?.call();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentIndex >= widget.items.length || _isAnimatingOut) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentIndex >= widget.items.length || _isAnimatingOut) return;
    
    setState(() {
      _isDragging = false;
    });

    final screenSize = MediaQuery.of(context).size;
    final velocity = details.velocity.pixelsPerSecond;
    final dx = _dragOffset.dx;
    
    // Premium thresholding: combination of distance and velocity
    final bool swipedFarEnough = dx.abs() > screenSize.width * 0.45;
    final bool flickedFastEnough = velocity.dx.abs() > 800 && dx.abs() > 20;

    if (swipedFarEnough || flickedFastEnough) {
      _runExitAnimation(velocity);
    } else {
      _runSpringAnimation(velocity);
    }
  }

  void _runSpringAnimation(Offset velocity) {
    // Premium spring physics: slightly overdamped for a high-end feel
    final spring = SpringDescription(
      mass: 0.8,
      stiffness: 250.0,
      damping: 25.0,
    );

    _offsetAnimation = _controller.drive(
      Tween<Offset>(begin: _dragOffset, end: Offset.zero),
    );

    _rotationAnimation = _controller.drive(
      Tween<double>(
        begin: _calculateRotation(_dragOffset.dx, _dragOffset.dy),
        end: 0,
      ),
    );

    // Initial velocity conversion from pixels/sec to unit/sec
    final simulation = SpringSimulation(
      spring,
      0, // start
      1, // end
      -velocity.dx.abs() / 500, // approximate normalized velocity
    );

    _controller.animateWith(simulation);
  }

  void _runExitAnimation(Offset velocity) {
    final screenSize = MediaQuery.of(context).size;
    
    // Determine exit direction from velocity if provided (programmatic/flick), 
    // otherwise from drag position (slow swipe)
    final isRight = velocity.dx != 0 ? velocity.dx > 0 : _dragOffset.dx >= 0;
    final targetX = isRight ? screenSize.width * 1.5 : -screenSize.width * 1.5;
    
    // Use velocity to determine targetY for a natural trajectory
    double targetY = _dragOffset.dy;
    if (velocity.dx.abs() > 10) {
      targetY = _dragOffset.dy + (velocity.dy / velocity.dx.abs()) * (targetX - _dragOffset.dx).abs();
    }
    // Limit vertical exit to screen bounds + margin
    targetY = targetY.clamp(-screenSize.height, screenSize.height);

    setState(() {
      _isAnimatingOut = true;
      _lastSwipeIsRight = isRight;
    });

    _offsetAnimation = _controller.drive(
      Tween<Offset>(begin: _dragOffset, end: Offset(targetX, targetY)),
    );

    _rotationAnimation = _controller.drive(
      Tween<double>(
        begin: _calculateRotation(_dragOffset.dx, _dragOffset.dy),
        end: _calculateRotation(targetX, targetY),
      ),
    );

    // Speed up exit based on velocity, but keep it smooth
    final double durationMultiplier = (1.0 - (velocity.dx.abs() / 4000)).clamp(0.2, 1.0);
    
    _controller.animateTo(1.0, 
      duration: Duration(milliseconds: (350 * durationMultiplier).toInt()),
      curve: Curves.easeOutCubic,
    ).then((_) => _onCardExited());
  }

  double _calculateRotation(double dx, double dy) {
    // Rotation based on both horizontal and vertical position for more natural feel
    final screenWidth = MediaQuery.of(context).size.width;
    // Max 15 degree rotation
    return (dx / screenWidth) * (math.pi / 12);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.items.length) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    // Calculate progress (0.0 to 1.0) based on drag distance
    final progress = (_dragOffset.dx.abs() / (size.width * 0.5)).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Background card (The next one)
        if (_currentIndex + 1 < widget.items.length)
          _buildBackgroundCard(progress),

        // Foreground card (The current one)
        _buildForegroundCard(),
      ],
    );
  }

  Widget _buildForegroundCard() {
    return RepaintBoundary(
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Transform.translate(
          offset: _dragOffset,
          child: Transform.rotate(
            angle: _isDragging 
              ? _calculateRotation(_dragOffset.dx, _dragOffset.dy) 
              : _rotationAnimation.value,
            child: widget.itemBuilder(context, widget.items[_currentIndex]),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundCard(double progress) {
    // Premium depth effect:
    // Scale: 0.9 -> 1.0
    // Opacity: 0.5 -> 1.0
    // Vertical translation: 20 -> 0
    final double scale = 0.92 + (0.08 * progress);
    final double opacity = 0.6 + (0.4 * progress);
    final double translateY = 15.0 * (1.0 - progress);

    return Transform.translate(
      offset: Offset(0, translateY),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: IgnorePointer(
            child: widget.itemBuilder(context, widget.items[_currentIndex + 1]),
          ),
        ),
      ),
    );
  }
}


