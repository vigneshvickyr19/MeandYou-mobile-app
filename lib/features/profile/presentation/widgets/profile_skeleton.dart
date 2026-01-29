import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileSkeleton extends StatefulWidget {
  const ProfileSkeleton({super.key});

  @override
  State<ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends State<ProfileSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
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
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Skeleton
            Stack(
              children: [
                _buildSkeletonBox(height: 300, width: double.infinity),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.black, width: 4),
                        color: const Color(0xFF1A1A1A),
                      ),
                      child: _buildSkeletonBox(
                        height: 120,
                        width: 120,
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Info Skeleton
            _buildSkeletonBox(height: 24, width: 200),
            const SizedBox(height: 8),
            _buildSkeletonBox(height: 16, width: 150),
            const SizedBox(height: 24),
            // Stats Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  3,
                  (index) => _buildSkeletonBox(
                    height: 80,
                    width: (MediaQuery.of(context).size.width - 48 - 24) / 3,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Content Sections Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(
                  3,
                  (index) => Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildSkeletonBox(
                        height: 150,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBox({
    required double height,
    required double width,
    BorderRadius? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.1 + (_animation.value * 0.1),
                0.5 + (_animation.value * 0.1),
                0.9 + (_animation.value * 0.1),
              ],
              colors: [
                const Color(0xFF1A1A1A),
                const Color(0xFF2A2A2A),
                const Color(0xFF1A1A1A),
              ],
            ),
          ),
        );
      },
    );
  }
}
