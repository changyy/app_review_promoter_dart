import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_analytics.dart';
import '../utils/constants.dart';

/// Service for handling persistent storage of review promotion data
class ReviewStorageService {
  static ReviewStorageService? _instance;
  SharedPreferences? _prefs;

  ReviewStorageService._();

  /// Singleton instance
  static ReviewStorageService get instance {
    _instance ??= ReviewStorageService._();
    return _instance!;
  }

  /// Initialize the storage service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure preferences are loaded
  Future<SharedPreferences> get _preferences async {
    await initialize();
    return _prefs!;
  }

  /// Get the last reviewed app version
  Future<String?> getLastReviewedVersion() async {
    final prefs = await _preferences;
    return prefs.getString(AppReviewConstants.keyLastReviewVersion);
  }

  /// Set the last reviewed app version
  Future<void> setLastReviewedVersion(String version) async {
    final prefs = await _preferences;
    await prefs.setString(AppReviewConstants.keyLastReviewVersion, version);
  }

  /// Get the last user choice
  Future<String?> getLastUserChoice() async {
    final prefs = await _preferences;
    return prefs.getString(AppReviewConstants.keyLastReviewChoice);
  }

  /// Set the last user choice
  Future<void> setLastUserChoice(String choice) async {
    final prefs = await _preferences;
    await prefs.setString(AppReviewConstants.keyLastReviewChoice, choice);
  }

  /// Get the first launch time
  Future<int?> getFirstLaunchTime() async {
    final prefs = await _preferences;
    return prefs.getInt(AppReviewConstants.keyFirstLaunchTime);
  }

  /// Set the first launch time
  Future<void> setFirstLaunchTime(int timestamp) async {
    final prefs = await _preferences;
    await prefs.setInt(AppReviewConstants.keyFirstLaunchTime, timestamp);
  }

  /// Get total usage time
  Future<int> getTotalUsageTime() async {
    final prefs = await _preferences;
    return prefs.getInt(AppReviewConstants.keyTotalUsageTime) ?? 0;
  }

  /// Set total usage time
  Future<void> setTotalUsageTime(int usageTime) async {
    final prefs = await _preferences;
    await prefs.setInt(AppReviewConstants.keyTotalUsageTime, usageTime);
  }

  /// Add to total usage time
  Future<void> addUsageTime(int additionalTime) async {
    final currentUsage = await getTotalUsageTime();
    await setTotalUsageTime(currentUsage + additionalTime);
  }

  /// Get session start time
  Future<int?> getSessionStartTime() async {
    final prefs = await _preferences;
    return prefs.getInt(AppReviewConstants.keySessionStartTime);
  }

  /// Set session start time
  Future<void> setSessionStartTime(int timestamp) async {
    final prefs = await _preferences;
    await prefs.setInt(AppReviewConstants.keySessionStartTime, timestamp);
  }

  /// Save analytics data
  Future<void> saveAnalytics(ReviewAnalytics analytics) async {
    final prefs = await _preferences;
    final analyticsJson = jsonEncode(analytics.toMap());
    await prefs.setString('app_review_promoter_analytics', analyticsJson);
  }

  /// Load analytics data
  Future<ReviewAnalytics?> loadAnalytics() async {
    final prefs = await _preferences;
    final analyticsJson = prefs.getString('app_review_promoter_analytics');
    if (analyticsJson == null) return null;

    try {
      final analyticsMap = jsonDecode(analyticsJson) as Map<String, dynamic>;
      return ReviewAnalytics.fromMap(analyticsMap);
    } catch (e) {
      return null;
    }
  }

  /// Clear all stored data (useful for testing or reset functionality)
  Future<void> clearAll() async {
    final prefs = await _preferences;
    await Future.wait([
      prefs.remove(AppReviewConstants.keyLastReviewVersion),
      prefs.remove(AppReviewConstants.keyLastReviewChoice),
      prefs.remove(AppReviewConstants.keyFirstLaunchTime),
      prefs.remove(AppReviewConstants.keyTotalUsageTime),
      prefs.remove(AppReviewConstants.keySessionStartTime),
      prefs.remove('app_review_promoter_analytics'),
    ]);
  }

  /// Clear data for a specific version (useful when testing new versions)
  Future<void> clearVersionData(String version) async {
    final lastVersion = await getLastReviewedVersion();
    if (lastVersion == version) {
      final prefs = await _preferences;
      await Future.wait([
        prefs.remove(AppReviewConstants.keyLastReviewVersion),
        prefs.remove(AppReviewConstants.keyLastReviewChoice),
      ]);
    }
  }
}
