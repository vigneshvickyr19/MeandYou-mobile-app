import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: const Text(
              'Profile Photos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 600),
            child: Text(
              'Upload at least one photo. People love to see who they are talking to!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), 
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 32),

          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
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
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
