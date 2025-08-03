/// Represents the current state of the review promotion flow
enum ReviewStep {
  /// Initial state - not shown yet
  hidden,

  /// Asking about user satisfaction
  satisfaction,

  /// Requesting review based on satisfaction response
  reviewRequest,

  /// Showing thank you message
  thankYou,

  /// Flow completed, won't show again for this version
  completed,
}

/// Represents user's satisfaction response
enum SatisfactionResponse {
  /// User is satisfied
  satisfied,

  /// User is not satisfied
  unsatisfied,

  /// No response yet
  none,
}

/// Represents user's review response
enum ReviewResponse {
  /// User agreed to review
  agreed,

  /// User declined to review
  declined,

  /// No response yet
  none,
}

/// Current state of the review promotion
class ReviewState {
  /// Current step in the review flow
  final ReviewStep step;

  /// User's satisfaction response
  final SatisfactionResponse satisfactionResponse;

  /// User's review response
  final ReviewResponse reviewResponse;

  /// Whether the banner/dialog should be visible
  final bool isVisible;

  /// Current app version
  final String appVersion;

  /// Total usage time in milliseconds
  final int totalUsageTime;

  /// Session start time in milliseconds since epoch
  final int sessionStartTime;

  const ReviewState({
    this.step = ReviewStep.hidden,
    this.satisfactionResponse = SatisfactionResponse.none,
    this.reviewResponse = ReviewResponse.none,
    this.isVisible = false,
    this.appVersion = '',
    this.totalUsageTime = 0,
    this.sessionStartTime = 0,
  });

  /// Creates a copy of this state with the given fields replaced
  ReviewState copyWith({
    ReviewStep? step,
    SatisfactionResponse? satisfactionResponse,
    ReviewResponse? reviewResponse,
    bool? isVisible,
    String? appVersion,
    int? totalUsageTime,
    int? sessionStartTime,
  }) {
    return ReviewState(
      step: step ?? this.step,
      satisfactionResponse: satisfactionResponse ?? this.satisfactionResponse,
      reviewResponse: reviewResponse ?? this.reviewResponse,
      isVisible: isVisible ?? this.isVisible,
      appVersion: appVersion ?? this.appVersion,
      totalUsageTime: totalUsageTime ?? this.totalUsageTime,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
    );
  }

  @override
  String toString() {
    return 'ReviewState(step: $step, satisfaction: $satisfactionResponse, '
        'review: $reviewResponse, visible: $isVisible, version: $appVersion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewState &&
        other.step == step &&
        other.satisfactionResponse == satisfactionResponse &&
        other.reviewResponse == reviewResponse &&
        other.isVisible == isVisible &&
        other.appVersion == appVersion &&
        other.totalUsageTime == totalUsageTime &&
        other.sessionStartTime == sessionStartTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      step,
      satisfactionResponse,
      reviewResponse,
      isVisible,
      appVersion,
      totalUsageTime,
      sessionStartTime,
    );
  }
}
