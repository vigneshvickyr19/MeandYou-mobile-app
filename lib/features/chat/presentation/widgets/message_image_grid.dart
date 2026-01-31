import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_full_screen_image_viewer.dart';

class MessageImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final bool isLocalPath;

  const MessageImageGrid({
    super.key,
    required this.imageUrls,
    this.isLocalPath = false,
  });

  void _openFullScreenViewer(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenImageViewer(
          imageUrls: imageUrls,
          initialIndex: index,
          isLocalPath: isLocalPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final imageCount = imageUrls.length;

    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildGridLayout(imageCount, context),
      ),
    );
  }

  Widget _buildGridLayout(int count, BuildContext context) {
    if (count == 1) {
      return _buildSingleImage(imageUrls[0], context);
    } else if (count == 2) {
      return _buildTwoImages(context);
    } else if (count == 3) {
      return _buildThreeImages(context);
    } else if (count == 4) {
      return _buildFourImages(context);
    } else {
      return _buildFiveOrMoreImages(count, context);
    }
  }

  Widget _buildSingleImage(String url, BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: _buildImage(url, BoxFit.cover, 0, context),
    );
  }

  Widget _buildTwoImages(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Row(
        children: [
          Expanded(child: _buildImage(imageUrls[0], BoxFit.cover, 0, context)),
          const SizedBox(width: 2),
          Expanded(child: _buildImage(imageUrls[1], BoxFit.cover, 1, context)),
        ],
      ),
    );
  }

  Widget _buildThreeImages(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildImage(imageUrls[0], BoxFit.cover, 0, context),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildImage(imageUrls[1], BoxFit.cover, 1, context)),
                const SizedBox(height: 2),
                Expanded(child: _buildImage(imageUrls[2], BoxFit.cover, 2, context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourImages(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(imageUrls[0], BoxFit.cover, 0, context)),
                const SizedBox(width: 2),
                Expanded(child: _buildImage(imageUrls[1], BoxFit.cover, 1, context)),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(imageUrls[2], BoxFit.cover, 2, context)),
                const SizedBox(width: 2),
                Expanded(child: _buildImage(imageUrls[3], BoxFit.cover, 3, context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiveOrMoreImages(int count, BuildContext context) {
    return SizedBox(
      height: 350,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(imageUrls[0], BoxFit.cover, 0, context)),
                const SizedBox(width: 2),
                Expanded(child: _buildImage(imageUrls[1], BoxFit.cover, 1, context)),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(imageUrls[2], BoxFit.cover, 2, context)),
                const SizedBox(width: 2),
                Expanded(child: _buildImage(imageUrls[3], BoxFit.cover, 3, context)),
                const SizedBox(width: 2),
                Expanded(
                  child: count > 5
                      ? _buildImageWithOverlay(imageUrls[4], count - 5, 4, context)
                      : _buildImage(imageUrls[4], BoxFit.cover, 4, context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url, BoxFit fit, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullScreenViewer(context, index),
      child: Hero(
        tag: 'image_$url',
        child: _buildImageOnly(url, fit),
      ),
    );
  }

  Widget _buildImageOnly(String url, BoxFit fit) {
    return isLocalPath
        ? Image.file(
            File(url),
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          )
        : Image.network(
            url,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingWidget();
            },
            errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          );
  }

  Widget _buildImageWithOverlay(String url, int remainingCount, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullScreenViewer(context, index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'image_$url',
            child: _buildImageOnly(url, BoxFit.cover),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
            ),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: AppColors.black.withOpacity(0.3),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primary.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.black.withOpacity(0.3),
      child: Center(
        child: Icon(
          Icons.broken_image_rounded,
          color: AppColors.white.withOpacity(0.3),
          size: 40,
        ),
      ),
    );
  }
}
