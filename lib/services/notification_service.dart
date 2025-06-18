import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  int _notificationId(String reminderId) => reminderId.hashCode;

  Future<void> scheduleReminderNotification(Reminder reminder) async {
    if (!reminder.isEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: DefaultStyleInformation(true, true),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    final now = DateTime.now();
    var scheduledTime = tz.TZDateTime.local(
      now.year,
      now.month,
      now.day,
      reminder.reminderTime.hour,
      reminder.reminderTime.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      _notificationId(reminder.id),
      reminder.title,
      reminder.description ?? '',
      scheduledTime,
      notificationDetails,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  Future<void> cancelReminderNotification(String reminderId) async {
    await flutterLocalNotificationsPlugin.cancel(_notificationId(reminderId));
  }

  Future<void> updateReminderNotification(Reminder reminder) async {
    await cancelReminderNotification(reminder.id);
    await scheduleReminderNotification(reminder);
  }
}
