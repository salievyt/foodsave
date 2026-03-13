import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/services/persistence_helper.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/theme/app_spacing.dart';
import 'package:food_save/core/widgets/base_page.dart';
import 'package:food_save/features/profile/presentation/controllers/profile_controller.dart';
import 'package:food_save/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:food_save/main.dart';
import 'package:food_save/core/utils/responsive.dart';

@RoutePage()
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ProfilePageContent(ref: ref);
  }
}

class _ProfilePageContent extends BasePage {
  final WidgetRef ref;
  const _ProfilePageContent({required this.ref});

  Future<void> _pickAvatar(WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await ref.read(userProfileProvider.notifier).uploadAvatar(image.path);
    }
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      title: const Text("Профиль"),
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w800,
        fontSize: 22,
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    final h = Responsive.hPadding(context);

    final profile = profileState.data ??
        UserProfile(username: "", dietaryPreferences: "", allergies: "", email: "");

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: h, vertical: AppSpacing.lg),
      children: [
        // Avatar & Name
        Center(
          child: GestureDetector(
            onTap: () => _pickAvatar(ref),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  profile.username,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (profile.email != null && profile.email!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.email!,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // Stats Row
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: AppSpacing.borderRadiusLg,
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, "Спасено", "${profile.dietaryPreferences.isNotEmpty ? 0 : 0}"),
              Container(width: 1, height: 30, color: theme.dividerColor),
              _buildStatItem(context, "Выброшено", "0"),
              Container(width: 1, height: 30, color: theme.dividerColor),
              _buildStatItem(context, "Дней", "0"),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Menu sections
        _buildSectionTitle(context, "Питание"),
        const SizedBox(height: AppSpacing.md),
        _buildMenuCard(
          context,
          children: [
            _buildMenuTile(
              context,
              icon: Icons.restaurant_outlined,
              title: "Предпочтения",
              subtitle: profile.dietaryPreferences.isEmpty ? "Не указано" : profile.dietaryPreferences,
              onTap: () => _showSelectionDialog(context, ref, "Предпочтения", 
                ["Вегетарианец", "Палео", "Кето", "Без ограничений"], true),
            ),
            _buildDivider(context),
            _buildMenuTile(
              context,
              icon: Icons.warning_amber_outlined,
              title: "Аллергии",
              subtitle: profile.allergies.isEmpty ? "Не указано" : profile.allergies,
              onTap: () => _showSelectionDialog(context, ref, "Аллергии",
                ["Лактоза", "Глютен", "Орехи", "Морепродукты"], false),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        _buildSectionTitle(context, "Приложение"),
        const SizedBox(height: AppSpacing.md),
        _buildMenuCard(
          context,
          children: [
            _buildMenuTile(
              context,
              icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              title: "Тёмная тема",
              trailing: Switch(
                value: isDark,
                onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                activeColor: AppColors.primary,
              ),
            ),
            _buildDivider(context),
            _buildMenuTile(
              context,
              icon: Icons.bar_chart_outlined,
              title: "Статистика",
              onTap: () => context.router.push(const StatisticsRoute()),
            ),
            _buildDivider(context),
            _buildMenuTile(
              context,
              icon: Icons.chat_outlined,
              title: "Поддержка",
              onTap: () => context.router.push(const SupportChatRoute()),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        _buildSectionTitle(context, "Аккаунт"),
        const SizedBox(height: AppSpacing.md),
        _buildMenuCard(
          context,
          children: [
            _buildMenuTile(
              context,
              icon: Icons.edit_outlined,
              title: "Редактировать профиль",
              onTap: () => context.router.push(const EditProfileRoute()),
            ),
            _buildDivider(context),
            _buildMenuTile(
              context,
              icon: Icons.logout,
              title: "Выйти",
              titleColor: AppColors.error,
              onTap: () async {
                await PersistenceHelper.clearAuthTokens();
                if (context.mounted) {
                  context.router.replaceAll([const LoginRoute()]);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusLg,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ?? Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 68,
      color: Theme.of(context).dividerColor,
    );
  }

  void _showSelectionDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<String> options,
    bool isPreferences,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...options.map((option) => ListTile(
              title: Text(option),
              onTap: () async {
                if (isPreferences) {
                  await ref.read(userProfileProvider.notifier).updatePreferences(option);
                } else {
                  await ref.read(userProfileProvider.notifier).updateAllergies(option);
                }
                if (context.mounted) Navigator.pop(context);
              },
            )),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
