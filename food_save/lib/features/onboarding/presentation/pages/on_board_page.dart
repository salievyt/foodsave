import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/services/persistence_helper.dart';
import 'package:food_save/core/widgets/base_page.dart';
import 'onboard_card.dart';
import 'onboard_model.dart';

@RoutePage()
class OnBoardPage extends StatefulWidget {
  const OnBoardPage({super.key});

  @override
  State<OnBoardPage> createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  final PageController _controller = PageController();
  int page = 0;

  late final List<OnboardModel> pages = [
    OnboardModel(
      title: "Спасай еду.\nЭкономь деньги.",
      description: "Мы следим за продуктами в твоём холодильнике и подсказываем, что из них можно приготовить.",
      image: "assets/illustrations/fridge.png",
    ),
    OnboardModel(
      title: "Знакомо?",
      description: "Овощи портятся\nМолоко забывается\nЕда отправляется в мусор\n\nКаждый человек выбрасывает десятки продуктов в год.",
      image: "assets/illustrations/problem.png",
    ),
    OnboardModel(
      title: "Просто сфотографируй чек",
      description: "FoodSave автоматически распознает купленные продукты, добавит их в холодильник и поставит срок годности.",
      image: "assets/illustrations/receipt.png",
    ),
    OnboardModel(
      title: "Твой холодильник\nпод контролем",
      description: "Авокадо — 3 дня\nКурица — 2 дня\nМолоко — 1 день\n\nМы заранее предупреждаем, что скоро испортится.",
      image: "assets/illustrations/inventory.png",
    ),
    OnboardModel(
      title: "Что приготовить?",
      description: "AI-помощник мгновенно предлагает вкусные блюда из продуктов, которые скоро испортятся.",
      image: "assets/illustrations/recipes.png",
    ),
    OnboardModel(
      title: "Ты будешь удивлён",
      description: "💰 Экономия до 30%\n🌍 Меньше отходов\n📊 Статистика спасённой еды",
      image: "assets/illustrations/eco.png",
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnBoardPageContent(
      pages: pages,
      currentPage: page,
      controller: _controller,
      onPageChanged: (i) => setState(() => page = i),
    );
  }
}

class _OnBoardPageContent extends BasePage {
  final List<OnboardModel> pages;
  final int currentPage;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  const _OnBoardPageContent({
    required this.pages,
    required this.currentPage,
    required this.controller,
    required this.onPageChanged,
  });

  @override
  Widget buildBody(BuildContext context) {
    final bool isLastPage = currentPage == pages.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isLastPage ? 0.0 : 1.0,
                    child: TextButton(
                      onPressed: isLastPage ? null : () async {
                        await PersistenceHelper.setOnboardingSeen();
                        if (context.mounted) {
                          context.router.replace(const LoginRoute());
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: const Text(
                        "Пропустить",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: controller,
                physics: const BouncingScrollPhysics(),
                itemCount: pages.length,
                onPageChanged: onPageChanged,
                itemBuilder: (_, i) {
                  return OnboardCard(data: pages[i]);
                },
              ),
            ),

            // Indicators & Button Controls
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage == index ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        if (isLastPage) {
                          await PersistenceHelper.setOnboardingSeen();
                          if (context.mounted) context.router.replace(const LoginRoute());
                        } else {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          isLastPage ? "Начать пользоваться" : "Дальше",
                          key: ValueKey<bool>(isLastPage),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
