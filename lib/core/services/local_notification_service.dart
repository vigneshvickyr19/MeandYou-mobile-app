import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import '../data_providers/notification_messages.dart';
import 'deep_link_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('🔔 [LocalNotification] Background tap payload: ${notificationResponse.payload}');
  // Background taps typically launch the app, and the plugin queues the initial payload
  // which is then passed to onDidReceiveNotificationResponse when the main isolate initializes.
  // This entry point is mandatory for background button actions on Android/iOS.
}

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  static LocalNotificationService get instance => _instance;
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  FlutterLocalNotificationsPlugin get plugin => _notifications;

  static const String dailyChannelId = 'daily_engagement_channel_v4';
  static const String dailyChannelName = 'Daily Engagement Alerts';
  
  static const String highImportanceChannelId = 'high_importance_channel_v4';
  static const String highImportanceChannelName = 'High Importance Notifications';

  // Constant IDs
  static const int morningNotificationId = 8301;
  static const int afternoonNotificationId = 14302;
  static const int eveningNotificationId = 20303;
  static const int testNotificationId = 9999;
  static const int repeatingTestId = 9998;

  bool _isServiceInitialized = false;

  Future<void> initialize(GlobalKey<NavigatorState>? navigatorKey) async {
    if (_isServiceInitialized) {
      debugPrint('🔔 [LocalNotification] Service already initialized.');
      return;
    }
    
    debugPrint('🔔 [LocalNotification] Starting initialization...');

    // 1. Initialize Timezones Dynamically
    await _initializeTimezone();

    // 2. Request Permissions
    await _requestPermissions();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We request manually natively or below
      requestBadgePermission: false,
      requestSoundPermission: false,
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
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (!kIsWeb && Platform.isAndroid) {
      await _createChannels();
    }

    // Initial production scheduling
    await scheduleDailyNotifications();
    
    _isServiceInitialized = true;
    debugPrint('🔔 [LocalNotification] Service fully initialized');
  }

  Future<void> _initializeTimezone() async {
    try {
      tz_data.initializeTimeZones();
      final timezone = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezone.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('🔔 [LocalNotification] Timezone dynamically set to $timeZoneName: ${tz.TZDateTime.now(tz.local).toString()}');
    } catch (e) {
      debugPrint('🔔 [LocalNotification] TZ Init Error: $e');
      // Fallback
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    if (Platform.isAndroid) {
      // 1. Notification Permission (Android 13+)
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
      
      // 2. Ignore Battery Optimizations (Allows bypassed Doze mode restrictions)
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        debugPrint('🔔 [LocalNotification] Requesting Battery Optimization bypass...');
        await Permission.ignoreBatteryOptimizations.request();
      }

      // 3. Exact Alarm Permission (Android 12+) using plugin capability check
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          
      if (androidPlugin != null) {
        final bool canSchedule = await androidPlugin.canScheduleExactNotifications() ?? false;
        if (!canSchedule) {
          debugPrint('🔔 [LocalNotification] Requesting Exact Alarm permission via plugin...');
          await androidPlugin.requestExactAlarmsPermission();
        }
      } else {
        if (await Permission.scheduleExactAlarm.isDenied) {
          debugPrint('🔔 [LocalNotification] Requesting Exact Alarm permission via permission_handler...');
          await Permission.scheduleExactAlarm.request();
        }
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    }
  }

  Future<void> _createChannels() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return;

      final dailyChannel = AndroidNotificationChannel(
        dailyChannelId,
        dailyChannelName,
        description: 'Persistent daily engage prompts',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final highImportanceChannel = AndroidNotificationChannel(
        highImportanceChannelId,
        highImportanceChannelName,
        description: 'Real-time and test match alerts',
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
        debugPrint('🔔 [LocalNotification] Handing payload to DeepLinkService: $data');
        DeepLinkService().handleNotificationPayload(data);
      }
    } catch (e) {
      debugPrint('🔔 [LocalNotification] Tap handler error: $e');
    }
  }

  Future<void> scheduleDailyNotifications() async {
    try {
      debugPrint('🔔 [LocalNotification] Rescheduling all 3 daily slots...');
      
      // Cancel existing to prevent duplicate stacking
      await _notifications.cancel(morningNotificationId);
      await _notifications.cancel(afternoonNotificationId);
      await _notifications.cancel(eveningNotificationId);
      
      final tz.Location loc = tz.local;
      final Random random = Random();

      await _scheduleZonedDaily(morningNotificationId, 8, 30, NotificationPool.morningMessages, loc, random);
      await _scheduleZonedDaily(afternoonNotificationId, 14, 30, NotificationPool.afternoonMessages, loc, random);
      await _scheduleZonedDaily(eveningNotificationId, 20, 30, NotificationPool.eveningMessages, loc, random);
      
      debugPrint('🔔 [LocalNotification] Production daily scheduling complete.');
    } catch (e) {
      debugPrint('🔔 [LocalNotification] Scheduling daily error: $e');
    }
  }

  Future<void> _scheduleZonedDaily(int id, int hour, int minute, List<NotificationMessage> pool, tz.Location loc, Random rand) async {
    if (pool.isEmpty) return;
    
    final message = pool[rand.nextInt(pool.length)];
    final scheduledDate = _nextInstanceOfTime(hour, minute, loc);

    debugPrint('🔔 [LocalNotification] Slot ID: $id | Scheduled for: ${scheduledDate.toString()} | Content: ${message.title}');

    // We attempt exact scheduling. If the OS strictly prohibits exactly timed alarms without permission,
    // we degrade to inexact instead of failing completely, ensuring some level of delivery.
    try {
      await _notifications.zonedSchedule(
        id,
        message.title,
        message.body,
        scheduledDate,
        _getDetails(dailyChannelId, dailyChannelName),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: jsonEncode({'route': message.route}),
      );
    } catch (e) {
      debugPrint('🔔 [LocalNotification] Daily exact scheduling error: $e. Falling back to inexact.');
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
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, tz.Location loc) {
    final tz.TZDateTime nowAtLoc = tz.TZDateTime.now(loc);
    tz.TZDateTime targetAtLoc = tz.TZDateTime(loc, nowAtLoc.year, nowAtLoc.month, nowAtLoc.day, hour, minute);
    
    // If the precise time has already passed today, schedule for the same time on the NEXT DAY.
    if (targetAtLoc.isBefore(nowAtLoc)) {
      targetAtLoc = targetAtLoc.add(const Duration(days: 1));
      debugPrint('🔔 [LocalNotification] Target passed for today. Scheduling for NEXT DAY: ${targetAtLoc.toString()}');
    }
    return targetAtLoc;
  }

  Future<void> scheduleTestNotification(int secondsDelay) async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: secondsDelay));
    
    try {
      debugPrint('🔔 [LocalNotification] Scheduling ONE-OFF test in $secondsDelay second(s) at ${scheduledDate.toString()}');

      await _notifications.zonedSchedule(
        testNotificationId,
        'One-off Test 🔔',
        'Triggered successfully after $secondsDelay second(s)',
        scheduledDate,
        _getDetails(highImportanceChannelId, highImportanceChannelName),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({'route': '/home'}),
      );
    } catch (e) {
      debugPrint('🔔 [LocalNotification] Test scheduling EXACT error: $e. Falling back to inexact.');
      await _notifications.zonedSchedule(
        testNotificationId,
        'One-off Test (Fallback) 🔔',
        'Triggered via Inexact fallback after $secondsDelay second(s)',
        scheduledDate,
        _getDetails(highImportanceChannelId, highImportanceChannelName),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({'route': '/home'}),
      );
    }
  }

  Future<void> scheduleRepeatingTestNotification({required int secondsFromNow}) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(Duration(seconds: secondsFromNow));
    
    debugPrint('🔔 [LocalNotification] Scheduling REPEATING test (Daily) in $secondsFromNow seconds at ${scheduledDate.toString()}');

    try {
      await _notifications.zonedSchedule(
        repeatingTestId,
        'Daily Repeating Test 🔔',
        'Scheduled at ${scheduledDate.hour}:${scheduledDate.minute}:${scheduledDate.second}. This will repeat daily.',
        scheduledDate,
        _getDetails(dailyChannelId, dailyChannelName), // Use daily channel for repetition
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: jsonEncode({'route': '/home'}),
      );
    } catch (e) {
      debugPrint('🔔 [LocalNotification] Repeating test EXACT error: $e. Falling back to inexact.');
      await _notifications.zonedSchedule(
        repeatingTestId,
        'Daily Repeating Test (Fallback) 🔔',
        'Scheduled at ${scheduledDate.hour}:${scheduledDate.minute}. Repeating.',
        scheduledDate,
        _getDetails(dailyChannelId, dailyChannelName),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: jsonEncode({'route': '/home'}),
      );
    }
  }

  Future<void> showImmediateTestNotification() async {
    try {
      debugPrint('🔔 [LocalNotification] Triggering INSTANT test notification...');
      await _notifications.show(
        testNotificationId,
        'Instant Test 🔔',
        'Verification: If you see this, the foreground notification service is alive!',
        _getDetails(highImportanceChannelId, highImportanceChannelName),
        payload: jsonEncode({'route': '/home'}),
      );
    } catch (e) {
      debugPrint('🔔 [LocalNotification] Instant trigger error: $e');
    }
  }

  Future<void> cancelAll() async {
    debugPrint('🔔 [LocalNotification] Cancelling ALL notifications.');
    await _notifications.cancelAll();
  }

  NotificationDetails _getDetails(String channelId, String name) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        name,
        channelDescription: 'App Notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        fullScreenIntent: true,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
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
