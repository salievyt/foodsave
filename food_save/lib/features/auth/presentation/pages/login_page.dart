import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/widgets/base_page.dart';
import 'package:food_save/features/auth/presentation/controllers/auth_controller.dart';

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

  const _LoginPageContent({
    required this.ref,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget buildBody(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              "Добро пожаловать",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Войдите чтобы продолжить",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Логин",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Пароль",
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.pushRoute(const ResetPasswordRoute()),
                child: const Text("Забыли пароль?"),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: authState.isLoading ? null : () async {
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
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Войти", style: TextStyle(color: Colors.white)),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Нет аккаунта?"),
                TextButton(
                  onPressed: () => context.pushRoute(const RegisterRoute()),
                  child: const Text("Регистрация"),
                )
              ],
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}