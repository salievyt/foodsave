import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_save/core/router/app_router.dart';
import 'package:food_save/core/theme/app_theme.dart';
import 'package:food_save/core/services/notification_service.dart';
import 'package:food_save/core/services/sentry_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Theme mode provider — persists to SharedPreferences.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode') ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await prefs.setBool('dark_mode', false);
    } else {
      state = ThemeMode.dark;
      await prefs.setBool('dark_mode', true);
    }
  }

  bool get isDark => state == ThemeMode.dark;
}

// ignore: unused_element
Future<void> _initSentry() async {
  final sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';
  
  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.environment = dotenv.env['ENVIRONMENT'] ?? 'production';
        options.release = 'foodsave@1.1.0';
        // Трейсинг
        options.tracesSampleRate = 0.1;
        // Фильтрация
        options.beforeSend = (event) async {
          // Не отправлять в debug режиме
          if (event.environment == 'development') {
            return null;
          }
          return event;
        } as BeforeSendCallback?;
      },
      appRunner: () {},
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService.init();
  
  // Инициализация Sentry
  await SentryService.init();
  
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FoodSave',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: AppRouter().config(),
    );
  }
}
