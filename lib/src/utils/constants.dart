/// Constants used throughout the app_review_promoter package.
class AppReviewConstants {
  /// Storage keys for shared preferences
  static const String keyLastReviewVersion = 'app_review_promoter_last_version';
  static const String keyLastReviewChoice = 'app_review_promoter_last_choice';
  static const String keyFirstLaunchTime = 'app_review_promoter_first_launch';
  static const String keyTotalUsageTime = 'app_review_promoter_total_usage';
  static const String keySessionStartTime = 'app_review_promoter_session_start';

  /// Default configuration values
  static const Duration defaultMinUsageTime = Duration(minutes: 3);
  static const Duration defaultSessionTrackingInterval = Duration(seconds: 10);

  /// Review step identifiers
  static const String choiceYes = 'yes';
  static const String choiceNo = 'no';
  static const String choiceCompleted = 'completed';

  /// Analytics event names
  static const String eventReviewShown = 'review_prompt_shown';
  static const String eventSatisfactionYes = 'satisfaction_yes';
  static const String eventSatisfactionNo = 'satisfaction_no';
  static const String eventReviewRequested = 'review_requested';
  static const String eventReviewDeclined = 'review_declined';
  static const String eventStoreOpened = 'store_opened';
}
