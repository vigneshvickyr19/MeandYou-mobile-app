import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import 'chat_avatar.dart';

class ChatStarterSuggestions extends StatelessWidget {
  final UserModel otherUser;
  final List<String> suggestions;
  final bool isLoading;
  final Function(String) onSuggestionTap;

  const ChatStarterSuggestions({
    super.key,
    required this.otherUser,
    required this.suggestions,
    required this.isLoading,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // User Avatar & Welcome with Background Glow
            FadeInDown(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Pulse(
                    infinite: true,
                    duration: const Duration(seconds: 4),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      ChatAvatar(
                        userId: otherUser.id,
                        imageUrl: otherUser.thumbnailUrl ?? otherUser.profileImageUrl,
                        size: 80,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Say hello to ${otherUser.fullName?.split(' ').first}!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            
            // Shimmering subtitle or status
            FadeIn(
              delay: const Duration(milliseconds: 500),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isLoading 
                    ? [AppColors.primary, Colors.white70, AppColors.primary]
                    : [Colors.white70, Colors.white70],
                ).createShader(bounds),
                child: Text(
                  isLoading ? 'AI IS CRAFTING THE PERFECT OPENERS...' : 'Break the ice with one of these AI starters',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Suggestions List
            if (isLoading)
              _buildLoading()
            else
              ...suggestions.map((suggestion) => _buildSuggestionCard(suggestion)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(String suggestion) {
    return FadeInUp(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => onSuggestionTap(suggestion),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.send_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: List.generate(3, (index) => 
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
