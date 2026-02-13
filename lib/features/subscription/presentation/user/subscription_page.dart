import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/subscription_view.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<SubscriptionController>().initUser(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              Expanded(
                child: SubscriptionView(
                  showHeader: false, // AppBar handles title
                  onPlanSelected: (id) => setState(() => _selectedPlanId = id),
                ),
              ),
              _buildBottomAction(controller),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Go Premium', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildBottomAction(SubscriptionController controller) {
    final plan = _selectedPlanId != null 
        ? controller.activePlans.firstWhere((p) => p.id == _selectedPlanId)
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              onPressed: plan == null || controller.isLoading ? null : () => _handleSubscribe(plan.id),
              child: controller.isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                : Text(
                    plan != null ? 'Continue with ${plan.name}' : 'Continue',
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Recurring billing, cancel anytime.',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _handleSubscribe(String planId) async {
    final controller = context.read<SubscriptionController>();
    final success = await controller.processPurchase(planId);

    if (mounted) {
      AppSnackbar.show(
        context,
        message: success ? 'Purchase initiated! Premium status will refresh shortly.' : 'Purchase failed. Please try again.',
        type: success ? SnackbarType.success : SnackbarType.error,
      );
    }
  }
}
