import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../core/purchase_service.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/png_button.dart';

class GoldenTicketScreen extends StatefulWidget {
  const GoldenTicketScreen({super.key});

  @override
  State<GoldenTicketScreen> createState() => _GoldenTicketScreenState();
}

class _GoldenTicketScreenState extends State<GoldenTicketScreen> {
  StreamSubscription<PurchaseEvent>? _sub;
  AppController? _app;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppScope.of(context);
    if (!identical(_app, app)) {
      _app?.removeListener(_refresh);
      _app?.purchases.removeListener(_refresh);
      _app = app;
      app.addListener(_refresh);
      app.purchases.addListener(_refresh);
      _sub?.cancel();
      _sub = app.purchases.events.listen(_onEvent);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _onEvent(PurchaseEvent event) async {
    if (!mounted) return;
    _refresh();
    final app = AppScope.of(context);
    switch (event) {
      case PurchaseEvent.purchased:
        app.audio.playDuckCue(AssetPaths.sfxPurchase, const Duration(milliseconds: 2200));
        AppHaptics.success(app.save.hapticsEnabled);
        final enter = await showGameDialog(
          context: context,
          title: 'The Golden Act is now open.',
          body: 'The Golden Act is now open.',
          cancelLabel: 'Enter Golden Act',
          confirmLabel: 'Enter Golden Act',
        );
        if (!mounted) return;
        _refresh();
        if (enter) context.go('/map?show=13');
      case PurchaseEvent.restored:
        await showGameDialog(
          context: context,
          title: 'Golden Joker restored.',
          body: 'Golden Joker restored.',
          cancelLabel: 'OK',
          confirmLabel: 'OK',
        );
      case PurchaseEvent.restoreEmpty:
        await showGameDialog(
          context: context,
          title: 'No Purchase Found',
          body: 'No Golden Joker purchase was found for this Apple ID.',
          cancelLabel: 'OK',
          confirmLabel: 'OK',
        );
      case PurchaseEvent.failed:
        app.audio.playSfx(AssetPaths.sfxError);
        await showGameDialog(
          context: context,
          title: 'Purchase Not Completed',
          body: 'No charge was made. Please try again.',
          cancelLabel: 'OK',
          confirmLabel: 'OK',
        );
      case PurchaseEvent.entitled:
        break;
    }
  }

  @override
  void dispose() {
    _app?.removeListener(_refresh);
    _app?.purchases.removeListener(_refresh);
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final purchases = app.purchases;
    final owned = app.save.goldenTicketOwned || purchases.phase == PurchasePhase.owned;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PngAsset(path: AssetPaths.bgStoreGold, fit: BoxFit.cover),
          SafeArea(
            child: ContentFrame(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconTap(
                      icon: Icons.arrow_back_ios_new,
                      tooltip: 'Back',
                      onPressed: app.bindTap(() => context.pop()),
                    ),
                  ),
                  const SizedBox(
                    height: 180,
                    child: PngAsset(path: AssetPaths.goldenTicketHero, fit: BoxFit.contain),
                  ),
                  InkPanel(
                    child: Column(
                      children: [
                        Text('GOLDEN JOKER', textAlign: TextAlign.center, style: AppTheme.display(26, shadow: false)),
                        const SizedBox(height: 8),
                        Text(
                          'Turn the deck over and enter the secret final act.',
                          textAlign: TextAlign.center,
                          style: AppTheme.body(16, shadow: false),
                        ),
                        const SizedBox(height: 10),
                        for (final line in const [
                          '4 new shows and 16 new rounds',
                          'The Golden Act stage and soundtrack',
                          'Exclusive Joker bow and golden ending',
                          'A permanent unlock — no subscriptions',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('• $line', textAlign: TextAlign.center, style: AppTheme.body(15, shadow: false)),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _purchaseButton(app, owned),
                  const SizedBox(height: 8),
                  PngButton(
                    label: 'Restore Purchases',
                    asset: AssetPaths.buttonSecondary,
                    onPressed: _busy
                        ? null
                        : app.bindTap(() async {
                            setState(() => _busy = true);
                            await purchases.restore();
                            if (mounted) setState(() => _busy = false);
                          }),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _purchaseButton(AppController app, bool owned) {
    final phase = app.purchases.phase;
    if (owned) {
      return const PngButton(
        label: 'Golden Joker Owned',
        asset: AssetPaths.buttonGold,
        inkLabel: true,
        onPressed: null,
      );
    }
    if (phase == PurchasePhase.loading) {
      return const PngButton(
        label: 'Loading…',
        asset: AssetPaths.buttonGold,
        inkLabel: true,
        onPressed: null,
      );
    }
    if (phase == PurchasePhase.pending) {
      return const PngButton(
        label: 'Completing Purchase…',
        asset: AssetPaths.buttonGold,
        inkLabel: true,
        onPressed: null,
      );
    }
    if (phase == PurchasePhase.unavailable) {
      return Column(
        children: [
          InkPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              'The App Store is unavailable right now. The game remains fully playable.',
              textAlign: TextAlign.center,
              style: AppTheme.body(15, shadow: false),
            ),
          ),
          const SizedBox(height: 8),
          PngButton(
            label: 'Try Again',
            asset: AssetPaths.buttonGold,
            inkLabel: true,
            onPressed: app.bindTap(app.purchases.reloadProduct),
          ),
        ],
      );
    }
    final price = app.purchases.product?.price ?? '';
    return PngButton(
      label: 'Unlock for $price',
      asset: AssetPaths.buttonGold,
      inkLabel: true,
      onPressed: _busy ? null : app.bindTap(app.purchases.buy),
    );
  }
}
