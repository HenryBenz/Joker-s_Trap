import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/png_button.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.7),
      child: SafeArea(
        child: ContentFrame(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('THE CURTAIN IS DOWN', textAlign: TextAlign.center, style: AppTheme.display(28)),
              ),
              const SizedBox(height: 20),
              PngButton(
                label: 'Resume',
                darkenOnPress: true,
                onPressed: app.bindTap(onResume),
              ),
              const SizedBox(height: 8),
              PngButton(
                label: 'Restart Show',
                asset: AssetPaths.buttonSecondary,
                onPressed: app.bindTap(() async {
                  final confirmed = await showGameDialog(
                    context: context,
                    title: 'Restart this show?',
                    body: 'Current round progress will be lost.',
                    cancelLabel: 'Cancel',
                    confirmLabel: 'Restart',
                    destructive: true,
                  );
                  if (confirmed) onRestart();
                }),
              ),
              const SizedBox(height: 8),
              PngButton(
                label: 'Settings',
                asset: AssetPaths.buttonSecondary,
                onPressed: app.bindTap(() => context.push('/settings')),
              ),
              const SizedBox(height: 8),
              PngButton(
                label: 'Quit to Map',
                asset: AssetPaths.buttonSecondary,
                onPressed: app.bindTap(() async {
                  final confirmed = await showGameDialog(
                    context: context,
                    title: 'Leave the stage?',
                    body: 'This show will restart from round one next time.',
                    cancelLabel: 'Stay',
                    confirmLabel: 'Leave',
                    destructive: true,
                  );
                  if (confirmed) onQuit();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
