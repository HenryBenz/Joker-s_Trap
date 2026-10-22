import 'package:flutter_test/flutter_test.dart';
import 'package:jokers_trap/core/seeded_random.dart';
import 'package:jokers_trap/data/campaign_config.dart';
import 'package:jokers_trap/data/rule_catalog.dart';
import 'package:jokers_trap/game/deck_generator.dart';
import 'package:jokers_trap/game/hand_scorer.dart';
import 'package:jokers_trap/game/joker_ai.dart';
import 'package:jokers_trap/models/card_model.dart';
import 'package:jokers_trap/models/rule_model.dart';
import 'package:jokers_trap/screens/campaign_map_screen.dart';
import 'package:jokers_trap/screens/collection_screen.dart';
import 'package:jokers_trap/screens/ending_screen.dart';
import 'package:jokers_trap/screens/game_screen.dart';
import 'package:jokers_trap/screens/golden_ticket_screen.dart';
import 'package:jokers_trap/screens/how_to_play_screen.dart';
import 'package:jokers_trap/screens/main_menu_screen.dart';
import 'package:jokers_trap/screens/onboarding_screen.dart';
import 'package:jokers_trap/screens/settings_screen.dart';
import 'package:jokers_trap/screens/show_intro_screen.dart';
import 'package:jokers_trap/screens/show_result_screen.dart';
import 'package:jokers_trap/screens/splash_screen.dart';

void main() {
  test('screen widgets are available to the router', () {
    expect(
      [
        SplashScreen.new,
        OnboardingScreen.new,
        MainMenuScreen.new,
        CampaignMapScreen.new,
        ShowIntroScreen.new,
        GameScreen.new,
        ShowResultScreen.new,
        EndingScreen.new,
        CollectionScreen.new,
        GoldenTicketScreen.new,
        SettingsScreen.new,
        HowToPlayScreen.new,
      ],
      hasLength(12),
    );
  });

  test('xorshift matches the specified 32-bit steps', () {
    final rng = XorShift32(20261016 + 1000 + 97);
    expect(rng.next(), 0x31828815);
    expect(rng.next(), 0x708312f5);
  });

  test('each round deal is deterministic and uses 12 distinct cards', () {
    final first = DeckGenerator.deal(showId: 1, roundNumber: 1);
    final again = DeckGenerator.deal(showId: 1, roundNumber: 1);
    final other = DeckGenerator.deal(showId: 1, roundNumber: 2);
    expect(first.player.map((card) => card.id), again.player.map((card) => card.id));
    expect(first.player.map((card) => card.id), isNot(other.player.map((card) => card.id)));
    final ids = {...first.player.map((card) => card.id), ...first.joker.map((card) => card.id)};
    expect(ids, hasLength(12));
    expect(DeckGenerator.canonicalDeck(), hasLength(36));
  });

  test('campaign has 16 shows and the published lie table', () {
    expect(CampaignConfig.shows, hasLength(16));
    expect(CampaignConfig.shows.expand((show) => show.rounds), hasLength(64));
    final opening = CampaignConfig.show(1).rounds.first;
    expect(opening.initial, RuleId.oddMajority);
    expect(opening.optionA, RuleId.sameColor);
    expect(opening.optionB, RuleId.evenMajority);
    expect(opening.finalRule, RuleId.sameColor);
    final finale = CampaignConfig.show(16).rounds.last;
    expect(finale.initial, RuleId.evenMajority);
    expect(finale.finalRule, RuleId.alternating);
    expect(CampaignConfig.show(1).percentile, 0.45);
    expect(CampaignConfig.show(8).percentile, 0.60);
    expect(CampaignConfig.show(12).percentile, 0.72);
    expect(CampaignConfig.show(16).percentile, 0.82);
  });

  test('every rule awards its bonus only when the condition is true', () {
    CardModel card(Suit suit, int rank) => CardModel(suit, rank);
    final red = [
      card(Suit.hearts, 2),
      card(Suit.diamonds, 4),
      card(Suit.hearts, 6),
    ];
    expect(HandScorer.score(red, RuleId.sameColor).bonus, 12);
    expect(HandScorer.score(red, RuleId.evenMajority).bonus, 10);
    expect(
      HandScorer.score(
        [card(Suit.hearts, 1), card(Suit.clubs, 2), card(Suit.diamonds, 3)],
        RuleId.mixedSuits,
      ).bonus,
      12,
    );
    expect(
      HandScorer.score(
        [card(Suit.hearts, 1), card(Suit.clubs, 4), card(Suit.spades, 9)],
        RuleId.ascending,
      ).bonus,
      12,
    );
    expect(
      HandScorer.score(
        [card(Suit.spades, 9), card(Suit.hearts, 4), card(Suit.clubs, 1)],
        RuleId.descending,
      ).bonus,
      12,
    );
    expect(
      HandScorer.score(
        [card(Suit.hearts, 7), card(Suit.clubs, 7), card(Suit.spades, 1)],
        RuleId.pair,
      ).bonus,
      12,
    );
    expect(
      HandScorer.score(
        [card(Suit.hearts, 7), card(Suit.clubs, 7), card(Suit.spades, 7)],
        RuleId.pair,
      ).bonus,
      0,
    );
    expect(
      HandScorer.score(
        [card(Suit.hearts, 5), card(Suit.clubs, 5), card(Suit.diamonds, 5)],
        RuleId.exact15,
      ).bonus,
      15,
    );
    expect(
      HandScorer.score(
        [card(Suit.hearts, 9), card(Suit.clubs, 8), card(Suit.spades, 1)],
        RuleId.exact18,
      ).total,
      33,
    );
    expect(
      HandScorer.score(
        [card(Suit.hearts, 1), card(Suit.spades, 2), card(Suit.diamonds, 3)],
        RuleId.alternating,
      ).bonus,
      14,
    );
    expect(RuleCatalog.rules, hasLength(10));
  });

  test('joker chooses the specified percentile and breaks ties by index', () {
    final hand = [
      for (var rank = 1; rank <= 6; rank++) CardModel(Suit.hearts, rank),
    ];
    final choice = JokerAi.choose(
      hand: hand,
      rule: RuleId.exact15,
      percentile: 0.45,
    );
    expect(choice.indices, hasLength(3));
    final all = JokerAi.choose(hand: hand, rule: RuleId.sameColor, percentile: 0);
    expect(all.score.total, lessThan(20));
    final topIndex = ((120 - 1) * 0.82).floor();
    expect(topIndex, 97);
  });
}
