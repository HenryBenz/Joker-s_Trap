import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'core/asset_paths.dart';
import 'core/audio_service.dart';
import 'core/purchase_service.dart';
import 'core/save_service.dart';
import 'data/campaign_config.dart';
import 'models/rule_model.dart';
import 'models/save_data.dart';

class ShowSession {
  int? showId;
  int objections = 2;

  void begin(int id) {
    showId = id;
    objections = 2;
  }

  void sync(int id) {
    if (showId != id) begin(id);
  }
}

class AppController extends ChangeNotifier {
  AppController({
    required this.saveService,
    required this.audio,
    required this.purchases,
  });

  final SaveService saveService;
  final AudioService audio;
  final PurchaseService purchases;
  final ShowSession session = ShowSession();
  SaveData save = SaveData.initial();
  bool corruptNotice = false;
  bool temporaryMute = false;
  int mapAct = 0;
  StreamSubscription<PurchaseEvent>? _purchaseSub;

  Future<void> load() async {
    final result = await saveService.load();
    save = result.data;
    corruptNotice = result.corrupt;
    audio.applySettings(music: save.musicVolume, sfx: save.sfxVolume);
    if (save.goldenTicketOwned) purchases.markOwned();
    _purchaseSub ??= purchases.events.listen(_onPurchase);
    notifyListeners();
  }

  Future<void> persist() => saveService.save(save);

  void toggleMute() {
    temporaryMute = !temporaryMute;
    audio.setTemporaryMute(temporaryMute);
    notifyListeners();
  }

  VoidCallback bindTap(VoidCallback action) {
    return () {
      audio.playSfx(AssetPaths.sfxButton);
      action();
    };
  }

  Future<void> setMusic(double value, {required bool persistNow}) async {
    save = save.copyWith(musicVolume: value.clamp(0, 1));
    audio.applySettings(music: save.musicVolume, sfx: save.sfxVolume);
    if (temporaryMute) audio.setTemporaryMute(true);
    notifyListeners();
    if (persistNow) await persist();
  }

  Future<void> setSfx(double value, {required bool persistNow}) async {
    save = save.copyWith(sfxVolume: value.clamp(0, 1));
    audio.applySettings(music: save.musicVolume, sfx: save.sfxVolume);
    if (temporaryMute) audio.setTemporaryMute(true);
    notifyListeners();
    if (persistNow) await persist();
  }

  Future<void> setHaptics(bool value) async {
    save = save.copyWith(hapticsEnabled: value);
    await persist();
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    save = save.copyWith(reduceMotion: value);
    await persist();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    save = save.copyWith(onboardingComplete: true);
    await persist();
    notifyListeners();
  }

  Future<void> startNewGame() async {
    save = save.resetCampaign(startNew: true);
    session.showId = null;
    await persist();
    notifyListeners();
  }

  Future<void> resetCampaign() async {
    save = save.resetCampaign(startNew: false);
    session.showId = null;
    await persist();
    notifyListeners();
  }

  Future<void> enterShow(int id) async {
    save = save.copyWith(
      campaignStarted: true,
      activeShowId: id,
      activeRoundIndex: 0,
      activeRoundResults: const [],
    );
    session.begin(id);
    await persist();
    notifyListeners();
  }

  Future<void> commitRound(bool win) async {
    final results = [...save.activeRoundResults, win];
    final unlocks = [...save.collectionUnlocks];
    final id = win ? 'joker_shock' : 'joker_laugh';
    if (!unlocks.contains(id)) unlocks.add(id);
    save = save.copyWith(
      activeRoundResults: results,
      activeRoundIndex: results.length < 4 ? results.length : 3,
      collectionUnlocks: unlocks,
    );
    await persist();
    notifyListeners();
  }

  Future<void> applyShowResult(int showId, List<bool> results) async {
    final wins = results.where((result) => result).length;
    final cleared = wins >= 3;
    final ids = [...save.clearedShowIds];
    var highest = save.highestUnlockedShow;
    final unlocks = [...save.collectionUnlocks];
    final best = Map<String, int>.from(save.bestShowScores);
    if (cleared) {
      if (!ids.contains(showId)) ids.add(showId);
      if (wins > (best['$showId'] ?? 0)) best['$showId'] = wins;
      if (showId < 12) {
        highest = max(highest, showId + 1);
      } else if (showId == 12) {
        highest = max(highest, 12);
        if (save.goldenTicketOwned) highest = max(highest, 13);
        if (!unlocks.contains('joker_defeat')) unlocks.add('joker_defeat');
      } else if (showId < 16) {
        highest = max(highest, showId + 1);
      } else if (!unlocks.contains('joker_bow')) {
        unlocks.add('joker_bow');
      }
    }
    save = save.copyWith(
      clearedShowIds: ids,
      highestUnlockedShow: highest,
      bestShowScores: best,
      collectionUnlocks: unlocks,
      activeShowId: null,
      activeRoundIndex: 0,
      activeRoundResults: const [],
    );
    await persist();
    notifyListeners();
  }

  Future<void> grantTicket() async {
    var highest = save.highestUnlockedShow;
    if (save.clearedShowIds.contains(12)) highest = max(highest, 13);
    save = save.copyWith(
      goldenTicketOwned: true,
      highestUnlockedShow: highest,
    );
    purchases.markOwned();
    notifyListeners();
    await persist();
  }

  Future<void> markEnding(String id) async {
    if (save.seenEndingIds.contains(id)) return;
    save = save.copyWith(seenEndingIds: [...save.seenEndingIds, id]);
    await persist();
    notifyListeners();
  }

  Future<void> quitShow() async {
    save = save.copyWith(
      activeShowId: null,
      activeRoundIndex: 0,
      activeRoundResults: const [],
    );
    session.showId = null;
    await persist();
    notifyListeners();
  }

  Future<void> restartActiveShow() async {
    final id = save.activeShowId;
    if (id == null) return;
    save = save.copyWith(
      activeShowId: id,
      activeRoundIndex: 0,
      activeRoundResults: const [],
    );
    session.begin(id);
    await persist();
    notifyListeners();
  }

  void setMapAct(int act) {
    if (mapAct == act) return;
    mapAct = act;
    notifyListeners();
  }

  int get freeShowsCleared =>
      save.clearedShowIds.where((id) => id <= 12).length;

  Set<RuleId> unlockedRules() {
    final shows = <int>{
      ...save.clearedShowIds,
      if (save.activeShowId != null) save.activeShowId!,
    };
    return {
      for (final id in shows) ...CampaignConfig.rulesInShow(id),
    };
  }

  void _onPurchase(PurchaseEvent event) {
    if (event == PurchaseEvent.purchased ||
        event == PurchaseEvent.restored ||
        event == PurchaseEvent.entitled) {
      grantTicket();
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({required AppController controller, required super.child})
    : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing');
    return scope!.notifier!;
  }
}

class JokersTrapApp extends StatefulWidget {
  const JokersTrapApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<JokersTrapApp> createState() => _JokersTrapAppState();
}

class _JokersTrapAppState extends State<JokersTrapApp> {
  late final GoRouter _router = createRouter();
  String? _track;

  @override
  void initState() {
    super.initState();
    _router.routerDelegate.addListener(_syncMusic);
    widget.controller.addListener(_syncMusic);
  }

  void _syncMusic() {
    final uri = _router.routeInformationProvider.value.uri;
    final track = trackForLocation(uri, widget.controller);
    if (track == null || track == _track) return;
    _track = track;
    final loop = !track.contains('ending');
    widget.controller.audio.playMusic(track, loop: loop);
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_syncMusic);
    widget.controller.removeListener(_syncMusic);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: widget.controller,
      child: MaterialApp.router(
        title: 'Joker’s Trap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme(),
        routerConfig: _router,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          final scale = media.textScaler.scale(1).clamp(0.0, 1.3);
          return MediaQuery(
            data: media.copyWith(textScaler: TextScaler.linear(scale)),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

String? trackForLocation(Uri uri, AppController app) {
  final path = uri.path;
  if (path.startsWith('/settings') || path.startsWith('/how-to-play')) {
    return null;
  }
  if (path == '/ending/free') return AssetPaths.musicEndingFree;
  if (path == '/ending/gold') return AssetPaths.musicEndingGold;
  if (path == '/golden-ticket') return AssetPaths.musicGolden;
  if (path == '/menu' ||
      path == '/collection' ||
      path == '/onboarding' ||
      path == '/splash') {
    return AssetPaths.musicMain;
  }
  if (path == '/map') {
    final show = int.tryParse(uri.queryParameters['show'] ?? '');
    final act = show == null ? app.mapAct : (show - 1) ~/ 4;
    return AssetPaths.musicForAct(act);
  }
  if (path.startsWith('/show/')) {
    final id = int.tryParse(path.split('/').last) ?? 1;
    return AssetPaths.musicForAct((id - 1) ~/ 4);
  }
  if (path == '/game' || path == '/show-result') {
    final query = int.tryParse(uri.queryParameters['show'] ?? '');
    final id = query ?? app.save.activeShowId ?? 1;
    return AssetPaths.musicForAct((id - 1) ~/ 4);
  }
  return AssetPaths.musicMain;
}
