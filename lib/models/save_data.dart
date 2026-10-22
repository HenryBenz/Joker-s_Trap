class SaveData {
  const SaveData({
    required this.schemaVersion,
    required this.onboardingComplete,
    required this.campaignStarted,
    required this.highestUnlockedShow,
    required this.clearedShowIds,
    required this.bestShowScores,
    required this.activeShowId,
    required this.activeRoundIndex,
    required this.activeRoundResults,
    required this.collectionUnlocks,
    required this.goldenTicketOwned,
    required this.seenEndingIds,
    required this.musicVolume,
    required this.sfxVolume,
    required this.hapticsEnabled,
    required this.reduceMotion,
  });

  final int schemaVersion;
  final bool onboardingComplete;
  final bool campaignStarted;
  final int highestUnlockedShow;
  final List<int> clearedShowIds;
  final Map<String, int> bestShowScores;
  final int? activeShowId;
  final int activeRoundIndex;
  final List<bool> activeRoundResults;
  final List<String> collectionUnlocks;
  final bool goldenTicketOwned;
  final List<String> seenEndingIds;
  final double musicVolume;
  final double sfxVolume;
  final bool hapticsEnabled;
  final bool reduceMotion;

  static const initialUnlocks = ['joker_idle', 'joker_grin'];

  factory SaveData.initial() {
    return const SaveData(
      schemaVersion: 1,
      onboardingComplete: false,
      campaignStarted: false,
      highestUnlockedShow: 1,
      clearedShowIds: [],
      bestShowScores: {},
      activeShowId: null,
      activeRoundIndex: 0,
      activeRoundResults: [],
      collectionUnlocks: initialUnlocks,
      goldenTicketOwned: false,
      seenEndingIds: [],
      musicVolume: 0.8,
      sfxVolume: 0.9,
      hapticsEnabled: true,
      reduceMotion: false,
    );
  }

  factory SaveData.fromJson(Map<String, dynamic> json) {
    return SaveData(
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      onboardingComplete: json['onboardingComplete'] == true,
      campaignStarted: json['campaignStarted'] == true,
      highestUnlockedShow: (json['highestUnlockedShow'] as num?)?.toInt() ?? 1,
      clearedShowIds: _intList(json['clearedShowIds']),
      bestShowScores: _scoreMap(json['bestShowScores']),
      activeShowId: json['activeShowId'] == null
          ? null
          : (json['activeShowId'] as num).toInt(),
      activeRoundIndex: (json['activeRoundIndex'] as num?)?.toInt() ?? 0,
      activeRoundResults: _boolList(json['activeRoundResults']),
      collectionUnlocks: _stringList(json['collectionUnlocks']).isEmpty
          ? initialUnlocks
          : _stringList(json['collectionUnlocks']),
      goldenTicketOwned: json['goldenTicketOwned'] == true,
      seenEndingIds: _stringList(json['seenEndingIds']),
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.8,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 0.9,
      hapticsEnabled: json['hapticsEnabled'] != false,
      reduceMotion: json['reduceMotion'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'onboardingComplete': onboardingComplete,
      'campaignStarted': campaignStarted,
      'highestUnlockedShow': highestUnlockedShow,
      'clearedShowIds': clearedShowIds,
      'bestShowScores': bestShowScores,
      'activeShowId': activeShowId,
      'activeRoundIndex': activeRoundIndex,
      'activeRoundResults': activeRoundResults,
      'collectionUnlocks': collectionUnlocks,
      'goldenTicketOwned': goldenTicketOwned,
      'seenEndingIds': seenEndingIds,
      'musicVolume': musicVolume,
      'sfxVolume': sfxVolume,
      'hapticsEnabled': hapticsEnabled,
      'reduceMotion': reduceMotion,
    };
  }

  SaveData copyWith({
    int? schemaVersion,
    bool? onboardingComplete,
    bool? campaignStarted,
    int? highestUnlockedShow,
    List<int>? clearedShowIds,
    Map<String, int>? bestShowScores,
    Object? activeShowId = _unset,
    int? activeRoundIndex,
    List<bool>? activeRoundResults,
    List<String>? collectionUnlocks,
    bool? goldenTicketOwned,
    List<String>? seenEndingIds,
    double? musicVolume,
    double? sfxVolume,
    bool? hapticsEnabled,
    bool? reduceMotion,
  }) {
    return SaveData(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      campaignStarted: campaignStarted ?? this.campaignStarted,
      highestUnlockedShow: highestUnlockedShow ?? this.highestUnlockedShow,
      clearedShowIds: clearedShowIds ?? this.clearedShowIds,
      bestShowScores: bestShowScores ?? this.bestShowScores,
      activeShowId: activeShowId == _unset
          ? this.activeShowId
          : activeShowId as int?,
      activeRoundIndex: activeRoundIndex ?? this.activeRoundIndex,
      activeRoundResults: activeRoundResults ?? this.activeRoundResults,
      collectionUnlocks: collectionUnlocks ?? this.collectionUnlocks,
      goldenTicketOwned: goldenTicketOwned ?? this.goldenTicketOwned,
      seenEndingIds: seenEndingIds ?? this.seenEndingIds,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }

  SaveData resetCampaign({required bool startNew}) {
    return copyWith(
      campaignStarted: startNew,
      highestUnlockedShow: 1,
      clearedShowIds: const [],
      bestShowScores: const {},
      activeShowId: null,
      activeRoundIndex: 0,
      activeRoundResults: const [],
      collectionUnlocks: initialUnlocks,
      seenEndingIds: const [],
    );
  }

  int? bestWinsFor(int showId) => bestShowScores['$showId'];

  bool hasUnlock(String id) => collectionUnlocks.contains(id);
}

const _unset = Object();

List<int> _intList(Object? value) {
  if (value is! List) return const [];
  return value.map((item) => (item as num).toInt()).toList();
}

List<bool> _boolList(Object? value) {
  if (value is! List) return const [];
  return value.map((item) => item == true).toList();
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}

Map<String, int> _scoreMap(Object? value) {
  if (value is! Map) return const {};
  return value.map(
    (key, item) => MapEntry(key.toString(), (item as num).toInt()),
  );
}
