import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum PurchasePhase { loading, ready, pending, owned, unavailable }

class PurchaseService extends ChangeNotifier {
  PurchaseService();

  static const productId = 'com.jokerstrap.golden_ticket';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? product;
  PurchasePhase phase = PurchasePhase.loading;
  bool userRestore = false;
  bool restoreFound = false;
  final _events = StreamController<PurchaseEvent>.broadcast();

  Stream<PurchaseEvent> get events => _events.stream;

  Future<void> start() async {
    phase = PurchasePhase.loading;
    notifyListeners();
    try {
      _subscription ??= _iap.purchaseStream.listen(
        _onPurchases,
        onError: (_) {
          phase = PurchasePhase.unavailable;
          notifyListeners();
        },
      );
      final available = await _iap.isAvailable();
      if (!available) {
        phase = PurchasePhase.unavailable;
        notifyListeners();
        return;
      }
      await reloadProduct();
    } catch (_) {
      phase = PurchasePhase.unavailable;
      notifyListeners();
    }
  }

  Future<void> reloadProduct() async {
    phase = PurchasePhase.loading;
    notifyListeners();
    try {
      final response = await _iap.queryProductDetails({productId});
      if (response.productDetails.isEmpty) {
        phase = PurchasePhase.unavailable;
      } else {
        product = response.productDetails.first;
        phase = PurchasePhase.ready;
      }
    } catch (_) {
      phase = PurchasePhase.unavailable;
    }
    notifyListeners();
  }

  Future<void> buy() async {
    final details = product;
    if (details == null || phase == PurchasePhase.pending) return;
    phase = PurchasePhase.pending;
    notifyListeners();
    try {
      final started = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: details),
      );
      if (!started) {
        phase = PurchasePhase.ready;
        notifyListeners();
      }
    } catch (_) {
      phase = PurchasePhase.ready;
      _events.add(PurchaseEvent.failed);
      notifyListeners();
    }
  }

  Future<void> restore() async {
    userRestore = true;
    restoreFound = false;
    try {
      await _iap.restorePurchases();
    } catch (_) {
      userRestore = false;
      _events.add(PurchaseEvent.restoreEmpty);
      return;
    }
    await Future<void>.delayed(const Duration(seconds: 2));
    if (userRestore && !restoreFound) {
      userRestore = false;
      _events.add(PurchaseEvent.restoreEmpty);
    }
  }

  void markOwned() {
    phase = PurchasePhase.owned;
    notifyListeners();
  }

  void _onPurchases(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID != productId) {
        _complete(purchase);
        continue;
      }
      switch (purchase.status) {
        case PurchaseStatus.pending:
          phase = PurchasePhase.pending;
          notifyListeners();
        case PurchaseStatus.purchased:
          phase = PurchasePhase.owned;
          _complete(purchase);
          _events.add(PurchaseEvent.purchased);
          notifyListeners();
        case PurchaseStatus.restored:
          restoreFound = true;
          phase = PurchasePhase.owned;
          _complete(purchase);
          if (userRestore) {
            userRestore = false;
            _events.add(PurchaseEvent.restored);
          } else {
            _events.add(PurchaseEvent.entitled);
          }
          notifyListeners();
        case PurchaseStatus.error:
          phase = product == null
              ? PurchasePhase.unavailable
              : PurchasePhase.ready;
          _complete(purchase);
          _events.add(PurchaseEvent.failed);
          notifyListeners();
        case PurchaseStatus.canceled:
          phase = product == null
              ? PurchasePhase.unavailable
              : PurchasePhase.ready;
          _complete(purchase);
          notifyListeners();
      }
    }
  }

  void _complete(PurchaseDetails purchase) {
    if (purchase.pendingCompletePurchase) {
      _iap.completePurchase(purchase);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _events.close();
    super.dispose();
  }
}

enum PurchaseEvent { purchased, restored, entitled, failed, restoreEmpty }
