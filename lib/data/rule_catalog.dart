import '../models/rule_model.dart';

class RuleCatalog {
  static const rules = <RuleModel>[
    RuleModel(
      id: RuleId.sameColor,
      code: 'SAME_COLOR',
      name: 'One Color',
      condition: 'All three cards are red, or all three are black',
      bonus: 12,
    ),
    RuleModel(
      id: RuleId.mixedSuits,
      code: 'MIXED_SUITS',
      name: 'Three Emblems',
      condition: 'All three cards have different suits',
      bonus: 12,
    ),
    RuleModel(
      id: RuleId.ascending,
      code: 'ASCENDING',
      name: 'Rising Act',
      condition: 'Selected ranks satisfy card1 < card2 < card3',
      bonus: 12,
    ),
    RuleModel(
      id: RuleId.descending,
      code: 'DESCENDING',
      name: 'Falling Act',
      condition: 'Selected ranks satisfy card1 > card2 > card3',
      bonus: 12,
    ),
    RuleModel(
      id: RuleId.oddMajority,
      code: 'ODD_MAJORITY',
      name: 'Odd Company',
      condition: 'At least two selected ranks are odd',
      bonus: 10,
    ),
    RuleModel(
      id: RuleId.evenMajority,
      code: 'EVEN_MAJORITY',
      name: 'Even Company',
      condition: 'At least two selected ranks are even',
      bonus: 10,
    ),
    RuleModel(
      id: RuleId.exact15,
      code: 'EXACT_15',
      name: 'Perfect Fifteen',
      condition: 'Rank sum equals 15',
      bonus: 15,
    ),
    RuleModel(
      id: RuleId.exact18,
      code: 'EXACT_18',
      name: 'Perfect Eighteen',
      condition: 'Rank sum equals 18',
      bonus: 15,
    ),
    RuleModel(
      id: RuleId.pair,
      code: 'PAIR',
      name: 'Double Face',
      condition: 'Exactly two cards share a rank; three equal ranks do not qualify',
      bonus: 12,
    ),
    RuleModel(
      id: RuleId.alternating,
      code: 'ALTERNATING',
      name: 'Color Dance',
      condition: 'Colors in selection order are red-black-red or black-red-black',
      bonus: 14,
    ),
  ];

  static RuleModel byId(RuleId id) => rules.firstWhere((rule) => rule.id == id);

  static RuleId parse(String code) {
    return rules.firstWhere((rule) => rule.code == code).id;
  }
}
