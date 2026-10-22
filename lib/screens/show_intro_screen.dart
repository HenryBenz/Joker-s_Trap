import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../data/campaign_config.dart';
import '../widgets/joker_portrait.dart';
import '../widgets/png_button.dart';

class ShowIntroScreen extends StatelessWidget {
  const ShowIntroScreen({super.key, required this.showId});

  final int showId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final show = CampaignConfig.show(showId);
    if (show.isPremium && !app.save.goldenTicketOwned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/golden-ticket');
      });
    }
    final best = app.save.bestWinsFor(showId);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PngAsset(path: show.backgroundAsset, fit: BoxFit.cover),
          SafeArea(
            child: ContentFrame(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconTap(
                      icon: Icons.arrow_back_ios_new,
                      tooltip: 'Back',
                      onPressed: app.bindTap(() => context.go('/map?show=$showId')),
                    ),
                  ),
                  Expanded(
                    child: JokerPortrait(
                      asset: show.jokerAsset,
                      reduceMotion: app.save.reduceMotion,
                    ),
                  ),
                  InkPanel(
                    child: Column(
                      children: [
                        Text(show.actLabel, textAlign: TextAlign.center, style: AppTheme.body(14, color: AppColors.gold, shadow: false)),
                        Text(show.actTitle, textAlign: TextAlign.center, style: AppTheme.body(15, shadow: false)),
                        const SizedBox(height: 6),
                        Text('Show $showId', textAlign: TextAlign.center, style: AppTheme.body(15, shadow: false)),
                        Text(show.title, textAlign: TextAlign.center, style: AppTheme.display(24, shadow: false)),
                        const SizedBox(height: 8),
                        Text('Win at least 3 of 4 rounds.', textAlign: TextAlign.center, style: AppTheme.body(16, shadow: false)),
                        const SizedBox(height: 6),
                        Text(
                          'You have 2 Objections. Each one lets you replace a locked Anchor after the lie is revealed.',
                          textAlign: TextAlign.center,
                          style: AppTheme.body(15, shadow: false),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          best == null ? 'BEST: —' : 'BEST: $best / 4',
                          style: AppTheme.display(18, color: AppColors.gold, shadow: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PngButton(
                    label: 'Enter the Stage',
                    darkenOnPress: true,
                    onPressed: app.bindTap(() async {
                      await app.enterShow(showId);
                      if (context.mounted) context.go('/game');
                    }),
                  ),
                  const SizedBox(height: 8),
                  PngButton(
                    label: 'Back to Map',
                    asset: AssetPaths.buttonSecondary,
                    onPressed: app.bindTap(() => context.go('/map?show=$showId')),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
