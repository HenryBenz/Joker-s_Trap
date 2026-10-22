import '../core/asset_paths.dart';
import '../models/round_config.dart';
import '../models/rule_model.dart';
import '../models/show_config.dart';
import 'rule_catalog.dart';

class CampaignConfig {
  static final shows = _build();

  static ShowConfig show(int id) => shows[id - 1];

  static int actForShow(int showId) => (showId - 1) ~/ 4;

  static List<ShowConfig> showsForAct(int act) {
    return shows.where((show) => show.act == act).toList();
  }

  static Set<RuleId> rulesInShow(int showId) {
    final show = CampaignConfig.show(showId);
    final ids = <RuleId>{};
    for (final round in show.rounds) {
      ids.add(round.initial);
      ids.add(round.optionA);
      ids.add(round.optionB);
    }
    return ids;
  }

  static List<ShowConfig> _build() {
    const titles = [
      'First Deception',
      'Bells in the Dark',
      'The Painted Smile',
      'Curtain of Cards',
      'Hall of Mirrors',
      'Crown Without a King',
      'The Laughing Clock',
      'Royal Misrule',
      'Scarlet Thunder',
      'House of Two Truths',
      'Broken Spotlight',
      "The Joker's Trap",
      'Gilded Lie',
      'Upside-Down Court',
      'Golden Teeth',
      'Truth Behind the Mask',
    ];
    const rounds = <List<String>>[
      [
        'ODD_MAJORITY|SAME_COLOR|EVEN_MAJORITY|A',
        'SAME_COLOR|ODD_MAJORITY|MIXED_SUITS|A',
        'EVEN_MAJORITY|ASCENDING|SAME_COLOR|B',
        'MIXED_SUITS|EVEN_MAJORITY|DESCENDING|A',
      ],
      [
        'ASCENDING|DESCENDING|ODD_MAJORITY|B',
        'SAME_COLOR|MIXED_SUITS|EVEN_MAJORITY|A',
        'ODD_MAJORITY|ASCENDING|SAME_COLOR|A',
        'DESCENDING|EVEN_MAJORITY|MIXED_SUITS|B',
      ],
      [
        'MIXED_SUITS|EXACT_15|SAME_COLOR|B',
        'ODD_MAJORITY|PAIR|ASCENDING|B',
        'SAME_COLOR|EXACT_15|EVEN_MAJORITY|A',
        'ASCENDING|PAIR|DESCENDING|A',
      ],
      [
        'EVEN_MAJORITY|ALTERNATING|SAME_COLOR|A',
        'MIXED_SUITS|EXACT_15|DESCENDING|B',
        'ASCENDING|ALTERNATING|ODD_MAJORITY|A',
        'SAME_COLOR|PAIR|EXACT_15|B',
      ],
      [
        'ASCENDING|DESCENDING|EXACT_15|A',
        'SAME_COLOR|ALTERNATING|MIXED_SUITS|A',
        'PAIR|ODD_MAJORITY|EXACT_18|B',
        'EVEN_MAJORITY|ASCENDING|ALTERNATING|B',
      ],
      [
        'MIXED_SUITS|PAIR|SAME_COLOR|A',
        'DESCENDING|EXACT_18|ODD_MAJORITY|B',
        'EXACT_15|ALTERNATING|ASCENDING|A',
        'SAME_COLOR|EVEN_MAJORITY|DESCENDING|B',
      ],
      [
        'ODD_MAJORITY|EXACT_18|PAIR|A',
        'ASCENDING|ALTERNATING|DESCENDING|B',
        'MIXED_SUITS|SAME_COLOR|EXACT_15|B',
        'EVEN_MAJORITY|PAIR|ASCENDING|A',
      ],
      [
        'PAIR|EXACT_15|MIXED_SUITS|B',
        'SAME_COLOR|DESCENDING|ALTERNATING|A',
        'EXACT_18|ODD_MAJORITY|ASCENDING|B',
        'MIXED_SUITS|EVEN_MAJORITY|PAIR|B',
      ],
      [
        'ALTERNATING|SAME_COLOR|EXACT_18|B',
        'PAIR|ASCENDING|DESCENDING|A',
        'EXACT_15|MIXED_SUITS|ODD_MAJORITY|A',
        'EVEN_MAJORITY|EXACT_18|ALTERNATING|B',
      ],
      [
        'SAME_COLOR|PAIR|MIXED_SUITS|A',
        'ASCENDING|EXACT_15|ALTERNATING|B',
        'ODD_MAJORITY|DESCENDING|EXACT_18|A',
        'PAIR|EVEN_MAJORITY|SAME_COLOR|B',
      ],
      [
        'EXACT_18|ALTERNATING|ASCENDING|A',
        'MIXED_SUITS|PAIR|DESCENDING|B',
        'EXACT_15|SAME_COLOR|EVEN_MAJORITY|A',
        'ASCENDING|ODD_MAJORITY|ALTERNATING|B',
      ],
      [
        'SAME_COLOR|EXACT_18|ALTERNATING|A',
        'DESCENDING|PAIR|ASCENDING|A',
        'MIXED_SUITS|EXACT_15|EVEN_MAJORITY|A',
        'ODD_MAJORITY|ALTERNATING|PAIR|B',
      ],
      [
        'ASCENDING|EXACT_18|PAIR|B',
        'SAME_COLOR|ALTERNATING|EXACT_15|A',
        'EVEN_MAJORITY|MIXED_SUITS|DESCENDING|B',
        'PAIR|ODD_MAJORITY|EXACT_18|A',
      ],
      [
        'ALTERNATING|ASCENDING|SAME_COLOR|A',
        'EXACT_15|DESCENDING|MIXED_SUITS|A',
        'PAIR|EXACT_18|EVEN_MAJORITY|A',
        'ODD_MAJORITY|SAME_COLOR|ALTERNATING|B',
      ],
      [
        'MIXED_SUITS|EXACT_18|PAIR|B',
        'DESCENDING|ALTERNATING|EXACT_15|A',
        'SAME_COLOR|ASCENDING|EVEN_MAJORITY|A',
        'EXACT_18|ODD_MAJORITY|MIXED_SUITS|B',
      ],
      [
        'PAIR|ALTERNATING|EXACT_18|A',
        'ASCENDING|SAME_COLOR|DESCENDING|B',
        'MIXED_SUITS|EXACT_15|ODD_MAJORITY|A',
        'EVEN_MAJORITY|PAIR|ALTERNATING|B',
      ],
    ];

    return [
      for (var i = 0; i < 16; i++)
        ShowConfig(
          id: i + 1,
          act: i ~/ 4,
          actLabel: _actLabel(i ~/ 4),
          actTitle: _actTitle(i ~/ 4),
          title: titles[i],
          percentile: _percentile(i ~/ 4),
          backgroundAsset: AssetPaths.mapBackground(i ~/ 4),
          jokerAsset: AssetPaths.actJoker(i ~/ 4),
          rounds: [
            for (var r = 0; r < 4; r++) _round(r + 1, rounds[i][r]),
          ],
        ),
    ];
  }

  static RoundConfig _round(int number, String spec) {
    final parts = spec.split('|');
    return RoundConfig(
      number: number,
      initial: RuleCatalog.parse(parts[0]),
      optionA: RuleCatalog.parse(parts[1]),
      optionB: RuleCatalog.parse(parts[2]),
      finalIsA: parts[3] == 'A',
    );
  }

  static String _actLabel(int act) {
    return switch (act) {
      0 => 'ACT I',
      1 => 'ACT II',
      2 => 'ACT III',
      _ => 'GOLDEN ACT',
    };
  }

  static String _actTitle(int act) {
    return switch (act) {
      0 => 'The Velvet Entrance',
      1 => 'The Crooked Palace',
      2 => 'The Last Laugh',
      _ => 'Backside of the Deck',
    };
  }

  static double _percentile(int act) {
    return switch (act) {
      0 => 0.45,
      1 => 0.60,
      2 => 0.72,
      _ => 0.82,
    };
  }
}
