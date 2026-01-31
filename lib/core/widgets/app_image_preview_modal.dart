import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/app_colors.dart';

class ImagePreviewModal extends StatefulWidget {
  final List<XFile> images;
  final Function(String caption) onSend;
  final VoidCallback onClose;

  const ImagePreviewModal({
    super.key,
    required this.images,
    required this.onSend,
    required this.onClose,
  });

  @override
  State<ImagePreviewModal> createState() => _ImagePreviewModalState();
}

class _ImagePreviewModalState extends State<ImagePreviewModal> {
  final TextEditingController _captionController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isSending = false;

  @override
  void dispose() {
    _captionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      await widget.onSend(_captionController.text.trim());
      if (mounted) {
        widget.onClose();
      }
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildImageViewer(),
                ),
                if (widget.images.length > 1) _buildImageThumbnails(),
                _buildCaptionInput(),
              ],
            ),
            if (_isSending) _buildSendingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hasExcessImages = widget.images.length > 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: AppColors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: widget.onClose,
              ),
              const Spacer(),
              Column(
                children: [
                  Text(
                    widget.images.length > 1
                        ? '${_currentIndex + 1} / ${widget.images.length}'
                        : 'Preview',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hasExcessImages)
                    Text(
                      'Only first 10 will be sent',
                      style: TextStyle(
                        color: Colors.orange.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() => _currentIndex = index);
      },
      itemCount: widget.images.length,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: Image.file(
              File(widget.images[index].path),
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageThumbnails() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: AppColors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(widget.images[index].path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaptionInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: AppColors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.08),
                ),
              ),
              child: TextField(
                controller: _captionController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Add a caption...',
                  hintStyle: TextStyle(
                    color: AppColors.white.withOpacity(0.3),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendingOverlay() {
    return FadeIn(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Sending...',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
