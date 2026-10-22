import 'round_config.dart';

class ShowConfig {
  const ShowConfig({
    required this.id,
    required this.act,
    required this.actLabel,
    required this.actTitle,
    required this.title,
    required this.percentile,
    required this.backgroundAsset,
    required this.jokerAsset,
    required this.rounds,
  });

  final int id;
  final int act;
  final String actLabel;
  final String actTitle;
  final String title;
  final double percentile;
  final String backgroundAsset;
  final String jokerAsset;
  final List<RoundConfig> rounds;

  bool get isPremium => id >= 13;
}
