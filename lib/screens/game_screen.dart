import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../data/campaign_config.dart';
import '../data/rule_catalog.dart';
import '../game/game_controller.dart';
import '../models/rule_model.dart';
import '../widgets/audio_icon_button.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/joker_portrait.dart';
import '../widgets/playing_card.dart';
import '../widgets/png_button.dart';
import '../widgets/rule_panel.dart';
import 'pause_overlay.dart';
import 'round_result_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  GameController? _game;
  int _generation = 0;
  bool _paused = false;
  bool _dialog = false;
  bool _revealRunning = false;
  bool _showScores = false;
  bool _showOverlay = false;
  bool _committed = false;
  int _jokerShown = 0;
  bool _finalRuleVisible = false;
  double _flip = 0;
  bool _optionsResolved = false;
  bool _jokerSmirk = false;
  RuleId? _tooltip;
  List<bool> _dots = const [];
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _startRound();
  }

  void _startRound() {
    final app = AppScope.of(context);
    final showId = app.save.activeShowId;
    if (showId == null) return;
    final show = CampaignConfig.show(showId);
    if (show.isPremium && !app.save.goldenTicketOwned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/golden-ticket');
      });
      return;
    }
    app.session.sync(showId);
    _game?.removeListener(_onGame);
    _game?.dispose();
    _generation += 1;
    _revealRunning = false;
    _showScores = false;
    _showOverlay = false;
    _committed = false;
    _jokerShown = 0;
    _finalRuleVisible = false;
    _flip = 0;
    _optionsResolved = false;
    _jokerSmirk = false;
    _tooltip = null;
    _dots = List<bool>.from(app.save.activeRoundResults);
    _game = GameController(
      show: show,
      roundIndex: app.save.activeRoundIndex.clamp(0, 3),
      objectionsLeft: app.session.objections,
    )..addListener(_onGame);
    app.audio.beginRound();
    final generation = _generation;
    for (var i = 0; i < 6; i++) {
      Future<void>.delayed(Duration(milliseconds: 90 * i), () {
        if (!mounted || generation != _generation) return;
        app.audio.playDeal();
      });
    }
    if (!_ticker.isActive) _ticker.start();
    setState(() {});
  }

  void _onGame() {
    if (mounted) setState(() {});
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1000000;
    _lastTick = elapsed;
    final game = _game;
    if (game == null || _paused || _dialog || _revealRunning) return;
    final warn = game.tick(dt.clamp(0, 0.1));
    if (warn) {
      AppScope.of(context).audio.playSfx(AssetPaths.sfxTimer);
    }
    if (game.submitted && game.phase == RoundPhase.revealingResult && !_revealRunning) {
      _runReveal();
    }
  }

  Future<void> _wait(int milliseconds) async {
    var left = milliseconds;
    while (left > 0) {
      if (!mounted) return;
      if (_paused || _dialog) {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        continue;
      }
      final step = min(40, left);
      await Future<void>.delayed(Duration(milliseconds: step));
      left -= step;
    }
  }

  Future<void> _runFlip() async {
    final app = AppScope.of(context);
    final game = _game;
    if (game == null) return;
    app.audio.playSfx(AssetPaths.sfxRuleFlip);
    await AppHaptics.medium(app.save.hapticsEnabled);
    if (app.save.reduceMotion) {
      await _wait(200);
      if (!mounted) return;
      setState(() => _finalRuleVisible = true);
    } else {
      const step = 16;
      for (var elapsed = 0; elapsed < 300; elapsed += step) {
        await _wait(step);
        if (!mounted) return;
        setState(() => _flip = (elapsed + step) / 300);
      }
      setState(() => _finalRuleVisible = true);
      for (var elapsed = 0; elapsed < 300; elapsed += step) {
        await _wait(step);
        if (!mounted) return;
        setState(() => _flip = 1 - (elapsed + step) / 300);
      }
      setState(() => _flip = 0);
    }
    setState(() {
      _optionsResolved = true;
      _jokerSmirk = true;
    });
    await _wait(800);
    if (!mounted) return;
    setState(() => _jokerSmirk = false);
    game.finishFlip();
    app.session.objections = game.objectionsLeft;
  }

  Future<void> _runReveal() async {
    if (_revealRunning) return;
    _revealRunning = true;
    final app = AppScope.of(context);
    final game = _game!;
    await _wait(450);
    for (var i = 1; i <= 3; i++) {
      if (!mounted) return;
      setState(() => _jokerShown = i);
      await _wait(180);
    }
    if (!mounted) return;
    setState(() => _showScores = true);
    final won = game.playerWon == true;
    if (won) {
      app.audio.playDuckCue(AssetPaths.sfxWin, const Duration(milliseconds: 1500));
      await AppHaptics.success(app.save.hapticsEnabled);
    } else {
      await app.audio.playRoundLoss();
      await AppHaptics.error(app.save.hapticsEnabled);
    }
    if (!_committed) {
      _committed = true;
      await app.commitRound(won);
      if (mounted) {
        setState(() => _dots = List<bool>.from(app.save.activeRoundResults));
      }
    }
    await _wait(1200);
    if (!mounted) return;
    game.markComplete();
    setState(() => _showOverlay = true);
  }

  void _onCard(int index) {
    final game = _game;
    if (game == null) return;
    final before = List<int?>.from(game.picks);
    final phase = game.phase;
    game.tapCard(index);
    final app = AppScope.of(context);
    if (phase == RoundPhase.waitingForAnchor && game.phase == RoundPhase.flippingRule) {
      app.audio.playSfx(AssetPaths.sfxSelect);
      AppHaptics.light(app.save.hapticsEnabled);
      _runFlip();
      return;
    }
    if (before.toString() != game.picks.toString()) {
      final removed = before.whereType<int>().length > game.picks.whereType<int>().length;
      app.audio.playSfx(removed ? AssetPaths.sfxDeselect : AssetPaths.sfxSelect);
      AppHaptics.light(app.save.hapticsEnabled);
    }
  }

  Future<void> _objection() async {
    final game = _game;
    if (game == null || !game.objectionEnabled) return;
    setState(() => _dialog = true);
    final spend = await showGameDialog(
      context: context,
      title: 'OBJECT TO THE LIE?',
      body: 'Spend 1 Objection to unlock the Anchor and choose all three cards again. The revealed rule will stay.',
      cancelLabel: 'Keep Hand',
      confirmLabel: 'Spend Objection',
      barrierDismissible: false,
    );
    if (!mounted) return;
    setState(() => _dialog = false);
    if (!spend) return;
    final app = AppScope.of(context);
    app.audio.playSfx(AssetPaths.sfxObjection);
    game.spendObjection();
    app.session.objections = game.objectionsLeft;
    setState(() {});
  }

  void _playHand() {
    final game = _game;
    if (game == null || !game.canPlayHand) return;
    game.submit();
    _runReveal();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final background = state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden;
    if (!background || _paused) {
      if (background) AppScope.of(context).audio.holdForResume();
      return;
    }
    setState(() => _paused = true);
    AppScope.of(context).audio.holdForResume();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _game?.removeListener(_onGame);
    _game?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final game = _game;
    if (game == null) {
      return const Scaffold(backgroundColor: AppColors.midnight);
    }
    final show = game.show;
    final round = game.round;
    final mainRule = _finalRuleVisible ? round.finalRule : round.initial;
    final angle = _flip * pi / 2;
    final short = MediaQuery.sizeOf(context).height < 700;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PngAsset(path: show.backgroundAsset, fit: BoxFit.cover),
          TickerMode(
            enabled: !_paused && !_dialog,
            child: SafeArea(
              child: ContentFrame(
                padding: 12,
                child: Column(
                  children: [
                    _hud(app, game),
                    SizedBox(
                      height: short ? 64 : 90,
                      child: JokerPortrait(
                        asset: _showOverlay
                            ? (game.playerWon == true
                                  ? AssetPaths.jokerReactionLose
                                  : AssetPaths.jokerReactionWin)
                            : show.jokerAsset,
                        motion: _jokerSmirk
                            ? JokerMotion.laugh
                            : _showScores
                            ? (game.playerWon == true ? JokerMotion.shock : JokerMotion.laugh)
                            : JokerMotion.idle,
                        reduceMotion: app.save.reduceMotion,
                      ),
                    ),
                    SizedBox(
                      height: short ? 48 : 54,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < 6; i++)
                            Transform.rotate(
                              angle: (i - 2.5) * 0.08,
                              child: SizedBox(
                                width: 34,
                                child: PlayingCard(
                                  card: game.jokerHand[i],
                                  faceDown: !_jokerFaceUp(game, i),
                                  width: 34,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _tooltip = null),
                      child: Column(
                        children: [
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(_finalRuleVisible ? -angle : angle),
                            child: RulePanel(
                              rule: mainRule,
                              label: _finalRuleVisible ? 'THE REAL RULE' : 'THE CURRENT STORY',
                              onTap: () => setState(() => _tooltip = mainRule),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: RulePanel(
                                  rule: round.optionA,
                                  label: 'POSSIBLE LIE A',
                                  compact: true,
                                  gold: _optionsResolved && round.finalIsA,
                                  dimmed: _optionsResolved && !round.finalIsA,
                                  onTap: () => setState(() => _tooltip = round.optionA),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RulePanel(
                                  rule: round.optionB,
                                  label: 'POSSIBLE LIE B',
                                  compact: true,
                                  gold: _optionsResolved && !round.finalIsA,
                                  dimmed: _optionsResolved && round.finalIsA,
                                  onTap: () => setState(() => _tooltip = round.optionB),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_tooltip != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${RuleCatalog.byId(_tooltip!).condition}  +${RuleCatalog.byId(_tooltip!).bonus}',
                          textAlign: TextAlign.center,
                          style: AppTheme.body(12, color: AppColors.gold),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Expanded(child: _hand(game)),
                    if (_showScores && !_showOverlay && game.playerScore != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(child: _scoreColumn('YOU', game.playerScore!.base, game.playerScore!.bonus, game.playerScore!.total)),
                            Expanded(child: _scoreColumn('JOKER', game.jokerScore.base, game.jokerScore.bonus, game.jokerScore.total)),
                          ],
                        ),
                      ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xE612002B),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: PngButton(
                                label: 'Objection (${game.objectionsLeft})',
                                asset: AssetPaths.buttonSecondary,
                                height: 54,
                                onPressed: game.objectionEnabled ? app.bindTap(_objection) : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: PngButton(
                                label: 'Play Hand',
                                darkenOnPress: true,
                                height: 54,
                                onPressed: game.canPlayHand ? app.bindTap(_playHand) : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          if (_showScores && game.playerWon == true)
            const IgnorePointer(child: PngAsset(path: AssetPaths.fxConfetti, fit: BoxFit.cover)),
          if (_showScores && game.playerWon == false)
            const IgnorePointer(
              child: Opacity(
                opacity: 0.7,
                child: PngAsset(path: AssetPaths.fxRedVignette, fit: BoxFit.cover),
              ),
            ),
          if (_showOverlay && game.playerScore != null)
            RoundResultOverlay(
              won: game.playerWon == true,
              tied: game.playerScore!.total == game.jokerScore.total,
              playerTotal: game.playerScore!.total,
              jokerTotal: game.jokerScore.total,
              finalRound: game.roundIndex == 3,
              onNext: app.bindTap(() {
                if (game.roundIndex == 3) {
                  context.go('/show-result?show=${show.id}');
                } else {
                  _startRound();
                }
              }),
            ),
          if (_paused)
            PauseOverlay(
              onResume: () {
                app.audio.releaseHold();
                setState(() => _paused = false);
              },
              onRestart: () async {
                await app.restartActiveShow();
                if (!mounted) return;
                setState(() => _paused = false);
                _startRound();
              },
              onQuit: () async {
                final id = show.id;
                await app.quitShow();
                if (!mounted) return;
                context.go('/map?show=$id');
              },
            ),
        ],
      ),
    );
  }

  bool _jokerFaceUp(GameController game, int index) {
    if (_jokerShown <= 0) return false;
    final shown = game.jokerPick.take(_jokerShown).toSet();
    return shown.contains(index);
  }

  Widget _hud(AppController app, GameController game) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD912002B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.75)),
      ),
      child: Row(
      children: [
        IconTap(
          icon: Icons.pause_rounded,
          tooltip: 'Pause',
          onPressed: app.bindTap(() => setState(() => _paused = true)),
        ),
        Expanded(
          child: Column(
            children: [
              Text('ROUND ${game.roundIndex + 1} / 4', style: AppTheme.body(14, shadow: false)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 4; i++)
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cream),
                        color: i < _dots.length
                            ? (_dots[i] ? AppColors.success : AppColors.failure)
                            : Colors.transparent,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Text(
          GameController.formatTimer(game.timeRemaining),
          style: AppTheme.display(
            18,
            color: game.timeRemaining <= 10 ? AppColors.failure : AppColors.cream,
            shadow: false,
          ),
        ),
        AudioIconButton(
          muted: app.temporaryMute,
          onPressed: app.bindTap(app.toggleMute),
        ),
      ],
    ),
    );
  }

  Widget _hand(GameController game) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        var cardWidth = min(78.0, available / 6);
        final natural = cardWidth * 6;
        var overlap = 0.0;
        if (natural > available) {
          final minTotal = cardWidth * 6 * (1 - 0.28) + cardWidth * 0.28;
          if (minTotal > available) {
            cardWidth = available / (6 - 0.28 * 5);
          }
          overlap = max(0, (cardWidth * 6 - available) / 5);
          overlap = min(overlap, cardWidth * 0.28);
        }
        final step = cardWidth - overlap;
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            for (var i = 0; i < 6; i++)
              Positioned(
                left: (available - (step * 5 + cardWidth)) / 2 + step * i,
                bottom: game.picks.contains(i) ? 22 : 0,
                child: GestureDetector(
                  onTap: () => _onCard(i),
                  child: AnimatedScale(
                    scale: game.picks.contains(i) ? 1.04 : 1,
                    duration: const Duration(milliseconds: 160),
                    child: PlayingCard(
                      card: game.playerHand[i],
                      width: cardWidth,
                      selection: game.picks[0] == i
                          ? CardSelection.anchor
                          : (game.picks.contains(i) ? CardSelection.normal : null),
                      orderBadge: game.picks.indexOf(i) == -1 ? null : game.picks.indexOf(i) + 1,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _scoreColumn(String title, int base, int bonus, int total) {
    return Column(
      children: [
        Text(title, style: AppTheme.body(12, color: AppColors.gold)),
        Text('Base $base', style: AppTheme.body(13)),
        Text('Rule +$bonus', style: AppTheme.body(13)),
        Text('Total $total', style: AppTheme.display(16)),
      ],
    );
  }
}
