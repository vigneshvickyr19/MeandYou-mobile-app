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
import 'deep_link_service.dart';
import '../constants/call_constants.dart';
import '../constants/notification_constants.dart';
import '../constants/app_routes.dart';
import 'database_service.dart';
import 'notification_api_service.dart';
import '../models/user_model.dart';

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

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final DatabaseService _databaseService = DatabaseService();

  bool _initialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) {
      if (kDebugMode) {}
      return;
    }

    try {
      // Request notification permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Configure FCM
      await _configureFCM();

      // Listen to CallKit events
      _listenToCallEvents();

      // Get FCM token
      await _getToken();

      _initialized = true;
      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// Set the navigator key for navigation
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    // Also pass it to DeepLinkService to ensure it has the key
    DeepLinkService().initialize(key);
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
          _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // name
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
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
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationOpenedApp(message);
      }
    });

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      if (kDebugMode) {}
      _saveTokenToFirestore(newToken);
    });
  }

  /// Save FCM token to Firestore if user is logged in
  Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _databaseService.updateUserField(user.uid, {'fcmToken': token});
        if (kDebugMode) {}
      } catch (e) {
        if (kDebugMode) {}
      }
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

    // Check for call signal
    if (message.data[NotificationConstants.keyType] ==
        NotificationConstants.typeCallSignal) {
      final payload = CallSignalPayload.fromMap(message.data);
      handleCallSignal(payload);
      return;
    }

    // Check for call signal
    if (message.data['type'] == 'CALL_SIGNAL') {
      final payload = CallSignalPayload.fromMap(message.data);
      handleCallSignal(payload);
      return;
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

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {}

    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _navigateToScreen(data);
      } catch (e) {
        if (kDebugMode) {}
      }
    }
  }

  /// Show a test local notification
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      0,
      'Test Notification',
      'This is a local test notification to verify it works!',
      details,
    );
  }

  /// Handle Call Signal
  Future<void> handleCallSignal(CallSignalPayload payload) async {
    if (kDebugMode) {}
    try {
      switch (payload.action) {
        case CallAction.start:
          await _showIncomingCallUi(payload);
          break;
        case CallAction.end:
        case CallAction.decline:
        case CallAction.missed:
          await FlutterCallkitIncoming.endCall(payload.callId);
          await _checkAndHandleEndCallUI(
            payload,
          ); // Optional: close any active screens
          break;
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  Future<void> _checkAndHandleEndCallUI(CallSignalPayload payload) async {
    // Delegate to listener or DeepLinkService if needed, or broadcast event
  }

  /// Show Incoming Call UI using CallKit
  Future<void> _showIncomingCallUi(CallSignalPayload payload) async {
    final params = CallKitParams(
      id: payload.callId,
      nameCaller: payload.callerName,
      appName: 'Me And You',
      avatar: 'https://i.pravatar.cc/100', // Placeholder
      handle: payload.callerId,
      type: payload.callType == CallType.video ? 1 : 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{
        NotificationConstants.keyUserId: payload.callerId,
        NotificationConstants.keyCalleeId: payload.calleeId,
      },
      headers: <String, dynamic>{'ApiKey': 'Abc@123!', 'Platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification:
            true, // IMPORTANT: 'true' enables the full screen Activity behavior defined in Manifest
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

    if (kDebugMode) {
      print(
        'NotificationService: Showing CallKit UI with params: ${params.toJson()}',
      );
    }

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  /// Listen to CallKit events (Accept, Decline, etc.)
  void _listenToCallEvents() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;

      if (kDebugMode) {}

      switch (event.event) {
        case Event.actionCallAccept:
          if (kDebugMode) {
            // Navigation to call screen is needed here
          }
          _handleCallAccept(event);
          break;
        case Event.actionCallDecline:
          if (kDebugMode) await _handleCallDecline(event);
          break;
        case Event.actionCallEnded:
          if (kDebugMode) await _handleCallDecline(event, isEnd: true);
          break;
        case Event.actionCallTimeout:
          if (kDebugMode) await _handleCallDecline(event, isMissed: true);
          break;
        case Event.actionCallCallback:
          // Valid only for Android when app is killed/background
          if (kDebugMode) break;
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
        // Navigate to Call Screen via DeepLinkService logic
        _navigateToScreen({
          NotificationConstants.keyRoute: AppRoutes.call, // Use constant!
          NotificationConstants.keyRoomId:
              body['id'], // Corrected key to RoomId/ChatId
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

      // The callerId from the incoming call becomes the recipient of our 'Decline' signal
      final String? callerId =
          extra[NotificationConstants.keyUserId] as String?;
      final String? callId = body['id'] as String?;
      final String? myId =
          extra[NotificationConstants.keyCalleeId] as String? ??
          FirebaseAuth.instance.currentUser?.uid;

      if (callerId != null && callId != null && myId != null) {
        // Fetch caller to get their token
        final UserModel? caller = await _databaseService.getUserById(callerId);

        if (caller != null && caller.fcmToken != null) {
          String action = 'DECLINE';
          if (isEnd) action = 'END';
          if (isMissed) action = 'MISSED';

          await NotificationApiService.instance.sendCallSignal(
            deviceToken: caller.fcmToken!,
            callId: callId,
            callerId: myId, // I am declining
            callerName: 'User', // Could fetch my name
            calleeId: callerId, // Sending back to caller
            callType:
                'AUDIO', // Unknown from event, defaulting (or store in extra)
            action: action,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }
}
