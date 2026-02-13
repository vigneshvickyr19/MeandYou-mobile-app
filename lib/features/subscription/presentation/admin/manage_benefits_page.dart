import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_text_area.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/admin_benefit_list_item.dart';

class ManageBenefitsPage extends StatelessWidget {
  const ManageBenefitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.benefits.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () => _showAddBenefitSheet(context, controller),
            child: const Icon(Icons.add, color: AppColors.white),
          ),
          body: controller.benefits.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: controller.benefits.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final benefit = controller.benefits[index];
                    return AdminBenefitListItem(benefit: benefit);
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.03), shape: BoxShape.circle),
            child: Icon(Icons.star_border_rounded, size: 48, color: AppColors.white.withValues(alpha: 0.1)),
          ),
          const SizedBox(height: 16),
          Text('No benefits created yet', style: TextStyle(color: AppColors.white.withValues(alpha: 0.24), fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showAddBenefitSheet(BuildContext context, SubscriptionController controller) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(width: 40, child: Divider(color: AppColors.white.withValues(alpha: 0.24), thickness: 4)),
            ),
            const SizedBox(height: 24),
            const Text('Add New Benefit', style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Create a reusable benefit for your subscription plans.', style: TextStyle(color: AppColors.white.withValues(alpha: 0.38), fontSize: 14)),
            const SizedBox(height: 32),
            AppInput(
              label: 'Benefit Title',
              hintText: 'e.g. Unlimited Superlikes',
              controller: titleController,
            ),
            const SizedBox(height: 20),
            AppTextArea(
              label: 'Description',
              hintText: 'Describe what the user gets...',
              controller: descController,
              minLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    await controller.createBenefit(titleController.text, descController.text);
                    if (context.mounted) {
                      AppSnackbar.show(
                        context,
                        message: 'Benefit created successfully!',
                        type: SnackbarType.success,
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Add Benefit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
