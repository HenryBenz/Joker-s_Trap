import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../data/campaign_config.dart';
import '../widgets/png_button.dart';

class ShowResultScreen extends StatefulWidget {
  const ShowResultScreen({super.key, required this.showId});

  final int? showId;

  @override
  State<ShowResultScreen> createState() => _ShowResultScreenState();
}

class _ShowResultScreenState extends State<ShowResultScreen> {
  bool _applied = false;
  late int _showId = 1;
  late List<bool> _results = const [];
  late int _wins = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_applied) return;
    _applied = true;
    final app = AppScope.of(context);
    _showId = widget.showId ?? app.save.activeShowId ?? 1;
    _results = List<bool>.from(app.save.activeRoundResults);
    _wins = _results.where((win) => win).length;
    final cleared = _wins >= 3;
    app.applyShowResult(_showId, _results);
    app.audio.playDuckCue(
      cleared ? AssetPaths.sfxShowClear : AssetPaths.sfxShowFail,
      Duration(milliseconds: cleared ? 2400 : 2000),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final show = CampaignConfig.show(_showId);
    final cleared = _wins >= 3;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PngAsset(path: show.backgroundAsset, fit: BoxFit.cover),
          const ColoredBox(color: Color(0x99000000)),
          SafeArea(
            child: ContentFrame(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 220,
                    child: PngAsset(
                      path: cleared ? AssetPaths.jokerReactionLose : AssetPaths.jokerReactionWin,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(show.title, textAlign: TextAlign.center, style: AppTheme.body(16)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      cleared ? 'SHOW CLEARED' : 'THE TRAP CLOSES',
                      textAlign: TextAlign.center,
                      style: AppTheme.display(30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cleared ? 'You won $_wins of 4 rounds.' : 'Win at least 3 rounds to clear the show.',
                    textAlign: TextAlign.center,
                    style: AppTheme.body(16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final win in _results)
                        Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: win ? AppColors.success : AppColors.failure,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (cleared) ...[
                    PngButton(
                      label: 'Continue',
                      darkenOnPress: true,
                      onPressed: app.bindTap(() {
                        if (_showId == 12) {
                          context.go('/ending/free');
                        } else if (_showId == 16) {
                          context.go('/ending/gold');
                        } else {
                          context.go('/map?show=${_showId + 1}');
                        }
                      }),
                    ),
                    const SizedBox(height: 8),
                    PngButton(
                      label: 'Replay Show',
                      asset: AssetPaths.buttonSecondary,
                      onPressed: app.bindTap(() => context.go('/show/$_showId')),
                    ),
                  ] else ...[
                    PngButton(
                      label: 'Retry Show',
                      darkenOnPress: true,
                      onPressed: app.bindTap(() async {
                        await app.enterShow(_showId);
                        if (context.mounted) context.go('/game');
                      }),
                    ),
                    const SizedBox(height: 8),
                    PngButton(
                      label: 'Back to Map',
                      asset: AssetPaths.buttonSecondary,
                      onPressed: app.bindTap(() => context.go('/map?show=$_showId')),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
