import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';

class ChatSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final bool isLoading;
  final Function(String) onSuggestionTap;

  const ChatSuggestions({
    super.key,
    required this.suggestions,
    required this.isLoading,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Flash(
                  infinite: true,
                  duration: const Duration(seconds: 3),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primary, Colors.white],
                  ).createShader(bounds),
                  child: Text(
                    suggestions.isNotEmpty ? 'AI REPLIES' : 'AI IS THINKING...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: isLoading ? _buildSkeleton() : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      itemCount: suggestions.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return FadeInRight(
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: index * 100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onSuggestionTap(suggestions[index]),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  suggestions[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 150,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }
}
