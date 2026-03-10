import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/widgets/base_page.dart';
import 'package:food_save/features/auth/presentation/controllers/auth_controller.dart';
import 'package:food_save/core/services/persistence_helper.dart';

@RoutePage()
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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
    return _LoginPageContent(
      ref: ref,
      emailController: _emailController,
      passwordController: _passwordController,
    );
  }
}

class _LoginPageContent extends BasePage {
  final WidgetRef ref;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  static const _heroHeight = 220.0;

  const _LoginPageContent({
    required this.ref,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget buildBody(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

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
                title: "С возвращением",
                subtitle: "Войдите в аккаунт, чтобы продолжить",
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
                child: Column(
                  children: [
                    _AuthCard(
                      child: Column(
                        children: [
                          _InputField(
                            controller: emailController,
                            label: "Логин",
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 14),
                          _InputField(
                            controller: passwordController,
                            label: "Пароль",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.pushRoute(const ResetPasswordRoute()),
                              child: const Text("Забыли пароль?"),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: authState.isLoading
                                  ? null
                                  : () async {
                                      await ref.read(authControllerProvider.notifier).login(
                                        emailController.text,
                                        passwordController.text,
                                      );

                                      final newState = ref.read(authControllerProvider);
                                      if (newState.data && context.mounted) {
                                        context.router.replaceAll([const MainRoute()]);
                                      } else if (newState.error != null && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Ошибка входа: ${newState.error}')),
                                        );
                                      }
                                    },
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text("Войти", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AuthFooter(
                      text: "Нет аккаунта?",
                      actionText: "Регистрация",
                      onPressed: () => context.pushRoute(const RegisterRoute()),
                    ),
                    const SizedBox(height: 24),
                  ],
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

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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
