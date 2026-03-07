import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/services/persistence_helper.dart';
import 'package:food_save/features/profile/presentation/controllers/profile_controller.dart';
import 'package:food_save/main.dart';

@RoutePage()
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              centerTitle: false,
              title: const Text(
                "Твой Профиль",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Profile Header
                  profileAsync.when(
                    data: (profile) => _buildProfileHeader(context, ref, profile),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => _buildProfileHeader(context, ref, UserProfile(username: "Ошибка", dietaryPreferences: "", allergies: "", email: "Ошибка загрузки")),
                  ),

                  const SizedBox(height: 32),

                  // Working menu items only
                  _buildSectionTitle("Настройки питания"),
                  _buildMenuItem(
                    ref, 
                    Icons.restaurant_menu_rounded, 
                    "Пищевые предпочтения", 
                    onTap: () => _showSelectionDialog(
                      context, ref, "Предпочтения", 
                      ["Вегетарианец", "Палео", "Кето", "Без ограничений"],
                      true
                    )
                  ),
                  _buildMenuItem(
                    ref, 
                    Icons.medication_liquid_rounded, 
                    "Аллергии", 
                    onTap: () => _showSelectionDialog(
                      context, ref, "Аллергии", 
                      ["Лактоза", "Глютен", "Орехи", "Морепродукты"],
                      false
                    )
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle("Приложение"),

                  // Dark theme toggle
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.textPrimary, size: 20),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              "Тёмная тема",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Switch.adaptive(
                            value: isDark,
                            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildMenuItem(ref, Icons.bar_chart_rounded, "Статистика", onTap: () {
                    context.router.push(const StatisticsRoute());
                  }),
                  _buildMenuItem(ref, Icons.chat_rounded, "Чат поддержки", onTap: () {
                    context.router.push(const SupportChatRoute());
                  }),

                  const SizedBox(height: 24),
                  _buildSectionTitle("Аккаунт"),
                  
                  const SizedBox(height: 8),
                  
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        await PersistenceHelper.clearAuthTokens();
                        if (context.mounted) {
                          context.router.replaceAll([const LoginRoute()]);
                        }
                      },
                      child: const Text(
                        "Выйти из аккаунта",
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 120),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => _pickAvatar(ref),
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    image: profile.avatarUrl != null 
                      ? DecorationImage(
                          image: NetworkImage(profile.avatarUrl!), 
                          fit: BoxFit.cover,
                        )
                      : null,
                  ),
                  child: profile.avatarUrl == null 
                    ? const Icon(Icons.person_rounded, size: 40, color: AppColors.primary)
                    : null,
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: () => _pickAvatar(ref),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                      onPressed: () => _showEditInfoDialog(context, ref, profile),
                    ),
                  ],
                ),
                Text(
                  profile.email ?? "Email не указан",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectionDialog(BuildContext context, WidgetRef ref, String title, List<String> options, bool isPrefs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => ListTile(
            title: Text(opt),
            onTap: () {
              if (isPrefs) {
                ref.read(userProfileProvider.notifier).updatePreferences(opt);
              } else {
                ref.read(userProfileProvider.notifier).updateAllergies(opt);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Настройка "$opt" обновлена на сервере!')));
            },
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(WidgetRef ref, IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.textPrimary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}