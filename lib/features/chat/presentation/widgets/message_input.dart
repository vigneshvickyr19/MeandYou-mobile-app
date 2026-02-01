import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(List<XFile>)? onImagesSelected;
  final List<XFile> selectedImages;
  final VoidCallback? onClearImages;
  final Function(bool)? onTypingChanged;
  final bool showBorder;
  final VoidCallback? onStartRecording;
  final Future<String?> Function()? onStopRecording;
  final VoidCallback? onCancelRecording;
  final Function(String path, Duration duration)? onSendVoiceMessage;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.onImagesSelected,
    this.selectedImages = const [],
    this.onClearImages,
    this.onTypingChanged,
    this.showBorder = false,
    this.onStartRecording,
    this.onStopRecording,
    this.onCancelRecording,
    this.onSendVoiceMessage,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _hasText = false;
  bool _showEmoji = false;
  final FocusNode _focusNode = FocusNode();
  
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmoji) {
        setState(() => _showEmoji = false);
      }
    });
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      widget.onTypingChanged?.call(hasText);
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty || widget.selectedImages.isNotEmpty) {
      widget.onSendMessage(text);
      _controller.clear();
      setState(() => _hasText = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      widget.onImagesSelected?.call(images);
    }
  }

  Future<void> _pickFromCamera() async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      widget.onImagesSelected?.call([image]);
    }
  }

  void _showMediaSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMediaOption(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _pickFromGallery();
                        },
                      ),
                      _buildMediaOption(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _pickFromCamera();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startRecording() {
    widget.onStartRecording?.call();
    setState(() {
      _isRecording = true;
      _recordDuration = Duration.zero;
    });
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration = Duration(seconds: timer.tick);
      });
    });
  }

  Future<void> _stopAndSend() async {
    _recordTimer?.cancel();
    final duration = _recordDuration;
    // Keep internal state recording true until we process stop, or optimistic update?
    // Let's reset purely UI state
    setState(() {
      _isRecording = false;
      _recordDuration = Duration.zero;
    });

    if (widget.onStopRecording != null) {
      final path = await widget.onStopRecording!();
      if (path != null) {
        widget.onSendVoiceMessage?.call(path, duration);
      }
    }
  }

  void _cancelRecording() {
    _recordTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordDuration = Duration.zero;
    });
    widget.onCancelRecording?.call();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.8),
              ),
              child: Column(
                children: [
                  if (widget.selectedImages.isNotEmpty)
                    _buildImagePreviewList(),
                  Row(
                    children: [
                      if (_isRecording)
                        Expanded(
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Row(
                              children: [
                                FadeIn(
                                  duration: const Duration(milliseconds: 500),
                                  child: const Icon(Icons.fiber_manual_record, color: Colors.red, size: 16),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _formatDuration(_recordDuration),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "Recording...",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _cancelRecording,
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        IconButton(
                          icon: Icon(
                            _showEmoji
                                ? Icons.keyboard_rounded
                                : Icons.emoji_emotions_rounded,
                            color: _showEmoji
                                ? AppColors.primary
                                : AppColors.white.withValues(alpha: 0.6),
                            size: 26,
                          ),
                          onPressed: () {
                            setState(() => _showEmoji = !_showEmoji);
                            if (_showEmoji) {
                              _focusNode.unfocus();
                            } else {
                              _focusNode.requestFocus();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_rounded,
                            color: AppColors.white.withValues(alpha: 0.6),
                            size: 26,
                          ),
                          onPressed: _showMediaSheet,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Message...',
                                hintStyle: TextStyle(
                                  color: AppColors.white.withValues(alpha: 0.3),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              maxLines: 5,
                              minLines: 1,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      if (_isRecording)
                         ZoomIn(
                           duration: const Duration(milliseconds: 300),
                           child: GestureDetector(
                             onTap: _stopAndSend,
                             child: Container(
                               width: 48,
                               height: 48,
                               decoration: BoxDecoration(
                                 color: AppColors.primary,
                                 shape: BoxShape.circle,
                                 boxShadow: [
                                   BoxShadow(
                                     color: AppColors.primary.withValues(alpha: 0.4),
                                     blurRadius: 10,
                                     offset: const Offset(0, 4),
                                   ),
                                 ],
                               ),
                               child: const Icon(
                                 Icons.send_rounded,
                                 color: Colors.white,
                                 size: 22,
                               ),
                             ),
                           ),
                         )
                      else if (_hasText || widget.selectedImages.isNotEmpty)
                        ZoomIn(
                          duration: const Duration(milliseconds: 300),
                          child: GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        )
                      else
                        FadeInRight(
                          duration: const Duration(milliseconds: 200),
                          child: GestureDetector(
                            onLongPress: _startRecording, // Hold to record
                            onLongPressUp: _stopAndSend, // Release to send
                            onTap: _startRecording, // Tap to record (toggle mode)
                            child: Container(
                                padding: const EdgeInsets.all(10), // bigger touch target
                                child: Icon(
                                    Icons.mic_rounded,
                                    color: AppColors.white.withValues(alpha: 0.6),
                                    size: 26,
                                ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showEmoji) _buildEmojiPicker(),
      ],
    );
  }

  Widget _buildImagePreviewList() {
    return ZoomIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.selectedImages.length,
          itemBuilder: (context, index) {
            return Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(widget.selectedImages[index].path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        final images = List<XFile>.from(widget.selectedImages);
                        images.removeAt(index);
                        widget.onImagesSelected?.call(images);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            _controller.text = _controller.text + emoji.emoji;
            _onTextChanged();
          },
          config: Config(
            emojiViewConfig: EmojiViewConfig(
              columns: 7,
              emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
              gridPadding: EdgeInsets.zero,
              backgroundColor: const Color(0xFF121212),
              loadingIndicator: const SizedBox.shrink(),
              recentsLimit: 28,
              noRecents: const Text(
                'No Recents',
                style: TextStyle(fontSize: 20, color: Colors.black26),
                textAlign: TextAlign.center,
              ),
            ),
            categoryViewConfig: CategoryViewConfig(
              initCategory: Category.RECENT,
              recentTabBehavior: RecentTabBehavior.RECENT,
              backgroundColor: const Color(0xFF121212),
              indicatorColor: AppColors.primary,
              iconColor: Colors.grey,
              iconColorSelected: AppColors.primary,
              backspaceColor: AppColors.primary,
              categoryIcons: const CategoryIcons(),
            ),
          ),
        ),
      ),
    );
  }
}
