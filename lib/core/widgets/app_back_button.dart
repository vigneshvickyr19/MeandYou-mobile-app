import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppBackButton extends StatelessWidget {
  /// If routeName is null → Navigator.pop()
  /// If routeName is provided → Navigator.pushReplacementNamed()
  final String? routeName;
  final VoidCallback? onTap;

  const AppBackButton({super.key, this.routeName, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          } else if (routeName != null) {
            Navigator.pushReplacementNamed(context, routeName!);
          } else if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white.withOpacity(0.9),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
