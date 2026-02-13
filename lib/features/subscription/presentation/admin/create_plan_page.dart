import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_select.dart';
import '../../domain/constants/subscription_constants.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import '../controllers/subscription_controller.dart';

class CreatePlanPage extends StatefulWidget {
  final SubscriptionPlanEntity? plan; // If passing, it's edit mode
  const CreatePlanPage({super.key, this.plan});

  @override
  State<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends State<CreatePlanPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _badgeController;
  DurationType _durationType = DurationType.monthly;
  int _durationInDays = 30;
  String _productId = SubscriptionConstants.tiers.first.id;
  List<String> _selectedBenefitIds = [];
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plan?.name);
    _priceController = TextEditingController(text: widget.plan?.price.toString());
    _badgeController = TextEditingController(text: widget.plan?.badge);
    if (widget.plan != null) {
      _productId = widget.plan!.productId;
      _durationType = widget.plan!.durationType;
      _durationInDays = widget.plan!.durationInDays;
      _selectedBenefitIds = List.from(widget.plan!.benefitIds);
      _isActive = widget.plan!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.plan == null ? 'Create Plan' : 'Edit Plan',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SubscriptionController>(
        builder: (context, controller, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              children: [
                const Text('Plan Details', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AppSelect<String>(
                        label: 'Tier',
                        selectedValue: _productId,
                        items: SubscriptionConstants.tiers.map((tier) {
                          return DropdownMenuItem(
                            value: tier.id,
                            child: Text(tier.name.toUpperCase(), style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _productId = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: AppInput(
                        label: 'Duration Label',
                        hintText: 'e.g. 1 Month',
                        controller: _nameController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppInput(
                        label: 'Price',
                        hintText: '2999',
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: AppSelect<DurationType>(
                        label: 'Duration Type',
                        selectedValue: _durationType,
                        items: DurationType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.toString().split('.').last.toUpperCase(), style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _durationType = val;
                              if (val == DurationType.weekly) _durationInDays = 7;
                              if (val == DurationType.monthly) _durationInDays = 30;
                              if (val == DurationType.quarterly) _durationInDays = 90;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AppInput(
                  label: 'Badge (Optional)',
                  hintText: 'e.g. Save 70%',
                  controller: _badgeController,
                ),
                const SizedBox(height: 32),
                const Text('Benefits', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildBenefitsSelector(controller),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Visible to Users', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text('Inactive plans are hidden from store', style: TextStyle(color: AppColors.white.withValues(alpha: 0.38), fontSize: 12)),
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => _savePlan(controller),
                    child: Text(widget.plan == null ? 'Create Plan' : 'Save Changes',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBenefitsSelector(SubscriptionController controller) {
    if (controller.benefits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: const Text('No benefits available. Create benefits first.', style: TextStyle(color: AppColors.error, fontSize: 13)),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: controller.benefits.map((benefit) {
        final isSelected = _selectedBenefitIds.contains(benefit.id);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedBenefitIds.remove(benefit.id);
              } else {
                _selectedBenefitIds.add(benefit.id);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.white.withValues(alpha: 0.05), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) const Icon(Icons.check_rounded, size: 16, color: AppColors.primary),
                if (isSelected) const SizedBox(width: 8),
                Text(
                  benefit.title,
                  style: TextStyle(color: isSelected ? AppColors.primary : AppColors.white.withValues(alpha: 0.6), fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _savePlan(SubscriptionController controller) async {
    if (_formKey.currentState!.validate()) {
      final plan = SubscriptionPlanEntity(
        id: widget.plan?.id ?? '',
        name: _nameController.text,
        productId: _productId,
        price: double.parse(_priceController.text),
        durationType: _durationType,
        durationInDays: _durationInDays,
        currency: 'INR',
        benefitIds: _selectedBenefitIds,
        badge: _badgeController.text.isEmpty ? null : _badgeController.text,
        isActive: _isActive,
      );

      if (widget.plan == null) {
        await controller.createPlan(plan);
      } else {
        await controller.updatePlan(plan);
      }

      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Plan saved successfully!',
          type: SnackbarType.success,
        );
        Navigator.pop(context);
      }
    }
  }
}
