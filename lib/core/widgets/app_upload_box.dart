import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';

class AppUploadBox extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final File? imageFile;
  final String? imageUrl;
  final bool isPrimary;

  const AppUploadBox({
    super.key,
    required this.size,
    this.onTap,
    this.onRemove,
    this.imageFile,
    this.imageUrl,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          /// IMAGE / UPLOAD BOX
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
              image: imageFile != null
                  ? DecorationImage(
                      image: FileImage(imageFile!),
                      fit: BoxFit.cover,
                    )
                  : (imageUrl != null && imageUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child:
                (imageFile == null && (imageUrl == null || imageUrl!.isEmpty))
                ? Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppImages.addImageIcon,
                            width: 24,
                            height: 24,
                          ),
                        ),
                        if (isPrimary)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 12,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : null,
          ),

          /// ❌ REMOVE BUTTON (TOP RIGHT)
          if (imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty))
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
