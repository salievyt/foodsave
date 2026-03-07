import 'package:auto_route/auto_route.dart';
import 'app_router.gr.dart';


@AutoRouterConfig()
class AppRouter extends RootStackRouter{

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page ,initial: true ),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: CodeRoute.page),
    AutoRoute(page: OnBoardRoute.page),
    AutoRoute(page: ResetPasswordRoute.page),
    AutoRoute(page: SuccessRoute.page),
    AutoRoute(page: SupportChatRoute.page),
    AutoRoute(page: StatisticsRoute.page),
    AutoRoute(page: RecipeDetailRoute.page),
    AutoRoute(
      page: MainRoute.page,
      children: [
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: FridgeRoute.page),
        AutoRoute(page: ScannerRoute.page),
        AutoRoute(page: RecipesRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ]
    ),
  ];
}