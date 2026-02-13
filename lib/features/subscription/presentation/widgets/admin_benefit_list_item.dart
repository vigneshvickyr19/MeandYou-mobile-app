import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_area.dart';
import '../../domain/entities/benefit_entity.dart';
import '../controllers/subscription_controller.dart';

class AdminBenefitListItem extends StatelessWidget {
  final BenefitEntity benefit;
  const AdminBenefitListItem({super.key, required this.benefit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.star_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(benefit.title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(benefit.description, style: TextStyle(color: AppColors.white.withValues(alpha: 0.38), fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.edit_note_rounded, color: AppColors.white.withValues(alpha: 0.54), size: 24),
                onPressed: () => _showEditSheet(context),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: benefit.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (val) async {
                    await context.read<SubscriptionController>().updateBenefit(BenefitEntity(
                      id: benefit.id,
                      title: benefit.title,
                      code: benefit.code,
                      description: benefit.description,
                      isActive: val,
                    ));
                    if (context.mounted) {
                      AppSnackbar.show(
                        context,
                        message: 'Status updated to ${val ? 'Active' : 'Inactive'}',
                        type: SnackbarType.success,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    final titleController = TextEditingController(text: benefit.title);
    final descController = TextEditingController(text: benefit.description);
    final controller = context.read<SubscriptionController>();

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
            Center(child: SizedBox(width: 40, child: Divider(color: AppColors.white.withValues(alpha: 0.24), thickness: 4))),
            const SizedBox(height: 24),
            const Text('Edit Benefit', style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            AppInput(label: 'Benefit Title', controller: titleController),
            const SizedBox(height: 20),
            AppTextArea(label: 'Description', controller: descController, minLines: 3),
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
                  await controller.updateBenefit(BenefitEntity(
                    id: benefit.id,
                    title: titleController.text.trim(),
                    code: benefit.code, // Code remains same after creation
                    description: descController.text.trim(),
                    isActive: benefit.isActive,
                  ));
                  if (context.mounted) {
                    AppSnackbar.show(
                      context,
                      message: 'Benefit updated successfully!',
                      type: SnackbarType.success,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Update Benefit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
