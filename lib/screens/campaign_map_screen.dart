import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../data/campaign_config.dart';
import '../models/show_config.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/png_button.dart';

class CampaignMapScreen extends StatefulWidget {
  const CampaignMapScreen({super.key, required this.initialAct});

  final int initialAct;

  @override
  State<CampaignMapScreen> createState() => _CampaignMapScreenState();
}

class _CampaignMapScreenState extends State<CampaignMapScreen> {
  late final PageController _pages = PageController(initialPage: widget.initialAct);
  late int _act = widget.initialAct;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = AppScope.of(context);
      app.setMapAct(_act);
      app.audio.playMusic(AssetPaths.musicForAct(_act), loop: true);
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _setAct(int act) {
    setState(() => _act = act);
    final app = AppScope.of(context);
    app.setMapAct(act);
    app.audio.playMusic(AssetPaths.musicForAct(act), loop: true);
  }

  void _openShow(ShowConfig show, AppController app) {
    final owned = app.save.goldenTicketOwned;
    if (show.isPremium && !owned) {
      context.push('/golden-ticket');
      return;
    }
    if (show.id > app.save.highestUnlockedShow) {
      app.audio.playSfx(AssetPaths.sfxLocked);
      showGameToast(context, 'Clear the previous show first.');
      return;
    }
    context.go('/show/${show.id}');
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final show = CampaignConfig.shows[_act * 4];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PngAsset(path: AssetPaths.mapBackground(_act), fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconTap(
                        icon: Icons.home_rounded,
                        tooltip: 'Home',
                        onPressed: app.bindTap(() => context.go('/menu')),
                      ),
                      IconTap(
                        icon: Icons.chevron_left,
                        onPressed: _act == 0
                            ? null
                            : app.bindTap(() {
                                _pages.previousPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                );
                              }),
                      ),
                      Expanded(
                        child: InkPanel(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text(
                            show.actLabel,
                            textAlign: TextAlign.center,
                            style: AppTheme.display(18, shadow: false),
                          ),
                        ),
                      ),
                      IconTap(
                        icon: Icons.chevron_right,
                        onPressed: _act == 3
                            ? null
                            : app.bindTap(() {
                                _pages.nextPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                );
                              }),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                InkPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        '${app.freeShowsCleared} / 12 FREE SHOWS CLEARED',
                        textAlign: TextAlign.center,
                        style: AppTheme.body(14, color: AppColors.gold, shadow: false),
                      ),
                      Text(show.actTitle, textAlign: TextAlign.center, style: AppTheme.body(15, shadow: false)),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: 4,
                    onPageChanged: _setAct,
                    itemBuilder: (context, act) {
                      final nodes = CampaignConfig.showsForAct(act);
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final area = Size(constraints.maxWidth, constraints.maxHeight);
                          final fitted = applyBoxFit(BoxFit.contain, const Size(650, 1900), area);
                          final dest = Alignment.center.inscribe(fitted.destination, Offset.zero & area);
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fromRect(
                                rect: dest,
                                child: const PngAsset(path: AssetPaths.mapPath, fit: BoxFit.fill),
                              ),
                              for (var i = 0; i < nodes.length; i++)
                                _placedNode(
                                  area: area,
                                  dest: dest,
                                  index: i,
                                  show: nodes[i],
                                  onTap: () => _openShow(nodes[i], app),
                                ),
                              if (act == 3 && !app.save.goldenTicketOwned)
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    child: Center(
                                      child: ContentFrame(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'GOLDEN JOKER REQUIRED',
                                                textAlign: TextAlign.center,
                                                style: AppTheme.display(26),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            PngButton(
                                              label: 'Golden Joker',
                                              asset: AssetPaths.buttonGold,
                                              inkLabel: true,
                                              onPressed: app.bindTap(() => context.push('/golden-ticket')),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    },
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

/// Gem centers on `map_path.png` (650×1900), top show first.
const _pathStops = <Offset>[
  Offset(0.543, 0.121),
  Offset(0.316, 0.392),
  Offset(0.720, 0.602),
  Offset(0.335, 0.831),
];

Widget _placedNode({
  required Size area,
  required Rect dest,
  required int index,
  required ShowConfig show,
  required VoidCallback onTap,
}) {
  const width = 136.0;
  const circle = 76.0;
  final stop = _pathStops[index.clamp(0, _pathStops.length - 1)];
  final cx = dest.left + dest.width * stop.dx;
  final cy = dest.top + dest.height * stop.dy;
  final left = (cx - width / 2).clamp(0.0, math.max(0.0, area.width - width)).toDouble();
  final top = (cy - circle / 2).clamp(0.0, math.max(0.0, area.height - circle - 36)).toDouble();
  return Positioned(
    left: left,
    top: top,
    width: width,
    child: _ShowNode(show: show, onTap: onTap),
  );
}

class _ShowNode extends StatefulWidget {
  const _ShowNode({required this.show, required this.onTap});

  final ShowConfig show;
  final VoidCallback onTap;

  @override
  State<_ShowNode> createState() => _ShowNodeState();
}

class _ShowNodeState extends State<_ShowNode> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final save = app.save;
    final ticketLocked = widget.show.isPremium && !save.goldenTicketOwned;
    final progressLocked = widget.show.id > save.highestUnlockedShow;
    final cleared = save.clearedShowIds.contains(widget.show.id);
    final unlocked = !ticketLocked && !progressLocked && !cleared;
    final asset = progressLocked && !ticketLocked
        ? AssetPaths.nodeLocked
        : (cleared || ticketLocked ? AssetPaths.nodeCleared : AssetPaths.nodeUnlocked);
    final best = save.bestWinsFor(widget.show.id);
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (unlocked && !app.save.reduceMotion)
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) => Opacity(
                      opacity: 0.35 + (0.55 * _pulse.value),
                      child: child,
                    ),
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonMagenta,
                      ),
                    ),
                  ),
                PngAsset(path: asset, fit: BoxFit.contain),
                Text('${widget.show.id}', style: AppTheme.display(20, color: AppColors.ink, shadow: false)),
                if (ticketLocked)
                  const Icon(Icons.confirmation_number, color: AppColors.ink, size: 18),
                if (progressLocked && !ticketLocked)
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(Icons.lock, color: AppColors.gold, size: 18),
                  ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xE612002B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                widget.show.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.body(12, height: 1.15, shadow: false),
              ),
            ),
          ),
          if (cleared)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  const Icon(Icons.workspace_premium, color: AppColors.gold, size: 14),
                Text(' ${best ?? 0}/4', style: AppTheme.body(12, color: AppColors.gold)),
              ],
            ),
        ],
      ),
    );
  }
}
