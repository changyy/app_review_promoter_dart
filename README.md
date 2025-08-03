# App Review Promoter

[![pub package](https://img.shields.io/pub/v/app_review_promoter.svg)](https://pub.dev/packages/app_review_promoter)

A Flutter package for intelligently promoting app reviews with customizable timing and multi-step user engagement flow.

## Features

- ⏰ **Smart Timing**: Automatically prompts users after a configurable usage duration
- 🔄 **Multi-step Flow**: Two-step satisfaction survey followed by review request
- 📱 **Version Tracking**: Only prompts once per app version
- 🎨 **Fully Customizable**: All messages, styling, and actions can be customized
- 📊 **Analytics Support**: Built-in analytics tracking with custom callbacks
- 🏪 **Custom Store Actions**: Complete control over review/store redirection
- 🧪 **Debug Support**: Force show capability for development testing

## Quick Start

Add to your `pubspec.yaml`:

```yaml
dependencies:
  app_review_promoter:
    git:
      url: https://github.com/changyy/app_review_promoter_dart.git
  
  # Add review functionality dependencies as needed
  in_app_review: ^4.8.0      # For in-app review functionality
  url_launcher: ^6.3.0       # For custom URL handling (optional)
```

## Usage

### 1. Basic Setup

```dart
import 'package:app_review_promoter/app_review_promoter.dart';

// Initialize the review manager during app startup
await AppReviewManager.instance.initialize(
  ReviewConfig(
    appVersion: '1.0.0',
    messages: ReviewMessages(
      initialQuestion: 'Are you enjoying our app?',
      initialYesButton: 'Yes',
      initialNoButton: 'No',
      satisfiedMessage: 'Great! Would you mind leaving us a review?',
      unsatisfiedMessage: 'We\'d love to hear your feedback. Please consider leaving a review.',
      secondYesButton: 'Sure',
      secondNoButton: 'Maybe Later',
      agreeToReviewMessage: 'Thank you for your support!',
      declineToReviewMessage: 'Thank you for your feedback!',
    ),
    onReviewRequested: () async {
      // Custom logic for handling review requests
      // e.g., open App Store, Google Play, or in-app review
    },
  ),
);

// Start tracking AFTER privacy acceptance or other initial flows
await AppReviewManager.instance.startTracking();
```

### 2. Display Review Banner

```dart
// Banner automatically manages its own visibility
ReviewBanner()

// With debug force show for testing
ReviewBanner(debugForceShow: true)

// With custom child widget
ReviewBanner(
  child: CustomReviewWidget(), // Your own UI implementation
)
```

### 3. Analytics Callbacks

```dart
ReviewConfig(
  appVersion: '1.0.0',
  messages: /* ... */,
  
  // Track satisfaction responses (first step)
  onSatisfactionResponse: (bool isSatisfied) {
    // Send analytics event
    analytics.track('review_satisfaction', {'satisfied': isSatisfied});
  },
  
  // Track review responses (second step)
  onReviewResponse: (bool agreedToReview) {
    // Send analytics event
    analytics.track('review_request', {'agreed': agreedToReview});
  },
  
  // Track complete flow analytics
  onFlowCompleted: (ReviewAnalytics analytics) {
    // Complete analytics data with timestamps and user journey
    sendAnalytics('review_flow_completed', analytics.toJson());
  },
)
```

### 4. Flow Control

```dart
// Pause tracking during sensitive flows
AppReviewManager.instance.pauseTracking();

// Resume tracking when appropriate
await AppReviewManager.instance.resumeTracking();

// Check if user already responded for this version
bool hasResponded = AppReviewManager.instance.hasUserAlreadyResponded;
```

### 5. Custom Styling

```dart
ReviewConfig(
  // ... other config
  style: ReviewStyle(
    backgroundColor: Colors.blue[50],
    borderColor: Colors.blue[200],
    borderRadius: 8.0,
    messageTextColor: Colors.black87,
    primaryButtonBackgroundColor: Colors.blue,
    buttonTextColor: Colors.white,
    padding: EdgeInsets.all(16.0),
    margin: EdgeInsets.symmetric(horizontal: 16.0),
  ),
)
```

## Configuration Options

### ReviewConfig

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `appVersion` | `String` | Current app version for tracking | Required |
| `minUsageTime` | `Duration` | Minimum usage before showing prompt | 3 minutes |
| `messages` | `ReviewMessages` | All customizable text messages | Required |
| `onReviewRequested` | `Function()` | Custom callback when user agrees to review | null |
| `onSatisfactionResponse` | `Function(bool)` | Callback for satisfaction step responses | null |
| `onReviewResponse` | `Function(bool)` | Callback for review step responses | null |
| `onFlowCompleted` | `Function(ReviewAnalytics)` | Callback with complete analytics data | null |
| `style` | `ReviewStyle` | UI styling options | Default styling |
| `enableAnalytics` | `bool` | Enable/disable analytics tracking | true |

### ReviewMessages

All text content is fully customizable:

| Property | Description |
|----------|-------------|
| `initialQuestion` | First step satisfaction question |
| `initialYesButton` / `initialNoButton` | First step button labels |
| `satisfiedMessage` | Message shown when user is satisfied |
| `unsatisfiedMessage` | Message shown when user is unsatisfied |
| `secondYesButton` / `secondNoButton` | Second step button labels |
| `agreeToReviewMessage` | Final message when user agrees to review |
| `declineToReviewMessage` | Final message when user declines |

### ReviewStyle

Comprehensive styling options for complete visual customization:

| Property | Type | Description |
|----------|------|-------------|
| `backgroundColor` | `Color` | Banner background color |
| `borderColor` | `Color` | Border color |
| `borderRadius` | `double` | Corner radius |
| `messageTextColor` | `Color` | Text color for messages |
| `buttonTextColor` | `Color` | Button text color |
| `primaryButtonBackgroundColor` | `Color` | Primary button background |
| `secondaryButtonBackgroundColor` | `Color` | Secondary button background |
| `padding` | `EdgeInsets` | Internal padding |
| `margin` | `EdgeInsets` | External margin |

## Debug Features

For development and testing:

```dart
// Force show review banner (ignores all conditions)
AppReviewManager.instance.debugForceShow();

// Simulate usage time to trigger normal flow
AppReviewManager.instance.debugSimulateUsage(Duration(minutes: 5));

// Get current state information
Map<String, dynamic> debugInfo = AppReviewManager.instance.debugInfo;
print(debugInfo);

// Reset all data for testing
await AppReviewManager.instance.resetAll();
```

## Desktop Platform Considerations

### Review System Differences

Each desktop platform has different review ecosystems:

| Platform | Primary Store | Review URL Format |
|----------|---------------|-------------------|
| **Windows** | Microsoft Store | `ms-windows-store://review/?ProductId=ID` |
| **macOS** | Mac App Store | `macappstore://apps.apple.com/app/idID?action=write-review` |
| **Linux** | Snap Store | `snap://app-name` |
| **Linux** | Flathub | `https://flathub.org/apps/app.id` |
| **All** | GitHub Releases | `https://github.com/org/repo/releases` |

### Timing Considerations for Desktop

Desktop usage patterns differ from mobile:

```dart
ReviewConfig(
  // Desktop users typically have longer sessions
  minUsageTime: Duration(minutes: 10), // vs 3 minutes for mobile
  
  // Desktop users may prefer different messaging
  messages: ReviewMessages(
    initialQuestion: 'How has your experience been with our application?',
    satisfiedMessage: 'Great! Would you consider leaving a review on the store?',
    // ... more formal language for desktop users
  ),
)
```

### Distribution Strategy

Consider where your desktop app is distributed:

```dart
Future<void> _handleDesktopReview() async {
  // Check distribution channel and direct accordingly
  if (isDistributedViaStore()) {
    await _openStoreReview();
  } else {
    // Direct to GitHub, website, or email feedback
    await _openAlternativeFeedback();
  }
}
```

## Best Practices

1. **Initialize Early**: Call `initialize()` during app startup but before UI rendering
2. **Start After Privacy**: Call `startTracking()` only after user accepts privacy policies
3. **Version Tracking**: Always update `appVersion` when releasing new versions
4. **Custom Actions**: Use `onReviewRequested` callback for platform-specific review flows
5. **Analytics**: Implement callbacks to track user engagement and optimize timing
6. **Platform-Aware Timing**: Adjust `minUsageTime` based on platform (longer for desktop)
7. **Fallback Strategy**: Always provide alternative feedback methods for non-store distributions

## Required Additional Dependencies

This package is designed to be **dependency-minimal**. It only handles timing, UI flow, and state management. For actual review functionality, add these packages to your app:

```yaml
dependencies:
  # Required for in-app review functionality
  in_app_review: ^4.8.0      # Cross-platform in-app review
  
  # Optional for custom URL handling
  url_launcher: ^6.3.0       # Manual URL launching
  store_kit_2: ^2.0.0        # iOS-specific (optional)
```

## Platform Integration

### iOS App Store

```dart
import 'package:store_kit_2/store_kit_2.dart';

ReviewConfig(
  onReviewRequested: () async {
    await SKStoreReviewController.requestReview();
  },
)
```

### Android Google Play

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

### Desktop Platforms (Windows, macOS, Linux)

For desktop platforms, you can direct users to web-based review systems or software repositories:

```dart
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

ReviewConfig(
  onReviewRequested: () async {
    await _openDesktopReview();
  },
)

Future<void> _openDesktopReview() async {
  String? url;
  
  if (Platform.isWindows) {
    // Microsoft Store
    url = 'ms-windows-store://review/?ProductId=YOUR_PRODUCT_ID';
    // Alternative: Web URL
    // url = 'https://www.microsoft.com/store/apps/YOUR_APP_ID';
  } else if (Platform.isMacOS) {
    // Mac App Store
    url = 'macappstore://apps.apple.com/app/idYOUR_APP_ID?action=write-review';
    // Alternative: Web URL
    // url = 'https://apps.apple.com/app/idYOUR_APP_ID?action=write-review';
  } else if (Platform.isLinux) {
    // Snap Store
    url = 'snap://your-app-name';
    // Alternative: GitHub releases or custom website
    // url = 'https://github.com/your-org/your-app/releases';
  }
  
  if (url != null && await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    // Fallback to website
    await _openWebsiteFeedback();
  }
}

Future<void> _openWebsiteFeedback() async {
  const String websiteUrl = 'https://your-website.com/feedback';
  if (await canLaunchUrl(Uri.parse(websiteUrl))) {
    await launchUrl(Uri.parse(websiteUrl), mode: LaunchMode.externalApplication);
  }
}
```

### Cross-Platform Universal Implementation

Here's a complete cross-platform solution that handles all platforms:

```dart
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

ReviewConfig(
  onReviewRequested: () async {
    await _handleReviewRequest();
  },
)

Future<void> _handleReviewRequest() async {
  try {
    // For mobile platforms, try in-app review first
    if (Platform.isIOS || Platform.isAndroid) {
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        return;
      }
      // Fallback to store listing
      await inAppReview.openStoreListing(
        appStoreId: 'YOUR_IOS_APP_ID',
      );
      return;
    }
    
    // For desktop platforms
    await _openDesktopReview();
  } catch (e) {
    // Ultimate fallback - website
    await _openWebsiteFeedback();
  }
}

Future<void> _openDesktopReview() async {
  final Map<String, String> platformUrls = {
    'windows': 'https://www.microsoft.com/store/apps/YOUR_APP_ID',
    'macos': 'https://apps.apple.com/app/idYOUR_APP_ID?action=write-review',
    'linux': 'https://snapcraft.io/your-app-name',
  };
  
  String? url;
  if (Platform.isWindows) url = platformUrls['windows'];
  if (Platform.isMacOS) url = platformUrls['macos'];
  if (Platform.isLinux) url = platformUrls['linux'];
  
  if (url != null && await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    await _openWebsiteFeedback();
  }
}

Future<void> _openWebsiteFeedback() async {
  const String feedbackUrl = 'https://your-website.com/feedback';
  if (await canLaunchUrl(Uri.parse(feedbackUrl))) {
    await launchUrl(Uri.parse(feedbackUrl), mode: LaunchMode.externalApplication);
  }
}
```

## License

MIT License. See LICENSE file for details.

