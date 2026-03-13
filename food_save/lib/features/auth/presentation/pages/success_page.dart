import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:food_save/core/router/app_router.gr.dart';

@RoutePage()
class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  static const accent = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Container(
              width: 120,
              height: 120,

              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.check,
                size: 70,
                color: accent,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Готово!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Вы успешно вошли",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
              ),

              onPressed: () async {
                if (context.mounted) {
                  context.router.replaceAll([const MainRoute()]);
                }
              },

              child: const Text("Продолжить"),
            )
          ],
        ),
      ),
    );
  }
}