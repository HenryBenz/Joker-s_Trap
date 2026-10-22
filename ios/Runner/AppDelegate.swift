import Flutter
import StoreKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, SKPaymentTransactionObserver {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // iOS 16.4 and later complete a promoted Golden Joker through PurchaseIntent.
    // Earlier systems use the payment-queue callback below. Only one path is active.
    // App Store Connect scans the uploaded binary for this selector.
    _ = #selector(paymentQueue(_:shouldAddStorePayment:for:))
    if #available(iOS 16.4, *) {
      PurchaseIntentListener.shared.start()
    } else {
      SKPaymentQueue.default().add(self)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
  }

  /// App Store Connect looks for this selector in the uploaded app.
  /// Returning true lets a promoted purchase continue on iOS 16.0–16.3.
  /// This observer is not registered on iOS 16.4+, where PurchaseIntent handles it.
  func paymentQueue(
    _ queue: SKPaymentQueue,
    shouldAddStorePayment payment: SKPayment,
    for product: SKProduct
  ) -> Bool {
    return true
  }
}
