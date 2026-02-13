import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import '../controllers/subscription_controller.dart';
import '../admin/create_plan_page.dart';

class AdminPlanListItem extends StatelessWidget {
  final SubscriptionPlanEntity plan;
  const AdminPlanListItem({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(plan.name, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          plan.productId.toUpperCase(),
                          style: TextStyle(color: AppColors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${plan.currency == 'INR' ? '₹' : plan.currency == 'USD' ? '\$' : plan.currency} ${plan.price.toStringAsFixed(plan.price % 1 == 0 ? 0 : 2)}',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        ' / ${plan.durationType.toString().split('.').last}',
                        style: TextStyle(color: AppColors.white.withValues(alpha: 0.38), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              if (plan.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(plan.badge!.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStat(Icons.star_outline_rounded, '${plan.benefitIds.length} Benefits'),
              const SizedBox(width: 16),
              _buildStat(Icons.calendar_today_rounded, '${plan.durationInDays} Days'),
              const Spacer(),
              _buildStatusBadge(),
            ],
          ),
          const Divider(color: Colors.white10, height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreatePlanPage(plan: plan)),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                  label: const Text('Edit Plan Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.white.withValues(alpha: 0.7),
                    backgroundColor: AppColors.white.withValues(alpha: 0.03),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.white.withValues(alpha: 0.38)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: AppColors.white.withValues(alpha: 0.6), fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: plan.isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: plan.isActive ? AppColors.success : AppColors.error),
          const SizedBox(width: 6),
          Text(
            plan.isActive ? 'Active' : 'Inactive',
            style: TextStyle(color: plan.isActive ? AppColors.success : AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
