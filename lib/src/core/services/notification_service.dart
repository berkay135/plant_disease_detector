import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_disease_detector/src/features/garden/data/plant_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    print('✅ NotificationService initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
    // Navigate to plant detail if payload contains plant ID
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      print('🔔 Android notification permission: $granted');
      return granted ?? false;
    }
    
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      print('🔔 iOS notification permission: $granted');
      return granted ?? false;
    }
    
    return true;
  }

  /// Schedule a watering reminder for a plant
  Future<void> scheduleWateringReminder(PlantModel plant) async {
    if (!plant.notificationsEnabled) {
      print('🔕 Notifications disabled for ${plant.name}');
      return;
    }

    // Cancel existing notification for this plant
    await cancelNotification(plant.id.hashCode);

    // Calculate next watering time
    final nextWatering = plant.nextWateringDate;
    if (nextWatering == null) {
      print('⚠️ No watering date for ${plant.name}');
      return;
    }

    // Schedule notification at the plant's notification time
    final scheduledDate = DateTime(
      nextWatering.year,
      nextWatering.month,
      nextWatering.day,
      plant.notificationHour,
      plant.notificationMinute,
    );

    // If the scheduled time is in the past, schedule for tomorrow
    final now = DateTime.now();
    DateTime finalScheduledDate = scheduledDate;
    if (scheduledDate.isBefore(now)) {
      finalScheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _scheduleNotification(
      id: plant.id.hashCode,
      title: '💧 Sulama Zamanı!',
      body: '${plant.name} sulanmayı bekliyor',
      scheduledDate: finalScheduledDate,
      payload: plant.id,
    );

    print('📅 Scheduled watering reminder for ${plant.name} at $finalScheduledDate');
  }

  /// Schedule a test notification (for debugging)
  Future<void> scheduleTestNotification({int delaySeconds = 5}) async {
    final scheduledDate = DateTime.now().add(Duration(seconds: delaySeconds));
    
    await _scheduleNotification(
      id: 999999,
      title: '🧪 Test Bildirimi',
      body: 'Bildirimler çalışıyor!',
      scheduledDate: scheduledDate,
      payload: 'test',
    );

    print('🧪 Test notification scheduled for $scheduledDate');
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'plant_watering_channel',
      'Sulama Hatırlatıcıları',
      channelDescription: 'Bitkilerinizi sulamanız için hatırlatmalar',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
    print('📬 Notification shown: $title');
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'plant_watering_channel',
      'Sulama Hatırlatıcıları',
      channelDescription: 'Bitkilerinizi sulamanız için hatırlatmalar',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🔕 All notifications cancelled');
  }

  /// Schedule reminders for all plants that need watering
  Future<void> scheduleAllReminders(List<PlantModel> plants) async {
    for (final plant in plants) {
      if (plant.notificationsEnabled) {
        await scheduleWateringReminder(plant);
      }
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
