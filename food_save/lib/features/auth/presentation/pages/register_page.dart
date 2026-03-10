import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/widgets/base_page.dart';
import 'package:food_save/features/auth/presentation/controllers/auth_controller.dart';

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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Создать аккаунт",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Начните спасать еду вместе с нами",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 40),
            
            _buildField(
              controller: usernameController,
              label: "Логин",
              icon: Icons.person_outline_rounded,
              validator: (v) => v!.isEmpty ? "Введите логин" : null,
            ),
            const SizedBox(height: 16),
            
            _buildField(
              controller: emailController,
              label: "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => !v!.contains('@') ? "Введите корректный email" : null,
            ),
            const SizedBox(height: 16),
            
            _buildField(
              controller: passwordController,
              label: "Пароль",
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              validator: (v) => v!.length < 6 ? "Минимум 6 символов" : null,
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                onPressed: authState.isLoading ? null : () async {
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
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Зарегистрироваться",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => context.router.pop(),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    children: [
                      TextSpan(text: "Уже есть аккаунт? "),
                      TextSpan(
                        text: "Войти",
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}