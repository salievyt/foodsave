import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:food_save/core/theme/theme.dart';

import '../../../../core/router/app_router.gr.dart';

@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
          body: child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              boxShadow: AppSpacing.shadowSm,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, 
                  vertical: AppSpacing.sm,
                ),
                child: GNav(
                  rippleColor: AppColors.primary.withOpacity(0.2),
                  hoverColor: AppColors.primary.withOpacity(0.1),
                  gap: AppSpacing.sm,
                  activeColor: AppColors.primary,
                  iconSize: AppSpacing.iconMd,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, 
                    vertical: AppSpacing.sm + 4,
                  ),
                  duration: AppSpacing.animNormal,
                  tabBackgroundColor: AppColors.primary.withOpacity(0.1),
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  tabs: [
                    GButton(
                      icon: LineIcons.home,
                      text: 'Дом',
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    GButton(
                      icon: LineIcons.utensils,
                      text: 'Холод',
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    GButton(
                      icon: LineIcons.qrcode,
                      text: 'Скан',
                      iconActiveColor: AppColors.primary,
                      iconColor: AppColors.primary,
                      textColor: AppColors.primary,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    GButton(
                      icon: LineIcons.bookReader,
                      text: 'Рецепты',
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    GButton(
                      icon: LineIcons.user,
                      text: 'Профиль',
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                  selectedIndex: tabsRouter.activeIndex,
                  onTabChange: (index) {
                    HapticsService.selectionClick();
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
