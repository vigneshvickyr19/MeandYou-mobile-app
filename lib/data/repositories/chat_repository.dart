import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../features/chat/data/models/chat_room_model.dart';
import '../../features/chat/data/models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _chatsCollection =>
      _firestore.collection(FirebaseConstants.chats);
  CollectionReference get _messagesCollection =>
      _firestore.collection(FirebaseConstants.messages);

  static String getChatRoomId(String userId1, String userId2) {
    final participants = [userId1, userId2]..sort();
    return participants.join('_');
  }

  Future<String> getOrCreateChatRoom(String userId1, String userId2) async {
    final chatRoomId = getChatRoomId(userId1, userId2);
    final participants = [userId1, userId2]..sort();

    final chatRoomRef = _chatsCollection.doc(chatRoomId);
    final chatRoomDoc = await chatRoomRef.get();

    if (!chatRoomDoc.exists) {
      final newChatRoom = ChatRoomModel(
        id: chatRoomId,
        participants: participants,
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await chatRoomRef.set({
        ...newChatRoom.toMap(),
        FirebaseConstants.lastMessageAt: FieldValue.serverTimestamp(),
        FirebaseConstants.updatedAt: FieldValue.serverTimestamp(),
      });
    }

    return chatRoomId;
  }

  Stream<ChatRoomModel?> streamChatRoom(String chatRoomId) {
    return _chatsCollection.doc(chatRoomId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChatRoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    return _chatsCollection
        .where(FirebaseConstants.participants, arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final rooms = snapshot.docs
              .map(
                (doc) => ChatRoomModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

          rooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
          return rooms;
        });
  }

  /// Sends a message and updates the chat room metadata
  ///
  /// IMPORTANT: This method does NOT mark the message as seen for the sender.
  /// The sender's lastReadAt is only updated when they open/view the chat.
  ///
  /// Updates:
  /// - Creates message document
  /// - Increments receiver's unreadCount
  /// - Updates lastMessage preview
  /// - Updates lastMessageTime for sorting
  Future<void> sendMessage(MessageModel message) async {
    if (message.receiverId.isEmpty || message.chatRoomId.isEmpty) return;

    final batch = _firestore.batch();

    // 1. Create the message document
    final messageRef = _messagesCollection.doc();
    batch.set(messageRef, message.copyWith(id: messageRef.id).toMap());

    // 2. Update the chat room document
    final chatRoomRef = _chatsCollection.doc(message.chatRoomId);

    // Determine last message text for preview
    String lastMsgText = message.content;
    if (message.type == MessageType.image) {
      lastMsgText = 'Sent an image';
    } else if (message.type == MessageType.video) {
      lastMsgText = 'Sent a video';
    } else if (message.type == MessageType.audio) {
      lastMsgText = 'Voice Message';
    }

    batch.update(chatRoomRef, {
      FirebaseConstants.lastMessage: lastMsgText,
      FirebaseConstants.lastMessageTime: FieldValue.serverTimestamp(),
      FirebaseConstants.lastMessageAt: FieldValue.serverTimestamp(),
      FirebaseConstants.lastMessageSenderId: message.senderId,
      FirebaseConstants.updatedAt: FieldValue.serverTimestamp(),
      // Only increment receiver's unread count
      '${FirebaseConstants.unreadCount}.${message.receiverId}':
          FieldValue.increment(1),
    });

    await batch.commit();
  }

  Stream<List<MessageModel>> getMessages(String chatRoomId) {
    return _messagesCollection
        .where(FirebaseConstants.chatRoomId, isEqualTo: chatRoomId)
        .snapshots()
        .map((snapshot) {
          final messages = snapshot.docs
              .map(
                (doc) => MessageModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

          messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return messages;
        });
  }

  /// Marks all messages in a chat as seen for the specified user
  ///
  /// This is called when:
  /// 1. User opens/enters a chat (ChatDetailController.initialize)
  /// 2. New messages arrive while user is viewing the chat
  ///
  /// Updates:
  /// - Sets unreadCount to 0 for the user
  /// - Updates lastReadAt timestamp (used for seen status calculation)
  ///
  /// SCALABLE: Single write operation regardless of message count
  Future<void> markMessagesAsSeen(String chatRoomId, String userId) async {
    if (chatRoomId.isEmpty || userId.isEmpty) return;

    try {
      // SCALABLE APPROACH:
      // Instead of updating every message status to "seen", we just update
      // the lastReadAt timestamp for the user in the ChatRoom.
      // Message bubbles will decide their "seen" status by comparing their
      // timestamp to this value. This is much faster and cheaper.

      final chatRoomRef = _chatsCollection.doc(chatRoomId);
      await chatRoomRef.update({
        '${FirebaseConstants.unreadCount}.$userId': 0,
        'lastReadAt.$userId': FieldValue.serverTimestamp(),
        FirebaseConstants.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error in markMessagesAsSeen: $e');
    }
  }

  /// Updates the typing indicator for a user in a chat
  ///
  /// Called when:
  /// - User starts typing (after a short debounce)
  /// - User stops typing (after inactivity timeout)
  /// - User sends a message (set to false)
  Future<void> updateTypingStatus(
    String chatRoomId,
    String userId,
    bool isTyping,
  ) async {
    await _chatsCollection.doc(chatRoomId).update({
      '${FirebaseConstants.typing}.$userId': isTyping,
    });
  }

  Future<void> addReaction(String messageId, String reaction) async {
    await _messagesCollection.doc(messageId).update({
      FirebaseConstants.reactions: FieldValue.arrayUnion([reaction]),
    });
  }

  Future<void> likeMessage(String messageId) async {
    await _messagesCollection.doc(messageId).update({
      FirebaseConstants.likeCount: FieldValue.increment(1),
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await _messagesCollection.doc(messageId).update({
      FirebaseConstants.isDeleted: true,
      FirebaseConstants.content: 'This message was deleted',
    });
  }
}
