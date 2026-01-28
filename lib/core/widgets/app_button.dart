import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

enum AppButtonType { primary, transparent }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final String? iconPath;
  final bool isEnabled;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.iconPath,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == AppButtonType.primary;
    final bool effectiveEnabled = isEnabled && !isLoading;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: effectiveEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: AppColors.white.withValues(alpha: 0.15)),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isPrimary ? _buildPrimary(effectiveEnabled) : _buildTransparent(effectiveEnabled),
      ),
    );
  }

  // ---------- PRIMARY BUTTON ----------
  Widget _buildPrimary(bool enabled) {
    return Ink(
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.primary, AppColors.secondary],
              )
            : null,
        color: enabled ? null : AppColors.darkOverlay,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.black,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: enabled ? AppColors.black : AppColors.greyDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  // ---------- TRANSPARENT BUTTON ----------
  Widget _buildTransparent(bool enabled) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.transparent : AppColors.darkOverlay,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          else ...[
            if (iconPath != null) ...[
              SvgPicture.asset(iconPath!, height: 20),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              style: TextStyle(
                color: enabled ? AppColors.white : AppColors.greyDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
