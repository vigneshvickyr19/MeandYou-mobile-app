import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_card.dart';
import '../../../subscription/presentation/admin/admin_subscription_management_page.dart';

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
        padding: const EdgeInsets.all(24),
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
              title: 'Announcements',
              subtitle: 'Send global offers & updates',
              icon: Icons.campaign_outlined,
              onTap: () => _manageAnnouncements(context),
            ),

            const SizedBox(height: 32),
            const Text(
              'User Management',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),

            AdminCard(
              title: 'User Overrides',
              subtitle: 'Custom limits for specific IDs',
              icon: Icons.person_search_rounded,
              onTap: () => _manageOverrides(context),
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
              'Update Free Like Limits',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField('Male Limit', maleController),
            const SizedBox(height: 16),
            _buildTextField('Female Limit', femaleController),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  controller.updateLikeLimits(
                    int.parse(maleController.text),
                    int.parse(femaleController.text),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _manageHelp(BuildContext context) {
    // Basic implementation for now
  }

  void _manageAnnouncements(BuildContext context) {
    final controller = context.read<AdminController>();
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        msgController.text.isNotEmpty) {
                      controller.createAnnouncement(
                        titleController.text,
                        msgController.text,
                        'offer',
                        targetAudience,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Send Broadcast',
                    style: TextStyle(fontWeight: FontWeight.bold),
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

  void _manageOverrides(BuildContext context) {
    final controller = context.read<AdminController>();
    final idController = TextEditingController();
    final limitController = TextEditingController();

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
              'User Specific Override',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField('User ID', idController),
            const SizedBox(height: 16),
            _buildTextField('New Limit', limitController),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  controller.updateUserOverride(
                    idController.text.trim(),
                    int.parse(limitController.text),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Apply Override',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
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
          style: const TextStyle(color: Colors.white),
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
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
