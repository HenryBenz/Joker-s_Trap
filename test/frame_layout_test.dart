import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jokers_trap/core/app_theme.dart';
import 'package:jokers_trap/core/asset_paths.dart';
import 'package:jokers_trap/models/rule_model.dart';
import 'package:jokers_trap/screens/round_result_overlay.dart';
import 'package:jokers_trap/widgets/confirmation_dialog.dart';
import 'package:jokers_trap/widgets/ornate_frame.dart';
import 'package:jokers_trap/widgets/png_button.dart';
import 'package:jokers_trap/widgets/rule_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpPhone(WidgetTester tester, Widget child, {Size size = const Size(390, 844)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    return tester.pumpWidget(MaterialApp(theme: AppTheme.theme(), home: child));
  }

  testWidgets('dialog copy stays inside the frame on a phone', (tester) async {
    await pumpPhone(
      tester,
      const Scaffold(body: SizedBox.shrink()),
    );
    final context = tester.element(find.byType(Scaffold));
    final future = showGameDialog(
      context: context,
      title: 'Start a new game?',
      body: 'Campaign progress and best scores will be erased. Your Golden Joker and settings will remain.',
      cancelLabel: 'Cancel',
      confirmLabel: 'Start Over',
      destructive: true,
    );
    await tester.pumpAndSettle();
    expect(find.text('Start a new game?'), findsOneWidget);
    expect(find.text('Start Over'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final frame = tester.getRect(find.byType(OrnateFrame));
    final title = tester.getRect(find.text('Start a new game?'));
    final confirm = tester.getRect(find.text('Start Over'));
    final safe = Rect.fromLTRB(
      frame.left + frame.width * 0.12,
      frame.top + frame.height * 0.18,
      frame.right - frame.width * 0.12,
      frame.bottom - frame.height * 0.18,
    );
    expect(safe.contains(title.topLeft) && safe.contains(title.bottomRight), isTrue);
    expect(safe.contains(confirm.topLeft) && safe.contains(confirm.bottomRight), isTrue);
    Navigator.of(context).pop(false);
    await future;
  });

  testWidgets('rule panels and result card do not overflow', (tester) async {
    await pumpPhone(
      tester,
      Scaffold(
        body: Column(
          children: [
            RulePanel(rule: RuleId.oddMajority, label: 'THE CURRENT STORY', onTap: () {}),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RulePanel(rule: RuleId.sameColor, label: 'POSSIBLE LIE A', compact: true, onTap: () {}),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RulePanel(rule: RuleId.evenMajority, label: 'POSSIBLE LIE B', compact: true, onTap: () {}),
                ),
              ],
            ),
            const Expanded(
              child: RoundResultOverlay(
                won: true,
                tied: true,
                playerTotal: 30,
                jokerTotal: 12,
                finalRound: false,
                onNext: _noop,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Next Round'), findsOneWidget);
    final panels = tester.getRect(find.byType(RulePanel).first);
    final result = tester.getRect(find.byType(AspectRatio));
    final headline = tester.getRect(find.text('YOU CAUGHT THE LIE'));
    expect(headline.top > result.top + result.height * 0.25, isTrue);
    expect(headline.bottom < result.top + result.height * 0.36, isTrue);
    expect(headline.left > result.left + result.width * 0.12, isTrue);
    expect(headline.right < result.right - result.width * 0.12, isTrue);
    final next = tester.getRect(find.text('Next Round'));
    expect(next.top > result.top + result.height * 0.80, isTrue);
    expect(next.bottom < result.top + result.height * 0.92, isTrue);
    final story = tester.getRect(find.text('Odd Company'));
    expect(story.left > panels.left + panels.width * 0.1, isTrue);
    expect(story.right < panels.right - panels.width * 0.1, isTrue);
    expect(story.top > panels.top + panels.height * 0.18, isTrue);
    expect(story.bottom < panels.bottom - panels.height * 0.18, isTrue);
  });

  testWidgets('side-by-side buttons keep a readable plate', (tester) async {
    await pumpPhone(
      tester,
      Scaffold(
        body: Center(
          child: Row(
            children: [
              Expanded(
                child: PngButton(label: 'Objection (2)', asset: AssetPaths.buttonSecondary, onPressed: () {}),
              ),
              const SizedBox(width: 8),
              Expanded(child: PngButton(label: 'Play Hand', onPressed: () {})),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    final plate = tester.getSize(find.byType(PngButton).first);
    expect(plate.height, greaterThanOrEqualTo(48));
  });
}

void _noop() {}
