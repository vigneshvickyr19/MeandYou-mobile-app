import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:io';
import '../../../../../core/constants/app_colors.dart';
import '../../controllers/edit_profile_controller.dart';
import '../../../data/models/ai_analysis_model.dart';

class PhotoAnalysisCard extends StatelessWidget {
  final SectionAnalysis analysis;
  final List<String> photos;
  final EditProfileController controller;
  final VoidCallback onImprove;

  const PhotoAnalysisCard({
    super.key,
    required this.analysis,
    required this.photos,
    required this.controller,
    required this.onImprove,
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
            
            if (photos.isEmpty) 
               _buildEmptyState()
            else
              ...List.generate(photos.length, (index) {
                final photoAnalysis = controller.getPhotoAnalysis(index);
                return _buildPhotoItem(photos[index], photoAnalysis, index);
              }),

            const SizedBox(height: 12),
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
          child: const Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Photo Dynamics",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "AI Visual Quality Scoring",
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

  Widget _buildPhotoItem(String path, PhotoAnalysisDetail detail, int index) {
    final bool isNetwork = path.startsWith('http');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImagePreview(path, isNetwork),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      index == 0 ? "PRIMARY PHOTO" : "GALLERY PHOTO $index",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      detail.label.toUpperCase(),
                      style: TextStyle(color: detail.color, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  detail.feedback,
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _buildQualityBar(detail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String path, bool isNetwork) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        image: DecorationImage(
          image: isNetwork ? NetworkImage(path) : FileImage(File(path)) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildQualityBar(PhotoAnalysisDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Quality Score", style: TextStyle(color: Colors.white24, fontSize: 9)),
            Text("${detail.score}%", style: TextStyle(color: detail.color, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: detail.score / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation<Color>(detail.color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
     return const Center(
        child: Text("No photos analyzed yet", style: TextStyle(color: Colors.white24, fontSize: 12)),
     );
  }

  Widget _buildAction(BuildContext context) {
    return const SizedBox.shrink(); 
  }
}
