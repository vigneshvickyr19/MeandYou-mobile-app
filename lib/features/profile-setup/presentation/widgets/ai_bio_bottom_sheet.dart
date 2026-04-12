import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/ai_bio_api_service.dart';
import '../../../../core/widgets/app_button.dart';

class AiBioBottomSheet extends StatefulWidget {
  final String interests;
  final String personality;

  const AiBioBottomSheet({
    super.key,
    required this.interests,
    required this.personality,
  });

  static Future<String?> show(
    BuildContext context, {
    required String interests,
    required String personality,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiBioBottomSheet(
        interests: interests,
        personality: personality,
      ),
    );
  }

  @override
  State<AiBioBottomSheet> createState() => _AiBioBottomSheetState();
}

class _AiBioBottomSheetState extends State<AiBioBottomSheet> {
  List<String> _suggestions = [];
  bool _isLoading = true;
  String? _selectedBio;

  @override
  void initState() {
    super.initState();
    _fetchBios();
  }

  Future<void> _fetchBios() async {
    setState(() => _isLoading = true);
    final bios = await AiBioApiService.instance.generateMultipleBios(
      interests: widget.interests,
      personality: widget.personality,
    );
    if (mounted) {
      setState(() {
        _suggestions = bios;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppColors.primary, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Bio Ideas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _fetchBios,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: _isLoading ? Colors.white24 : AppColors.primary,
                  ),
                  tooltip: 'Regenerate suggestions',
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _isLoading ? _buildSkeleton() : _buildContent(),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: 'Select Bio',
                    isLoading: false,
                    onPressed: _selectedBio == null
                        ? null
                        : () => Navigator.pop(context, _selectedBio),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_suggestions.isEmpty) {
      return const Center(
        child: Text(
          'Failed to generate bios.\nPlease try again.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final bio = _suggestions[index];
        bool isSelected = _selectedBio == bio;

        return GestureDetector(
          onTap: () => setState(() => _selectedBio = bio),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1,
              ),
            ),
            child: Text(
              bio,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _skeletonLine(width: 200, top: 16, left: 16),
              _skeletonLine(width: 150, top: 8, left: 16),
              _skeletonLine(width: 250, top: 8, left: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _skeletonLine({
    required double width,
    required double top,
    required double left,
  }) {
    return Container(
      margin: EdgeInsets.only(top: top, left: left),
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
