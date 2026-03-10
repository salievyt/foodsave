import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/widgets/base_page.dart';
import 'package:food_save/features/auth/presentation/controllers/auth_controller.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/services/persistence_helper.dart';

@RoutePage()
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _redirectIfLoggedIn();
  }

  Future<void> _redirectIfLoggedIn() async {
    final isLoggedIn = await PersistenceHelper.isLoggedIn();
    if (isLoggedIn && mounted) {
      context.router.replaceAll([const MainRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _RegisterPageContent(
      ref: ref,
      formKey: _formKey,
      usernameController: _usernameController,
      emailController: _emailController,
      passwordController: _passwordController,
    );
  }
}

class _RegisterPageContent extends BasePage {
  final WidgetRef ref;
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  static const _heroHeight = 220.0;

  const _RegisterPageContent({
    required this.ref,
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(backgroundColor: Colors.transparent, elevation: 0);
  }

  @override
  Widget buildBody(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background, Color(0xFFF4F6F8)],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _AuthHero(
                height: _heroHeight,
                title: "Создать аккаунт",
                subtitle: "Сохраняйте продукты и получайте рекомендации",
                onSkip: authState.isLoading
                    ? null
                    : () async {
                        await ref.read(authControllerProvider.notifier).loginAsGuest();
                        final newState = ref.read(authControllerProvider);
                        if (newState.data && context.mounted) {
                          context.router.replaceAll([const MainRoute()]);
                        } else if (newState.error != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка гостевого входа: ${newState.error}')),
                          );
                        }
                      },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _AuthCard(
                        child: Column(
                          children: [
                            _InputField(
                              controller: usernameController,
                              label: "Логин",
                              icon: Icons.person_outline_rounded,
                              validator: (v) => v!.isEmpty ? "Введите логин" : null,
                            ),
                            const SizedBox(height: 14),
                            _InputField(
                              controller: emailController,
                              label: "Email",
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => !v!.contains('@') ? "Введите корректный email" : null,
                            ),
                            const SizedBox(height: 14),
                            _InputField(
                              controller: passwordController,
                              label: "Пароль",
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              validator: (v) => v!.length < 6 ? "Минимум 6 символов" : null,
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: authState.isLoading
                                    ? null
                                    : () async {
                                        if (formKey.currentState!.validate()) {
                                          await ref.read(authControllerProvider.notifier).register(
                                            usernameController.text.trim(),
                                            emailController.text.trim(),
                                            passwordController.text.trim(),
                                          );

                                          final newState = ref.read(authControllerProvider);
                                          if (newState.data && context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Регистрация успешна! Войдите в аккаунт.")),
                                            );
                                            context.router.pop();
                                          } else if (newState.error != null && context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Ошибка: ${newState.error}")),
                                            );
                                          }
                                        }
                                      },
                                child: authState.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        "Зарегистрироваться",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _AuthFooter(
                        text: "Уже есть аккаунт?",
                        actionText: "Войти",
                        onPressed: () => context.router.pop(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _AuthHero extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final VoidCallback? onSkip;

  const _AuthHero({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF1F1), Color(0xFFFFF7F7)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: TextButton(
              onPressed: onSkip,
              child: const Text("Гость"),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 28,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  final Widget child;

  const _AuthCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: const Color(0xFFF6F7F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

class _AuthFooter extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onPressed;

  const _AuthFooter({
    required this.text,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: const TextStyle(color: AppColors.textSecondary)),
        TextButton(onPressed: onPressed, child: Text(actionText)),
      ],
    );
  }
}
