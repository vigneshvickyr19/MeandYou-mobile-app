import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/message_model.dart';
import '../../data/models/chat_room_model.dart';
import '../../../../data/repositories/chat_repository.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/notification_api_service.dart';
import '../../../../core/services/notification_payload_builder.dart';
import '../../../notifications/data/services/notification_storage_service.dart';
import '../../../notifications/data/models/notification_model.dart';
import 'package:uuid/uuid.dart';

class ChatDetailController extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final DatabaseService _databaseService = DatabaseService();
  final NotificationApiService _notificationApiService = NotificationApiService.instance;
  final NotificationStorageService _notificationStorageService = NotificationStorageService();

  bool _isRecording = false;

  List<MessageModel> _messages = [];
  final List<MessageModel> _optimisticMessages = [];
  List<MessageModel> _cachedCombinedMessages = [];
  bool _needsRebuildCache = true;
  bool _isLoading = false;
  bool _messagesLoaded = false;
  bool _isTyping = false;
  bool _isOtherUserTyping = false;
  String _chatRoomId = '';
  ChatRoomModel? _chatRoom;
  String _currentUserId = '';
  String _otherUserId = '';
  List<XFile> _selectedImages = [];
  StreamSubscription? _typingSubscription;

  List<MessageModel> get messages {
    if (_needsRebuildCache) {
      // Combine regular messages with optimistic ones, avoiding duplicates by ID
      final combined = List<MessageModel>.from(_optimisticMessages);
      for (var msg in _messages) {
        if (!_optimisticMessages.any((opt) => opt.id == msg.id)) {
          combined.add(msg);
        }
      }
      // Sort by timestamp descending
      combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _cachedCombinedMessages = combined;
      _needsRebuildCache = false;
    }
    return _cachedCombinedMessages;
  }

  bool get isLoading => _isLoading && !_messagesLoaded;
  bool get isRecording => _isRecording;
  bool get isTyping => _isTyping;
  bool get isOtherUserTyping => _isOtherUserTyping;
  List<XFile> get selectedImages => _selectedImages;
  ChatRoomModel? get chatRoom => _chatRoom;

  void initialize(String chatRoomId, String currentUserId, String otherUserId) {
    _chatRoomId = chatRoomId;
    _currentUserId = currentUserId;
    _otherUserId = otherUserId;

    // Set loading to true initially if no messages
    if (!_messagesLoaded) {
      _isLoading = true;
      notifyListeners();
    }

    loadMessages();
    markMessagesAsSeen(); // Initial clear
    _listenToChatRoom();
  }

  StreamSubscription? _chatRoomSubscription;
  bool _isMarkingAsSeen = false;

  void _listenToChatRoom() {
    _chatRoomSubscription?.cancel();
    _chatRoomSubscription = _chatRepository.streamChatRoom(_chatRoomId).listen((
      chatRoom,
    ) {
      if (chatRoom != null) {
        _chatRoom = chatRoom;

        // Handle unread count - if we are in this room and there are unread messages for us, clear them
        final unreadForMe = chatRoom.getUnreadCount(_currentUserId);
        if (unreadForMe > 0 && !_isMarkingAsSeen) {
          markMessagesAsSeen();
        }

        // Handle typing status
        final typingStatus = chatRoom.isUserTyping(_otherUserId);
        if (_isOtherUserTyping != typingStatus) {
          _isOtherUserTyping = typingStatus;
          notifyListeners();
        }
      }
    });
  }

  void loadMessages() {
    _chatRepository
        .getMessages(_chatRoomId)
        .listen(
          (messages) {
            _messages = messages;
            _isLoading = false;
            _messagesLoaded = true;
            _needsRebuildCache = true;

            // Clean up optimistic messages that are now confirmed
            _optimisticMessages.removeWhere(
              (opt) => messages.any(
                (MessageModel msg) =>
                    msg.content == opt.content &&
                    msg.senderId == opt.senderId &&
                    (msg.timestamp.difference(opt.timestamp).inSeconds.abs() <
                        5),
              ),
            );

            if (hasListeners) {
              notifyListeners();
            }

            // Mark any new messages as seen
            markMessagesAsSeen();
          },
          onError: (error) {
            debugPrint('Error loading messages: $error');
            _isLoading = false;
            _messagesLoaded = true; // Mark as loaded to stop showing spinner
            if (hasListeners) {
              notifyListeners();
            }
          },
        );
  }

  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        _isRecording = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      notifyListeners();
      return path;
    } catch (e) {
      debugPrint("Error stopping recording: $e");
      _isRecording = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> cancelRecording() async {
      try {
        await _audioRecorder.stop();
      } catch (e) {
        // ignore
      }
      _isRecording = false;
      notifyListeners();
  }

  Future<void> sendVoiceMessage(String path, Duration duration) async {
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final ref = FirebaseStorage.instance.ref().child('chat_audio').child(fileName);
    
    try {
      final uploadTask = ref.putFile(File(path));
      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();
      
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final message = MessageModel(
        id: tempId,
        chatRoomId: _chatRoomId,
        senderId: _currentUserId,
        receiverId: _otherUserId,
        content: '',
        type: MessageType.audio,
        timestamp: DateTime.now(),
        audioUrl: downloadUrl,
        duration: _formatDuration(duration),
      );
      
      await _chatRepository.sendMessage(message);

      // Send notification for voice message
      await _sendChatNotification(
        messageType: 'voice',
        messagePreview: '',
      );
    } catch (e) {
      debugPrint("Error sending voice message: $e");
      rethrow;
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty && _selectedImages.isEmpty) return;

    final imagesToSend = _selectedImages.take(10).toList();

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final message = MessageModel(
      id: tempId,
      chatRoomId: _chatRoomId,
      senderId: _currentUserId,
      receiverId: _otherUserId,
      content: content.trim(),
      type: imagesToSend.isNotEmpty ? MessageType.image : MessageType.text,
      timestamp: DateTime.now(),
      imageUrl: imagesToSend.isNotEmpty ? imagesToSend.first.path : null,
      imageUrls: imagesToSend.map((img) => img.path).toList(),
    );

    _optimisticMessages.insert(0, message);
    _needsRebuildCache = true;
    _selectedImages = [];
    notifyListeners();

    try {
      await _chatRepository.sendMessage(message);

      // Send notification with proper message type
      String messageType;
      String messagePreview;
      int? imageCount;

      if (imagesToSend.isNotEmpty) {
        messageType = 'image';
        messagePreview = '';
        imageCount = imagesToSend.length;
      } else {
        messageType = 'text';
        messagePreview = content.trim();
      }

      await _sendChatNotification(
        messageType: messageType,
        messagePreview: messagePreview,
        imageCount: imageCount,
      );
    } catch (e) {
      _optimisticMessages.removeWhere((m) => m.id == tempId);
      _needsRebuildCache = true;
      notifyListeners();
      rethrow;
    }
  }

  /// Send chat notification using payload builder
  Future<void> _sendChatNotification({
    required String messageType,
    required String messagePreview,
    int? imageCount,
  }) async {
    try {
      final otherUser = await _databaseService.getUserById(_otherUserId);
      if (otherUser == null || otherUser.fcmToken == null) {
        debugPrint('Cannot send notification: User offline or no token');
        return;
      }

      // Fetch current user to get their name
      final currentUser = await _databaseService.getUserById(_currentUserId);
      final senderName = currentUser?.fullName ?? 'Someone';

      // Build notification payload using the builder
      final payload = NotificationPayloadBuilder.buildChatNotification(
        chatId: _chatRoomId,
        senderId: _currentUserId,
        senderName: senderName,
        senderPhotoUrl: currentUser?.profileImageUrl,
        messagePreview: messagePreview,
        messageType: messageType,
        imageCount: imageCount,
      );

      // Validate payload
      if (!NotificationPayloadBuilder.validatePayload(payload)) {
        debugPrint('Invalid notification payload');
        return;
      }

      // Extract title and body
      final titleBody = NotificationPayloadBuilder.extractTitleAndBody(payload);

      // Send notification
      await _notificationApiService.sendNotification(
        deviceToken: otherUser.fcmToken!,
        title: titleBody['title']!,
        body: titleBody['body']!,
        data: payload,
      );

      // Store notification in Firestore for history
      await _notificationStorageService.sendNotification(
        receiverId: _otherUserId,
        senderId: _currentUserId,
        senderName: senderName,
        senderPhotoUrl: currentUser?.profileImageUrl,
        type: NotificationType.message,
        title: titleBody['title']!,
        message: titleBody['body']!,
        metadata: {
          'chatId': _chatRoomId,
          ...payload,
        },
      );

      debugPrint('Chat notification sent and stored successfully');
    } catch (e) {
      debugPrint('Error sending/storing chat notification: $e');
      // Don't rethrow - notification failure shouldn't break message sending
    }
  }

  Future<void> initiateCall(String callType) async {
    try {
      final otherUser = await _databaseService.getUserById(_otherUserId);
      
      if (otherUser != null && otherUser.fcmToken != null) {
        final currentUser = await _databaseService.getUserById(_currentUserId);
        final senderName = currentUser?.fullName ?? 'User';
        final callId =const Uuid().v4();

        await _notificationApiService.sendCallSignal(
          deviceToken: otherUser.fcmToken!,
          callId: callId,
          callerId: _currentUserId,
          callerName: senderName,
          calleeId: _otherUserId,
          callType: callType,
          action: 'START',
        );
        debugPrint("Call signal sent successfully");
        // TODO: Navigate to outgoing call UI
      } else {
        debugPrint("Cannot call: User offline or no token");
      }
    } catch (e) {
      debugPrint("Error initiating call: $e");
    }
  }

  Future<void> pickImagesFromGallery() async {
    final images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      _selectedImages.addAll(images);
      notifyListeners();
    }
  }

  Future<void> pickImageFromCamera() async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _selectedImages.add(image);
      notifyListeners();
    }
  }

  void addImage(XFile image) {
    _selectedImages.add(image);
    notifyListeners();
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  void clearSelectedImages() {
    _selectedImages = [];
    notifyListeners();
  }

  Future<void> markMessagesAsSeen() async {
    if (_isMarkingAsSeen) return;

    _isMarkingAsSeen = true;
    try {
      await _chatRepository.markMessagesAsSeen(_chatRoomId, _currentUserId);
    } finally {
      _isMarkingAsSeen = false;
    }
  }

  Future<void> updateTypingStatus(bool isTyping) async {
    if (_isTyping != isTyping) {
      _isTyping = isTyping;
      await _chatRepository.updateTypingStatus(
        _chatRoomId,
        _currentUserId,
        isTyping,
      );
      notifyListeners();
    }
  }

  Future<void> likeMessage(String messageId) async {
    await _chatRepository.likeMessage(messageId);
  }

  Future<void> addReaction(String messageId, String reaction) async {
    await _chatRepository.addReaction(messageId, reaction);
    
    // Send notification for reaction
    await _sendChatNotification(
      messageType: 'reaction',
      messagePreview: '',
    );
  }

  String getDateLabel(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  bool shouldShowDateLabel(int index) {
    final currentMessages = messages;
    if (index == currentMessages.length - 1) return true;

    final currentDate = currentMessages[index].timestamp;
    final nextDate = currentMessages[index + 1].timestamp;

    return currentDate.day != nextDate.day ||
        currentDate.month != nextDate.month ||
        currentDate.year != nextDate.year;
  }

  @override
  void dispose() {
    _chatRoomSubscription?.cancel();
    _typingSubscription?.cancel();
    if (_chatRoomId.isNotEmpty && _currentUserId.isNotEmpty) {
      updateTypingStatus(false);
    }
    super.dispose();
  }
}
