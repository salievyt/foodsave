import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SentryService {
  static const String _dsnKey = 'SENTRY_DSN';
  
  static Future<void> init() async {
    final dsn = dotenv.env[_dsnKey];
    
    if (dsn == null || dsn.isEmpty) {
      debugPrint('Sentry DSN not configured - skipping initialization');
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        // Сэмплирование для продакшена
        options.tracesSampleRate = kDebugMode ? 1.0 : 0.1;
        options.sampleRate = kDebugMode ? 1.0 : 0.1;
        
        // Теги
        options.beforeSend = (event, hint) {
          event = event.copyWith(
            tags: {
              ...event.tags ?? {},
              'app': 'food_save_flutter',
              'environment': kDebugMode ? 'development' : 'production',
            },
          );
          return event;
        };
      },
      appRunner: () {},
    );
    
    debugPrint('Sentry initialized successfully');
  }

  /// Отправить кастомное событие
  static Future<void> captureMessage(String message, {SentryLevel level = SentryLevel.info}) async {
    await Sentry.captureMessage(message, level: level);
  }

  /// Отправить исключение
  static Future<void> captureException(Object error, {StackTrace? stackTrace}) async {
    await Sentry.captureException(error, stackTrace: stackTrace);
  }

  /// Установить пользователя
  static Future<void> setUser(String userId, {String? email}) async {
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: userId,
        email: email,
      ));
    });
  }

  /// Очистить пользователя (при логауте)
  static Future<void> clearUser() async {
    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  /// Добавить breadcrumb
  static Future<void> addBreadcrumb(String message, {String? category}) async {
    await Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      timestamp: DateTime.now(),
    ));
  }
}
