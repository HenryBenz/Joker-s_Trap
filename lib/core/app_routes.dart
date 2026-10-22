import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../screens/campaign_map_screen.dart';
import '../screens/collection_screen.dart';
import '../screens/ending_screen.dart';
import '../screens/game_screen.dart';
import '../screens/golden_ticket_screen.dart';
import '../screens/how_to_play_screen.dart';
import '../screens/main_menu_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/show_intro_screen.dart';
import '../screens/show_result_screen.dart';
import '../screens/splash_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', pageBuilder: (context, state) => _page(context, state, const SplashScreen())),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _page(
          context,
          state,
          OnboardingScreen(preview: state.uri.queryParameters['preview'] == '1'),
        ),
      ),
      GoRoute(path: '/menu', pageBuilder: (context, state) => _page(context, state, const MainMenuScreen())),
      GoRoute(
        path: '/map',
        pageBuilder: (context, state) {
          final show = int.tryParse(state.uri.queryParameters['show'] ?? '');
          final act = int.tryParse(state.uri.queryParameters['act'] ?? '');
          final initial = show != null ? (show - 1) ~/ 4 : (act ?? 0);
          return _page(context, state, CampaignMapScreen(initialAct: initial.clamp(0, 3)));
        },
      ),
      GoRoute(
        path: '/show/:id',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
          return _page(context, state, ShowIntroScreen(showId: id));
        },
      ),
      GoRoute(path: '/game', pageBuilder: (context, state) => _page(context, state, const GameScreen())),
      GoRoute(
        path: '/show-result',
        pageBuilder: (context, state) => _page(
          context,
          state,
          ShowResultScreen(showId: int.tryParse(state.uri.queryParameters['show'] ?? '')),
        ),
      ),
      GoRoute(
        path: '/ending/:id',
        pageBuilder: (context, state) => _page(
          context,
          state,
          EndingScreen(golden: state.pathParameters['id'] == 'gold'),
        ),
      ),
      GoRoute(path: '/collection', pageBuilder: (context, state) => _page(context, state, const CollectionScreen())),
      GoRoute(path: '/golden-ticket', pageBuilder: (context, state) => _page(context, state, const GoldenTicketScreen())),
      GoRoute(path: '/settings', pageBuilder: (context, state) => _page(context, state, const SettingsScreen())),
      GoRoute(path: '/how-to-play', pageBuilder: (context, state) => _page(context, state, const HowToPlayScreen())),
    ],
  );
}

CustomTransitionPage<void> _page(BuildContext context, GoRouterState state, Widget child) {
  final reduce = AppScope.of(context).save.reduceMotion;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondary, pageChild) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: reduce
            ? pageChild
            : AnimatedBuilder(
                animation: curved,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, 16 * (1 - curved.value)),
                  child: child,
                ),
                child: pageChild,
              ),
      );
    },
  );
}
