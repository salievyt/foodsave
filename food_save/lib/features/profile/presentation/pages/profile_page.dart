import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/services/persistence_helper.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/widgets/base_page.dart';
import 'package:food_save/features/profile/presentation/controllers/profile_controller.dart';
import 'package:food_save/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:food_save/main.dart';

import '../widgets/profile_guest_badge.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_section.dart';
import '../widgets/profile_theme_toggle.dart';
import '../widgets/profile_tile.dart';

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

  void _showEditInfoDialog(BuildContext context, WidgetRef ref, UserProfile profile) {
    final nameController = TextEditingController(text: profile.username);
    final emailController = TextEditingController(text: profile.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Редактировать профиль"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Логин"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
          ElevatedButton(
            onPressed: () async {
              await ref.read(userProfileProvider.notifier).updateProfileField({
                'username': nameController.text,
                'email': emailController.text,
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Сохранить"),
          ),
        ],
      ),
    );
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

    if (profileState.isLoading && profileState.data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = profileState.data ??
        UserProfile(username: "", dietaryPreferences: "", allergies: "", email: "");

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        FutureBuilder<bool>(
          future: PersistenceHelper.isGuest(),
          builder: (context, snapshot) {
            final isGuest = snapshot.data ?? false;
            return ProfileHeader(
              profile: profile,
              badge: isGuest ? const ProfileGuestBadge(label: "Гостевой аккаунт") : null,
              onAvatarTap: () => _pickAvatar(ref),
            );
          },
        ),
        const SizedBox(height: 20),
        ProfileSection(
          title: "Питание",
          children: [
            ProfileTile(
              icon: Icons.restaurant_menu_rounded,
              title: "Предпочтения",
              subtitle: profile.dietaryPreferences.isEmpty
                  ? "Не указано"
                  : profile.dietaryPreferences,
              onTap: () => _showSelectionDialog(
                context,
                ref,
                "Предпочтения",
                ["Вегетарианец", "Палео", "Кето", "Без ограничений"],
                true,
              ),
            ),
            const SizedBox(height: 10),
            ProfileTile(
              icon: Icons.medication_liquid_rounded,
              title: "Аллергии",
              subtitle: profile.allergies.isEmpty ? "Не указано" : profile.allergies,
              onTap: () => _showSelectionDialog(
                context,
                ref,
                "Аллергии",
                ["Лактоза", "Глютен", "Орехи", "Морепродукты"],
                false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ProfileSection(
          title: "Приложение",
          children: [
            ProfileThemeToggle(isDark: isDark, onToggle: () => ref.read(themeModeProvider.notifier).toggle()),
            const SizedBox(height: 10),
            ProfileTile(
              icon: Icons.bar_chart_rounded,
              title: "Статистика",
              onTap: () => context.router.push(const StatisticsRoute()),
            ),
            const SizedBox(height: 10),
            ProfileTile(
              icon: Icons.chat_rounded,
              title: "Чат поддержки",
              onTap: () => context.router.push(const SupportChatRoute()),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ProfileSection(
          title: "Аккаунт",
          children: [
            ProfileTile(
              icon: Icons.edit_outlined,
              title: "Редактировать профиль",
              onTap: () => _showEditInfoDialog(context, ref, profile),
            ),
            const SizedBox(height: 10),
            ProfileLogoutButton(
              onPressed: () async {
                await PersistenceHelper.clearAuthTokens();
                if (context.mounted) {
                  context.router.replaceAll([const LoginRoute()]);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showSelectionDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<String> options,
    bool isPreferences,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map(
                  (o) => ListTile(
                    title: Text(o),
                    onTap: () async {
                      if (isPreferences) {
                        await ref.read(userProfileProvider.notifier).updatePreferences(o);
                      } else {
                        await ref.read(userProfileProvider.notifier).updateAllergies(o);
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Закрыть")),
        ],
      ),
    );
  }
}
