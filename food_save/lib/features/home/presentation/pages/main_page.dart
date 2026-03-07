import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:food_save/core/theme/app_colors.dart';

import '../../../../core/router/app_router.gr.dart';

@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        FridgeRoute(),
        ScannerRoute(),
        RecipesRoute(),
        ProfileRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withValues(alpha: .1),
                )
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 8,
                  activeColor: AppColors.primary,
                  iconSize: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  color: AppColors.textSecondary,
                  tabs: const [
                    GButton(
                      icon: LineIcons.home,
                      text: 'Дом',
                    ),
                    GButton(
                      icon: LineIcons.utensils,
                      text: 'Холод',
                    ),
                    GButton(
                      icon: LineIcons.qrcode,
                      text: 'Скан',
                      iconActiveColor: AppColors.primary,
                      iconColor: AppColors.primary,
                      textColor: AppColors.primary,
                    ),
                    GButton(
                      icon: LineIcons.bookReader,
                      text: 'Рецепты',
                    ),
                    GButton(
                      icon: LineIcons.user,
                      text: 'Профиль',
                    ),
                  ],
                  selectedIndex: tabsRouter.activeIndex,
                  onTabChange: (index) {
                    tabsRouter.setActiveIndex(index);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
