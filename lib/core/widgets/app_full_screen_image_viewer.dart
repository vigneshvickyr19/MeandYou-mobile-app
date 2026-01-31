import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/app_colors.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final bool isLocalPath;
  final VoidCallback? onClose;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.isLocalPath = false,
    this.onClose,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _closeViewer() {
    widget.onClose?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            _buildImageViewer(),
            if (_showControls) _buildTopBar(),
            if (_showControls && widget.imageUrls.length > 1) _buildBottomIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      itemCount: widget.imageUrls.length,
      itemBuilder: (context, index) {
        return Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Hero(
              tag: 'image_${widget.imageUrls[index]}',
              child: _buildImage(widget.imageUrls[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(String url) {
    if (widget.isLocalPath) {
      return Image.file(
        File(url),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else {
      return Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: FadeIn(
        duration: const Duration(milliseconds: 200),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: _closeViewer,
                ),
                const Spacer(),
                if (widget.imageUrls.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: FadeIn(
        duration: const Duration(milliseconds: 200),
        child: SafeArea(
          top: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.imageUrls.length > 10 ? 10 : widget.imageUrls.length,
                  (index) {
                    final isActive = index == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    final progress = loadingProgress.expectedTotalBytes != null
        ? loadingProgress.cumulativeBytesLoaded /
            loadingProgress.expectedTotalBytes!
        : null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 16),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_rounded,
            color: Colors.white.withOpacity(0.3),
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
