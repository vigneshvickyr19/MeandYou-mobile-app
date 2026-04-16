import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/ai_analysis_model.dart';

class InterestsAnalysisCard extends StatelessWidget {
  final SectionAnalysis analysis;
  final List<String> currentInterests;
  final VoidCallback onApply;

  const InterestsAnalysisCard({
    super.key,
    required this.analysis,
    required this.currentInterests,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            
            _buildVersionLabel("YOUR INTERESTS"),
            _buildInterestChips(currentInterests, isOriginal: true),
            
            if (analysis.suggestions != null && analysis.suggestions!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildVersionLabel("AI SUGGESTED INTERESTS"),
              _buildInterestChips(analysis.suggestions!, isOriginal: false),
            ],

            const SizedBox(height: 24),
            _buildAction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.interests_rounded, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Interests",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "AI Flavor Profile Optimization",
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
        _buildSectionScore(),
      ],
    );
  }

  Widget _buildSectionScore() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        "${analysis.score}%",
        style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildVersionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInterestChips(List<String> interests, {required bool isOriginal}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: interests.map((s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isOriginal ? Colors.white.withValues(alpha: 0.05) : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOriginal ? Colors.white.withValues(alpha: 0.05) : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          s,
          style: TextStyle(
            color: isOriginal ? Colors.white54 : Colors.white,
            fontSize: 12,
            fontWeight: isOriginal ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildAction(BuildContext context) {
    return const SizedBox.shrink(); // Interests are now read-only viewable
  }
}
