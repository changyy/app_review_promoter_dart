import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/review_config.dart';
import '../models/review_state.dart';
import '../models/review_analytics.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

/// Main manager class for handling app review promotion logic
class AppReviewManager extends ChangeNotifier {
  static AppReviewManager? _instance;

  /// Configuration for the review manager
  ReviewConfig _config = const ReviewConfig();

  /// Current state of the review flow
  ReviewState _state = const ReviewState();

  /// Analytics data
  ReviewAnalytics _analytics = const ReviewAnalytics();

  /// Storage service instance
  final ReviewStorageService _storage = ReviewStorageService.instance;

  /// Timer for tracking usage time
  Timer? _usageTimer;

  AppReviewManager._();

  /// Singleton instance
  static AppReviewManager get instance {
    _instance ??= AppReviewManager._();
    return _instance!;
  }

  /// Current configuration
  ReviewConfig get config => _config;

  /// Current state
  ReviewState get state => _state;

  /// Current analytics
  ReviewAnalytics get analytics => _analytics;

  /// Initialize the review manager with configuration
  Future<void> initialize(ReviewConfig config) async {
    _config = config;

    // Initialize storage
    await _storage.initialize();

    // Load existing state
    await _loadState();

    // Don't start session tracking yet - wait for explicit start
    notifyListeners();
  }

  /// Start the review promotion process (call after privacy acceptance, etc.)
  Future<void> startTracking() async {
    // Start session tracking
    await _startSession();

    // Check if we should show the review prompt
    await _checkShouldShow();
  }

  /// Pause tracking (call during sensitive flows like privacy screens)
  void pauseTracking() {
    _usageTimer?.cancel();
    _usageTimer = null;
  }

  /// Resume tracking
  Future<void> resumeTracking() async {
    await _startSession();
    await _checkShouldShow();
  }

  /// Load state from storage
  Future<void> _loadState() async {
    final lastVersion = await _storage.getLastReviewedVersion();
    final lastChoice = await _storage.getLastUserChoice();
    final totalUsage = await _storage.getTotalUsageTime();
    final analytics = await _storage.loadAnalytics();

    _state = _state.copyWith(
      appVersion: _config.appVersion,
      totalUsageTime: totalUsage,
    );

    if (analytics != null) {
      _analytics = analytics;
    }

    // If current version already has a choice recorded, mark as completed
    if (lastVersion == _config.appVersion && lastChoice != null) {
      _state = _state.copyWith(step: ReviewStep.completed);
    }

    notifyListeners();
  }

  /// Start tracking session usage time
  Future<void> _startSession() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _storage.setSessionStartTime(now);

    _state = _state.copyWith(sessionStartTime: now);

    // Start usage timer
    _usageTimer?.cancel();
    _usageTimer = Timer.periodic(
      AppReviewConstants.defaultSessionTrackingInterval,
      _updateUsageTime,
    );

    notifyListeners();
  }

  /// Update usage time
  void _updateUsageTime(Timer timer) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final sessionTime = now - _state.sessionStartTime;

    // Add session time to total usage
    _storage.addUsageTime(sessionTime.toInt());

    _state = _state.copyWith(
      totalUsageTime: _state.totalUsageTime + sessionTime.toInt(),
      sessionStartTime: now,
    );

    // Check if we should show the prompt
    _checkShouldShow();

    notifyListeners();
  }

  /// Check if the review prompt should be shown
  Future<void> _checkShouldShow() async {
    // Don't show if already completed for this version
    if (_state.step == ReviewStep.completed) return;

    // Don't show if already visible
    if (_state.isVisible) return;

    // Check if minimum usage time is reached
    final minUsageMs = _config.minUsageTime.inMilliseconds;
    if (_state.totalUsageTime < minUsageMs) return;

    // Check version-specific completion
    final lastVersion = await _storage.getLastReviewedVersion();
    if (lastVersion == _config.appVersion) return;

    // All conditions met - show the prompt
    await _showReviewPrompt();
  }

  /// Show the review prompt
  Future<void> _showReviewPrompt() async {
    _state = _state.copyWith(
      step: ReviewStep.satisfaction,
      isVisible: true,
    );

    _analytics = _analytics.copyWith(
      firstShownAt: DateTime.now(),
      appVersion: _config.appVersion,
      usageTimeWhenShown: _state.totalUsageTime,
    );

    await _storage.saveAnalytics(_analytics);

    if (_config.enableAnalytics) {
      _trackEvent(AppReviewConstants.eventReviewShown, {
        'app_version': _config.appVersion,
        'usage_time_ms': _state.totalUsageTime,
      });
    }

    notifyListeners();
  }

  /// Handle satisfaction response
  Future<void> handleSatisfactionResponse(bool isSatisfied) async {
    _state = _state.copyWith(
      satisfactionResponse: isSatisfied
          ? SatisfactionResponse.satisfied
          : SatisfactionResponse.unsatisfied,
      step: ReviewStep.reviewRequest,
    );

    _analytics = _analytics.copyWith(
      satisfactionRespondedAt: DateTime.now(),
      wasSatisfied: isSatisfied,
    );

    await _storage.saveAnalytics(_analytics);

    // Call user callback
    _config.onSatisfactionResponse?.call(isSatisfied);

    if (_config.enableAnalytics) {
      _trackEvent(
        isSatisfied
            ? AppReviewConstants.eventSatisfactionYes
            : AppReviewConstants.eventSatisfactionNo,
        {'app_version': _config.appVersion},
      );
    }

    notifyListeners();
  }

  /// Handle review response
  Future<void> handleReviewResponse(bool agreedToReview) async {
    _state = _state.copyWith(
      reviewResponse:
          agreedToReview ? ReviewResponse.agreed : ReviewResponse.declined,
      step: ReviewStep.thankYou,
    );

    _analytics = _analytics.copyWith(
      reviewRespondedAt: DateTime.now(),
      agreedToReview: agreedToReview,
    );

    await _storage.saveAnalytics(_analytics);

    // Call user callback
    _config.onReviewResponse?.call(agreedToReview);

    if (_config.enableAnalytics) {
      _trackEvent(
        agreedToReview
            ? AppReviewConstants.eventReviewRequested
            : AppReviewConstants.eventReviewDeclined,
        {'app_version': _config.appVersion},
      );
    }

    if (agreedToReview) {
      await _openStoreReview();
    }

    // Auto-hide after a delay
    Timer(const Duration(seconds: 3), () {
      _completeFlow();
    });

    notifyListeners();
  }

  /// Open store review
  Future<void> _openStoreReview() async {
    try {
      // Use custom callback if provided
      if (_config.onReviewRequested != null) {
        await _config.onReviewRequested!();
      }

      _analytics = _analytics.copyWith(
        storeOpenedAt: DateTime.now(),
        storeWasOpened: true,
      );

      await _storage.saveAnalytics(_analytics);

      if (_config.enableAnalytics) {
        _trackEvent(AppReviewConstants.eventStoreOpened, {
          'app_version': _config.appVersion,
          'custom_callback': _config.onReviewRequested != null,
        });
      }
    } catch (e) {
      // Handle error silently or log it
      if (kDebugMode) {
        print('Error opening store review: $e');
      }
    }
  }

  /// Complete the review flow
  Future<void> _completeFlow() async {
    _state = _state.copyWith(
      step: ReviewStep.completed,
      isVisible: false,
    );

    // Update final analytics
    _analytics = _analytics.copyWith(
      completedAt: DateTime.now(),
      flowWasCompleted: true,
    );

    await _storage.saveAnalytics(_analytics);

    // Call completion callback with final analytics data
    _config.onFlowCompleted?.call(_analytics);

    // Record completion in storage
    await _storage.setLastReviewedVersion(_config.appVersion);
    await _storage.setLastUserChoice(AppReviewConstants.choiceCompleted);

    notifyListeners();
  }

  /// Manually hide the review prompt
  void hideReviewPrompt() {
    _state = _state.copyWith(isVisible: false);
    notifyListeners();
  }

  /// Track analytics event
  void _trackEvent(String event, Map<String, dynamic> parameters) {
    _config.onAnalyticsEvent?.call(event, parameters);
  }

  /// Stop session tracking
  void stopSessionTracking() {
    _usageTimer?.cancel();
    _usageTimer = null;
  }

  /// Reset all data (useful for testing)
  Future<void> resetAll() async {
    await _storage.clearAll();
    _state = const ReviewState();
    _analytics = const ReviewAnalytics();
    notifyListeners();
  }

  /// Debug: Force show review prompt (ignores all conditions)
  void debugForceShow() {
    _state = _state.copyWith(
      step: ReviewStep.satisfaction,
      isVisible: true,
    );
    notifyListeners();
  }

  /// Debug: Simulate usage time to trigger normal flow
  void debugSimulateUsage(Duration duration) {
    _state = _state.copyWith(
      totalUsageTime: duration.inMilliseconds,
    );
    _checkShouldShow();
    notifyListeners();
  }

  /// Debug: Get current state information
  Map<String, dynamic> get debugInfo => {
        'appVersion': _config.appVersion,
        'totalUsageTime': _state.totalUsageTime,
        'minUsageTime': _config.minUsageTime.inMilliseconds,
        'step': _state.step.toString(),
        'isVisible': _state.isVisible,
        'hasUserAlreadyResponded': hasUserAlreadyResponded,
      };

  /// Check if user has already provided feedback for current version
  bool get hasUserAlreadyResponded => _state.step == ReviewStep.completed;

  @override
  void dispose() {
    _usageTimer?.cancel();
    super.dispose();
  }
}
