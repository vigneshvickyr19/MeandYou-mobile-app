import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/message_model.dart';

/// Status indicator showing time, read receipts, and message state
class MessageStatusIndicator extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final bool isLastInGroup;
  final DateTime? otherUserLastReadAt;
  final VoidCallback? onResend;

  const MessageStatusIndicator({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.isLastInGroup,
    this.otherUserLastReadAt,
    this.onResend,
  });

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'pm' : 'am';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    if (!isLastInGroup &&
        message.status != MessageStatus.error &&
        message.status != MessageStatus.sending) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.isPinned) _buildPinIcon(),
          _buildStatusIcon(),
          if (isCurrentUser &&
              message.status != MessageStatus.sending &&
              message.status != MessageStatus.error)
            ..._buildReadReceipt(),
          if (message.status == MessageStatus.error) _buildRetryButton(),
        ],
      ),
    );
  }

  Widget _buildPinIcon() {
    return const Padding(
      padding: EdgeInsets.only(right: 4),
      child: Icon(
        Icons.push_pin_rounded,
        color: Colors.white38,
        size: 10,
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (message.status == MessageStatus.error) {
      return const Icon(
        Icons.error_outline_rounded,
        color: Colors.redAccent,
        size: 14,
      );
    } else if (message.status == MessageStatus.sending) {
      return SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.white.withValues(alpha: 0.4),
          ),
        ),
      );
    } else {
      return Text(
        _formatTime(message.timestamp),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 10,
        ),
      );
    }
  }

  List<Widget> _buildReadReceipt() {
    bool isSeen = false;
    if (otherUserLastReadAt != null) {
      isSeen = otherUserLastReadAt!.isAtSameMomentAs(message.timestamp) ||
          otherUserLastReadAt!.isAfter(message.timestamp);
    }

    return [
      const SizedBox(width: 4),
      Icon(
        isSeen ? Icons.done_all_rounded : Icons.done_rounded,
        size: 14,
        color: isSeen
            ? AppColors.info
            : Colors.white.withValues(alpha: 0.4),
      ),
    ];
  }

  Widget _buildRetryButton() {
    return Row(
      children: [
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onResend,
          child: const Text(
            "Retry",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
