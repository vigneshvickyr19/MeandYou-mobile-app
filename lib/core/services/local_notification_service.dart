import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data_providers/notification_messages.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // Public getter for external services (like permission requests)
  FlutterLocalNotificationsPlugin get plugin => _notifications;

  static const String dailyChannelId = 'daily_engagement_channel_v2';
  static const String dailyChannelName = 'Daily Engagement Alerts';
  
  static const String highImportanceChannelId = 'high_importance_channel_v2';
  static const String highImportanceChannelName = 'High Importance Notifications';

  // Fixed IDs for daily notifications
  static const int morningNotificationId = 8301;
  static const int afternoonNotificationId = 14302;
  static const int eveningNotificationId = 20303;

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _isServiceInitialized = false;

  Future<void> initialize(GlobalKey<NavigatorState>? navigatorKey) async {
    if (navigatorKey != null) {
      _navigatorKey = navigatorKey;
    }

    if (_isServiceInitialized) return;
    
    try {
      tz_data.initializeTimeZones();
    } catch (e) {
      debugPrint('LocalNotificationService: TZ init error: $e');
    }

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

    await scheduleDailyNotifications();
    _isServiceInitialized = true;
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
      debugPrint('LocalNotificationService: Channel error: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == null || response.payload!.isEmpty) return;
    
    try {
      final decoded = jsonDecode(response.payload!);
      if (decoded is Map) {
        final Map<String, dynamic> data = decoded.cast<String, dynamic>();
        if (data.containsKey('route')) {
          final String route = data['route'] as String;
          _navigatorKey?.currentState?.pushNamed(route);
        }
      }
    } catch (e) {
      debugPrint('LocalNotificationService: Tap handle error: $e');
    }
  }

  Future<void> scheduleDailyNotifications() async {
    try {
      await _notifications.cancel(morningNotificationId);
      await _notifications.cancel(afternoonNotificationId);
      await _notifications.cancel(eveningNotificationId);
      
      final tz.Location locArrive = tz.getLocation('Asia/Kolkata');
      final Random random = Random();

      await _scheduleZoned(morningNotificationId, 8, 30, NotificationPool.morningMessages, locArrive, random);
      await _scheduleZoned(afternoonNotificationId, 14, 30, NotificationPool.afternoonMessages, locArrive, random);
      await _scheduleZoned(eveningNotificationId, 20, 30, NotificationPool.eveningMessages, locArrive, random);
    } catch (e) {
      debugPrint('LocalNotificationService: Scheduling error: $e');
    }
  }

  Future<void> _scheduleZoned(int id, int hour, int minute, List<NotificationMessage> pool, tz.Location loc, Random rand) async {
    if (pool.isEmpty) return;
    
    final message = pool[rand.nextInt(pool.length)];
    final scheduledDate = _nextInstanceOfTime(hour, minute, loc);

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
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, tz.Location loc) {
    final tz.TZDateTime nowAtLoc = tz.TZDateTime.now(loc);
    tz.TZDateTime targetAtLoc = tz.TZDateTime(loc, nowAtLoc.year, nowAtLoc.month, nowAtLoc.day, hour, minute);
    
    if (targetAtLoc.isBefore(nowAtLoc)) {
      targetAtLoc = targetAtLoc.add(const Duration(days: 1));
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
        priority: Priority.high,
        ticker: 'eng_ticker',
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
