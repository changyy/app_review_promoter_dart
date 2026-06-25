import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_review_promoter/app_review_promoter.dart';

/// Records launcher calls so we can assert which action the resolution picked.
class _FakeLauncher extends StoreReviewLauncher {
  int requestReviewCount = 0;
  final List<({String? appStoreId, String? microsoftStoreId})> openStore = [];
  final bool throwOnOpen;

  _FakeLauncher({this.throwOnOpen = false});

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> requestReview() async => requestReviewCount++;

  @override
  Future<void> openStoreListing({
    String? appStoreId,
    String? microsoftStoreId,
  }) async {
    if (throwOnOpen) throw Exception('store open failed');
    openStore.add((appStoreId: appStoreId, microsoftStoreId: microsoftStoreId));
  }
}

Future<_FakeLauncher> _run(
  ReviewConfig config,
  TargetPlatform platform, {
  bool throwOnOpen = false,
}) async {
  final fake = _FakeLauncher(throwOnOpen: throwOnOpen);
  final m = AppReviewManager.instance;
  await m.resetAll();
  await m.initialize(config, launcher: fake, platformResolver: () => platform);
  await m.debugRunReviewAction();
  return fake;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('package default (no handler)', () {
    test('iOS storeListing with id → openStoreListing(appStoreId)', () async {
      final fake = await _run(
        const ReviewConfig(
            ios: PlatformReviewConfig.storeListing(storeId: '123456789')),
        TargetPlatform.iOS,
      );
      expect(fake.openStore, hasLength(1));
      expect(fake.openStore.single.appStoreId, '123456789');
      expect(fake.requestReviewCount, 0);
    });

    test('iOS storeListing WITHOUT id → fallback requestReview', () async {
      final fake = await _run(
        const ReviewConfig(ios: PlatformReviewConfig.storeListing()),
        TargetPlatform.iOS,
      );
      expect(fake.openStore, isEmpty);
      expect(fake.requestReviewCount, 1);
    });

    test('Android storeListing → openStoreListing (no id needed)', () async {
      final fake = await _run(
        const ReviewConfig(android: PlatformReviewConfig.storeListing()),
        TargetPlatform.android,
      );
      expect(fake.openStore, hasLength(1));
      expect(fake.openStore.single.appStoreId, isNull);
      expect(fake.requestReviewCount, 0);
    });

    test('iOS system → requestReview', () async {
      final fake = await _run(
        const ReviewConfig(ios: PlatformReviewConfig.system()),
        TargetPlatform.iOS,
      );
      expect(fake.requestReviewCount, 1);
      expect(fake.openStore, isEmpty);
    });

    test('platform left null → defaults to system (requestReview)', () async {
      final fake = await _run(const ReviewConfig(), TargetPlatform.iOS);
      expect(fake.requestReviewCount, 1);
    });

    test('storeListing but openStoreListing throws → fallback requestReview',
        () async {
      final fake = await _run(
        const ReviewConfig(
            ios: PlatformReviewConfig.storeListing(storeId: '123456789')),
        TargetPlatform.iOS,
        throwOnOpen: true,
      );
      expect(fake.requestReviewCount, 1);
    });

    test('iOS and Android can differ', () async {
      const config = ReviewConfig(
        ios: PlatformReviewConfig.storeListing(storeId: '123456789'),
        android: PlatformReviewConfig.system(),
      );
      final ios = await _run(config, TargetPlatform.iOS);
      expect(ios.openStore, hasLength(1));
      final android = await _run(config, TargetPlatform.android);
      expect(android.requestReviewCount, 1);
      expect(android.openStore, isEmpty);
    });
  });

  group('user handler priority', () {
    test('handler returns true → package default NOT run', () async {
      var called = false;
      final fake = await _run(
        ReviewConfig(
          ios: const PlatformReviewConfig.storeListing(storeId: '123456789'),
          onReviewRequest: (ctx) async {
            called = true;
            return true; // handled, stop
          },
        ),
        TargetPlatform.iOS,
      );
      expect(called, isTrue);
      expect(fake.openStore, isEmpty);
      expect(fake.requestReviewCount, 0);
    });

    test('handler returns false → falls through to package default', () async {
      final fake = await _run(
        ReviewConfig(
          ios: const PlatformReviewConfig.storeListing(storeId: '123456789'),
          onReviewRequest: (ctx) async => false, // hand back
        ),
        TargetPlatform.iOS,
      );
      expect(fake.openStore, hasLength(1));
      expect(fake.openStore.single.appStoreId, '123456789');
    });

    test('legacy onReviewRequested → called, launcher untouched', () async {
      var legacy = false;
      final fake = await _run(
        ReviewConfig(
          ios: const PlatformReviewConfig.storeListing(storeId: '123456789'),
          onReviewRequested: () async => legacy = true,
        ),
        TargetPlatform.iOS,
      );
      expect(legacy, isTrue);
      expect(fake.openStore, isEmpty);
      expect(fake.requestReviewCount, 0);
    });

    test('ReviewContext carries platform + appVersion', () async {
      TargetPlatform? seen;
      String? ver;
      await _run(
        ReviewConfig(
          appVersion: '9.9.9',
          onReviewRequest: (ctx) async {
            seen = ctx.platform;
            ver = ctx.appVersion;
            return true;
          },
        ),
        TargetPlatform.android,
      );
      expect(seen, TargetPlatform.android);
      expect(ver, '9.9.9');
    });
  });
}
