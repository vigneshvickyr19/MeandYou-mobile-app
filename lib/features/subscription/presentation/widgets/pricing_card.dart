import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import '../controllers/subscription_controller.dart';

class PricingCard extends StatelessWidget {
  final SubscriptionPlanEntity plan;
  final List<String> benefits;
  final bool isPremium;

  const PricingCard({
    super.key,
    required this.plan,
    required this.benefits,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMostPopular = plan.badge?.toLowerCase() == 'most popular';
    final durationLabel = _getDurationLabel();

    return Container(
      width: 300,
      decoration: BoxDecoration(
        gradient: isMostPopular
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
              )
            : null,
        color: isMostPopular ? null : AppColors.card,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isMostPopular ? AppColors.primary : AppColors.white.withOpacity(0.08),
          width: 2,
        ),
        boxShadow: isMostPopular ? [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 24, spreadRadius: 0)] : null,
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          if (plan.badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                plan.badge!.toUpperCase(),
                style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          const SizedBox(height: 16),
          Text(plan.name, style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan.currency == 'USD' ? '\$' : plan.currency == 'INR' ? '₹' : plan.currency, style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w600)),
              Text(plan.price % 1 == 0 ? plan.price.toStringAsFixed(0) : plan.price.toStringAsFixed(2), style: const TextStyle(color: AppColors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text('/$durationLabel', style: TextStyle(color: AppColors.white.withOpacity(0.38), fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: benefits.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benefits[index],
                          style: TextStyle(color: AppColors.white.withOpacity(0.7), fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPremium ? AppColors.success : AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: isPremium ? null : () => _handleSubscribe(context),
                child: Text(
                  isPremium ? 'Currently Active' : 'Subscribe Now',
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDurationLabel() {
    switch (plan.durationType) {
      case DurationType.weekly:
        return 'wk';
      case DurationType.monthly:
        return 'mo';
      case DurationType.quarterly:
        return 'qr';
      default:
        return 'mo';
    }
  }

  void _handleSubscribe(BuildContext context) async {
    final controller = context.read<SubscriptionController>();
    final success = await controller.processPurchase(plan.id);

    if (context.mounted) {
      if (success) {
        AppSnackbar.show(
          context,
          message: 'Purchase initiated! Premium status will refresh shortly.',
          type: SnackbarType.success,
        );
      } else {
        AppSnackbar.show(
          context,
          message: 'Purchase failed. Please try again.',
          type: SnackbarType.error,
        );
      }
    }
  }
}
