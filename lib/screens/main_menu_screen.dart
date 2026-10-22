import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../widgets/audio_icon_button.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/joker_portrait.dart';
import '../widgets/png_button.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeCorrupt());
  }

  Future<void> _maybeCorrupt() async {
    final app = AppScope.of(context);
    if (!app.corruptNotice) return;
    app.corruptNotice = false;
    app.audio.playSfx(AssetPaths.sfxError);
    await showGameDialog(
      context: context,
      title: 'Progress Reset',
      body: 'Local progress could not be read, so a new campaign was created.',
      cancelLabel: 'OK',
      confirmLabel: 'OK',
    );
  }

  void _continue(AppController app) {
    final save = app.save;
    if (save.activeShowId != null) {
      if (save.activeRoundResults.length >= 4) {
        context.go('/show-result?show=${save.activeShowId}');
      } else {
        context.go('/game');
      }
    } else {
      context.go('/map');
    }
  }

  Future<void> _newGame(AppController app) async {
    if (!app.save.campaignStarted) {
      await app.startNewGame();
      if (!mounted) return;
      context.go('/map');
      return;
    }
    final confirmed = await showGameDialog(
      context: context,
      title: 'Start a new game?',
      body: 'Campaign progress and best scores will be erased. Your Golden Joker and settings will remain.',
      cancelLabel: 'Cancel',
      confirmLabel: 'Start Over',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await app.startNewGame();
    if (!mounted) return;
    context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PngAsset(path: AssetPaths.bgMainMenu, fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: AudioIconButton(
                    muted: app.temporaryMute,
                    onPressed: app.bindTap(app.toggleMute),
                  ),
                ),
                SizedBox(
                  height: height * 0.38,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white, Colors.transparent],
                      stops: [0.62, 0.84, 1],
                    ).createShader(rect),
                    child: JokerPortrait(
                      asset: AssetPaths.jokerMenu,
                      blinkAsset: AssetPaths.jokerMenuBlink,
                      reduceMotion: app.save.reduceMotion,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 72,
                  child: PngAsset(path: AssetPaths.logo, fit: BoxFit.contain),
                ),
                Expanded(
                  child: ContentFrame(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 12),
                      children: [
                        PngButton(
                          label: 'Continue',
                          darkenOnPress: true,
                          onPressed: app.save.campaignStarted
                              ? app.bindTap(() => _continue(app))
                              : null,
                        ),
                        const SizedBox(height: 8),
                        PngButton(
                          label: 'New Game',
                          darkenOnPress: true,
                          onPressed: app.bindTap(() => _newGame(app)),
                        ),
                        const SizedBox(height: 8),
                        PngButton(
                          label: 'Collection',
                          asset: AssetPaths.buttonSecondary,
                          onPressed: app.bindTap(() => context.push('/collection')),
                        ),
                        const SizedBox(height: 8),
                        PngButton(
                          label: 'Golden Joker',
                          asset: AssetPaths.buttonGold,
                          inkLabel: true,
                          onPressed: app.bindTap(() => context.push('/golden-ticket')),
                        ),
                        const SizedBox(height: 8),
                        PngButton(
                          label: 'How to Play',
                          asset: AssetPaths.buttonSecondary,
                          onPressed: app.bindTap(() => context.push('/how-to-play')),
                        ),
                        const SizedBox(height: 8),
                        PngButton(
                          label: 'Settings',
                          asset: AssetPaths.buttonSecondary,
                          onPressed: app.bindTap(() => context.push('/settings')),
                        ),
                      ],
                    ),
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
