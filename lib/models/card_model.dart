enum Suit { hearts, diamonds, clubs, spades }

class CardModel {
  const CardModel(this.suit, this.rank);

  final Suit suit;
  final int rank;

  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;

  String get id => '${suit.name}_$rank';

  @override
  bool operator ==(Object other) =>
      other is CardModel && other.suit == suit && other.rank == rank;

  @override
  int get hashCode => Object.hash(suit, rank);
}
