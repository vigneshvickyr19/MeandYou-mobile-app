import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NotificationApiService {
  static final NotificationApiService _instance = NotificationApiService._();
  static NotificationApiService get instance => _instance;

  final Dio _dio = Dio();
  final String _baseUrl = 'https://push-notification-ve9s.onrender.com';

  NotificationApiService._() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  /// Send a standard push notification
  Future<void> sendNotification({
    required String deviceToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (kDebugMode) {
        print('Sending notification to $deviceToken');
      }
      final response = await _dio.post(
        '/api/notifications/send',
        data: {
          'deviceToken': deviceToken,
          'title': title,
          'body': body,
          'data': data ?? {},
        },
      );
      if (kDebugMode) {
        print('Notification sent: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending notification: $e');
      }
      rethrow;
    }
  }

  /// Send a call signal (VoIP)
  Future<void> sendCallSignal({
    required String deviceToken,
    required String callId,
    required String callerId,
    required String callerName,
    required String calleeId,
    required String callType, // 'AUDIO' or 'VIDEO'
    required String action, // 'START', 'END', 'DECLINE', 'MISSED'
  }) async {
    try {
      if (kDebugMode) {
        print('Sending call signal ($action) to $deviceToken');
      }
      final response = await _dio.post(
        '/api/calls/signal',
        data: {
          'deviceToken': deviceToken,
          'callId': callId,
          'callerId': callerId,
          'callerName': callerName,
          'calleeId': calleeId,
          'callType': callType,
          'action': action,
        },
      );
      if (kDebugMode) {
        print('Call signal sent: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending call signal: $e');
      }
      rethrow;
    }
  }
}
