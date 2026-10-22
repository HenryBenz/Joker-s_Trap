import 'rule_model.dart';

class RoundConfig {
  const RoundConfig({
    required this.number,
    required this.initial,
    required this.optionA,
    required this.optionB,
    required this.finalIsA,
  });

  final int number;
  final RuleId initial;
  final RuleId optionA;
  final RuleId optionB;
  final bool finalIsA;

  RuleId get finalRule => finalIsA ? optionA : optionB;
}
