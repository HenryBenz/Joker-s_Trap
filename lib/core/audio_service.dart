import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

import 'asset_paths.dart';

class AudioService with WidgetsBindingObserver {
  AudioService();

  final AudioPlayer _musicA = AudioPlayer();
  final AudioPlayer _musicB = AudioPlayer();
  final List<AudioPlayer> _sfx = List.generate(8, (_) => AudioPlayer());
  int _sfxCursor = 0;
  AudioPlayer? _activeMusic;
  String? currentTrack;
  bool loopCurrent = true;
  double musicVolume = 0.8;
  double sfxVolume = 0.9;
  bool temporaryMute = false;
  double _duck = 1;
  bool _held = false;
  bool _pausedByLifecycle = false;
  int _dealSounds = 0;
  bool _ready = false;
  Timer? _duckTimer;

  Future<void> init() async {
    if (_ready) return;
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
        ),
      );
    } catch (_) {}
    for (final player in [_musicA, _musicB, ..._sfx]) {
      try {
        await player.setPlayerMode(PlayerMode.mediaPlayer);
      } catch (_) {}
    }
    for (final player in _sfx) {
      try {
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
      } catch (_) {}
    }
    WidgetsBinding.instance.addObserver(this);
    _ready = true;
  }

  void applySettings({required double music, required double sfx}) {
    musicVolume = music;
    sfxVolume = sfx;
    _applyMusicVolume();
  }

  void setTemporaryMute(bool muted) {
    temporaryMute = muted;
    _applyMusicVolume();
  }

  void beginRound() {
    _dealSounds = 0;
  }

  Future<void> playMusic(String asset, {required bool loop}) async {
    if (currentTrack == asset && _activeMusic != null) {
      loopCurrent = loop;
      return;
    }
    final incoming = identical(_activeMusic, _musicA) ? _musicB : _musicA;
    final outgoing = _activeMusic;
    currentTrack = asset;
    loopCurrent = loop;
    try {
      await incoming.stop();
      await incoming.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
      await incoming.setVolume(0);
      await incoming.play(AssetSource(asset));
      const steps = 12;
      for (var i = 1; i <= steps; i++) {
        final t = i / steps;
        if (!_held && !_pausedByLifecycle) {
          await incoming.setVolume(_musicLevel * t);
          if (outgoing != null) {
            await outgoing.setVolume(_musicLevel * (1 - t));
          }
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      await outgoing?.stop();
      _activeMusic = incoming;
      _applyMusicVolume();
    } catch (_) {}
  }

  Future<void> playSfx(String asset, {double volumeScale = 1}) async {
    final player = _sfx[_sfxCursor];
    _sfxCursor = (_sfxCursor + 1) % _sfx.length;
    try {
      await player.stop();
      await player.setVolume(temporaryMute ? 0 : sfxVolume * volumeScale);
      await player.play(AssetSource(asset));
    } catch (_) {}
  }

  Future<void> playDeal() async {
    if (_dealSounds >= 6) return;
    _dealSounds += 1;
    await playSfx(AssetPaths.sfxDeal);
  }

  Future<void> playDuckCue(String asset, Duration length, {double volumeScale = 1}) async {
    _setDuck(0.55);
    await playSfx(asset, volumeScale: volumeScale);
    _duckTimer?.cancel();
    _duckTimer = Timer(length, () {
      _releaseDuck();
    });
  }

  Future<void> playRoundLoss() async {
    _setDuck(0.55);
    await playSfx(AssetPaths.sfxLoss);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final laugh = Random().nextBool() ? AssetPaths.sfxLaugh1 : AssetPaths.sfxLaugh2;
    await playSfx(laugh, volumeScale: 0.65);
    _duckTimer?.cancel();
    _duckTimer = Timer(const Duration(milliseconds: 1600), _releaseDuck);
  }

  void holdForResume() {
    _held = true;
    _pausePlayers();
  }

  void releaseHold() {
    _held = false;
    if (!_pausedByLifecycle) {
      _resumePlayers();
    }
  }

  double get _musicLevel => temporaryMute ? 0 : musicVolume * _duck;

  void _applyMusicVolume() {
    final level = (_held || _pausedByLifecycle) ? 0.0 : _musicLevel;
    _activeMusic?.setVolume(level);
  }

  void _setDuck(double value) {
    _duck = value;
    _applyMusicVolume();
  }

  void _releaseDuck() {
    const steps = 10;
    var step = 0;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      step += 1;
      _duck = 0.55 + (1 - 0.55) * (step / steps);
      _applyMusicVolume();
      if (step >= steps) {
        _duck = 1;
        _applyMusicVolume();
        timer.cancel();
      }
    });
  }

  void _pausePlayers() {
    _musicA.pause();
    _musicB.pause();
  }

  void _resumePlayers() {
    if (_activeMusic == null || _held) return;
    _activeMusic!.resume();
    _applyMusicVolume();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final background = state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden;
    if (background) {
      _pausedByLifecycle = true;
      _pausePlayers();
    } else if (state == AppLifecycleState.resumed) {
      _pausedByLifecycle = false;
      if (!_held) _resumePlayers();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _duckTimer?.cancel();
    _musicA.dispose();
    _musicB.dispose();
    for (final player in _sfx) {
      player.dispose();
    }
  }
}
