import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../data/rule_catalog.dart';
import '../models/rule_model.dart';
import '../widgets/joker_portrait.dart';
import '../widgets/png_button.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
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
                    child: Text('COLLECTION', textAlign: TextAlign.center, style: AppTheme.display(22)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: PngButton(
                          label: const ['Rules', 'Joker', 'Endings'][i],
                          height: 52,
                          asset: _tab == i ? AssetPaths.buttonPrimary : AssetPaths.buttonSecondary,
                          darkenOnPress: _tab == i,
                          onPressed: app.bindTap(() => setState(() => _tab = i)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: switch (_tab) {
                  0 => _RulesTab(unlocked: app.unlockedRules()),
                  1 => _JokerTab(unlocks: app.save.collectionUnlocks),
                  _ => _EndingsTab(seen: app.save.seenEndingIds),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RulesTab extends StatelessWidget {
  const _RulesTab({required this.unlocked});
  final Set<RuleId> unlocked;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.72,
      children: [
        for (final rule in RuleCatalog.rules)
          unlocked.contains(rule.id)
              ? Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.royalPurple.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rule.name, style: AppTheme.display(16)),
                      const SizedBox(height: 6),
                      Expanded(child: Text(rule.condition, style: AppTheme.body(13))),
                      Text('+${rule.bonus}', style: AppTheme.body(14, color: AppColors.gold)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    const Expanded(
                      child: PngAsset(path: AssetPaths.cardBackRule, fit: BoxFit.contain),
                    ),
                    Text(
                      'Keep playing to reveal this rule.',
                      textAlign: TextAlign.center,
                      style: AppTheme.body(12),
                    ),
                  ],
                ),
      ],
    );
  }
}

class _JokerTab extends StatelessWidget {
  const _JokerTab({required this.unlocks});
  final List<String> unlocks;

  static const tiles = [
    ('joker_idle', 'Idle', AssetPaths.jokerMenu, null),
    ('joker_grin', 'Grin', AssetPaths.jokerAct1, null),
    ('joker_laugh', 'Laugh', AssetPaths.jokerReactionWin, AssetPaths.sfxLaugh1),
    ('joker_shock', 'Shock', AssetPaths.jokerReactionLose, AssetPaths.sfxShock),
    ('joker_defeat', 'Defeat', AssetPaths.jokerEndingUnmasked, AssetPaths.sfxShowClear),
    ('joker_bow', 'Bow', AssetPaths.jokerEndingBow, AssetPaths.sfxCurtain),
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.8,
      children: [
        for (final tile in tiles)
          GestureDetector(
            onTap: () {
              if (!unlocks.contains(tile.$1)) {
                app.audio.playSfx(AssetPaths.sfxLocked);
                return;
              }
              app.audio.playSfx(AssetPaths.sfxButton);
              if (tile.$4 != null) app.audio.playSfx(tile.$4!);
              showGeneralDialog<void>(
                context: context,
                barrierColor: Colors.black.withValues(alpha: 0.8),
                barrierDismissible: true,
                barrierLabel: tile.$2,
                pageBuilder: (context, _, _) {
                  return SafeArea(
                    child: Stack(
                      children: [
                        Center(
                          child: JokerPortrait(
                            asset: tile.$3,
                            blinkAsset: tile.$1 == 'joker_idle' ? AssetPaths.jokerMenuBlink : null,
                            motion: tile.$1 == 'joker_laugh'
                                ? JokerMotion.laugh
                                : tile.$1 == 'joker_shock'
                                ? JokerMotion.shock
                                : JokerMotion.idle,
                            reduceMotion: app.save.reduceMotion,
                            height: 420,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IconTap(
                            icon: Icons.close,
                            tooltip: 'Close',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Opacity(
              opacity: unlocks.contains(tile.$1) ? 1 : 0.45,
              child: Column(
                children: [
                  Expanded(child: PngAsset(path: tile.$3, fit: BoxFit.contain)),
                  Text(tile.$2, style: AppTheme.body(14)),
                  if (!unlocks.contains(tile.$1))
                    const Icon(Icons.lock, color: AppColors.gold, size: 16),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EndingsTab extends StatelessWidget {
  const _EndingsTab({required this.seen});
  final List<String> seen;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final tiles = [
      ('free_ending', 'Free Ending', 'Clear Show 12, The Joker\'s Trap.', '/ending/free'),
      ('golden_ending', 'Golden Ending', 'Clear Show 16, Truth Behind the Mask.', '/ending/gold'),
    ];
    return Column(
      children: [
        for (final tile in tiles)
          Expanded(
            child: GestureDetector(
              onTap: seen.contains(tile.$1)
                  ? app.bindTap(() => context.go(tile.$4))
                  : () => app.audio.playSfx(AssetPaths.sfxLocked),
              child: Column(
                children: [
                  const Expanded(child: PngAsset(path: AssetPaths.iconMask, fit: BoxFit.contain)),
                  Text(tile.$2, style: AppTheme.display(18)),
                  Text(
                    seen.contains(tile.$1) ? 'Replay' : tile.$3,
                    textAlign: TextAlign.center,
                    style: AppTheme.body(14),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
