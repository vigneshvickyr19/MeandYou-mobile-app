import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_card.dart';
import '../../../subscription/presentation/admin/admin_subscription_management_page.dart';
import '../../../../core/widgets/app_snackbar.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Admin Control Panel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Controls',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),

            AdminCard(
              title: 'Like Limits',
              subtitle: 'Manage daily free like quotas',
              icon: Icons.favorite_border_rounded,
              onTap: () => _manageLimits(context),
            ),
            const SizedBox(height: 16),

            AdminCard(
              title: 'Help Center',
              subtitle: 'Update FAQs and support docs',
              icon: Icons.help_outline_rounded,
              onTap: () => _manageHelp(context),
            ),
            const SizedBox(height: 16),

            AdminCard(
              title: 'Nearby Settings',
              subtitle: 'Configure search radius in KM',
              icon: Icons.location_on_outlined,
              onTap: () => _manageNearbyRadius(context),
            ),
            const SizedBox(height: 16),

            AdminCard(
              title: 'Announcements',
              subtitle: 'Send global offers & updates',
              icon: Icons.campaign_outlined,
              onTap: () => _manageAnnouncements(context),
            ),



            const SizedBox(height: 32),
            const Text(
              'Business & Monetization',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),

            AdminCard(
              title: 'Subscriptions',
              subtitle: 'Plans, Benefits & Revenue',
              icon: Icons.card_membership_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminSubscriptionManagementPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _manageLimits(BuildContext context) {
    final controller = context.read<AdminController>();
    final maleController = TextEditingController(
      text: controller.settings?.maleFreeLikes.toString() ?? '5',
    );
    final femaleController = TextEditingController(
      text: controller.settings?.femaleFreeLikes.toString() ?? '10',
    );
    bool maleUnlimited = controller.settings?.maleFreeLikes == -1;
    bool femaleUnlimited = controller.settings?.femaleFreeLikes == -1;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Free Like Limits',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildTextField('Male Limit', maleController, enabled: !maleUnlimited)),
                  const SizedBox(width: 16),
                  _buildUnlimitedToggle('Unlimited', maleUnlimited, (val) => setSheetState(() => maleUnlimited = val)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Female Limit', femaleController, enabled: !femaleUnlimited)),
                  const SizedBox(width: 16),
                  _buildUnlimitedToggle('Unlimited', femaleUnlimited, (val) => setSheetState(() => femaleUnlimited = val)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Consumer<AdminController>(
                  builder: (context, controller, _) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controller.isLoading ? null : () async {
                      try {
                        await controller.updateLikeLimits(
                          maleUnlimited ? -1 : int.parse(maleController.text),
                          femaleUnlimited ? -1 : int.parse(femaleController.text),
                        );
                        if (!context.mounted) return;
                        AppSnackbar.show(
                          context,
                          message: 'Free Like Limits updated successfully!',
                          type: SnackbarType.success,
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        AppSnackbar.show(
                          context,
                          message: 'Failed to update limits. Please try again.',
                          type: SnackbarType.error,
                        );
                      }
                    },
                    child: controller.isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _manageHelp(BuildContext context) {
    // Basic implementation for now
  }

  void _manageNearbyRadius(BuildContext context) {
    final controller = context.read<AdminController>();
    final radiusController = TextEditingController(
      text: controller.settings?.nearbyRadiusInKm.toString() ?? '10.0',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Nearby Radius',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sets the maximum distance (KM) for showing users in the Nearby tab. Use 0.5 for 500 meters.',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildTextField('Search Radius (KM)', radiusController, isDecimal: true),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Consumer<AdminController>(
                builder: (context, controller, _) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isLoading ? null : () async {
                    final radius = double.tryParse(radiusController.text);
                    if (radius != null) {
                      try {
                        await controller.updateNearbyRadius(radius);
                        if (!context.mounted) return;
                        AppSnackbar.show(
                          context,
                          message: 'Nearby Radius updated successfully!',
                          type: SnackbarType.success,
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        AppSnackbar.show(
                          context,
                          message: 'Failed to update radius. Please try again.',
                          type: SnackbarType.error,
                        );
                      }
                    }
                  },
                  child: controller.isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Save Settings',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _manageAnnouncements(BuildContext context) {
    final titleController = TextEditingController();
    final msgController = TextEditingController();
    String targetAudience = 'both';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Announcement',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('Title', titleController),
              const SizedBox(height: 16),
              _buildTextField('Message', msgController, maxLines: 3),
              const SizedBox(height: 24),
              const Text(
                'Target Audience',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTargetChip(
                    'All',
                    'both',
                    targetAudience,
                    (val) => setSheetState(() => targetAudience = val),
                  ),
                  const SizedBox(width: 8),
                  _buildTargetChip(
                    'Male',
                    'male',
                    targetAudience,
                    (val) => setSheetState(() => targetAudience = val),
                  ),
                  const SizedBox(width: 8),
                  _buildTargetChip(
                    'Female',
                    'female',
                    targetAudience,
                    (val) => setSheetState(() => targetAudience = val),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Consumer<AdminController>(
                  builder: (context, controller, _) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controller.isLoading ? null : () async {
                      if (titleController.text.isNotEmpty &&
                          msgController.text.isNotEmpty) {
                        try {
                          await controller.createAnnouncement(
                            titleController.text,
                            msgController.text,
                            'offer',
                            targetAudience,
                          );
                          if (!context.mounted) return;
                          AppSnackbar.show(
                            context,
                            message: 'Announcement sent successfully!',
                            type: SnackbarType.success,
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          AppSnackbar.show(
                            context,
                            message: 'Failed to send announcement.',
                            type: SnackbarType.error,
                          );
                        }
                      }
                    },
                    child: controller.isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Send Broadcast',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetChip(
    String label,
    String value,
    String current,
    Function(String) onSelect,
  ) {
    final isSelected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnlimitedToggle(String label, bool value, Function(bool) onChanged) {
    return Column(
      children: [
        const Text('Unlimited', style: TextStyle(color: Colors.white60, fontSize: 10)),
        const SizedBox(height: 4),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    bool enabled = true,
    bool isDecimal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          enabled: enabled,
          style: TextStyle(color: enabled ? Colors.white : Colors.white24),
          maxLines: maxLines,
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.01),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
