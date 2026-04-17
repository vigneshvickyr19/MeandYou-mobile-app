import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import '../data_providers/notification_messages.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  static LocalNotificationService get instance => _instance;
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // Public getter for external services
  FlutterLocalNotificationsPlugin get plugin => _notifications;

  static const String dailyChannelId = 'daily_engagement_channel_v2';
  static const String dailyChannelName = 'Daily Engagement Alerts';
  
  static const String highImportanceChannelId = 'high_importance_channel_v2';
  static const String highImportanceChannelName = 'High Importance Notifications';

  // Constant IDs
  static const int morningNotificationId = 8301;
  static const int afternoonNotificationId = 14302;
  static const int eveningNotificationId = 20303;
  static const int testNotificationId = 9999;

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _isServiceInitialized = false;

  Future<void> initialize(GlobalKey<NavigatorState>? navigatorKey) async {
    if (navigatorKey != null) {
      _navigatorKey = navigatorKey;
    }

    if (_isServiceInitialized) return;
    
    debugPrint('🔔 [LocalNotification] Starting initialization...');

    // 1. STRICT Timezone Initialization
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      debugPrint('🔔 [LocalNotification] Timezone set to Asia/Kolkata: ${tz.TZDateTime.now(tz.local).toString()}');
    } catch (e) {
      debugPrint('🔔 [LocalNotification] TZ Init Error: $e');
    }

    // 2. Request Permissions (Android 13+ and Exact Alarms)
    await _requestPermissions();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings, 
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onNotificationTapped(response);
      },
    );

    if (!kIsWeb && Platform.isAndroid) {
      await _createChannels();
    }

    // Initial production scheduling
    await scheduleDailyNotifications();
    
    _isServiceInitialized = true;
    debugPrint('🔔 [LocalNotification] Service fully initialized');
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    if (Platform.isAndroid) {
      // 1. Notification Permission (Android 13+)
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
      
      // 2. Exact Alarm Permission (Android 12+)
      if (await Permission.scheduleExactAlarm.isDenied) {
        debugPrint('🔔 [LocalNotification] Requesting Exact Alarm permission...');
        await Permission.scheduleExactAlarm.request();
      }
    } else if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> _createChannels() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return;

      final dailyChannel = AndroidNotificationChannel(
        dailyChannelId,
        dailyChannelName,
        description: 'Daily engage prompts',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final highImportanceChannel = AndroidNotificationChannel(
        highImportanceChannelId,
        highImportanceChannelName,
        description: 'Real-time match alerts',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await androidPlugin.createNotificationChannel(dailyChannel);
      await androidPlugin.createNotificationChannel(highImportanceChannel);
    } catch (e) {
      debugPrint('🔔 [LocalNotification] Channel creation error: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 [LocalNotification] Notification Tapped. Payload: ${response.payload}');
    if (response.payload == null || response.payload!.isEmpty) return;
    
    try {
      final decoded = jsonDecode(response.payload!);
      if (decoded is Map) {
        final Map<String, dynamic> data = decoded.cast<String, dynamic>();
        if (data.containsKey('route')) {
          final String route = data['route'] as String;
          debugPrint('🔔 [LocalNotification] Navigating to: $route');
          _navigatorKey?.currentState?.pushNamed(route);
        }
      }
    } catch (e) {
      debugPrint('🔔 [LocalNotification] Tap handler error: $e');
    }
  }

  Future<void> scheduleDailyNotifications() async {
    try {
      debugPrint('🔔 [LocalNotification] Rescheduling all 3 daily slots...');
      
      final notificationPermission = await Permission.notification.status;
      final alarmPermission = await Permission.scheduleExactAlarm.status;
      
      debugPrint('🔔 [LocalNotification] Permissions - Notification: $notificationPermission, Alarm: $alarmPermission');

      // Cancel existing to prevent stacking
      await _notifications.cancel(morningNotificationId);
      await _notifications.cancel(afternoonNotificationId);
      await _notifications.cancel(eveningNotificationId);
      
      final tz.Location loc = tz.getLocation('Asia/Kolkata');
      final Random random = Random();

      await _scheduleZoned(morningNotificationId, 8, 30, NotificationPool.morningMessages, loc, random);
      await _scheduleZoned(afternoonNotificationId, 14, 30, NotificationPool.afternoonMessages, loc, random);
      await _scheduleZoned(eveningNotificationId, 20, 30, NotificationPool.eveningMessages, loc, random);
      
      debugPrint('🔔 [LocalNotification] Production daily scheduling complete.');
    } catch (e) {
      debugPrint('🔔 [LocalNotification] Scheduling error: $e');
    }
  }

  Future<void> showImmediateTestNotification() async {
    try {
      debugPrint('🔔 [LocalNotification] Triggering INSTANT test notification...');
      await _notifications.show(
        testNotificationId,
        'Instant Test 🔔',
        'Verification: If you see this, the notification service is alive!',
        _getDetails(highImportanceChannelId, highImportanceChannelName),
        payload: jsonEncode({'route': '/home'}),
      );
    } catch (e) {
      debugPrint('🔔 [LocalNotification] Instant trigger error: $e');
    }
  }

  Future<void> scheduleTestNotification(int secondsDelay) async {
    // Using UTC for the test button to ensure absolute platform-agnostic timing
    final scheduledDate = tz.TZDateTime.now(tz.UTC).add(Duration(seconds: secondsDelay));
    
    try {
      final notificationPermission = await Permission.notification.status;
      debugPrint('🔔 [LocalNotification] Status - Notification: $notificationPermission');
      
      debugPrint('🔔 [LocalNotification] Scheduling UTC test in $secondsDelay seconds');
      debugPrint('🔔 [LocalNotification] Current (UTC): ${tz.TZDateTime.now(tz.UTC).toString()}');
      debugPrint('🔔 [LocalNotification] Scheduled (UTC): ${scheduledDate.toString()}');

      await _notifications.zonedSchedule(
        testNotificationId,
        'Delayed Test Notification (V3) 🔔',
        'Triggered via UTC zonedSchedule ($secondsDelay seconds)',
        scheduledDate,
        _getDetails(highImportanceChannelId, highImportanceChannelName),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({'route': '/home'}),
      );
    } catch (e) {
      debugPrint('🔔 [LocalNotification] Test scheduling error: $e');
      // Fallback for devices with strict alarm restrictions
      await _notifications.zonedSchedule(
        testNotificationId,
        'Delayed Test Notification (Fallback) 🔔',
        'Triggered via Inexact fallback',
        scheduledDate,
        _getDetails(highImportanceChannelId, highImportanceChannelName),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({'route': '/home'}),
      );
    }
  }

  Future<void> cancelAll() async {
    debugPrint('🔔 [LocalNotification] Cancelling ALL notifications.');
    await _notifications.cancelAll();
  }

  Future<void> _scheduleZoned(int id, int hour, int minute, List<NotificationMessage> pool, tz.Location loc, Random rand) async {
    if (pool.isEmpty) return;
    
    final message = pool[rand.nextInt(pool.length)];
    final scheduledDate = _nextInstanceOfTime(hour, minute, loc);

    debugPrint('🔔 [LocalNotification] Slot ID: $id | Scheduled for: ${scheduledDate.toString()}');
    debugPrint('🔔 [LocalNotification] Content: ${message.title}');

    await _notifications.zonedSchedule(
      id,
      message.title,
      message.body,
      scheduledDate,
      _getDetails(dailyChannelId, dailyChannelName),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: jsonEncode({'route': message.route}),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, tz.Location loc) {
    final tz.TZDateTime nowAtLoc = tz.TZDateTime.now(loc);
    tz.TZDateTime targetAtLoc = tz.TZDateTime(loc, nowAtLoc.year, nowAtLoc.month, nowAtLoc.day, hour, minute);
    
    if (targetAtLoc.isBefore(nowAtLoc)) {
      targetAtLoc = targetAtLoc.add(const Duration(days: 1));
      debugPrint('🔔 [LocalNotification] Target passed for today, scheduled for TOMORROW.');
    }
    return targetAtLoc;
  }

  NotificationDetails _getDetails(String channelId, String name) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        name,
        channelDescription: 'Engagement Alerts',
        importance: Importance.max,
        priority: Priority.max,
        ticker: 'me_and_you_ticker',
        fullScreenIntent: true, // Often required for heads-up on MIUI
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> showSimpleNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      _getDetails(highImportanceChannelId, highImportanceChannelName),
      payload: payload,
    );
  }
}

