import 'dart:io';
import 'dart:ui';
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
        bool hasImage = path != null && path.isNotEmpty;
        bool isNetwork = hasImage && path.startsWith('http');
        String quality = hasImage ? widget.controller.getPhotoAnalysis(index).label : "";
        
        return Stack(
          children: [
            AppUploadBox(
              size: double.infinity,
              imageFile: (hasImage && !isNetwork) ? File(path) : null,
              imageUrl: isNetwork ? path : null,
              onTap: () => _pickImage(index),
              onRemove: () => _removeImage(index),
            ),
            if (hasImage)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            quality == "Excellent" ? Icons.verified_rounded : Icons.star_rounded,
                            color: quality == "Excellent" ? Colors.blueAccent : Colors.amberAccent,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            quality,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (!hasImage && index == 0)
              const Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        "Primary",
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
