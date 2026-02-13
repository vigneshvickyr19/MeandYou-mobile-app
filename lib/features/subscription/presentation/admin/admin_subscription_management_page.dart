import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_capsule_tab.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/admin_benefit_list_item.dart';
import '../widgets/admin_plan_list_item.dart';
import 'manage_benefits_page.dart';
import 'manage_plans_page.dart';

class AdminSubscriptionManagementPage extends StatefulWidget {
  const AdminSubscriptionManagementPage({super.key});

  @override
  State<AdminSubscriptionManagementPage> createState() => _AdminSubscriptionManagementPageState();
}

class _AdminSubscriptionManagementPageState extends State<AdminSubscriptionManagementPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionController>().initAdmin();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Subscription Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                AppCapsuleTab(
                  tabs: const ['Benefits', 'Plans'],
                  selectedIndex: _selectedIndex,
                  onTabSelected: (index) {
                    setState(() => _selectedIndex = index);
                    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _selectedIndex = index),
              children: const [
                ManageBenefitsPage(),
                ManagePlansPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
