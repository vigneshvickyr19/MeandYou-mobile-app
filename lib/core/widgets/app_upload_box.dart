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
  final bool isPrimary;

  const AppUploadBox({
    super.key,
    required this.size,
    this.onTap,
    this.onRemove,
    this.imageFile,
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
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24, width: 1.2),
              image: imageFile != null
                  ? DecorationImage(
                      image: FileImage(imageFile!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageFile == null
                ? Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          AppImages.addImageIcon,
                          width: 28,
                          height: 28,
                        ),

                        if (isPrimary)
                          Positioned(
                            bottom: 10,
                            right: 10,
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
                                size: 14,
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
          if (imageFile != null)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
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
