import 'package:in_app_review/in_app_review.dart';

/// Abstraction over the actual store/system review calls, so the resolution
/// logic is testable (inject a fake) and the platform plugin stays isolated.
abstract class StoreReviewLauncher {
  const StoreReviewLauncher();

  /// Whether the native in-app review is available on this device.
  Future<bool> isAvailable();

  /// Native in-app review prompt (may be throttled / silently no-op).
  Future<void> requestReview();

  /// Open the store listing. iOS/macOS need [appStoreId]; Windows needs
  /// [microsoftStoreId]; Android uses the running package name automatically.
  Future<void> openStoreListing({String? appStoreId, String? microsoftStoreId});
}

/// Default launcher backed by the `in_app_review` plugin.
class InAppReviewLauncher extends StoreReviewLauncher {
  const InAppReviewLauncher();

  InAppReview get _review => InAppReview.instance;

  @override
  Future<bool> isAvailable() => _review.isAvailable();

  @override
  Future<void> requestReview() => _review.requestReview();

  @override
  Future<void> openStoreListing({
    String? appStoreId,
    String? microsoftStoreId,
  }) => _review.openStoreListing(
    appStoreId: appStoreId,
    microsoftStoreId: microsoftStoreId,
  );
}
