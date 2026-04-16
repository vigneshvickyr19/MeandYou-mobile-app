import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../controllers/edit_profile_controller.dart';
import '../widgets/edit_sections/edit_basic_info_section.dart';
import '../widgets/edit_sections/edit_personal_details_section.dart';
import '../widgets/edit_sections/edit_lifestyle_section.dart';
import '../widgets/edit_sections/edit_interests_section.dart';
import '../widgets/edit_sections/edit_preferences_section.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import 'package:intl/intl.dart';
import '../widgets/profile_score_header.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late EditProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController(context.read<AuthProvider>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const Center(child: AppBackButton()),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<EditProfileController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (controller.draftProfile == null) {
              return const Center(
                child: Text("Unable to load profile", style: TextStyle(color: Colors.white54)),
              );
            }

            return Stack(
              children: [
                // Background Glows
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ),

                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 140),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      ProfileScoreHeader(
                        score: controller.completenessScore,
                        advice: controller.getScoreAdvice(),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            EditBasicInfoSection(controller: controller),
                            const SizedBox(height: 32),
                            EditPersonalDetailsSection(controller: controller),
                            const SizedBox(height: 32),
                            EditLifestyleSection(controller: controller),
                            const SizedBox(height: 32),
                            EditInterestsSection(controller: controller),
                            const SizedBox(height: 32),
                            EditPreferencesSection(controller: controller),
                            const SizedBox(height: 24),
                            _buildLastUpdated(controller.draftProfile?.profileUpdatedAt),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildStickySaveButton(controller),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStickySaveButton(EditProfileController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: AppButton(
          text: controller.isSaving ? "Saving..." : "Save Changes",
          onPressed: controller.hasChanges && !controller.isSaving
              ? () async {
                  final success = await controller.saveProfile();
                  if (success) {
                    if (!mounted) return;
                    AppSnackbar.show(
                      context,
                      message: "Profile updated successfully!",
                      type: SnackbarType.success,
                    );
                    Navigator.pop(context, true);
                  } else {
                    if (!mounted) return;
                    AppSnackbar.show(
                      context,
                      message: "Failed to update profile. Please try again.",
                      type: SnackbarType.error,
                    );
                  }
                }
              : null,
          isLoading: controller.isSaving,
        ),
      ),
    );
  }

  Widget _buildLastUpdated(DateTime? date) {
    // Note: ProfileModel doesn't currently have profileUpdatedAt. 
    // This is a placeholder or you can add it to the model.
    final displayDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : "Recently";
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          "Last updated on $displayDate",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
