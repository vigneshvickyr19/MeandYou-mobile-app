import 'dart:ui';
import 'package:flutter/material.dart';

/// A high-performance, reusable widget that handles premium gated content visualization.
/// Features: Custom Shimmer Loading, Error Handling, and Backdrop Blurring.
class PremiumGatedImage extends StatelessWidget {
  final String? imageUrl;
  final bool isGated;
  final double blurSigma;
  final double borderRadius;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? overlay;
  final bool showLockIcon;

  const PremiumGatedImage({
    super.key,
    required this.imageUrl,
    required this.isGated,
    this.blurSigma = 20.0,
    this.borderRadius = 24.0,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.overlay,
    this.showLockIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final overlayWidget = overlay;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: const Color(0xFF1A1A1A),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Image Layer with Skeleton & Error Handling
            _buildImageWithStates(),

            // 2. Premium Blur Layer (Only if gated)
            if (isGated) 
              _buildBlurLayer(),

            // 3. Optional Overlay
            ... (overlayWidget != null ? [overlayWidget] : []),

            // 4. Lock Indicator Layer
            if (isGated && showLockIcon) _buildLockIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithStates() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(Icons.person_off_rounded);
    }

    return Image.network(
      imageUrl!,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            child: child,
          );
        }
        return _buildSkeleton();
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(Icons.error_outline_rounded),
    );
  }

  Widget _buildSkeleton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.6),
      duration: const Duration(milliseconds: 1500),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            color: Colors.white.withValues(alpha: 0.1),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                color: Colors.white.withValues(alpha: 0.1),
                size: 40,
              ),
            ),
          ),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildPlaceholder(IconData icon) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Center(
        child: Icon(icon, color: Colors.white10, size: 32),
      ),
    );
  }

  Widget _buildBlurLayer() {
    return RepaintBoundary(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildLockIndicator() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'PREMIUM',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
