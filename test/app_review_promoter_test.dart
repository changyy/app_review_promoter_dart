import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_review_promoter/app_review_promoter.dart';

void main() {
  group('AppReviewPromoter Model Tests', () {
    test('ReviewConfig can be created with default values', () {
      const config = ReviewConfig();

      expect(config.appVersion, equals('1.0.0'));
      expect(config.enableAnalytics, isTrue);
      expect(config.minUsageTime, equals(Duration(minutes: 3)));
      expect(config.onReviewRequested, isNull);
      expect(config.onSatisfactionResponse, isNull);
      expect(config.onReviewResponse, isNull);
      expect(config.onFlowCompleted, isNull);
    });

    test('ReviewConfig can be created with custom values', () {
      bool callbackCalled = false;

      final config = ReviewConfig(
        appVersion: '2.1.0',
        minUsageTime: Duration(minutes: 10),
        enableAnalytics: false,
        onSatisfactionResponse: (satisfied) {
          callbackCalled = true;
        },
      );

      expect(config.appVersion, equals('2.1.0'));
      expect(config.minUsageTime, equals(Duration(minutes: 10)));
      expect(config.enableAnalytics, isFalse);
      expect(config.onSatisfactionResponse, isNotNull);

      // Test callback
      config.onSatisfactionResponse!(true);
      expect(callbackCalled, isTrue);
    });

    test('ReviewMessages can be created with default values', () {
      const messages = ReviewMessages.defaultMessages();

      expect(messages.initialQuestion, equals('Are you enjoying our app?'));
      expect(messages.initialYesButton, equals('Yes'));
      expect(messages.initialNoButton, equals('No'));
      expect(messages.satisfiedMessage,
          equals('Great! Would you mind leaving us a review?'));
      expect(messages.unsatisfiedMessage, contains('feedback'));
      expect(messages.secondYesButton, equals('Sure'));
      expect(messages.secondNoButton, equals('Maybe Later'));
      expect(
          messages.agreeToReviewMessage, equals('Thank you for your support!'));
      expect(messages.declineToReviewMessage,
          equals('Thank you for your feedback!'));
    });

    test('ReviewMessages helper methods work correctly', () {
      const messages = ReviewMessages.defaultMessages();

      expect(
        messages.getSecondStepMessage(true),
        equals(messages.satisfiedMessage),
      );
      expect(
        messages.getSecondStepMessage(false),
        equals(messages.unsatisfiedMessage),
      );
      expect(
        messages.getFinalMessage(true),
        equals(messages.agreeToReviewMessage),
      );
      expect(
        messages.getFinalMessage(false),
        equals(messages.declineToReviewMessage),
      );
    });

    test('ReviewAnalytics can be created and copied', () {
      const analytics = ReviewAnalytics(
        appVersion: '1.2.3',
        wasSatisfied: true,
        agreedToReview: true,
        storeWasOpened: true,
        flowWasCompleted: true,
        usageTimeWhenShown: 300000,
      );

      expect(analytics.appVersion, equals('1.2.3'));
      expect(analytics.wasSatisfied, isTrue);
      expect(analytics.agreedToReview, isTrue);
      expect(analytics.storeWasOpened, isTrue);
      expect(analytics.flowWasCompleted, isTrue);
      expect(analytics.usageTimeWhenShown, equals(300000));

      // Test copyWith
      final updated = analytics.copyWith(
        wasSatisfied: false,
        agreedToReview: false,
      );

      expect(updated.wasSatisfied, isFalse);
      expect(updated.agreedToReview, isFalse);
      expect(updated.appVersion, equals('1.2.3')); // Should remain unchanged
      expect(updated.storeWasOpened, isTrue); // Should remain unchanged
    });

    test('ReviewAnalytics can serialize to/from map', () {
      final testDate = DateTime(2024, 1, 1, 12, 0, 0);
      final analytics = ReviewAnalytics(
        appVersion: '1.0.0',
        wasSatisfied: true,
        agreedToReview: false,
        storeWasOpened: false,
        flowWasCompleted: true,
        usageTimeWhenShown: 180000, // 3 minutes
        firstShownAt: testDate,
        completedAt: testDate.add(Duration(minutes: 5)),
      );

      // Test toMap
      final map = analytics.toMap();
      expect(map['app_version'], equals('1.0.0'));
      expect(map['was_satisfied'], isTrue);
      expect(map['agreed_to_review'], isFalse);
      expect(map['store_was_opened'], isFalse);
      expect(map['flow_was_completed'], isTrue);
      expect(map['usage_time_when_shown_ms'], equals(180000));
      expect(map['first_shown_at'], equals(testDate.toIso8601String()));
      expect(map['completed_at'],
          equals(testDate.add(Duration(minutes: 5)).toIso8601String()));

      // Test fromMap
      final restored = ReviewAnalytics.fromMap(map);
      expect(restored.appVersion, equals('1.0.0'));
      expect(restored.wasSatisfied, isTrue);
      expect(restored.agreedToReview, isFalse);
      expect(restored.storeWasOpened, isFalse);
      expect(restored.flowWasCompleted, isTrue);
      expect(restored.usageTimeWhenShown, equals(180000));
      expect(restored.firstShownAt, equals(testDate));
      expect(restored.completedAt, equals(testDate.add(Duration(minutes: 5))));
    });

    test('ReviewState enum values work correctly', () {
      expect(ReviewStep.values.length, equals(5));
      expect(ReviewStep.values, contains(ReviewStep.hidden));
      expect(ReviewStep.values, contains(ReviewStep.satisfaction));
      expect(ReviewStep.values, contains(ReviewStep.reviewRequest));
      expect(ReviewStep.values, contains(ReviewStep.thankYou));
      expect(ReviewStep.values, contains(ReviewStep.completed));

      expect(SatisfactionResponse.values.length, equals(3));
      expect(SatisfactionResponse.values,
          contains(SatisfactionResponse.satisfied));
      expect(SatisfactionResponse.values,
          contains(SatisfactionResponse.unsatisfied));
      expect(SatisfactionResponse.values, contains(SatisfactionResponse.none));

      expect(ReviewResponse.values.length, equals(3));
      expect(ReviewResponse.values, contains(ReviewResponse.agreed));
      expect(ReviewResponse.values, contains(ReviewResponse.declined));
      expect(ReviewResponse.values, contains(ReviewResponse.none));
    });

    test('AppReviewManager singleton works correctly', () {
      final manager1 = AppReviewManager.instance;
      final manager2 = AppReviewManager.instance;

      expect(identical(manager1, manager2), isTrue);
      expect(manager1.config.appVersion, isNotEmpty);
      expect(manager1.state.step, equals(ReviewStep.hidden));
    });

    testWidgets('ReviewBanner can be created without error',
        (WidgetTester tester) async {
      // Test that ReviewBanner can be created without throwing
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReviewBanner(),
          ),
        ),
      );

      // Should not throw any errors during creation
      expect(find.byType(ReviewBanner), findsOneWidget);

      // Should be hidden by default (no internal state set)
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('ReviewBanner can be forced to show',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReviewBanner(debugForceShow: true),
          ),
        ),
      );

      expect(find.byType(ReviewBanner), findsOneWidget);

      // Should show content when debugForceShow is true
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('ReviewBanner respects forceHide parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReviewBanner(forceHide: true),
          ),
        ),
      );

      expect(find.byType(ReviewBanner), findsOneWidget);

      // Should be completely hidden when forceHide is true
      expect(find.byType(Container), findsNothing);
    });
  });
}
