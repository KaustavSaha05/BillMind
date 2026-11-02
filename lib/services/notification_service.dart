import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:billmind/models/bill.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific bill
    print('Notification tapped: ${response.payload}');
  }

  // Schedule notification for a bill
  Future<void> scheduleBillReminder(Bill bill, {int daysBefore = 1}) async {
    if (bill.isPaid) return;

    final dueDate = bill.dueDate;
    final reminderDate = dueDate.subtract(Duration(days: daysBefore));
    
    // Don't schedule if reminder date is in the past
    if (reminderDate.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      'bill_reminders',
      'Bill Reminders',
      channelDescription: 'Notifications for upcoming bill payments',
      importance: Importance.high,
      priority: Priority.high,
      color: const Color(0xFF2196F3),
      enableLights: true,
      enableVibration: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    // Convert DateTime to TZDateTime for web compatibility
    final tzReminderDate = tz.TZDateTime.from(reminderDate, tz.local);

    await _notifications.zonedSchedule(
      bill.id ?? 0,
      'Bill Reminder',
      '${bill.name} is due in $daysBefore day${daysBefore == 1 ? '' : 's'}. Amount: \$${bill.amount.toStringAsFixed(2)}',
      tzReminderDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: bill.id.toString(),
    );
  }

  // Schedule multiple reminders for a bill
  Future<void> scheduleMultipleReminders(Bill bill) async {
    if (bill.isPaid) return;

    // Schedule reminders at 7 days, 3 days, and 1 day before due date
    await scheduleBillReminder(bill, daysBefore: 7);
    await scheduleBillReminder(bill, daysBefore: 3);
    await scheduleBillReminder(bill, daysBefore: 1);
  }

  // Cancel notification for a specific bill
  Future<void> cancelBillReminder(int billId) async {
    await _notifications.cancel(billId);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'immediate_notifications',
      'Immediate Notifications',
      channelDescription: 'Instant notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final androidEnabled = await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ?? false;
    return androidEnabled;
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    final androidGranted = await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission() ?? false;
    return androidGranted;
  }
}
