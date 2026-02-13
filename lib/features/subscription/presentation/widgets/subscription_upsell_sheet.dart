import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../controllers/subscription_controller.dart';
import 'subscription_view.dart';

class SubscriptionUpsellSheet extends StatefulWidget {
  final String title;
  final String? subtitle;

  const SubscriptionUpsellSheet({
    super.key,
    required this.title,
    this.subtitle,
  });

  static Future<void> show(BuildContext context, {String title = 'Out of likes?', String? subtitle}) {
    // Ensure data is initialized
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      context.read<SubscriptionController>().initUser(userId);
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubscriptionUpsellSheet(title: title, subtitle: subtitle),
    );
  }

  @override
  State<SubscriptionUpsellSheet> createState() => _SubscriptionUpsellSheetState();
}

class _SubscriptionUpsellSheetState extends State<SubscriptionUpsellSheet> {
  String? _selectedPlanId;
  double _selectedPrice = 0;
  String _currencySymbol = '₹';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          Expanded(
            child: SubscriptionView(
              title: widget.title,
              subtitle: widget.subtitle,
              physics: const BouncingScrollPhysics(),
              onPlanSelected: (id) {
                final controller = context.read<SubscriptionController>();
                final plan = controller.activePlans.firstWhere((p) => p.id == id);
                setState(() {
                  _selectedPlanId = id;
                  _selectedPrice = plan.price;
                  _currencySymbol = plan.currency == 'INR' ? '₹' : '\$';
                });
              },
            ),
          ),
          _buildActionSection(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: AppColors.white.withValues(alpha: 0.3), size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Consumer<SubscriptionController>(
      builder: (context, controller, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: AppColors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 40,
                offset: const Offset(0, -20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  onPressed: controller.isLoading ? null : () => _handleSubscribe(context, controller),
                  child: controller.isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                    : Text(
                        _selectedPlanId != null 
                          ? 'Continue for $_currencySymbol${_selectedPrice.toStringAsFixed(0)}'
                          : 'Continue',
                        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Recurring billing, cancel anytime.',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.2), fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSubscribe(BuildContext context, SubscriptionController controller) async {
    if (_selectedPlanId == null) return;
    
    final success = await controller.processPurchase(_selectedPlanId!);
    
    if (context.mounted) {
      if (success) {
        AppSnackbar.show(
          context,
          message: 'Premium activated! Refreshing your account...',
          type: SnackbarType.success,
        );
        Navigator.pop(context);
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

// I need to fix the state exposure.
