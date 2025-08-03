import '../utils/constants.dart';
import 'review_analytics.dart';

/// Configuration class for customizing the app review promotion behavior.
class ReviewConfig {
  /// App version to track (required for version-specific tracking)
  final String appVersion;

  /// Minimum usage time before showing the review prompt
  final Duration minUsageTime;

  /// Custom messages for different steps
  final ReviewMessages messages;

  /// Whether to enable analytics tracking
  final bool enableAnalytics;

  /// Custom analytics callback function
  final Function(String event, Map<String, dynamic> parameters)?
      onAnalyticsEvent;

  /// Custom callback when user agrees to review (用戶點擊第二段的 YES 時)
  /// This allows complete customization of the review action
  final Future<void> Function()? onReviewRequested;

  /// Callback when user responds to satisfaction question (第一段 YES/No)
  final void Function(bool isSatisfied)? onSatisfactionResponse;

  /// Callback when user responds to review request (第二段 YES/No)
  final void Function(bool agreedToReview)? onReviewResponse;

  /// Callback when the review flow completes
  final void Function(ReviewAnalytics analytics)? onFlowCompleted;

  /// Custom styling for the review promotion UI
  final ReviewStyle? style;

  const ReviewConfig({
    this.appVersion = '1.0.0',
    this.minUsageTime = AppReviewConstants.defaultMinUsageTime,
    this.messages = const ReviewMessages.defaultMessages(),
    this.enableAnalytics = true,
    this.onAnalyticsEvent,
    this.onReviewRequested,
    this.onSatisfactionResponse,
    this.onReviewResponse,
    this.onFlowCompleted,
    this.style,
  });

  /// Creates a copy of this config with the given fields replaced
  ReviewConfig copyWith({
    String? appVersion,
    Duration? minUsageTime,
    ReviewMessages? messages,
    bool? enableAnalytics,
    Function(String event, Map<String, dynamic> parameters)? onAnalyticsEvent,
    Future<void> Function()? onReviewRequested,
    void Function(bool isSatisfied)? onSatisfactionResponse,
    void Function(bool agreedToReview)? onReviewResponse,
    void Function(ReviewAnalytics analytics)? onFlowCompleted,
    ReviewStyle? style,
  }) {
    return ReviewConfig(
      appVersion: appVersion ?? this.appVersion,
      minUsageTime: minUsageTime ?? this.minUsageTime,
      messages: messages ?? this.messages,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      onAnalyticsEvent: onAnalyticsEvent ?? this.onAnalyticsEvent,
      onReviewRequested: onReviewRequested ?? this.onReviewRequested,
      onSatisfactionResponse:
          onSatisfactionResponse ?? this.onSatisfactionResponse,
      onReviewResponse: onReviewResponse ?? this.onReviewResponse,
      onFlowCompleted: onFlowCompleted ?? this.onFlowCompleted,
      style: style ?? this.style,
    );
  }
}

/// Customizable messages for the review promotion flow
/// All messages must be provided by the user for complete customization
class ReviewMessages {
  /// 第一段顯示訊息 - 初始滿意度問題
  final String initialQuestion;

  /// 第一段按鈕文字
  final String initialYesButton;
  final String initialNoButton;

  /// 第一段選 YES 後的顯示訊息
  final String satisfiedMessage;

  /// 第一段選 No 後的顯示訊息
  final String unsatisfiedMessage;

  /// 第二段按鈕文字
  final String secondYesButton;
  final String secondNoButton;

  /// 第二段選 YES 後的顯示訊息
  final String agreeToReviewMessage;

  /// 第二段選 No 後的顯示訊息
  final String declineToReviewMessage;

  const ReviewMessages({
    required this.initialQuestion,
    required this.initialYesButton,
    required this.initialNoButton,
    required this.satisfiedMessage,
    required this.unsatisfiedMessage,
    required this.secondYesButton,
    required this.secondNoButton,
    required this.agreeToReviewMessage,
    required this.declineToReviewMessage,
  });

  /// Default messages for basic usage
  const ReviewMessages.defaultMessages({
    this.initialQuestion = 'Are you enjoying our app?',
    this.initialYesButton = 'Yes',
    this.initialNoButton = 'No',
    this.satisfiedMessage = 'Great! Would you mind leaving us a review?',
    this.unsatisfiedMessage =
        'We\'d love to hear your feedback. Please consider leaving a review.',
    this.secondYesButton = 'Sure',
    this.secondNoButton = 'Maybe Later',
    this.agreeToReviewMessage = 'Thank you for your support!',
    this.declineToReviewMessage = 'Thank you for your feedback!',
  });

  /// Creates a copy of this messages with the given fields replaced
  ReviewMessages copyWith({
    String? initialQuestion,
    String? initialYesButton,
    String? initialNoButton,
    String? satisfiedMessage,
    String? unsatisfiedMessage,
    String? secondYesButton,
    String? secondNoButton,
    String? agreeToReviewMessage,
    String? declineToReviewMessage,
  }) {
    return ReviewMessages(
      initialQuestion: initialQuestion ?? this.initialQuestion,
      initialYesButton: initialYesButton ?? this.initialYesButton,
      initialNoButton: initialNoButton ?? this.initialNoButton,
      satisfiedMessage: satisfiedMessage ?? this.satisfiedMessage,
      unsatisfiedMessage: unsatisfiedMessage ?? this.unsatisfiedMessage,
      secondYesButton: secondYesButton ?? this.secondYesButton,
      secondNoButton: secondNoButton ?? this.secondNoButton,
      agreeToReviewMessage: agreeToReviewMessage ?? this.agreeToReviewMessage,
      declineToReviewMessage:
          declineToReviewMessage ?? this.declineToReviewMessage,
    );
  }

  /// Get the appropriate second step message based on satisfaction response
  String getSecondStepMessage(bool isSatisfied) {
    return isSatisfied ? satisfiedMessage : unsatisfiedMessage;
  }

  /// Get the appropriate final message based on review response
  String getFinalMessage(bool agreedToReview) {
    return agreedToReview ? agreeToReviewMessage : declineToReviewMessage;
  }
}

/// Customizable styling for the review promotion UI
/// All styling properties are optional - if not provided, defaults will be used
class ReviewStyle {
  /// Background color of the banner/container
  final dynamic backgroundColor;

  /// Border color and width
  final dynamic borderColor;
  final double? borderWidth;
  final double? borderRadius;

  /// Text colors
  final dynamic messageTextColor;
  final dynamic buttonTextColor;

  /// Button styling
  final dynamic primaryButtonBackgroundColor;
  final dynamic secondaryButtonBackgroundColor;
  final dynamic secondaryButtonTextColor; // 新增：負向按鈕文字顏色
  final dynamic buttonBorderColor;
  final double? buttonBorderRadius;
  final dynamic buttonTextStyle;

  /// Text styling
  final dynamic messageTextStyle;

  /// Spacing and padding
  final dynamic padding;
  final dynamic margin;
  final double? spacing;

  /// Icon or custom widget (optional)
  final dynamic leadingIcon;
  final dynamic trailingIcon;

  const ReviewStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.messageTextColor,
    this.buttonTextColor,
    this.primaryButtonBackgroundColor,
    this.secondaryButtonBackgroundColor,
    this.secondaryButtonTextColor, // 新增參數
    this.buttonBorderColor,
    this.buttonBorderRadius,
    this.buttonTextStyle,
    this.messageTextStyle,
    this.padding,
    this.margin,
    this.spacing,
    this.leadingIcon,
    this.trailingIcon,
  });

  /// Creates a copy of this style with the given fields replaced
  ReviewStyle copyWith({
    dynamic backgroundColor,
    dynamic borderColor,
    double? borderWidth,
    double? borderRadius,
    dynamic messageTextColor,
    dynamic buttonTextColor,
    dynamic primaryButtonBackgroundColor,
    dynamic secondaryButtonBackgroundColor,
    dynamic secondaryButtonTextColor, // 新增參數
    dynamic buttonBorderColor,
    double? buttonBorderRadius,
    dynamic buttonTextStyle,
    dynamic messageTextStyle,
    dynamic padding,
    dynamic margin,
    double? spacing,
    dynamic leadingIcon,
    dynamic trailingIcon,
  }) {
    return ReviewStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      messageTextColor: messageTextColor ?? this.messageTextColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      primaryButtonBackgroundColor:
          primaryButtonBackgroundColor ?? this.primaryButtonBackgroundColor,
      secondaryButtonBackgroundColor:
          secondaryButtonBackgroundColor ?? this.secondaryButtonBackgroundColor,
      secondaryButtonTextColor:
          secondaryButtonTextColor ?? this.secondaryButtonTextColor, // 新增實作
      buttonBorderColor: buttonBorderColor ?? this.buttonBorderColor,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      messageTextStyle: messageTextStyle ?? this.messageTextStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      spacing: spacing ?? this.spacing,
      leadingIcon: leadingIcon ?? this.leadingIcon,
      trailingIcon: trailingIcon ?? this.trailingIcon,
    );
  }
}
