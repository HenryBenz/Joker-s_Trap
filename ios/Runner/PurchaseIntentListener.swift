import StoreKit

/// Listens for purchases the user starts outside the app: a promoted
/// Golden Joker on the App Store page, or an offer opened from a link.
/// The purchase sheet is shown here. Flutter's transaction listener grants
/// the ticket and finishes the transaction.
@MainActor
final class PurchaseIntentListener {
  static let shared = PurchaseIntentListener()

  private var task: Task<Void, Never>?

  func start() {
    guard task == nil else { return }
    guard #available(iOS 16.4, *) else { return }
    // Keep the type referenced from app launch so the Release linker retains it.
    _ = PurchaseIntent.self
    task = Task { await listen() }
  }

  @available(iOS 16.4, *)
  private func listen() async {
    for await intent in PurchaseIntent.intents {
      await purchase(intent.product)
    }
  }

  @available(iOS 16.4, *)
  private func purchase(_ product: Product) async {
    do {
      let result = try await product.purchase()
      switch result {
      case .success(let verification):
        if case .unverified = verification {
          return
        }
      case .userCancelled, .pending:
        break
      @unknown default:
        break
      }
    } catch {
      return
    }
  }
}
