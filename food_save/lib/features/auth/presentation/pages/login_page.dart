import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/services/api_service.dart';
import 'package:food_save/core/services/persistence_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final email = TextEditingController();
  final password = TextEditingController();

  static const accent = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 40),

              const Text(
                "Добро пожаловать",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Войдите чтобы продолжить",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: email, // Variable name remains for stability, but UI changes
                decoration: InputDecoration(
                  labelText: "Логин",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Пароль",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.pushRoute(const ResetPasswordRoute());
                  },
                  child: const Text("Забыли пароль?"),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                onPressed: () async {
                  final api = ApiService();
                  try {
                    final response = await api.login(email.text, password.text);
                    if (response.statusCode == 200) {
                      final data = response.data;
                      await PersistenceHelper.saveAuthTokens(data['access'], data['refresh']);
                      
                      // Success! Already logged in via backend.
                      // Let's go to MainRoute directly or via CodeRoute but with real status
                      if (mounted) {
                        context.router.replaceAll([const MainRoute()]);
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ошибка входа. Проверьте данные.')),
                      );
                    }
                  }
                },
                child: const Text("Войти", style: TextStyle(color: Colors.white),),
              ),
            ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text("Нет аккаунта?"),

                  TextButton(
                    onPressed: () {
                      context.pushRoute(const RegisterRoute());
                    },
                    child: const Text("Регистрация"),
                  )
                ],
              ),

              const SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}