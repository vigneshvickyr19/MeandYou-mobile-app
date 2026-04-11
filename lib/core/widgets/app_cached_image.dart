import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppCachedImage extends StatelessWidget {
  final String? imageUrl;
  final int? imageVersion;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isRound;
  final double borderRadius;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.imageVersion,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.isRound = false,
    this.borderRadius = 0,
  });

  String get _versionedUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return '';
    // If it's a local file path (not a URL)
    if (!imageUrl!.startsWith('http')) return imageUrl!;
    
    if (imageVersion == null) return imageUrl!;
    
    // Check if URL already has parameters
    final separator = imageUrl!.contains('?') ? '&' : '?';
    return '$imageUrl${separator}v=$imageVersion';
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorPlaceholder();
    }

    Widget image = CachedNetworkImage(
      imageUrl: _versionedUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorPlaceholder(),
      // Ensure we use the proper cache key including version
      cacheKey: _versionedUrl,
    );

    if (isRound) {
      return ClipOval(child: image);
    } else if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }

    return image;
  }

  Widget _buildLoadingPlaceholder() {
    return _AppSkeletonLoader(
      width: width,
      height: height,
      isRound: isRound,
      borderRadius: borderRadius,
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.white.withValues(alpha: 0.05),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: (width ?? 40) * 0.6,
          color: AppColors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class _AppSkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final bool isRound;
  final double borderRadius;

  const _AppSkeletonLoader({
    this.width,
    this.height,
    this.isRound = false,
    this.borderRadius = 0,
  });

  @override
  State<_AppSkeletonLoader> createState() => _AppSkeletonLoaderState();
}

class _AppSkeletonLoaderState extends State<_AppSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.isRound ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isRound ? null : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: [
                AppColors.white.withValues(alpha: 0.05),
                AppColors.white.withValues(alpha: 0.12),
                AppColors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.person_rounded,
              size: (widget.width ?? 40) * 0.6,
              color: AppColors.white.withValues(alpha: 0.05),
            ),
          ),
        );
      },
    );
  }
}
