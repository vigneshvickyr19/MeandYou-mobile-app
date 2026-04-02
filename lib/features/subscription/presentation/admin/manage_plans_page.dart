import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/admin_plan_list_item.dart';
import 'create_plan_page.dart';

class ManagePlansPage extends StatelessWidget {
  const ManagePlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.allPlans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePlanPage()),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: controller.allPlans.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.allPlans.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final plan = controller.allPlans[index];
                    return AdminPlanListItem(plan: plan);
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
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text('No plans created yet', style: TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }
}
