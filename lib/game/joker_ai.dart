import '../models/card_model.dart';
import '../models/rule_model.dart';
import 'hand_scorer.dart';

class JokerChoice {
  const JokerChoice({
    required this.indices,
    required this.score,
  });

  final List<int> indices;
  final HandScore score;
}

class JokerAi {
  static JokerChoice choose({
    required List<CardModel> hand,
    required RuleId rule,
    required double percentile,
  }) {
    final results = <_ScoredPick>[];
    for (var a = 0; a < hand.length; a++) {
      for (var b = 0; b < hand.length; b++) {
        if (b == a) continue;
        for (var c = 0; c < hand.length; c++) {
          if (c == a || c == b) continue;
          final cards = [hand[a], hand[b], hand[c]];
          results.add(
            _ScoredPick(
              indices: [a, b, c],
              key: '$a$b$c',
              score: HandScorer.score(cards, rule),
            ),
          );
        }
      }
    }
    results.sort((left, right) {
      final byScore = left.score.total.compareTo(right.score.total);
      if (byScore != 0) return byScore;
      return left.key.compareTo(right.key);
    });
    final index = ((results.length - 1) * percentile).floor();
    final picked = results[index];
    return JokerChoice(indices: picked.indices, score: picked.score);
  }
}

class _ScoredPick {
  const _ScoredPick({
    required this.indices,
    required this.key,
    required this.score,
  });

  final List<int> indices;
  final String key;
  final HandScore score;
}
