import '../core/seeded_random.dart';
import '../models/card_model.dart';

class DeckGenerator {
  static List<CardModel> canonicalDeck() {
    return [
      for (final suit in Suit.values)
        for (var rank = 1; rank <= 9; rank++) CardModel(suit, rank),
    ];
  }

  static int seedFor({required int showId, required int roundNumber}) {
    return showId * 1000 + roundNumber * 97 + 20261016;
  }

  static ({List<CardModel> player, List<CardModel> joker}) deal({
    required int showId,
    required int roundNumber,
  }) {
    final rng = XorShift32(seedFor(showId: showId, roundNumber: roundNumber));
    final deck = canonicalDeck();
    for (var i = deck.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final swap = deck[i];
      deck[i] = deck[j];
      deck[j] = swap;
    }
    return (player: deck.sublist(0, 6), joker: deck.sublist(6, 12));
  }
}
