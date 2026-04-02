import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/location_formatter.dart';
import '../../../matching/presentation/controllers/nearby_controller.dart';
import '../../../matching/domain/entities/nearby_match_entity.dart';
import '../widgets/discover_action_button.dart';
import '../widgets/heart_flow_overlay.dart';
import '../../../../core/services/like_action_service.dart';
import '../../../../core/widgets/subscription_bottom_sheet.dart';
import '../../../../core/widgets/app_snackbar.dart';

class NearbyTab extends StatefulWidget {
  const NearbyTab({super.key});

  @override
  State<NearbyTab> createState() => _NearbyTabState();
}

class _NearbyTabState extends State<NearbyTab> with TickerProviderStateMixin {
  late NearbyController _controller;
  late PageController _pageController;
  int _currentPage = 0;
  double _currentPageValue = 0.0;
  final StreamController<void> _heartTriggerController = StreamController<void>.broadcast();

  @override
  void initState() {
    super.initState();
    _controller = NearbyController();
    _pageController = PageController(
      viewportFraction: 0.88,
      initialPage: 0,
    );

    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page ?? 0.0;
      });
    });

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
    _heartTriggerController.close();
    super.dispose();
  }

  void _handleLike(NearbyMatchEntity match) async {
    try {
      _heartTriggerController.add(null);
      HapticFeedback.mediumImpact();

      // Call Unified Like Service with Limit Check
      await LikeActionService.instance.handleLike(match.id);

      if (_currentPage < _controller.users.length - 1) {
        _pageController.animateToPage(
          _currentPage + 1,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutQuart,
        );
      }
    } on LikeLimitReachedException catch (_) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      SubscriptionBottomSheet.show(context);
    } catch (e) {
      debugPrint("Error liking user: $e");
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: 'Error liking profile. Please try again.',
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<NearbyController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return _buildLoadingState();
          }

          final users = controller.users;

          if (users.isEmpty) {
            return _buildEmptyState(controller.radius);
          }

          return Stack(
            children: [
              _buildCarousel(users),
              HeartFlowOverlay(triggerStream: _heartTriggerController.stream),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCarousel(List<NearbyMatchEntity> users) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Color(0xFF151515), Color(0xFF1A1A1A)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: PageView.builder(
          controller: _pageController,
          itemCount: users.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
            _controller.fetchLocationForMatch(users[index]);
            if (index + 1 < users.length) {
              _controller.fetchLocationForMatch(users[index + 1]);
            }
          },
          itemBuilder: (context, index) {
            return _buildCarouselCard(users[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildCarouselCard(NearbyMatchEntity match, int index) {
    final difference = (index - _currentPageValue).abs();
    final scale = 1.0 - (difference * 0.15).clamp(0.0, 0.15);
    final opacity = 1.0 - (difference * 0.5).clamp(0.0, 0.5);

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final double delta = index - _currentPageValue;
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(delta * 0.4);
        matrix.scaleByVector3(vm.Vector3(scale, scale, 1.0));

        return Center(
          child: Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: child
            ),
          ),
        );
      },
      child: _buildProfileCard(match, index == _currentPage, index),
    );
  }

  Widget _buildProfileCard(NearbyMatchEntity match, bool isActive, int index) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.68;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Stack(
        children: [
          Container(
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 40,
                  spreadRadius: -10,
                  offset: Offset(
                    (index - _currentPageValue) * 20,
                    25
                  ),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildParallaxImage(match, index),
                  _buildGradientOverlay(),
                  _buildProfileInfo(match),
                ],
              ),
            ),
          ),
          if (isActive) _buildDistanceBadge(match),
          if (isActive) _buildActionButtons(match),
        ],
      ),
    );
  }

  Widget _buildParallaxImage(NearbyMatchEntity match, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final double delta = index - _currentPageValue;
        return Container(
          transform: Matrix4.identity()..translateByVector3(vm.Vector3(delta * 40, 0.0, 0.0)),
          child: match.profileImageUrl != null && match.profileImageUrl!.isNotEmpty
              ? Image.network(
                  match.profileImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  scale: 1.1,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                )
              : _buildPlaceholderImage(),
        );
      },
    );
  }

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
              Colors.black.withValues(alpha: 0.1),
              Colors.black.withValues(alpha: 0.5),
              Colors.black.withValues(alpha: 0.85),
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(NearbyMatchEntity match) {
    return Positioned(
      bottom: 120,
      left: 24,
      right: 24,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: Column(
          key: ValueKey(match.id),
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                '${match.fullName}, ${match.age}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    LocationFormatter.getLocationName(match),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceBadge(NearbyMatchEntity match) {
    return Positioned(
      top: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.near_me_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 14,
                ),
                const SizedBox(width: 6),
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
        ),
      ),
    );
  }

  Widget _buildActionButtons(NearbyMatchEntity match) {
    return Positioned(
      bottom: 32,
      left: 24,
      right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DiscoverActionButton(
            icon: Icons.close_rounded,
            onTap: () {
              _controller.dislikeUser(match);
              if (_currentPage < _controller.users.length - 1) {
                _pageController.animateToPage(
                  _currentPage + 1,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutQuint,
                );
              }
            },
          ),
          DiscoverActionButton(
            icon: Icons.favorite_rounded,
            isLike: true,
            onTap: () => _handleLike(match),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
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

  Widget _buildEmptyState(double radius) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
        ),
      ),
      child: Center(
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
              'Check back later for new people\nwithin ${radius.toInt()}km',
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
    );
  }
}
