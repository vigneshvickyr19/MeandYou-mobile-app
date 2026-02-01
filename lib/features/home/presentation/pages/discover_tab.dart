import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/location_formatter.dart';
import '../controllers/discover_controller.dart';
import '../../../matching/domain/entities/nearby_match_entity.dart';

/// Discover Tab - iOS-style carousel with smooth animations
/// 
/// Features:
/// - PageView carousel with center card dominant
/// - Left and right cards partially visible (peek effect)
/// - Smooth slide animations with iOS easing
/// - Scale + opacity transitions for side cards
/// - Like action only on heart icon tap (API call)
/// - No swipe-to-like functionality
/// - Modern iOS aesthetic with premium feel
class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> with SingleTickerProviderStateMixin {
  late DiscoverController _controller;
  late PageController _pageController;
  int _currentPage = 0;
  double _currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = DiscoverController();
    _pageController = PageController(
      viewportFraction: 0.78, // Show peek of adjacent cards
      initialPage: 0,
    );
    
    // Listen to page changes for smooth animations
    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page ?? 0.0;
      });
    });
    
    // Load users after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        _controller.loadUsers(authProvider.currentUser!);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }



  /// Handle like action - API call only when heart icon is tapped
  void _handleLike(NearbyMatchEntity match) async {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';
    
    // Call API to like user
    await _controller.likeUser(currentUserId, match);
    
    // Animate to next card
    if (_currentPage < _controller.matches.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<DiscoverController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return _buildLoadingState();
          }

          final matches = controller.matches;

          if (matches.isEmpty) {
            return _buildEmptyState();
          }

          return _buildCarousel(matches);
        },
      ),
    );
  }

  /// Build iOS-style carousel
  Widget _buildCarousel(List<NearbyMatchEntity> matches) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF151515),
            Color(0xFF1A1A1A),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: PageView.builder(
          controller: _pageController,
          itemCount: matches.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
            // Fetch location for current and next match
            _controller.fetchLocationForMatch(matches[index]);
            if (index + 1 < matches.length) {
              _controller.fetchLocationForMatch(matches[index + 1]);
            }
          },
          itemBuilder: (context, index) {
            return _buildCarouselCard(matches[index], index);
          },
        ),
      ),
    );
  }

  /// Build individual carousel card with animations
  Widget _buildCarouselCard(NearbyMatchEntity match, int index) {
    // Calculate scale and opacity based on position
    final difference = (index - _currentPageValue).abs();
    final scale = 1.0 - (difference * 0.15).clamp(0.0, 0.15);
    final opacity = 1.0 - (difference * 0.5).clamp(0.0, 0.5);

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          ),
        );
      },
      child: _buildProfileCard(match, index == _currentPage),
    );
  }

  /// Build profile card matching the reference image
  Widget _buildProfileCard(NearbyMatchEntity match, bool isActive) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.68;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Stack(
        children: [
          // Main card container
          Container(
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Profile image
                  _buildProfileImage(match),
                  
                  // Gradient overlay for text readability
                  _buildGradientOverlay(),
                  
                  // Profile info at bottom
                  _buildProfileInfo(match),
                ],
              ),
            ),
          ),
          
          // Distance badge (top-right)
          if (isActive) _buildDistanceBadge(match),
          
          // Action buttons (bottom) - only show for active card
          if (isActive) _buildActionButtons(match),
        ],
      ),
    );
  }

  /// Build profile image
  Widget _buildProfileImage(NearbyMatchEntity match) {
    return match.profileImageUrl != null && match.profileImageUrl!.isNotEmpty
        ? Image.network(
            match.profileImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderImage();
            },
          )
        : _buildPlaceholderImage();
  }

  /// Build placeholder image
  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Center(
        child: Icon(
          Icons.person,
          size: 120,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// Build gradient overlay at bottom
  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.7),
              Colors.black.withValues(alpha: 0.9),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  /// Build profile info (name, age, location)
  Widget _buildProfileInfo(NearbyMatchEntity match) {
    return Positioned(
      bottom: 100,
      left: 24,
      right: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and age
          Text(
            '${match.fullName}, ${match.age}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          
          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  LocationFormatter.getLocationName(match),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
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

  /// Build distance badge (top-right)
  Widget _buildDistanceBadge(NearbyMatchEntity match) {
    return Positioned(
      top: 30,
      right: 30,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.near_me,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              LocationFormatter.getDistanceString(match.distance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build action buttons (like/dislike) - API call only on tap
  Widget _buildActionButtons(NearbyMatchEntity match) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dislike button
          _buildActionButton(
            icon: Icons.close,
            color: const Color(0xFF4A4A4A),
            size: 60,
            iconSize: 32,
            onTap: () {
              // Just remove from list, no API call
              _controller.dislikeUser(match);
              
              // Animate to next card
              if (_currentPage < _controller.matches.length - 1) {
                _pageController.animateToPage(
                  _currentPage + 1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
          
          const SizedBox(width: 24),
          
          // Like button - API call happens here
          _buildActionButton(
            icon: Icons.favorite,
            color: AppColors.primary,
            size: 70,
            iconSize: 36,
            onTap: () => _handleLike(match),
          ),
        ],
      ),
    );
  }

  /// Build individual action button
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Finding people nearby...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.people_outline_rounded,
                  size: 72,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'No one nearby',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Check back later for new people\nwithin 10km',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  final authProvider = context.read<AuthProvider>();
                  if (authProvider.currentUser != null) {
                    _controller.loadUsers(authProvider.currentUser!);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE85D04), Color(0xFFFF8C42)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Text(
                    'REFRESH',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
