import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class MatchingSkeleton extends StatelessWidget {
  const MatchingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left Peek Card
            Positioned(
              left: -size.width * 0.72,
              child: _buildSkeletonCard(context, scale: 0.85, opacity: 0.2),
            ),
            
            // Right Peek Card
            Positioned(
              right: -size.width * 0.72,
              child: _buildSkeletonCard(context, scale: 0.85, opacity: 0.2),
            ),
            
            // Center Card
            _buildSkeletonCard(context, scale: 1.0, opacity: 1.0),
            
            // Hint text at bottom
            Positioned(
              bottom: size.height * 0.05,
              child: FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: Text(
                  'FINDING PEOPLE NEARBY...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard(BuildContext context, {required double scale, required double opacity}) {
    final size = MediaQuery.of(context).size;
    final cardHeight = size.height * 0.68;
    final cardWidth = size.width * 0.88;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: -10,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Top badges skeletons (only on main card)
                if (opacity == 1.0) ...[
                  Positioned(
                    top: 24,
                    right: 24,
                    child: _buildCapsule(width: 70),
                  ),
                  Positioned(
                    top: 24,
                    left: 24,
                    child: _buildCapsule(width: 90),
                  ),
                ],

                // Info skeleton
                Positioned(
                  bottom: 120,
                  left: 24,
                  right: 24,
                  child: Column(
                    children: [
                      Pulse(
                        infinite: true,
                        duration: const Duration(milliseconds: 1500),
                        child: Container(
                          height: 28,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Pulse(
                        infinite: true,
                        duration: const Duration(milliseconds: 1500),
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons skeleton (only on main card)
                if (opacity == 1.0)
                  Positioned(
                    bottom: 32,
                    left: 24,
                    right: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleSkeleton(),
                        _buildCircleSkeleton(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCapsule({required double width}) {
    return Container(
      width: width,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildCircleSkeleton() {
    return Pulse(
      infinite: true,
      duration: const Duration(milliseconds: 2000),
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
    );
  }
}
