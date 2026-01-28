import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/widgets/app_upload_box.dart';
import '../../../../core/providers/profile_setup_provider.dart';

class StepPhotos extends StatefulWidget {
  const StepPhotos({super.key});

  @override
  State<StepPhotos> createState() => _StepPhotosState();
}

class _StepPhotosState extends State<StepPhotos> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int index) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;
    if (!mounted) return;

    final profileProvider = Provider.of<ProfileSetupProvider>(context, listen: false);
    List<String> currentPhotos = List.from(profileProvider.draftProfile?.photos ?? []);
    
    // Ensure the list is large enough
    while (currentPhotos.length <= index) {
      currentPhotos.add("");
    }
    
    currentPhotos[index] = picked.path;
    profileProvider.updateProfile((p) => p.copyWith(photos: currentPhotos));
  }

  void _removeImage(int index) {
    final profileProvider = Provider.of<ProfileSetupProvider>(context, listen: false);
    List<String> currentPhotos = List.from(profileProvider.draftProfile?.photos ?? []);
    if (index < currentPhotos.length) {
      currentPhotos[index] = "";
      profileProvider.updateProfile((p) => p.copyWith(photos: currentPhotos));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileSetupProvider>(context);
    List<String> photos = profileProvider.draftProfile?.photos ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Photos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload at least one photo. All fields are required.',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 24),

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
            String? path = index < photos.length ? photos[index] : null;
            return AppUploadBox(
              size: 100,
              imageFile: (path != null && path.isNotEmpty) ? File(path) : null,
              onTap: () => _pickImage(index),
              onRemove: () => _removeImage(index),
            );
          },
        ),
      ],
    );
  }
}
