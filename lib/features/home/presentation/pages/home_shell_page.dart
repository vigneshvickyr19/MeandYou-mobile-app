import 'package:flutter/material.dart';
import 'package:me_and_you/features/home/presentation/pages/home_page.dart';
import 'package:me_and_you/features/linkes/presentation/pages/like_page.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../controllers/home_navigation_controller.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/home_app_bar.dart';

class HomeShellPage extends StatelessWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeNavigationController(),
      child: Consumer<HomeNavigationController>(
        builder: (_, controller, __) {
          return Scaffold(
            backgroundColor: AppColors.black,
            appBar: const HomeAppBar(),
            body: IndexedStack(
              index: controller.index,
              children: const [
                HomePage(),
                LikePage(),
                ChatPage(),
                ProfilePage(),
              ],
            ),
            bottomNavigationBar: CustomBottomNav(
              currentIndex: controller.index,
              onChanged: controller.changeTab,
            ),
          );
        },
      ),
    );
  }
}
