import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/ai_analysis_model.dart';

class GeneralAnalysisCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final SectionAnalysis analysis;
  final VoidCallback? onImprove;

  const GeneralAnalysisCard({
    super.key,
    required this.title,
    required this.icon,
    required this.analysis,
    this.onImprove,
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            
            ...analysis.feedback.map((f) => _buildFeedbackRow(f)),
            
            if (analysis.suggestions != null && analysis.suggestions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSuggestions(analysis.suggestions!),
            ],

            if (onImprove != null) ...[
              const SizedBox(height: 24),
              _buildAction(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _buildScoreBadge(),
      ],
    );
  }

  Widget _buildScoreBadge() {
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

  Widget _buildFeedbackRow(String feedback) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle_rounded, color: Colors.white24, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feedback,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(List<String> suggestions) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          s,
          style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      )).toList(),
    );
  }

  Widget _buildAction() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onImprove,
        child: Text(
          "COMPLETE ${title.toUpperCase()}",
          style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
