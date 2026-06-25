import 'dart:async';

import 'package:flutter/foundation.dart';

/// How to take the user to leave a review on a given platform.
enum ReviewMode {
  /// Native in-app review prompt (`requestReview()`). May be throttled by the
  /// OS and silently show nothing; there is no signal whether it actually showed.
  system,

  /// Open the store product/review page directly (`openStoreListing()`).
  /// Reliable for explicit "rate" intent.
  storeListing,
}

/// Per-platform review behavior.
///
/// [storeId] meaning when [mode] is [ReviewMode.storeListing]:
/// - iOS / macOS: App Store numeric id (required; missing → falls back to system).
/// - Android: applicationId (optional; `null` uses the running package name).
/// - Windows: Microsoft Store id (required; missing → falls back to system).
class PlatformReviewConfig {
  final ReviewMode mode;
  final String? storeId;

  /// Use the native in-app review prompt on this platform.
  const PlatformReviewConfig.system()
      : mode = ReviewMode.system,
        storeId = null;

  /// Open the store listing on this platform.
  const PlatformReviewConfig.storeListing({this.storeId})
      : mode = ReviewMode.storeListing;
}

/// Context passed to a user-provided [ReviewRequestHandler].
class ReviewContext {
  /// Current platform, so a handler can branch per platform.
  final TargetPlatform platform;

  /// App version being reviewed.
  final String appVersion;

  /// Convenience: run the package's default behavior (per-platform
  /// system / storeListing) from inside a handler. After calling this you
  /// usually `return true` so the outer flow does not run it again.
  final Future<void> Function() runPackageDefault;

  const ReviewContext({
    required this.platform,
    required this.appVersion,
    required this.runPackageDefault,
  });
}

/// User-provided handler invoked when the user explicitly agrees to review.
///
/// Return value (inspired by HTML `onclick="return handler();"`):
/// - `true`  = handled, stop (the package does not run its default).
/// - `false` = hand back to the package; it then runs its default behavior.
typedef ReviewRequestHandler = FutureOr<bool> Function(ReviewContext ctx);
