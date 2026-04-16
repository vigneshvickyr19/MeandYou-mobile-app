import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'deep_link_service.dart';
import '../constants/call_constants.dart';
import '../constants/notification_constants.dart';
import '../constants/app_routes.dart';
import 'notification_api_service.dart';
import '../models/user_model.dart';
import 'database_service.dart';
import 'local_notification_service.dart';

/// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized in the background isolate
  try {
    // Check if Firebase is already initialized
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (e) {
      // Already initialized or platform doesn't support
    }

    if (kDebugMode) {}

    if (message.data[NotificationConstants.keyType] ==
        NotificationConstants.typeCallSignal) {
      final payload = CallSignalPayload.fromMap(message.data);
      if (kDebugMode) {}
      // Use the instance but don't call initialize() here as it might depend on UI context
      await NotificationService.instance.handleCallSignal(payload);
    }
  } catch (e) {
    if (kDebugMode) {}
  }
}

/// Service to manage Firebase Cloud Messaging and local notifications
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._();

  static const String _fcmTokenKey = 'last_fcm_token';

  // Lazy getter for FirebaseMessaging
  FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;

  final DatabaseService _databaseService = DatabaseService();

  bool _initialized = false;
  Future<void>? _initFuture;
  String? _fcmToken;
  RemoteMessage? _initialMessage;
  GlobalKey<NavigatorState>? _navigatorKey;

  // Tracks which FCM topics are actively subscribed to avoid redundant calls
  final Set<String> _subscribedTopics = {};

  String? get fcmToken => _fcmToken;
  RemoteMessage? get initialMessage => _initialMessage;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initFuture != null) return _initFuture;
    
    _initFuture = _performInitialization();
    return _initFuture;
  }

  Future<void> _performInitialization() async {
    if (_initialized) return;

    try {
      debugPrint('NotificationService: Starting initialization');
      
      // 0. Ensure Firebase is ready
      int attempts = 0;
      while (Firebase.apps.isEmpty && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (Firebase.apps.isEmpty) {
        debugPrint('NotificationService: Firebase not initialized after waiting');
        return;
      }

      // 1. Core setup - delegate local logic to the optimized specific service
      await LocalNotificationService().initialize(_navigatorKey);

      await _requestPermissions();

      // 2. Configure listeners and FETCH initial message
      await _configureFCM();
      
      if (!kIsWeb) _listenToCallEvents();

      _initialized = true;
      debugPrint('NotificationService: Initialization complete');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  /// Set the navigator key for navigation
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    // Also pass it to other services
    DeepLinkService().initialize(key);
    LocalNotificationService().initialize(key);

    // Check if we have an initial message to process
    if (_initialMessage != null) {
      debugPrint('NotificationService: Processing initial message after navigator set');
      _handleNotificationOpenedApp(_initialMessage!);
      _initialMessage = null;
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (kIsWeb) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Request iOS permissions
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Request Android 13+ notification permission
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          LocalNotificationService().plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  /// Initialize local notifications plugin (Legacy FCM handling)
  /// Note: Most local logic is now moved to LocalNotificationService
  Future<void> _initializeLocalNotifications() async {
    // This is already being handled by LocalNotificationService().initialize()
    // It remains here only if we need FCM-specific initialization that differs.
  }

  /// Configure Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    // Set foreground notification presentation options for iOS
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification opened app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);

    // Handle notification that opened app from terminated state
    try {
      final message = await _firebaseMessaging.getInitialMessage();
      if (message != null) {
        debugPrint('NotificationService: Found initial message from terminated state');
        // If navigator is already set, handle it now, otherwise store for later
        if (_navigatorKey?.currentState != null) {
          _handleNotificationOpenedApp(message);
        } else {
          _initialMessage = message;
        }
      }
    } catch (e) {
      debugPrint('NotificationService: Error getting initial message: $e');
    }

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      if (kDebugMode) {
        print('NotificationService: Token refreshed: $newToken');
      }
      _saveTokenToFirestore(newToken);
      
      // Re-subscribe to topics if user is logged in
      if (FirebaseAuth.instance.currentUser != null) {
        subscribeToGlobalTopic();
      }
    });
  }

  /// Save FCM token to Firestore if user is logged in
  Future<void> _saveTokenToFirestore(String token) async {
    // If we're already checking, don't double save
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Optimization: Only update if the token has changed since last save
        final prefs = await SharedPreferences.getInstance();
        final lastToken = prefs.getString(_fcmTokenKey);
        
        if (lastToken == token) {
          debugPrint("NotificationService: Token is unchanged, skipping Firestore update.");
          return;
        }

        await _databaseService.updateUserField(user.uid, {'fcmToken': token});
        
        // Cache the token locally after successful update
        await prefs.setString(_fcmTokenKey, token);
        debugPrint("NotificationService: FCM Token saved and cached for user: ${user.uid}");
      } catch (e) {
        debugPrint("NotificationService: Error saving FCM token: $e");
      }
    } else {
      debugPrint("NotificationService: Skip saving token, user not logged in yet.");
    }
  }

  /// Triggered after user log in to sync token immediately
  Future<void> syncTokenNow() async {
    if (_fcmToken != null) {
      await _saveTokenToFirestore(_fcmToken!);
    } else {
      await _getToken();
    }
  }

  /// Get FCM token
  Future<void> _getToken() async {
    try {
      if (kIsWeb) {
        _fcmToken = await _firebaseMessaging.getToken(
          vapidKey: 'REPLACE_WITH_YOUR_VAPID_KEY',
        );
      } else {
        _fcmToken = await _firebaseMessaging.getToken();
      }
      if (kDebugMode) {}
      if (_fcmToken != null) {
        await _saveTokenToFirestore(_fcmToken!);
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// Get VoIP token for iOS (required for CallKit)
  Future<String?> getVoIPToken() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      final token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
      if (token != null) {
        // Optionally save VoIP token
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _databaseService.updateUserField(user.uid, {'voipToken': token});
        }
      }
      return token;
    }
    return null;
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {}

    // Handle call signal with robustness
    final dynamic type = message.data[NotificationConstants.keyType] ?? message.data['type'];
    if (type == NotificationConstants.typeCallSignal || type == 'CALL_SIGNAL') {
      try {
        final Map<String, dynamic> data = message.data.cast<String, dynamic>();
        final payload = CallSignalPayload.fromMap(data);
        handleCallSignal(payload);
        return;
      } catch (e) {
        debugPrint('NotificationService: Call signal parsing error: $e');
      }
    }
    
    // Show local notification when app is in foreground
    _showLocalNotification(message);
  }

  /// Handle notification opened app
  void _handleNotificationOpenedApp(RemoteMessage message) {
    if (kDebugMode) {}

    _navigateToScreen(message.data);
  }

  /// Helper to navigate based on data
  void _navigateToScreen(Map<String, dynamic> data) {
    if (kDebugMode) {}
    DeepLinkService().handleNotificationPayload(data);
  }

  /// Show local notification (Delegated for performance)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await LocalNotificationService().showSimpleNotification(
      id: notification.hashCode,
      title: notification.title ?? '',
      body: notification.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap (Legacy handler, still needed for FCM payloads)
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final decoded = jsonDecode(response.payload!);
        if (decoded is Map) {
          final Map<String, dynamic> data = decoded.cast<String, dynamic>();
          
          // Handle local notification deep link
          if (data.containsKey('route')) {
             final String route = data['route'] as String;
             _navigatorKey?.currentState?.pushNamed(route);
             return;
          }

          _navigateToScreen(data);
        }
      } catch (e) {
        debugPrint('NotificationService: Tap handling error: $e');
      }
    }
  }

  // TOPIC SUBSCRIPTION MANAGEMENT
  /// Show a test local notification
  Future<void> showTestNotification() async {
    await LocalNotificationService().showSimpleNotification(
      id: 0,
      title: 'Test Notification',
      body: 'This is a local test notification to verify it works!',
    );
  }

  /// Handle Call Signal
  Future<void> handleCallSignal(CallSignalPayload payload) async {
    if (kDebugMode) {
      debugPrint('NotificationService: Handling call signal: ${payload.action}');
    }
    try {
      switch (payload.action) {
        case CallAction.start:
          await _showIncomingCallUi(payload);
          break;
        case CallAction.end:
        case CallAction.decline:
        case CallAction.missed:
          await FlutterCallkitIncoming.endCall(payload.callId);
          await _checkAndHandleEndCallUI(payload);
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService: Error handling call signal: $e');
      }
    }
  }

  Future<void> _checkAndHandleEndCallUI(CallSignalPayload payload) async {
    // Logic to handle UI cleanup on call end if needed
  }

  /// Show Incoming Call UI using CallKit
  Future<void> _showIncomingCallUi(CallSignalPayload payload) async {
    final params = CallKitParams(
      id: payload.callId,
      nameCaller: payload.callerName,
      appName: 'Me And You',
      avatar: 'https://i.pravatar.cc/100',
      handle: payload.callerId,
      type: payload.callType == CallType.video ? 1 : 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{
        NotificationConstants.keyUserId: payload.callerId,
        NotificationConstants.keyCalleeId: payload.calleeId,
      },
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundUrl: 'https://i.pravatar.cc/500',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
        isShowFullLockedScreen: true,
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  /// Listen to CallKit events (Accept, Decline, etc.)
  void _listenToCallEvents() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;

      switch (event.event) {
        case Event.actionCallAccept:
          _handleCallAccept(event);
          break;
        case Event.actionCallDecline:
          await _handleCallDecline(event);
          break;
        case Event.actionCallEnded:
          await _handleCallDecline(event, isEnd: true);
          break;
        case Event.actionCallTimeout:
          await _handleCallDecline(event, isMissed: true);
          break;
        default:
          break;
      }
    });
  }

  void _handleCallAccept(CallEvent event) {
    final body = event.body as Map<dynamic, dynamic>?;
    if (body != null) {
      final extra = body['extra'] as Map<dynamic, dynamic>?;
      if (extra != null) {
        _navigateToScreen({
          NotificationConstants.keyRoute: AppRoutes.call,
          NotificationConstants.keyRoomId: body['id'],
          ...extra.cast<String, dynamic>(),
        });
      }
    }
  }

  /// Handle Call Decline/End signal to backend
  Future<void> _handleCallDecline(
    CallEvent event, {
    bool isEnd = false,
    bool isMissed = false,
  }) async {
    try {
      final body = event.body as Map<dynamic, dynamic>?;
      if (body == null) return;

      final extra = body['extra'] as Map<dynamic, dynamic>?;
      if (extra == null) return;

      final String? callerId = extra[NotificationConstants.keyUserId] as String?;
      final String? callId = body['id'] as String?;
      final String? myId = extra[NotificationConstants.keyCalleeId] as String? ??
          FirebaseAuth.instance.currentUser?.uid;

      if (callerId != null && callId != null && myId != null) {
        final UserModel? caller = await _databaseService.getUserById(callerId);

        if (caller != null && caller.fcmToken != null) {
          String action = 'DECLINE';
          if (isEnd) action = 'END';
          if (isMissed) action = 'MISSED';

          await NotificationApiService.instance.sendCallSignal(
            deviceToken: caller.fcmToken!,
            callId: callId,
            callerId: myId,
            callerName: 'User',
            calleeId: callerId,
            callType: 'AUDIO',
            action: action,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService: Error declining call: $e');
      }
    }
  }

  // -----------------------------------------------------------------------------
  // TOPIC SUBSCRIPTION MANAGEMENT
  /// Subscribe to a specific topic — no-op if already subscribed this session
  Future<void> subscribeToTopic(String topic) async {
    if (_subscribedTopics.contains(topic)) return;

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _subscribedTopics.add(topic);
      if (kDebugMode) {
        print('NotificationService: Subscribed to topic: $topic');
      }
    } catch (e) {
      debugPrint('NotificationService: Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a specific topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _subscribedTopics.remove(topic);
      if (kDebugMode) {
        print('NotificationService: Unsubscribed from topic: $topic');
      }
    } catch (e) {
      debugPrint('NotificationService: Error unsubscribing from topic $topic: $e');
    }
  }

  /// Subscribe to the global "all_users" topic
  Future<void> subscribeToGlobalTopic() async {
    await subscribeToTopic(NotificationConstants.topicAllUsers);
  }

  /// Unsubscribe from the global "all_users" topic
  Future<void> unsubscribeFromGlobalTopic() async {
    await unsubscribeFromTopic(NotificationConstants.topicAllUsers);
  }

  /// Subscribe to gender-based topics
  Future<void> subscribeToGenderTopic(String gender) async {
    final normalizedGender = gender.toLowerCase();
    if (normalizedGender == 'male') {
      await subscribeToTopic(NotificationConstants.topicMale);
    } else if (normalizedGender == 'female') {
      await subscribeToTopic(NotificationConstants.topicFemale);
    }
  }

  /// Unsubscribe from gender-based topics
  Future<void> unsubscribeFromGenderTopic(String gender) async {
    final normalizedGender = gender.toLowerCase();
    if (normalizedGender == 'male') {
      await unsubscribeFromTopic(NotificationConstants.topicMale);
    } else if (normalizedGender == 'female') {
      await unsubscribeFromTopic(NotificationConstants.topicFemale);
    }
  }

  /// Clears the local subscription state cache — call on logout so the
  /// next user session re-subscribes correctly.
  void clearSubscriptionState() async {
    _subscribedTopics.clear();
    
    // Also clear the cached token so the next user session performs a fresh sync
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fcmTokenKey);
  }
}
