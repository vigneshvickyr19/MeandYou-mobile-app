import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    
    if (kDebugMode) {
      print('NotificationService: Handling background message: ${message.messageId}');
      print('NotificationService: Data: ${message.data}');
    }

    if (message.data['type'] == 'CALL_SIGNAL') {
      final payload = CallSignalPayload.fromMap(message.data);
      if (kDebugMode) {
        print('NotificationService: Processing Call Signal Action: ${payload.action}');
      }
      // Use the instance but don't call initialize() here as it might depend on UI context
      await NotificationService.instance.handleCallSignal(payload);
    }
  } catch (e) {
    if (kDebugMode) {
      print('NotificationService: Error in background handler: $e');
    }
  }
}

/// Service to manage Firebase Cloud Messaging and local notifications
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _fcmToken;
  
  String? get fcmToken => _fcmToken;

  GlobalKey<NavigatorState>? _navigatorKey;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) {
      if (kDebugMode) {
        print('Notification service already initialized');
      }
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
      if (kDebugMode) {
        print('Notification service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notification service: $e');
      }
      rethrow;
    }
  }

  /// Set the navigator key for navigation
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (kIsWeb) {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (kDebugMode) {
        print('Web notification permission status: ${settings.authorizationStatus}');
      }
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Request iOS permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('iOS notification permission status: ${settings.authorizationStatus}');
      }
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Request Android 13+ notification permission
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        if (kDebugMode) {
          print('Android notification permission granted: $granted');
        }
      }
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
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
              AndroidFlutterLocalNotificationsPlugin>()
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
      if (kDebugMode) {
        print('FCM Token refreshed: $newToken');
      }
      // TODO: Send token to your backend server
    });
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
      if (kDebugMode) {
        print('FCM Token: $_fcmToken');
      }
      // TODO: Send token to your backend server
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
    }
  }

  /// Get VoIP token for iOS (required for CallKit)
  Future<String?> getVoIPToken() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return await FlutterCallkitIncoming.getDevicePushTokenVoIP();
    }
    return null;
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
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
    if (kDebugMode) {
      print('Notification opened app: ${message.messageId}');
      print('Data: ${message.data}');
    }

    _navigateToScreen(message.data);
  }

  /// Helper to navigate based on data
  void _navigateToScreen(Map<String, dynamic> data) {
    if (_navigatorKey == null) {
      if (kDebugMode) {
        print('Navigator key is null, cannot navigate');
      }
      return;
    }

    final String? route = data['route'];
    final String? link = data['link'];

    if (kDebugMode) {
      print('NotificationService: Extracted route: $route, link: $link');
    }

    if (link != null) {
      if (kDebugMode) {
        print('NotificationService: Processing link: $link');
      }
      DeepLinkService().handleLink(link);
      return;
    }

    if (route != null) {
      if (kDebugMode) {
        print('NotificationService: Navigating to route: $route');
      }

      if (_navigatorKey!.currentState == null) {
        if (kDebugMode) {
          print('NotificationService: Navigator state is NULL even though key is set');
        }
        return;
      }

      _navigatorKey!.currentState?.pushNamedAndRemoveUntil(
        route,
        (r) => false,
        arguments: data,
      );
    } else {
      if (kDebugMode) {
        print('NotificationService: Both route and link are null in data');
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
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
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }

    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _navigateToScreen(data);
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing notification payload: $e');
        }
      }
    }
  }

  /// Show a test local notification
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
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
    if (kDebugMode) {
      print('NotificationService: handleCallSignal with action: ${payload.action}');
    }
    try {
      switch (payload.action) {
        case CallAction.START:
          await _showIncomingCallUi(payload);
          break;
        case CallAction.END:
        case CallAction.DECLINE:
        case CallAction.MISSED:
          await FlutterCallkitIncoming.endCall(payload.callId);
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('NotificationService: Error handling call signal: $e');
      }
    }
  }

  /// Show Incoming Call UI using CallKit
  Future<void> _showIncomingCallUi(CallSignalPayload payload) async {
    final params = CallKitParams(
      id: payload.callId,
      nameCaller: payload.callerName,
      appName: 'Me And You',
      avatar: 'https://i.pravatar.cc/100', // Placeholder
      handle: payload.callerId,
      type: payload.callType == CallType.VIDEO ? 1 : 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{'userId': payload.callerId},
      headers: <String, dynamic>{'ApiKey': 'Abc@123!', 'Platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: false, // Changed to false for better stability
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#09121C',
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
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsGrouping: false,
        supportsUngrouping: false,
        supportsDTMF: true,
        supportsHolding: true,
      ),
    );

    if (kDebugMode) {
      print('NotificationService: Showing CallKit UI with params: ${params.toJson()}');
    }

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  /// Listen to CallKit events (Accept, Decline, etc.)
  void _listenToCallEvents() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) return;

      switch (event.event) {
        case Event.actionCallAccept:
          if (kDebugMode) print('Call Accepted: ${event.body}');
          // TODO: Navigate to call screen
          break;
        case Event.actionCallDecline:
          if (kDebugMode) print('Call Declined: ${event.body}');
          // TODO: Send decline signal via backend
          break;
        case Event.actionCallEnded:
          if (kDebugMode) print('Call Ended: ${event.body}');
          break;
        case Event.actionCallTimeout:
          if (kDebugMode) print('Call Timeout: ${event.body}');
          break;
        default:
          break;
      }
    });
  }
}
