import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:food_save/core/router/app_router.gr.dart';
import 'package:food_save/core/services/persistence_helper.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SequenceTextAnimation(text: "Food Save")
        ),
      ),
    );
  }
}

class SequenceTextAnimation extends StatefulWidget {
  final String text;
  const SequenceTextAnimation({super.key, required this.text});

  @override
  State<SequenceTextAnimation> createState() => SequenceTextAnimationState();
}

class SequenceTextAnimationState extends State<SequenceTextAnimation> {
  late List<bool> _visibleChars;
  bool _isLastWordRed = false; // Флаг для покраснения последнего слова

  @override
  void initState() {
    super.initState();
    _visibleChars = List.generate(widget.text.length, (index) => index == 0);
    _startAnimation();
  }

  void _startAnimation() async {
    // 1. Ищем границы слов
    int firstSpaceIndex = widget.text.indexOf(' ');
    
    int endOfFirstWord = (firstSpaceIndex == -1) ? widget.text.length : firstSpaceIndex;
    // Если пробелов нет, начало последнего слова — 0, иначе — индекс после пробела

    // --- ЭТАП 1: Ждем секунду после появления первой буквы ---
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // --- ЭТАП 2: Показываем остаток первого слова ---
    setState(() {
      for (int i = 1; i < endOfFirstWord; i++) {
        _visibleChars[i] = true;
      }
    });

    // --- ЭТАП 3: Ждем секунду перед остальным текстом ---
    await Future.delayed(const Duration(milliseconds: 10));
    if (!mounted) return;

    // --- ЭТАП 4: Показываем все остальные слова ---
    setState(() {
      for (int i = endOfFirstWord; i < widget.text.length; i++) {
        _visibleChars[i] = true;
      }
    });

    // --- ЭТАП 5: Ждем секунду и красим последнее слово в красный ---
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _isLastWordRed = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final hasSeenOnboarding = await PersistenceHelper.hasSeenOnboarding();
    final isLoggedIn = await PersistenceHelper.isLoggedIn();

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      context.router.replace(const OnBoardRoute());
    } else if (!isLoggedIn) {
      context.router.replace(const LoginRoute());
    } else {
      context.router.replace(const MainRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.text.split('');
    int lastSpaceIndex = widget.text.lastIndexOf(' ');
    int startOfLastWord = (lastSpaceIndex == -1) ? 0 : lastSpaceIndex + 1;

    return Wrap(
      children: List.generate(chars.length, (index) {
        // Определяем, относится ли эта буква к последнему слову
        bool isPartOfLastWord = index >= startOfLastWord;

        return AnimatedOpacity(
          opacity: _visibleChars[index] ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(left: _visibleChars[index] ? 0 : 4),
            // Используем AnimatedDefaultTextStyle для плавной смены цвета
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                // Если это последнее слово и флаг активен — красим в красный
                color: (_isLastWordRed && isPartOfLastWord) 
                    ? Color(0xFFE53935)
                    : Colors.black,
              ),
              child: Text(chars[index]),
            ),
          ),
        );
      }),
    );
  }
}