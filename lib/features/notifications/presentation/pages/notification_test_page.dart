import 'package:flutter/material.dart';
import '../../../../core/services/local_notification_service.dart';

class NotificationTestPage extends StatelessWidget {
  const NotificationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Notification Test'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            
            _buildTestButton(
              context,
              label: 'Trigger Instantly',
              icon: Icons.flash_on_rounded,
              color: Colors.orange,
              onPressed: () => LocalNotificationService.instance.showImmediateTestNotification(),
              description: 'Forces a notification to appear immediately. Verifies channel/ID setup.',
            ),
            
            _buildTestButton(
              context,
              label: 'Trigger in 5 Seconds',
              icon: Icons.timer_outlined,
              color: Colors.blue,
              onPressed: () => LocalNotificationService.instance.scheduleTestNotification(5),
              description: 'Verifies plugin, permissions, and channel functionality.',
            ),
            
            _buildTestButton(
              context,
              label: 'Trigger in 1 Minute',
              icon: Icons.hourglass_bottom_rounded,
              color: Colors.indigo,
              onPressed: () => LocalNotificationService.instance.scheduleTestNotification(60),
              description: 'Verifies timezone logic and future scheduling.',
            ),
            
            _buildTestButton(
              context,
              label: 'Schedule All 3 Daily Slots',
              icon: Icons.calendar_today_rounded,
              color: Colors.green,
              onPressed: () => LocalNotificationService.instance.scheduleDailyNotifications(),
              description: 'Production logic: 8:30 AM, 2:30 PM, 8:30 PM IST.',
            ),
            
            const Divider(height: 48),
            
            _buildTestButton(
              context,
              label: 'Cancel All Notifications',
              icon: Icons.notifications_off_outlined,
              color: Colors.redAccent,
              onPressed: () => LocalNotificationService.instance.cancelAll(),
              description: 'Clears all scheduled notifications to prevent stacking.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Diagnostic Tools',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Use these tools to validate the notification system. Check console logs for "🔔 [LocalNotification]" tags to see detailed execution steps.',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              onPressed();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Action Triggered: $label'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(icon),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4),
            child: Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
