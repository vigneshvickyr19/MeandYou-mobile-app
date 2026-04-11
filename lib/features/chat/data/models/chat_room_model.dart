import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final Map<String, int> unreadCount;
  final Map<String, bool> typing;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isGroup;
  final String? groupName;
  final String? groupImage;
  final Map<String, DateTime> lastReadAt;
  final String? pinnedMessageId;

  ChatRoomModel({
    required this.id,
    required this.participants,
    this.lastMessage = '',
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    this.unreadCount = const <String, int>{},
    this.typing = const <String, bool>{},
    required this.createdAt,
    required this.updatedAt,
    this.isGroup = false,
    this.groupName,
    this.groupImage,
    this.lastReadAt = const <String, DateTime>{},
    this.pinnedMessageId,
  });

  factory ChatRoomModel.fromMap(Map<String, dynamic> map, String id) {
    // Try to get the latest timestamp from either lastMessageAt, lastMessageTime, or updatedAt
    final timestamp = (map[FirebaseConstants.lastMessageAt] as Timestamp?)?.toDate() ?? 
                       (map[FirebaseConstants.lastMessageTime] as Timestamp?)?.toDate() ?? 
                       (map[FirebaseConstants.updatedAt] as Timestamp?)?.toDate() ?? 
                       DateTime.now();

    return ChatRoomModel(
      id: id,
      participants: List<String>.from(map[FirebaseConstants.participants] ?? []),
      lastMessage: map[FirebaseConstants.lastMessage] ?? '',
      lastMessageTime: timestamp,
      lastMessageSenderId: map[FirebaseConstants.lastMessageSenderId] ?? '',
      unreadCount: (map[FirebaseConstants.unreadCount] as Map?)?.map(
            (key, value) => MapEntry(key as String, (value as num?)?.toInt() ?? 0),
          ) ??
          <String, int>{},
      typing: Map<String, bool>.from(map[FirebaseConstants.typing] ?? {}),
      createdAt: (map[FirebaseConstants.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map[FirebaseConstants.updatedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      isGroup: map[FirebaseConstants.isGroup] ?? false,
      groupName: map[FirebaseConstants.groupName],
      groupImage: map[FirebaseConstants.groupImage],
      lastReadAt: (map['lastReadAt'] as Map?)?.map(
            (key, value) => MapEntry(
              key as String,
              (value as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
            ),
          ) ??
          <String, DateTime>{},
      pinnedMessageId: map[FirebaseConstants.pinnedMessageId],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.participants: participants,
      FirebaseConstants.lastMessage: lastMessage,
      FirebaseConstants.lastMessageTime: Timestamp.fromDate(lastMessageTime),
      FirebaseConstants.lastMessageSenderId: lastMessageSenderId,
      FirebaseConstants.unreadCount: unreadCount,
      FirebaseConstants.typing: typing,
      FirebaseConstants.createdAt: Timestamp.fromDate(createdAt),
      FirebaseConstants.updatedAt: Timestamp.fromDate(updatedAt),
      FirebaseConstants.isGroup: isGroup,
      FirebaseConstants.groupName: groupName,
      FirebaseConstants.groupImage: groupImage,
      'lastReadAt': lastReadAt.map((key, value) => MapEntry(key, Timestamp.fromDate(value))),
      FirebaseConstants.pinnedMessageId: pinnedMessageId,
    };
  }

  ChatRoomModel copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    Map<String, bool>? typing,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isGroup,
    String? groupName,
    String? groupImage,
    Map<String, DateTime>? lastReadAt,
    String? pinnedMessageId,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      typing: typing ?? this.typing,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
      groupImage: groupImage ?? this.groupImage,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      pinnedMessageId: pinnedMessageId ?? this.pinnedMessageId,
    );
  }

  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Gets the unread message count for a specific user
  /// 
  /// DUAL-CHECK LOGIC:
  /// ----------------
  /// 1. First checks the unreadCount map (incremented on each new message)
  /// 2. Then validates against lastReadAt timestamp as a safety check
  /// 
  /// This prevents edge cases where:
  /// - Network delays cause out-of-order updates
  /// - User opens chat on multiple devices simultaneously
  /// - Firestore counters get temporarily out of sync
  /// 
  /// Returns 0 if:
  /// - No unread messages in the map
  /// - Last message timestamp is before user's lastReadAt (already seen)
  int getUnreadCount(String userId) {
    final count = unreadCount[userId] ?? 0;
    if (count == 0) return 0;
    
    // Scalable check: Compare last message time with user's lastReadAt
    final userLastRead = lastReadAt[userId];
    if (userLastRead != null) {
      // If message is older than or equal to lastReadAt, it's not unread
      // We add a tiny buffer (1ms) for timestamp precision
      if (!lastMessageTime.isAfter(userLastRead)) {
        return 0;
      }
    }
    
    return count;
  }

  DateTime getLastReadAt(String userId) {
    return lastReadAt[userId] ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  bool isUserTyping(String userId) {
    return typing[userId] ?? false;
  }
}
