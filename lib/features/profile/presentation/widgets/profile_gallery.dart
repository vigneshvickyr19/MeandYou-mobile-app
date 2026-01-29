import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileGallery extends StatelessWidget {
  final List<String> photos;

  const ProfileGallery({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          childAspectRatio: 1.0,
          children: List.generate(
            photos.isEmpty ? 6 : photos.length,
            (index) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: photos.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(photos[index]),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: const Color(0xFF1A1A1A),
              ),
              child: photos.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.image,
                        color: AppColors.white.withOpacity(0.1),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
