import 'package:flutter/material.dart';
import '../../../../core/constants/app_images.dart';



class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        AppImages.splashImage,
        fit: BoxFit.cover,
      ),
    );
  }
}
