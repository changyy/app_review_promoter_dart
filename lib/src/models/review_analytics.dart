/// Analytics data for the review promotion flow
class ReviewAnalytics {
  /// When the review prompt was first shown
  final DateTime? firstShownAt;

  /// When the user responded to satisfaction question
  final DateTime? satisfactionRespondedAt;

  /// When the user responded to review request
  final DateTime? reviewRespondedAt;

  /// When the store was opened (if applicable)
  final DateTime? storeOpenedAt;

  /// When the review flow was completed
  final DateTime? completedAt;

  /// User's satisfaction response
  final bool? wasSatisfied;

  /// Whether user agreed to review
  final bool? agreedToReview;

  /// Whether the store was actually opened
  final bool storeWasOpened;

  /// Whether the complete flow was finished
  final bool flowWasCompleted;

  /// App version when analytics was recorded
  final String appVersion;

  /// Total usage time when prompt was shown (in milliseconds)
  final int usageTimeWhenShown;

  const ReviewAnalytics({
    this.firstShownAt,
    this.satisfactionRespondedAt,
    this.reviewRespondedAt,
    this.storeOpenedAt,
    this.completedAt,
    this.wasSatisfied,
    this.agreedToReview,
    this.storeWasOpened = false,
    this.flowWasCompleted = false,
    this.appVersion = '',
    this.usageTimeWhenShown = 0,
  });

  /// Creates a copy of this analytics with the given fields replaced
  ReviewAnalytics copyWith({
    DateTime? firstShownAt,
    DateTime? satisfactionRespondedAt,
    DateTime? reviewRespondedAt,
    DateTime? storeOpenedAt,
    DateTime? completedAt,
    bool? wasSatisfied,
    bool? agreedToReview,
    bool? storeWasOpened,
    bool? flowWasCompleted,
    String? appVersion,
    int? usageTimeWhenShown,
  }) {
    return ReviewAnalytics(
      firstShownAt: firstShownAt ?? this.firstShownAt,
      satisfactionRespondedAt:
          satisfactionRespondedAt ?? this.satisfactionRespondedAt,
      reviewRespondedAt: reviewRespondedAt ?? this.reviewRespondedAt,
      storeOpenedAt: storeOpenedAt ?? this.storeOpenedAt,
      completedAt: completedAt ?? this.completedAt,
      wasSatisfied: wasSatisfied ?? this.wasSatisfied,
      agreedToReview: agreedToReview ?? this.agreedToReview,
      storeWasOpened: storeWasOpened ?? this.storeWasOpened,
      flowWasCompleted: flowWasCompleted ?? this.flowWasCompleted,
      appVersion: appVersion ?? this.appVersion,
      usageTimeWhenShown: usageTimeWhenShown ?? this.usageTimeWhenShown,
    );
  }

  /// Convert to map for analytics services
  Map<String, dynamic> toMap() {
    return {
      'first_shown_at': firstShownAt?.toIso8601String(),
      'satisfaction_responded_at': satisfactionRespondedAt?.toIso8601String(),
      'review_responded_at': reviewRespondedAt?.toIso8601String(),
      'store_opened_at': storeOpenedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'was_satisfied': wasSatisfied,
      'agreed_to_review': agreedToReview,
      'store_was_opened': storeWasOpened,
      'flow_was_completed': flowWasCompleted,
      'app_version': appVersion,
      'usage_time_when_shown_ms': usageTimeWhenShown,
    };
  }

  /// Create from map (for persistence)
  factory ReviewAnalytics.fromMap(Map<String, dynamic> map) {
    return ReviewAnalytics(
      firstShownAt: map['first_shown_at'] != null
          ? DateTime.parse(map['first_shown_at'])
          : null,
      satisfactionRespondedAt: map['satisfaction_responded_at'] != null
          ? DateTime.parse(map['satisfaction_responded_at'])
          : null,
      reviewRespondedAt: map['review_responded_at'] != null
          ? DateTime.parse(map['review_responded_at'])
          : null,
      storeOpenedAt: map['store_opened_at'] != null
          ? DateTime.parse(map['store_opened_at'])
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      wasSatisfied: map['was_satisfied'],
      agreedToReview: map['agreed_to_review'],
      storeWasOpened: map['store_was_opened'] ?? false,
      flowWasCompleted: map['flow_was_completed'] ?? false,
      appVersion: map['app_version'] ?? '',
      usageTimeWhenShown: map['usage_time_when_shown_ms'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'ReviewAnalytics(satisfied: $wasSatisfied, agreed: $agreedToReview, '
        'storeOpened: $storeWasOpened, version: $appVersion)';
  }
}
