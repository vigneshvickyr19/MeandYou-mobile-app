import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LikePage extends StatelessWidget {
  const LikePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Text(
          'Likes Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
