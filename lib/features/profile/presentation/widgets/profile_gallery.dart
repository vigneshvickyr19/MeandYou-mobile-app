import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_full_screen_image_viewer.dart';

class ProfileGallery extends StatelessWidget {
  final List<String> photos;

  const ProfileGallery({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Text(
            "Photo Gallery",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.count(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          childAspectRatio: 1.0,
          children: List.generate(
            photos.length,
            (index) => GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageViewer(
                      imageUrls: photos,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'image_${photos[index]}',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(photos[index]),
                      fit: BoxFit.cover,
                    ),
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
