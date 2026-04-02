import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../matching/domain/entities/nearby_match_entity.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/location_formatter.dart';

class MatchCompatibilitySheet extends StatefulWidget {
  final NearbyMatchEntity match;
  final UserModel currentUser;

  const MatchCompatibilitySheet({
    super.key,
    required this.match,
    required this.currentUser,
  });

  static void show(BuildContext context, NearbyMatchEntity match, UserModel currentUser) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => MatchCompatibilitySheet(match: match, currentUser: currentUser),
    );
  }

  @override
  State<MatchCompatibilitySheet> createState() => _MatchCompatibilitySheetState();
}

class _MatchCompatibilitySheetState extends State<MatchCompatibilitySheet> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isAgeMatch = widget.match.age >= (widget.currentUser.minAge ?? 18) && 
                          widget.match.age <= (widget.currentUser.maxAge ?? 99);
    
    return Container(
      height: screenHeight * 0.72,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 50,
            spreadRadius: 5,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Column(
            children: [
              _buildHandle(),
              const SizedBox(height: 10),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildPulseMeter(),
                      const SizedBox(height: 40),
                      _buildSummaryCard(),
                      const SizedBox(height: 32),
                      _buildCompatibilityGrid(isAgeMatch),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              _buildFooterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Colors.white60],
          ).createShader(bounds),
          child: const Text(
            'Compatibility Vibe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Deep dive into your resonance with ${widget.match.fullName}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPulseMeter() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 40,
                  spreadRadius: 10,
                )
              ],
            ),
          ),
          
          // Progress Ring
          SizedBox(
            width: 140,
            height: 140,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: widget.match.matchPercentage / 100),
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  color: AppColors.primary,
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          
          // Internal Ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.01),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: widget.match.matchPercentage),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        '${value.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      );
                    },
                  ),
                  Text(
                    'MATCH',
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: widget.match.profileImageUrl != null ? NetworkImage(widget.match.profileImageUrl!) : null,
            backgroundColor: Colors.white10,
            child: widget.match.profileImageUrl == null ? const Icon(Icons.person, color: Colors.white24) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Great Chemistry Potential',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your goals align perfectly with ${widget.match.fullName}\'s profile.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityGrid(bool isAgeMatch) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildGridItem(
          icon: Icons.auto_awesome_rounded,
          title: 'Intent Match',
          value: 'High',
          color: const Color(0xFFFF9E00),
          subtitle: 'Relationships',
        ),
        _buildGridItem(
          icon: Icons.cake_rounded,
          title: 'Age Range',
          value: isAgeMatch ? 'Matched' : 'Slight Out',
          color: isAgeMatch ? const Color(0xFF00F5D4) : Colors.white24,
          subtitle: '${widget.match.age} yrs old',
        ),
        _buildGridItem(
          icon: Icons.location_on_rounded,
          title: 'Proximity',
          value: widget.match.distance < 5 ? 'Elite' : 'Close',
          color: const Color(0xFF00BBF9),
          subtitle: LocationFormatter.getDistanceString(widget.match.distance),
        ),
        _buildGridItem(
          icon: Icons.interests_rounded,
          title: 'Personality',
          value: 'Likely',
          color: const Color(0xFF9B5DE5),
          subtitle: '${widget.match.interests.length} Interests',
        ),
      ],
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF0D0D0D).withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFFFF4E50)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text(
            'Explore Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
