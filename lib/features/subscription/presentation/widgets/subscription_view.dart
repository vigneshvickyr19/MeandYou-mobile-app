import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_capsule_tab.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/subscription_benefit_tile.dart';
import '../widgets/subscription_duration_card.dart';
import '../../domain/constants/subscription_constants.dart';
import '../../domain/entities/benefit_entity.dart';
import '../../domain/entities/subscription_plan_entity.dart';

class SubscriptionView extends StatefulWidget {
  final String title;
  final String? subtitle;
  final ScrollPhysics? physics;
  final bool showHeader;
  final Function(String)? onPlanSelected;

  const SubscriptionView({
    super.key,
    this.title = 'Go Premium',
    this.subtitle,
    this.physics,
    this.showHeader = true,
    this.onPlanSelected,
  });

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  String _selectedTierId = SubscriptionConstants.tiers.first.id;
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.activePlans.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final tierPlans = controller.activePlans.where((p) => p.productId == _selectedTierId).toList().cast<SubscriptionPlanEntity>();
        
        if (_selectedPlanId == null && tierPlans.isNotEmpty) {
          _selectedPlanId = tierPlans.first.id;
          // Notify parent on first auto-select
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.onPlanSelected != null && _selectedPlanId != null) {
              widget.onPlanSelected!(_selectedPlanId!);
            }
          });
        }

        final selectedPlan = tierPlans.firstWhere(
          (p) => p.id == _selectedPlanId,
          orElse: () => tierPlans.isNotEmpty ? tierPlans.first : controller.activePlans.first,
        );

        return SingleChildScrollView(
          physics: widget.physics,
          child: Column(
            children: [
              if (widget.showHeader) ...[
                const SizedBox(height: 10),
                Text(
                  'Premium',
                  style: TextStyle(color: AppColors.white.withValues(alpha: 0.6), fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.white.withValues(alpha: 0.5), fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
              
              _buildTierSelector(),
              const SizedBox(height: 32),
              _buildDurationList(tierPlans),
              const SizedBox(height: 32),
              _buildBenefitsList(controller, selectedPlan),
              const SizedBox(height: 20),
              _buildAutoRenewalInfo(),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAutoRenewalInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            'Auto-renewal info  •  ',
            style: TextStyle(color: AppColors.white.withValues(alpha: 0.3), fontSize: 12),
          ),
          GestureDetector(
            onTap: () {}, // Handle learn more
            child: const Text(
              'Learn more',
              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCapsuleTab(
        tabs: SubscriptionConstants.tiers.map((t) => t.name).toList(),
        selectedIndex: SubscriptionConstants.tierIds.indexOf(_selectedTierId),
        onTabSelected: (index) {
          setState(() {
            _selectedTierId = SubscriptionConstants.tierIds[index];
            _selectedPlanId = null;
          });
        },
      ),
    );
  }

  Widget _buildDurationList(List<SubscriptionPlanEntity> plans) {
    if (plans.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text('No plans available for this tier', style: TextStyle(color: Colors.white38)),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: plans.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final plan = plans[index];
          return SubscriptionDurationCard(
            plan: plan,
            isSelected: _selectedPlanId == plan.id,
            onTap: () {
              setState(() => _selectedPlanId = plan.id);
              if (widget.onPlanSelected != null) {
                widget.onPlanSelected!(plan.id);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildBenefitsList(SubscriptionController controller, SubscriptionPlanEntity plan) {
    if (plan.benefitIds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: plan.benefitIds.map((id) {
          final benefit = controller.benefits.cast<BenefitEntity>().firstWhere(
            (b) => b.id == id,
            orElse: () => BenefitEntity(id: id, title: 'Unknown', code: 'UNKNOWN', description: 'Benefit not found'),
          );
          return SubscriptionBenefitTile(benefit: benefit);
        }).toList(),
      ),
    );
  }

}
