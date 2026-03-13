import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/theme/app_spacing.dart';
import 'package:food_save/core/theme/app_haptics.dart';
import 'package:food_save/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:food_save/core/widgets/base_page.dart';
import 'package:food_save/core/utils/responsive.dart';

@RoutePage()
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _allergiesController;
  late TextEditingController _preferencesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileViewModelProvider).value;
    _nameController = TextEditingController(text: profile?.username ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _allergiesController = TextEditingController(text: profile?.allergies ?? '');
    _preferencesController = TextEditingController(text: profile?.dietaryPreferences ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _allergiesController.dispose();
    _preferencesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    AppHaptics.medium();
    
    try {
      await ref.read(profileViewModelProvider.notifier).updateProfile(
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        allergies: _allergiesController.text.trim(),
        dietaryPreferences: _preferencesController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль сохранён')),
        );
        context.router.maybePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = Responsive.hPadding(context);

    return _EditProfileContent(
      h: h,
      theme: theme,
      nameController: _nameController,
      emailController: _emailController,
      allergiesController: _allergiesController,
      preferencesController: _preferencesController,
      isLoading: _isLoading,
      saveProfile: _saveProfile,
    );
  }
}

class _EditProfileContent extends BasePage {
  final double h;
  final ThemeData theme;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController allergiesController;
  final TextEditingController preferencesController;
  final bool isLoading;
  final VoidCallback saveProfile;

  const _EditProfileContent({
    required this.h,
    required this.theme,
    required this.nameController,
    required this.emailController,
    required this.allergiesController,
    required this.preferencesController,
    required this.isLoading,
    required this.saveProfile,
  });

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Редактирование'),
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => context.router.maybePop(),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: h, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar section
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Name field
          _buildLabel('Имя пользователя'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Введите имя',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Email field
          _buildLabel('Email'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'Введите email',
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Allergies field
          _buildLabel('Аллергии'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: allergiesController,
            decoration: InputDecoration(
              hintText: 'Например: Орехи, Молоко',
            ),
            maxLines: 2,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Dietary preferences field
          _buildLabel('Диетические предпочтения'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: preferencesController,
            decoration: InputDecoration(
              hintText: 'Например: Вегетарианство, Без глютена',
            ),
            maxLines: 2,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : saveProfile,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Сохранить'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }
}
