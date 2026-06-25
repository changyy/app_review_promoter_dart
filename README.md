# App Review Promoter

[![pub package](https://img.shields.io/pub/v/app_review_promoter.svg)](https://pub.dev/packages/app_review_promoter)

A Flutter package for intelligently promoting app reviews with customizable timing and multi-step user engagement flow.

## Features

- ⏰ **Smart Timing**: Automatically prompts users after a configurable usage duration
- 🔄 **Multi-step Flow**: Two-step satisfaction survey followed by review request
- 📱 **Version Tracking**: Only prompts once per app version
- 🎨 **Fully Customizable**: All messages, styling, and actions can be customized
- 📊 **Analytics Support**: Built-in analytics tracking with custom callbacks
- 🧪 **Debug Support**: Force show capability for development testing

## Installation

```yaml
dependencies:
  app_review_promoter: ^1.0.1
```

## Quick Start

```dart
import 'package:app_review_promoter/app_review_promoter.dart';

// Initialize the review manager
await AppReviewManager.instance.initialize(
  ReviewConfig(
    appVersion: '1.0.0',
    minUsageTime: Duration(minutes: 3), // Default: 3 minutes
    messages: ReviewMessages.defaultMessages(),
    onReviewRequested: () async {
      // Handle review request - integrate with in_app_review or url_launcher
    },
  ),
);

// Start tracking after privacy acceptance
await AppReviewManager.instance.startTracking();

// Add ReviewBanner to your UI
ReviewBanner(
  child: YourMainContent(),
)
```

## Basic Usage

### Configuration

```dart
ReviewConfig(
  appVersion: '1.0.0',
  minUsageTime: Duration(minutes: 5),
  messages: ReviewMessages(
    initialQuestion: 'Are you enjoying our app?',
    satisfiedMessage: 'Great! Would you mind leaving us a review?',
    // ... other messages
  ),
  style: ReviewStyle(
    backgroundColor: Colors.blue[50],
    primaryButtonBackgroundColor: Colors.blue,
    // ... other styling
  ),
  onReviewRequested: () async {
    // Your review implementation
  },
  onFlowCompleted: (analytics) {
    // Track analytics
  },
)
```

### Display Options

```dart
// As a banner (wraps your content)
ReviewBanner(
  child: YourContent(),
)

// As a dialog (programmatic)
ReviewDialog.showIfNeeded(context);
```

### Debug Tools

```dart
// Force show for testing
AppReviewManager.instance.debugForceShow();

// Simulate usage time
AppReviewManager.instance.debugSimulateUsage(Duration(minutes: 5));

// Get debug info
final info = AppReviewManager.instance.debugInfo;

// Reset all data
await AppReviewManager.instance.resetAll();
```

## Store navigation (built-in, v1.1.0+)

Since 1.1.0 the package can take the user to the store itself — you no longer
need to wire `in_app_review` by hand. Configure it **per platform**:

```dart
ReviewConfig(
  // iOS opens the App Store review page (needs the App Store numeric id);
  // Android opens the Play listing automatically (uses the package name).
  ios: const PlatformReviewConfig.storeListing(storeId: '123456789'),
  android: const PlatformReviewConfig.storeListing(),
  // A platform left null defaults to the native in-app prompt (requestReview()).
)
```

- `ReviewMode.system` → native `requestReview()` (may be throttled by the OS).
- `ReviewMode.storeListing` → opens the store page (reliable for explicit "rate"
  intent). iOS/macOS need a store id; if missing, it falls back to `requestReview()`.
- iOS and Android can use different modes.

### Custom handler (takes priority)

Provide `onReviewRequest` to handle it yourself. Return `true` to stop, or `false`
to hand back to the package default:

```dart
ReviewConfig(
  onReviewRequest: (ctx) async {
    if (ctx.platform == TargetPlatform.iOS) {
      await myOwnFlow();
      return true;            // handled, stop
    }
    return false;             // fall through to the package default
  },
  android: const PlatformReviewConfig.storeListing(),
)
```

> Backward compatible: the legacy `onReviewRequested` callback still works and is
> treated as "handled" (the package will not run its default). With no handler and
> no per-platform config, behavior is unchanged (native prompt).

### Engagement trigger

Call `markEngagement()` when the user does something meaningful (e.g. opens a key
screen) to bump usage time to the threshold and let the prompt appear sooner:

```dart
AppReviewManager.instance.markEngagement();
```

## Example

See the [example](example/) directory for a complete sample app demonstrating all features.

## API Documentation

### ReviewConfig Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `appVersion` | `String` | Required | Current app version |
| `minUsageTime` | `Duration` | 3 minutes | Minimum usage before prompt |
| `messages` | `ReviewMessages` | Required | Customizable text |
| `style` | `ReviewStyle` | Default | UI styling |
| `enableAnalytics` | `bool` | true | Enable analytics |
| `onReviewRequest` | `ReviewRequestHandler` | null | Custom handler; return `true` to stop, `false` to fall through (priority) |
| `ios` / `android` / `macos` / `windows` | `PlatformReviewConfig` | null (→ system) | Per-platform default (system / storeListing) |
| `onReviewRequested` | `Function()` | null | Legacy review action callback (treated as handled) |
| `onFlowCompleted` | `Function(ReviewAnalytics)` | null | Completion callback |

### Additional Dependencies

Store/system review actions are built in via `in_app_review` (bundled since 1.1.0) —
you do not need to add it yourself for the default behavior. A custom `onReviewRequest`
handler may use any approach you like (e.g. `url_launcher`).

## License

MIT License. See LICENSE file for details.