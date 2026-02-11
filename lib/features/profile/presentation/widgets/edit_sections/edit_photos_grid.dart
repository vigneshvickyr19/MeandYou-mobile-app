import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/edit_profile_controller.dart';
import '../../../../../core/widgets/app_upload_box.dart';

class EditPhotosGrid extends StatefulWidget {
  final EditProfileController controller;

  const EditPhotosGrid({super.key, required this.controller});

  @override
  State<EditPhotosGrid> createState() => _EditPhotosGridState();
}

class _EditPhotosGridState extends State<EditPhotosGrid> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int index) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    List<String> currentPhotos = List.from(widget.controller.draftProfile?.photos ?? []);
    while (currentPhotos.length <= index) {
      currentPhotos.add("");
    }

    currentPhotos[index] = picked.path;
    widget.controller.updateDraft((p) => p.copyWith(photos: currentPhotos));
  }

  void _removeImage(int index) {
    List<String> currentPhotos = List.from(widget.controller.draftProfile?.photos ?? []);
    if (index < currentPhotos.length) {
      currentPhotos[index] = "";
      widget.controller.updateDraft((p) => p.copyWith(photos: currentPhotos));
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.controller.draftProfile?.photos ?? [];

    return GridView.builder(
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
        bool isNetwork = path != null && path.startsWith('http');
        
        return AppUploadBox(
          size: 100,
          imageFile: (path != null && path.isNotEmpty && !isNetwork) ? File(path) : null,
          imageUrl: isNetwork ? path : null,
          onTap: () => _pickImage(index),
          onRemove: () => _removeImage(index),
        );
      },
    );
  }
}
