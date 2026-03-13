// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i18;
import 'package:flutter/material.dart' as _i19;
import 'package:food_save/features/auth/presentation/pages/code_page.dart'
    as _i1;
import 'package:food_save/features/auth/presentation/pages/login_page.dart'
    as _i5;
import 'package:food_save/features/auth/presentation/pages/register_page.dart'
    as _i11;
import 'package:food_save/features/auth/presentation/pages/reset_password_page.dart'
    as _i12;
import 'package:food_save/features/auth/presentation/pages/success_page.dart'
    as _i16;
import 'package:food_save/features/fridge/presentation/pages/fridge_page.dart'
    as _i3;
import 'package:food_save/features/fridge/presentation/pages/scanner_page.dart'
    as _i13;
import 'package:food_save/features/home/presentation/pages/home_page.dart'
    as _i4;
import 'package:food_save/features/home/presentation/pages/main_page.dart'
    as _i6;
import 'package:food_save/features/onboarding/presentation/pages/on_board_page.dart'
    as _i7;
import 'package:food_save/features/onboarding/presentation/pages/splash_screen.dart'
    as _i14;
import 'package:food_save/features/profile/presentation/pages/edit_profile_page.dart'
    as _i2;
import 'package:food_save/features/profile/presentation/pages/profile_page.dart'
    as _i8;
import 'package:food_save/features/recipes/presentation/pages/recipe_detail_page.dart'
    as _i9;
import 'package:food_save/features/recipes/presentation/pages/recipes_page.dart'
    as _i10;
import 'package:food_save/features/recipes/presentation/viewmodels/recipes_view_model.dart'
    as _i20;
import 'package:food_save/features/statistics/presentation/pages/statistics_page.dart'
    as _i15;
import 'package:food_save/features/support/presentation/pages/support_chat_page.dart'
    as _i17;

/// generated route for
/// [_i1.CodePage]
class CodeRoute extends _i18.PageRouteInfo<void> {
  const CodeRoute({List<_i18.PageRouteInfo>? children})
    : super(CodeRoute.name, initialChildren: children);

  static const String name = 'CodeRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i1.CodePage();
    },
  );
}

/// generated route for
/// [_i2.EditProfilePage]
class EditProfileRoute extends _i18.PageRouteInfo<void> {
  const EditProfileRoute({List<_i18.PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i2.EditProfilePage();
    },
  );
}

/// generated route for
/// [_i3.FridgePage]
class FridgeRoute extends _i18.PageRouteInfo<void> {
  const FridgeRoute({List<_i18.PageRouteInfo>? children})
    : super(FridgeRoute.name, initialChildren: children);

  static const String name = 'FridgeRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i3.FridgePage();
    },
  );
}

/// generated route for
/// [_i4.HomePage]
class HomeRoute extends _i18.PageRouteInfo<void> {
  const HomeRoute({List<_i18.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i4.HomePage();
    },
  );
}

/// generated route for
/// [_i5.LoginPage]
class LoginRoute extends _i18.PageRouteInfo<void> {
  const LoginRoute({List<_i18.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i5.LoginPage();
    },
  );
}

/// generated route for
/// [_i6.MainPage]
class MainRoute extends _i18.PageRouteInfo<void> {
  const MainRoute({List<_i18.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i6.MainPage();
    },
  );
}

/// generated route for
/// [_i7.OnBoardPage]
class OnBoardRoute extends _i18.PageRouteInfo<void> {
  const OnBoardRoute({List<_i18.PageRouteInfo>? children})
    : super(OnBoardRoute.name, initialChildren: children);

  static const String name = 'OnBoardRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i7.OnBoardPage();
    },
  );
}

/// generated route for
/// [_i8.ProfilePage]
class ProfileRoute extends _i18.PageRouteInfo<void> {
  const ProfileRoute({List<_i18.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i8.ProfilePage();
    },
  );
}

/// generated route for
/// [_i9.RecipeDetailPage]
class RecipeDetailRoute extends _i18.PageRouteInfo<RecipeDetailRouteArgs> {
  RecipeDetailRoute({
    _i19.Key? key,
    required _i20.Recipe recipe,
    List<_i18.PageRouteInfo>? children,
  }) : super(
         RecipeDetailRoute.name,
         args: RecipeDetailRouteArgs(key: key, recipe: recipe),
         initialChildren: children,
       );

  static const String name = 'RecipeDetailRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RecipeDetailRouteArgs>();
      return _i9.RecipeDetailPage(key: args.key, recipe: args.recipe);
    },
  );
}

class RecipeDetailRouteArgs {
  const RecipeDetailRouteArgs({this.key, required this.recipe});

  final _i19.Key? key;

  final _i20.Recipe recipe;

  @override
  String toString() {
    return 'RecipeDetailRouteArgs{key: $key, recipe: $recipe}';
  }
}

/// generated route for
/// [_i10.RecipesPage]
class RecipesRoute extends _i18.PageRouteInfo<void> {
  const RecipesRoute({List<_i18.PageRouteInfo>? children})
    : super(RecipesRoute.name, initialChildren: children);

  static const String name = 'RecipesRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i10.RecipesPage();
    },
  );
}

/// generated route for
/// [_i11.RegisterPage]
class RegisterRoute extends _i18.PageRouteInfo<void> {
  const RegisterRoute({List<_i18.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i11.RegisterPage();
    },
  );
}

/// generated route for
/// [_i12.ResetPasswordPage]
class ResetPasswordRoute extends _i18.PageRouteInfo<void> {
  const ResetPasswordRoute({List<_i18.PageRouteInfo>? children})
    : super(ResetPasswordRoute.name, initialChildren: children);

  static const String name = 'ResetPasswordRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i12.ResetPasswordPage();
    },
  );
}

/// generated route for
/// [_i13.ScannerPage]
class ScannerRoute extends _i18.PageRouteInfo<void> {
  const ScannerRoute({List<_i18.PageRouteInfo>? children})
    : super(ScannerRoute.name, initialChildren: children);

  static const String name = 'ScannerRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i13.ScannerPage();
    },
  );
}

/// generated route for
/// [_i14.SplashScreen]
class SplashScreen extends _i18.PageRouteInfo<void> {
  const SplashScreen({List<_i18.PageRouteInfo>? children})
    : super(SplashScreen.name, initialChildren: children);

  static const String name = 'SplashScreen';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i14.SplashScreen();
    },
  );
}

/// generated route for
/// [_i15.StatisticsPage]
class StatisticsRoute extends _i18.PageRouteInfo<void> {
  const StatisticsRoute({List<_i18.PageRouteInfo>? children})
    : super(StatisticsRoute.name, initialChildren: children);

  static const String name = 'StatisticsRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i15.StatisticsPage();
    },
  );
}

/// generated route for
/// [_i16.SuccessPage]
class SuccessRoute extends _i18.PageRouteInfo<void> {
  const SuccessRoute({List<_i18.PageRouteInfo>? children})
    : super(SuccessRoute.name, initialChildren: children);

  static const String name = 'SuccessRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i16.SuccessPage();
    },
  );
}

/// generated route for
/// [_i17.SupportChatPage]
class SupportChatRoute extends _i18.PageRouteInfo<void> {
  const SupportChatRoute({List<_i18.PageRouteInfo>? children})
    : super(SupportChatRoute.name, initialChildren: children);

  static const String name = 'SupportChatRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i17.SupportChatPage();
    },
  );
}
