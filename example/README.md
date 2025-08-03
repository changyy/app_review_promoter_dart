# App Review Promoter Example

This example demonstrates how to use the `app_review_promoter` package to intelligently promote app reviews in your Flutter application.

## Features Demonstrated

- **Basic Setup**: How to initialize and configure the AppReviewManager
- **Usage Tracking**: Automatic tracking of app usage time
- **Review Dialog**: Showing the review dialog at appropriate times
- **Custom Configuration**: Customizing messages, timing, and styling
- **Debug Tools**: Testing and debugging functionality
- **Analytics**: Tracking user interactions with the review flow

## Running the Example

1. Ensure you have Flutter installed
2. Navigate to the example directory:
   ```bash
   cd example
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Key Components

### 1. AppReviewManager Configuration

```dart
final config = ReviewConfig(
  appVersion: '1.0.0',
  minUsageTime: Duration(minutes: 2),
  enableAnalytics: true,
  onReviewRequested: () {
    print('User requested to review the app');
  },
  onFlowCompleted: (analytics) {
    print('Review flow completed: ${analytics.toString()}');
  },
);

await AppReviewManager.instance.initialize(config);
AppReviewManager.instance.startTracking();
```

### 2. ReviewBanner Widget

Wrap your main content with `ReviewBanner` to show review prompts as banners:

```dart
ReviewBanner(
  child: YourMainContent(),
)
```

### 3. ReviewDialog

Show review dialogs programmatically:

```dart
ReviewDialog.showIfNeeded(context);
```

### 4. Debug Features

The example includes several debug buttons to help you test the review flow:

- **Force Show Review Dialog**: Immediately shows the review dialog
- **Simulate 5 Min Usage**: Adds 5 minutes to the usage tracker
- **Reset Review Data**: Clears all stored review data

## Testing the Review Flow

1. Run the app and interact with it normally
2. Use the "Simulate 5 Min Usage" button to quickly reach the minimum usage time
3. Use "Force Show Review Dialog" to test the review flow immediately
4. Try different responses to see the multi-step engagement process

## Customization

The example shows how to customize:

- **Timing**: When to show review prompts based on usage time
- **Messages**: Custom text for each step of the review flow
- **Styling**: Visual appearance of review dialogs and banners
- **Analytics**: Tracking and responding to user interactions

For more advanced usage and customization options, see the main package documentation.