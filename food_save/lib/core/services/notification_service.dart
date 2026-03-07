import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Schedule notifications for products expiring within 2 days.
  static Future<void> scheduleExpiryNotifications(List<Product> products) async {
    if (!_initialized) await init();

    // Cancel all existing notifications first
    await _plugin.cancelAll();

    final now = DateTime.now();
    int id = 0;

    for (final product in products) {
      if (product.isEaten || product.isSpoiled) continue;

      final daysLeft = product.expiryDate.difference(now).inDays;

      // Notify if expiring today or tomorrow
      if (daysLeft >= 0 && daysLeft <= 1) {
        await _plugin.show(
          id++,
          '⚠️ Продукт скоро испортится!',
          '${product.emoji} ${product.name} — ${daysLeft == 0 ? "сегодня последний день!" : "осталась 1 день!"}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'expiry_channel',
              'Срок годности',
              channelDescription: 'Уведомления о сроке годности продуктов',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
    }
  }
}
