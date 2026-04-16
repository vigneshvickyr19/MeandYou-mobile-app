import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/ai_analysis_model.dart';

class BioAnalysisCard extends StatelessWidget {
  final SectionAnalysis analysis;
  final String currentBio;
  final VoidCallback onApply;

  const BioAnalysisCard({
    super.key,
    required this.analysis,
    required this.currentBio,
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
            
            _buildVersionLabel("CURRENT VERSION"),
            _buildBioText(currentBio, isOriginal: true),
            
            if (analysis.improvedExample != null) ...[
              const SizedBox(height: 20),
              _buildVersionLabel("AI OPTIMIZED VERSION"),
              _buildBioText(analysis.improvedExample!, isOriginal: false),
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
          child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bio Optimization",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Smart Voice & Tone Analysis",
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
      padding: const EdgeInsets.only(bottom: 8),
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

  Widget _buildBioText(String text, {required bool isOriginal}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isOriginal ? Colors.white.withValues(alpha: 0.02) : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: isOriginal ? null : Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isOriginal ? Colors.white60 : Colors.white,
          fontSize: 14,
          height: 1.5,
          fontStyle: isOriginal ? FontStyle.italic : FontStyle.normal,
          fontWeight: isOriginal ? FontWeight.w400 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onApply,
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: const Text("USE THIS VERSION", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
