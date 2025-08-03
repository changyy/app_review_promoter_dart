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

## Platform Integration Example

```dart
import 'package:in_app_review/in_app_review.dart';

ReviewConfig(
  onReviewRequested: () async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing();
    }
  },
)
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
| `onReviewRequested` | `Function()` | null | Review action callback |
| `onFlowCompleted` | `Function(ReviewAnalytics)` | null | Completion callback |

### Additional Dependencies

This package handles the review flow UI and timing. For actual review functionality:

```yaml
dependencies:
  # For in-app reviews
  in_app_review: ^2.0.0
  
  # For custom URL handling
  url_launcher: ^6.0.0
```

## License

MIT License. See LICENSE file for details.