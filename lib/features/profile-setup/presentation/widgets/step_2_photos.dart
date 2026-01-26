import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/app_upload_box.dart';

class StepPhotos extends StatefulWidget {
  const StepPhotos({super.key});

  @override
  State<StepPhotos> createState() => _StepPhotosState();
}

class _StepPhotosState extends State<StepPhotos> {
  final ImagePicker _picker = ImagePicker();

  File? profileImage;
  final List<File?> galleryImages = List.generate(6, (_) => null);

  Future<void> _pickImage({required bool isProfile, int? index}) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      if (isProfile) {
        profileImage = File(picked.path);
      } else if (index != null) {
        galleryImages[index] = File(picked.path);
      }
    });
  }

  void _removeProfileImage() {
    setState(() {
      profileImage = null;
    });
  }

  void _removeGalleryImage(int index) {
    setState(() {
      galleryImages[index] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Photo & Gallery',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Upload a clear profile picture and add more photos to your gallery.',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),

        const SizedBox(height: 24),

        /// PROFILE PHOTO
        const Text(
          'Upload profile picture',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 12),

        AppUploadBox(
          size: 120,
          imageFile: profileImage,
          onTap: () => _pickImage(isProfile: true),
          onRemove: _removeProfileImage,
        ),

        const SizedBox(height: 28),

        /// ADDITIONAL PHOTOS
        const Text(
          'Upload additional photos (min 2, max 6)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemBuilder: (_, index) {
            return AppUploadBox(
              size: 100,
              imageFile: galleryImages[index],
              onTap: () => _pickImage(isProfile: false, index: index),
              onRemove: () => _removeGalleryImage(index),
            );
          },
        ),

        const SizedBox(height: 12),

        const Text(
          'Tap to edit, drag to reorder',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }
}
