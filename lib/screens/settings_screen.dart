import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/png_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final save = app.save;
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: ContentFrame(
          child: Column(
            children: [
              Row(
                children: [
                  IconTap(
                    icon: Icons.arrow_back_ios_new,
                    tooltip: 'Back',
                    onPressed: app.bindTap(() => context.pop()),
                  ),
                  Expanded(
                    child: Text('SETTINGS', textAlign: TextAlign.center, style: AppTheme.display(24)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
                    Text('Music', style: AppTheme.body(16)),
                    Slider(
                      min: 0,
                      max: 100,
                      value: (save.musicVolume * 100).clamp(0, 100),
                      onChanged: (value) => app.setMusic(value / 100, persistNow: false),
                      onChangeEnd: (value) => app.setMusic(value / 100, persistNow: true),
                    ),
                    Text('Sound Effects', style: AppTheme.body(16)),
                    Slider(
                      min: 0,
                      max: 100,
                      value: (save.sfxVolume * 100).clamp(0, 100),
                      onChanged: (value) => app.setSfx(value / 100, persistNow: false),
                      onChangeEnd: (value) => app.setSfx(value / 100, persistNow: true),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Haptics', style: AppTheme.body(16)),
                      value: save.hapticsEnabled,
                      onChanged: app.setHaptics,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Reduce Motion', style: AppTheme.body(16)),
                      value: save.reduceMotion,
                      onChanged: app.setReduceMotion,
                    ),
                    const SizedBox(height: 12),
                    PngButton(
                      label: 'Replay Onboarding',
                      asset: AssetPaths.buttonSecondary,
                      onPressed: app.bindTap(() => context.push('/onboarding?preview=1')),
                    ),
                    const SizedBox(height: 8),
                    PngButton(
                      label: 'Reset Campaign Progress',
                      darkenOnPress: true,
                      onPressed: app.bindTap(() async {
                        final confirmed = await showGameDialog(
                          context: context,
                          title: 'Start a new game?',
                          body: 'Campaign progress and best scores will be erased. Your Golden Joker and settings will remain.',
                          cancelLabel: 'Cancel',
                          confirmLabel: 'Start Over',
                          destructive: true,
                        );
                        if (!confirmed || !context.mounted) return;
                        await app.resetCampaign();
                        if (!context.mounted) return;
                        context.go('/menu');
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
