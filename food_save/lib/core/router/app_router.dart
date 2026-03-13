import 'package:auto_route/auto_route.dart';
import 'app_router.gr.dart';
import 'package:food_save/core/services/persistence_helper.dart';

/// Guard для защиты маршрутов - проверяет авторизацию
class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final isLoggedIn = await PersistenceHelper.isLoggedIn();
    
    if (isLoggedIn) {
      resolver.next(true);
    } else {
      // Не авторизован - перенаправляем на логин
      resolver.redirect(const LoginRoute());
    }
  }
}

/// Guard для гостевых маршрутов - наоборот, доступен только для неавторизованных
class GuestGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final isLoggedIn = await PersistenceHelper.isLoggedIn();
    
    if (!isLoggedIn) {
      resolver.next(true);
    } else {
      // Уже авторизован - перенаправляем на главную
      resolver.redirect(const MainRoute());
    }
  }
}

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  final AuthGuard authGuard = AuthGuard();
  final GuestGuard guestGuard = GuestGuard();

  @override
  List<AutoRoute> get routes => [
    // Публичные маршруты (доступны без авторизации)
    AutoRoute(page: SplashScreen.page, initial: true),
    AutoRoute(page: LoginRoute.page, guards: [guestGuard]),
    AutoRoute(page: RegisterRoute.page, guards: [guestGuard]),
    AutoRoute(page: CodeRoute.page, guards: [guestGuard]),
    AutoRoute(page: OnBoardRoute.page, guards: [guestGuard]),
    AutoRoute(page: ResetPasswordRoute.page, guards: [guestGuard]),
    AutoRoute(page: SuccessRoute.page),
    
    // Защищенные маршруты (требуют авторизации)
    AutoRoute(
      page: MainRoute.page,
      guards: [authGuard],
      children: [
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: FridgeRoute.page),
        AutoRoute(page: ScannerRoute.page),
        AutoRoute(page: RecipesRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ],
    ),
    AutoRoute(page: SupportChatRoute.page, guards: [authGuard]),
    AutoRoute(page: StatisticsRoute.page, guards: [authGuard]),
    AutoRoute(page: RecipeDetailRoute.page, guards: [authGuard]),
    AutoRoute(page: EditProfileRoute.page, guards: [authGuard]),
  ];

  @override
  RouteType get defaultRouteType => const RouteType.custom(
    transitionsBuilder: TransitionsBuilders.fadeIn,
    durationInMilliseconds: 300,
  );
}