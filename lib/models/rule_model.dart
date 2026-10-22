enum RuleId {
  sameColor,
  mixedSuits,
  ascending,
  descending,
  oddMajority,
  evenMajority,
  exact15,
  exact18,
  pair,
  alternating,
}

class RuleModel {
  const RuleModel({
    required this.id,
    required this.code,
    required this.name,
    required this.condition,
    required this.bonus,
  });

  final RuleId id;
  final String code;
  final String name;
  final String condition;
  final int bonus;
}
