import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/providers/auth_provider.dart';
import '../controllers/ai_profile_controller.dart';
import '../controllers/edit_profile_controller.dart';
import '../widgets/profile_analysis_results.dart';

class ProfileAnalysisPage extends StatefulWidget {
  final ProfileModel profile;

  const ProfileAnalysisPage({super.key, required this.profile});

  @override
  State<ProfileAnalysisPage> createState() => _ProfileAnalysisPageState();
}

class _ProfileAnalysisPageState extends State<ProfileAnalysisPage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AiProfileController()..performAnalysis(widget.profile),
        ),
        ChangeNotifierProvider(
          create: (_) => EditProfileController(context.read<AuthProvider>())..loadProfile(),
        ),
      ],
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const Center(child: AppBackButton()),
            actions: [
              Consumer<AiProfileController>(
                builder: (context, controller, _) {
                  return IconButton(
                    icon: Icon(
                      Icons.refresh_rounded, 
                      color: controller.isLoading ? Colors.white24 : Colors.white70,
                    ),
                    onPressed: controller.isLoading 
                      ? null 
                      : () => controller.performAnalysis(widget.profile, forceRefresh: true),
                  );
                }
              ),
              const SizedBox(width: 8),
            ],
            title: const Text(
              "Profile Discovery Score",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Stack(
            children: [
              Consumer2<AiProfileController, EditProfileController>(
                builder: (context, aiController, editController, _) {
                  if (aiController.isLoading || editController.isLoading) {
                    return _buildLoadingState(aiController);
                  }
                  return _buildResultsState(context, aiController);
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Consumer2<EditProfileController, AiProfileController>(
                  builder: (context, editController, aiController, _) {
                    // Hide save button if we are currently analyzing (Retrying)
                    if (editController.hasChanges && !aiController.isLoading) {
                      return _buildStickySaveButton(context, editController);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickySaveButton(BuildContext context, EditProfileController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // New "Go to Edit" button for better UX
          Expanded(
            flex: 2,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.editProfile),
              child: const Text("Go to Edit", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: controller.isSaving ? null : () async {
                  final success = await controller.saveProfile();
                  if (success) {
                     if (!mounted) return;
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
                         content: Text("Profile updated successfully!"),
                         behavior: SnackBarBehavior.floating,
                       ),
                     );
                     Navigator.of(context).pop();
                  }
                },
                child: controller.isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Save Changes", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AiProfileController controller) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scanning Progress Section
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Shimmer.fromColors(
                        baseColor: AppColors.primary.withOpacity(0.3),
                        highlightColor: AppColors.primary,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 4),
                          ),
                        ),
                      ),
                      const Icon(Icons.auto_awesome, color: AppColors.primary, size: 30),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Calculating Profile Score",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FadeInUp(
                          key: ValueKey(controller.loadingMessage),
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            controller.loadingMessage,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.9),
            highlightColor: AppColors.primary.withOpacity(0.5),
            child: const Text(
              "Analyzing Sections...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          _buildSkeletonCard(delay: 100),
          _buildSkeletonCard(delay: 200),
          _buildSkeletonCard(delay: 300),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard({required int delay}) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.03),
      highlightColor: Colors.white.withOpacity(0.08),
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        delay: Duration(milliseconds: delay),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 120,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 50,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 200,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsState(BuildContext context, AiProfileController controller) {
    final result = controller.analysisResult;
    if (result == null || !result.success) {
      return AppEmptyState(
        icon: Icons.analytics_outlined,
        title: "Score Unavailable",
        description: "We couldn't analyze your profile right now. This can happen if the AI is busy or your internet is unstable.",
        actionText: "Try Again",
        onActionPressed: () => controller.performAnalysis(widget.profile),
        isLoading: controller.isLoading,
      );
    }

    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: ProfileAnalysisResults(
        data: result.data,
        editController: context.read<EditProfileController>(),
      ),
    );
  }
}
