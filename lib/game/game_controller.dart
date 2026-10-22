import 'package:flutter/foundation.dart';

import '../models/card_model.dart';
import '../models/round_config.dart';
import '../models/show_config.dart';
import 'deck_generator.dart';
import 'hand_scorer.dart';
import 'joker_ai.dart';

enum RoundPhase {
  waitingForAnchor,
  flippingRule,
  selectingCards,
  revealingResult,
  roundComplete,
}

class GameController extends ChangeNotifier {
  GameController({
    required this.show,
    required this.roundIndex,
    required this.objectionsLeft,
  }) {
    final dealt = DeckGenerator.deal(
      showId: show.id,
      roundNumber: roundIndex + 1,
    );
    playerHand = dealt.player;
    jokerHand = dealt.joker;
    final choice = JokerAi.choose(
      hand: jokerHand,
      rule: round.finalRule,
      percentile: show.percentile,
    );
    jokerPick = choice.indices;
    jokerScore = choice.score;
  }

  final ShowConfig show;
  final int roundIndex;
  late final List<CardModel> playerHand;
  late final List<CardModel> jokerHand;
  late final List<int> jokerPick;
  late final HandScore jokerScore;

  int objectionsLeft;
  RoundPhase phase = RoundPhase.waitingForAnchor;
  final List<int?> picks = [null, null, null];
  double timeRemaining = 60;
  bool inputEnabled = true;
  bool submitted = false;
  bool warningPlayed = false;
  bool timedOut = false;
  HandScore? playerScore;
  bool? playerWon;

  RoundConfig get round => show.rounds[roundIndex];

  bool get canPlayHand =>
      phase == RoundPhase.selectingCards &&
      picks.every((pick) => pick != null) &&
      !submitted;

  bool get objectionEnabled =>
      phase == RoundPhase.selectingCards &&
      objectionsLeft > 0 &&
      !submitted;

  List<CardModel> get orderedPlayerCards =>
      [for (final index in picks) playerHand[index!]];

  void tapCard(int index) {
    if (!inputEnabled || submitted) return;
    if (phase == RoundPhase.waitingForAnchor) {
      picks[0] = index;
      phase = RoundPhase.flippingRule;
      inputEnabled = false;
      notifyListeners();
      return;
    }
    if (phase != RoundPhase.selectingCards) return;
    final slot = picks.indexOf(index);
    if (slot == 0) return;
    if (slot > 0) {
      picks[slot] = null;
      notifyListeners();
      return;
    }
    if (picks.every((pick) => pick != null)) return;
    picks[picks.indexOf(null)] = index;
    notifyListeners();
  }

  void finishFlip() {
    phase = RoundPhase.selectingCards;
    inputEnabled = true;
    notifyListeners();
  }

  void spendObjection() {
    if (!objectionEnabled) return;
    objectionsLeft -= 1;
    picks[0] = null;
    picks[1] = null;
    picks[2] = null;
    phase = RoundPhase.selectingCards;
    inputEnabled = true;
    notifyListeners();
  }

  /// Returns true the moment the timer first reaches the warning threshold.
  bool tick(double dt) {
    if (phase != RoundPhase.selectingCards || submitted) return false;
    timeRemaining = (timeRemaining - dt).clamp(0, 60);
    var warn = false;
    if (!warningPlayed && timeRemaining <= 10 && timeRemaining > 0) {
      warningPlayed = true;
      warn = true;
    }
    if (timeRemaining <= 0 && !timedOut) {
      timedOut = true;
      _fillAndSubmit();
    }
    notifyListeners();
    return warn;
  }

  void submit() {
    if (!canPlayHand) return;
    _score();
  }

  void _fillAndSubmit() {
    inputEnabled = false;
    final selected = picks.whereType<int>().toSet();
    final candidates = [
      for (var i = 0; i < playerHand.length; i++)
        if (!selected.contains(i)) i,
    ];
    candidates.sort((a, b) {
      final byRank = playerHand[b].rank.compareTo(playerHand[a].rank);
      if (byRank != 0) return byRank;
      return a.compareTo(b);
    });
    var cursor = 0;
    for (var slot = 0; slot < 3; slot++) {
      if (picks[slot] == null) {
        picks[slot] = candidates[cursor++];
      }
    }
    _score();
  }

  void _score() {
    submitted = true;
    inputEnabled = false;
    phase = RoundPhase.revealingResult;
    playerScore = HandScorer.score(orderedPlayerCards, round.finalRule);
    playerWon = playerScore!.total >= jokerScore.total;
    notifyListeners();
  }

  void markComplete() {
    phase = RoundPhase.roundComplete;
    notifyListeners();
  }

  static String formatTimer(double time) {
    final seconds = time <= 0 ? 0 : time.ceil().clamp(0, 60);
    return '0:${seconds.toString().padLeft(2, '0')}';
  }
}
