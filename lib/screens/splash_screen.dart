import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../widgets/png_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final started = DateTime.now();
    final app = AppScope.of(context);
    await app.audio.init().timeout(const Duration(seconds: 3), onTimeout: () {});
    await app.load().timeout(const Duration(seconds: 3), onTimeout: () {});
    await app.purchases.start().timeout(
      const Duration(seconds: 3),
      onTimeout: () {},
    );
    final elapsed = DateTime.now().difference(started);
    if (elapsed < const Duration(milliseconds: 1500)) {
      await Future<void>.delayed(const Duration(milliseconds: 1500) - elapsed);
    }
    if (!mounted) return;
    if (app.save.onboardingComplete) {
      context.go('/menu');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PngAsset(path: AssetPaths.bgSplash, fit: BoxFit.cover),
          Positioned(
            top: height * 0.42 - 80,
            left: 24,
            right: 24,
            child: const SizedBox(
              height: 160,
              child: PngAsset(path: AssetPaths.logo, fit: BoxFit.contain),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
