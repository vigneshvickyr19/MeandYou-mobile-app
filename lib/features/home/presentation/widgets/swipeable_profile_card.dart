import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/models/user_model.dart';

/// Modern swipeable profile card with action buttons
/// Matches the reference design with floating icons and smooth interactions
class SwipeableProfileCard extends StatefulWidget {
  final UserModel user;
  final double distance;
  final String locationName;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback? onCardTap;

  const SwipeableProfileCard({
    super.key,
    required this.user,
    required this.distance,
    required this.locationName,
    required this.onLike,
    required this.onDislike,
    this.onCardTap,
  });

  @override
  State<SwipeableProfileCard> createState() => _SwipeableProfileCardState();
}

class _SwipeableProfileCardState extends State<SwipeableProfileCard>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    // Swipe threshold
    const double threshold = 100;

    if (_dragOffset.dx > threshold) {
      // Swipe right - Like
      _animateCardAway(true);
    } else if (_dragOffset.dx < -threshold) {
      // Swipe left - Dislike
      _animateCardAway(false);
    } else {
      // Bounce back
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  void _animateCardAway(bool isLike) {
    final targetX = isLike ? 500.0 : -500.0;
    
    // Animate card off screen
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isLike) {
        widget.onLike();
      } else {
        widget.onDislike();
      }
    });

    setState(() {
      _dragOffset = Offset(targetX, _dragOffset.dy);
    });
  }

  int _calculateAge() {
    if (widget.user.age != null) {
      return widget.user.age!;
    }
    return 20 + (widget.user.id.hashCode % 15);
  }

  String _getDistanceText() {
    if (widget.distance < 1) {
      return '${(widget.distance * 1000).toInt()}m';
    }
    return '${widget.distance.toStringAsFixed(1)}km';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final rotation = _dragOffset.dx / 1000;
    final opacity = 1.0 - (_dragOffset.dx.abs() / 300).clamp(0.0, 0.5);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: widget.onCardTap,
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: rotation,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: screenSize.width * 0.88,
              height: screenSize.height * 0.68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Profile image
                    _buildProfileImage(),
                    
                    // Gradient overlay
                    _buildGradientOverlay(),
                    
                    // Distance badge (top-right)
                    _buildDistanceBadge(),
                    
                    // Profile info (bottom)
                    _buildProfileInfo(),
                    
                    // Action buttons (bottom corners)
                    _buildActionButtons(),
                    
                    // Swipe indicators
                    if (_isDragging) _buildSwipeIndicators(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Hero(
      tag: 'swipe_user_${widget.user.id}',
      child: widget.user.profileImageUrl != null &&
              widget.user.profileImageUrl!.isNotEmpty
          ? Image.network(
              widget.user.profileImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder();
              },
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D2D2D),
            Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 120,
          color: Colors.white.withOpacity(0.15),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.85),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildDistanceBadge() {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              _getDistanceText(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    final age = _calculateAge();

    return Positioned(
      bottom: 100,
      left: 24,
      right: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name and age
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  widget.user.fullName ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$age',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  widget.locationName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dislike button
          _buildActionButton(
            icon: Icons.close_rounded,
            onTap: () {
              _animateCardAway(false);
            },
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.4),
              ],
            ),
            size: 56,
          ),
          // Like button
          _buildActionButton(
            icon: Icons.favorite_rounded,
            onTap: () {
              _animateCardAway(true);
            },
            gradient: const LinearGradient(
              colors: [Color(0xFFE85D04), Color(0xFFFF8C42)],
            ),
            size: 56,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Gradient gradient,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: gradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    final isLikeDirection = _dragOffset.dx > 0;
    final indicatorOpacity = (_dragOffset.dx.abs() / 100).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isLikeDirection
                ? Colors.green.withOpacity(indicatorOpacity * 0.8)
                : Colors.red.withOpacity(indicatorOpacity * 0.8),
            width: 4,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Transform.rotate(
            angle: isLikeDirection ? -math.pi / 8 : math.pi / 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isLikeDirection
                    ? Colors.green.withOpacity(indicatorOpacity * 0.3)
                    : Colors.red.withOpacity(indicatorOpacity * 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLikeDirection
                      ? Colors.green.withOpacity(indicatorOpacity)
                      : Colors.red.withOpacity(indicatorOpacity),
                  width: 3,
                ),
              ),
              child: Text(
                isLikeDirection ? 'LIKE' : 'NOPE',
                style: TextStyle(
                  color: isLikeDirection ? Colors.green : Colors.red,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
