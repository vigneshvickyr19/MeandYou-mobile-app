import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ChatPage extends StatelessWidget {
  final String? chatId;

  const ChatPage({
    super.key,
    this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Chat Page",
            style: TextStyle(color: AppColors.white, fontSize: 24),
          ),
          if (chatId != null) ...[
            const SizedBox(height: 16),
            Text(
              "Chat ID: $chatId",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}

