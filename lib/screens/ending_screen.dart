import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../widgets/joker_portrait.dart';
import '../widgets/png_button.dart';

class EndingScreen extends StatefulWidget {
  const EndingScreen({super.key, required this.golden});

  final bool golden;

  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _play = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );
  bool _showButtons = false;
  bool _showSkip = false;
  Timer? _skipTimer;

  bool _opened = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_opened) return;
    _opened = true;
    final app = AppScope.of(context);
    app.markEnding(widget.golden ? 'golden_ending' : 'free_ending');
    app.audio.playSfx(AssetPaths.sfxCurtain);
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        app.audio.playDuckCue(
          AssetPaths.sfxConfetti,
          const Duration(milliseconds: 1200),
        );
      }
    });
    if (app.save.reduceMotion) {
      _play.value = 1;
      _showButtons = true;
    } else {
      _play.forward();
    }
    _play.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showButtons = true);
      }
    });
    _skipTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSkip = true);
    });
  }

  @override
  void dispose() {
    _skipTimer?.cancel();
    _play.dispose();
    super.dispose();
  }

  void _skip() {
    _play.value = 1;
    setState(() => _showButtons = true);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = app.save.reduceMotion ? 1.0 : _play.value;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PngAsset(
            path: widget.golden ? AssetPaths.bgEndingGold : AssetPaths.bgEndingFree,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: -200 * (1 - t),
            top: 0,
            bottom: 0,
            width: MediaQuery.sizeOf(context).width * 0.5,
            child: const ColoredBox(color: Color(0xAA7A1020)),
          ),
          Positioned(
            right: -200 * (1 - t),
            top: 0,
            bottom: 0,
            width: MediaQuery.sizeOf(context).width * 0.5,
            child: const ColoredBox(color: Color(0xAA7A1020)),
          ),
          for (var i = 0; i < 5; i++)
            Positioned(
              left: 40.0 + i * 60,
              bottom: -200 + (420 * t) + i * 20,
              child: const SizedBox(
                width: 48,
                height: 70,
                child: PngAsset(path: AssetPaths.cardBack, fit: BoxFit.contain),
              ),
            ),
          Positioned(
            top: 80 + (180 * (1 - t)),
            left: 0,
            right: 0,
            child: const SizedBox(
              height: 120,
              child: PngAsset(path: AssetPaths.iconMask, fit: BoxFit.contain),
            ),
          ),
          Align(
            alignment: Alignment(0, -0.2 + (0.15 * t)),
            child: JokerPortrait(
              asset: widget.golden ? AssetPaths.jokerEndingBow : AssetPaths.jokerEndingUnmasked,
              motion: widget.golden ? JokerMotion.bow : JokerMotion.idle,
              reduceMotion: app.save.reduceMotion,
              height: 360,
            ),
          ),
          Opacity(
            opacity: (t - 0.55).clamp(0, 1),
            child: const PngAsset(path: AssetPaths.fxConfetti, fit: BoxFit.cover),
          ),
          if (_showSkip && !_showButtons)
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: TextButton(
                  onPressed: app.bindTap(_skip),
                  child: Text('Skip', style: AppTheme.body(16, color: AppColors.gold)),
                ),
              ),
            ),
          if (_showButtons)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: ContentFrame(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkPanel(
                        child: Column(
                          children: [
                            Text(
                              widget.golden ? 'TRUTH BEHIND THE MASK' : 'YOU BROKE THE TRAP',
                              textAlign: TextAlign.center,
                              style: AppTheme.display(22, shadow: false),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.golden
                                  ? 'The Joker bows. For once, the applause is honest.'
                                  : 'The rules were never the prison. Believing the first rule was.',
                              textAlign: TextAlign.center,
                              style: AppTheme.body(16, shadow: false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      PngButton(
                        label: 'Return to Theatre',
                        darkenOnPress: true,
                        onPressed: app.bindTap(() => context.go('/map')),
                      ),
                      const SizedBox(height: 8),
                      PngButton(
                        label: widget.golden ? 'View Collection' : 'Discover the Golden Act',
                        asset: AssetPaths.buttonGold,
                        inkLabel: true,
                        onPressed: app.bindTap(() {
                          if (widget.golden) {
                            context.push('/collection');
                          } else if (app.save.goldenTicketOwned) {
                            context.go('/map?show=13');
                          } else {
                            context.push('/golden-ticket');
                          }
                        }),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
