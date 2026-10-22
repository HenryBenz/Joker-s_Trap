import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../widgets/png_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.preview});

  final bool preview;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      AssetPaths.onboardingAnchor,
      'LOCK THE ANCHOR',
      'Choose your first card while two possible rules remain in play.',
      'Next',
    ),
    (
      AssetPaths.onboardingFlip,
      'WATCH THE LIE',
      'The Joker replaces the rule. Your first card stays locked.',
      'Next',
    ),
    (
      AssetPaths.onboardingRecover,
      'BUILD AROUND IT',
      'Choose two more cards, beat the Joker\'s score, and win three rounds.',
      'Enter the Theatre',
    ),
  ];

  Future<void> _finish() async {
    final app = AppScope.of(context);
    if (widget.preview) {
      context.pop();
      return;
    }
    await app.completeOnboarding();
    if (!mounted) return;
    context.go('/menu');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return PopScope(
      canPop: widget.preview,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const PngAsset(path: AssetPaths.bgOnboarding, fit: BoxFit.cover),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                        child: _page < 2
                        ? Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xE612002B),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.gold.withValues(alpha: 0.9)),
                              ),
                              child: TextButton(
                                onPressed: app.bindTap(_finish),
                                child: Text('Skip', style: AppTheme.body(16, color: AppColors.gold, shadow: false)),
                              ),
                            ),
                          )
                        : const SizedBox(height: 48),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (index) => setState(() => _page = index),
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        return ContentFrame(
                          child: Column(
                            children: [
                              Expanded(
                                child: PngAsset(path: page.$1, fit: BoxFit.contain),
                              ),
                              InkPanel(
                                child: Column(
                                  children: [
                                    Text(page.$2, textAlign: TextAlign.center, style: AppTheme.display(26, shadow: false)),
                                    const SizedBox(height: 8),
                                    Text(page.$3, textAlign: TextAlign.center, style: AppTheme.body(17, shadow: false)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _page ? AppColors.gold : AppColors.cream.withValues(alpha: 0.35),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ContentFrame(
                    child: PngButton(
                      label: _pages[_page].$4,
                      darkenOnPress: true,
                      onPressed: app.bindTap(() {
                        if (_page < 2) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        } else {
                          _finish();
                        }
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
