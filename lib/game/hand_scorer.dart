import '../data/rule_catalog.dart';
import '../models/card_model.dart';
import '../models/rule_model.dart';

class HandScore {
  const HandScore({
    required this.base,
    required this.bonus,
    required this.ruleMet,
  });

  final int base;
  final int bonus;
  final bool ruleMet;

  int get total => base + bonus;
}

class HandScorer {
  static HandScore score(List<CardModel> ordered, RuleId rule) {
    final base = ordered.fold<int>(0, (sum, card) => sum + card.rank);
    final met = matches(ordered, rule);
    final bonus = met ? RuleCatalog.byId(rule).bonus : 0;
    return HandScore(base: base, bonus: bonus, ruleMet: met);
  }

  static bool matches(List<CardModel> cards, RuleId rule) {
    if (cards.length != 3) return false;
    final ranks = cards.map((card) => card.rank).toList();
    final sum = ranks.fold<int>(0, (a, b) => a + b);
    switch (rule) {
      case RuleId.sameColor:
        final red = cards.where((card) => card.isRed).length;
        return red == 3 || red == 0;
      case RuleId.mixedSuits:
        return cards.map((card) => card.suit).toSet().length == 3;
      case RuleId.ascending:
        return ranks[0] < ranks[1] && ranks[1] < ranks[2];
      case RuleId.descending:
        return ranks[0] > ranks[1] && ranks[1] > ranks[2];
      case RuleId.oddMajority:
        return ranks.where((rank) => rank.isOdd).length >= 2;
      case RuleId.evenMajority:
        return ranks.where((rank) => rank.isEven).length >= 2;
      case RuleId.exact15:
        return sum == 15;
      case RuleId.exact18:
        return sum == 18;
      case RuleId.pair:
        final counts = <int, int>{};
        for (final rank in ranks) {
          counts[rank] = (counts[rank] ?? 0) + 1;
        }
        return counts.values.any((count) => count == 2) &&
            !counts.values.any((count) => count == 3);
      case RuleId.alternating:
        final colors = cards.map((card) => card.isRed).toList();
        final redBlackRed = colors[0] && !colors[1] && colors[2];
        final blackRedBlack = !colors[0] && colors[1] && !colors[2];
        return redBlackRed || blackRedBlack;
    }
  }
}
