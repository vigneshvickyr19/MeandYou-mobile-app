import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/ai_analysis_model.dart';
import '../controllers/edit_profile_controller.dart';
import 'analysis/overall_score_header.dart';
import 'analysis/photo_analysis_card.dart';
import 'analysis/bio_analysis_card.dart';
import 'analysis/interests_analysis_card.dart';
import 'analysis/general_analysis_card.dart';

class ProfileAnalysisResults extends StatelessWidget {
  final AiAnalysisData data;
  final EditProfileController editController;

  const ProfileAnalysisResults({
    super.key,
    required this.data,
    required this.editController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverallScoreHeader(
            score: data.profileScore,
            feedback: _getScoreFeedback(data.profileScore),
          ),
          const SizedBox(height: 36),
          
          _buildSectionHeader("AI Analysis Insights"),
          const SizedBox(height: 20),
          
          PhotoAnalysisCard(
            analysis: data.photos,
            photos: editController.draftProfile?.photos ?? [],
            controller: editController,
            onImprove: () {},
          ),
          const SizedBox(height: 28),
          
          BioAnalysisCard(
            analysis: data.bio,
            currentBio: editController.draftProfile?.bio ?? "",
            onApply: () => _handleBioImprovement(context),
          ),
          const SizedBox(height: 28),
          
          InterestsAnalysisCard(
            analysis: data.interests,
            currentInterests: editController.draftProfile?.interests ?? [],
            onApply: () {}, // Interests are read-only
          ),
          const SizedBox(height: 28),

          GeneralAnalysisCard(
            title: "Personal Details",
            icon: Icons.person_outline_rounded,
            analysis: data.personalDetails,
          ),
          const SizedBox(height: 28),

          GeneralAnalysisCard(
            title: "Lifestyle",
            icon: Icons.auto_awesome_outlined,
            analysis: data.lifestyle,
          ),
          
          const SizedBox(height: 40),
          _buildExpertTips(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  void _handleBioImprovement(BuildContext context) {
    if (data.bio.improvedExample != null) {
      editController.updateDraft((p) => p.copyWith(bio: data.bio.improvedExample));
    }
  }



  String _getScoreFeedback(int score) {
    if (score >= 90) return "Exceptional! Your profile is highly optimized for maximum match potential.";
    if (score >= 75) return "Great job! A few small tweaks could make your profile stand out even more.";
    if (score >= 50) return "Good progress. Follow the AI suggestions to improve your visibility.";
    return "Needs attention. Completing these sections will significantly boost your profile rank.";
  }

  Widget _buildExpertTips() {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_rounded, color: Colors.yellow, size: 24),
                SizedBox(width: 12),
                Text(
                  "Dating Success Tips",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...data.overallTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(color: Colors.yellow, fontSize: 20)),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

