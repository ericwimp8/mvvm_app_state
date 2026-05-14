import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_app_state/mvvm_app_state.dart';

void main() {
  group('AppFailureKind', () {
    test('exposes expected values in declaration order', () {
      expect(AppFailureKind.values, [
        AppFailureKind.cancelled,
        AppFailureKind.conflict,
        AppFailureKind.forbidden,
        AppFailureKind.network,
        AppFailureKind.notFound,
        AppFailureKind.persistence,
        AppFailureKind.platform,
        AppFailureKind.timeout,
        AppFailureKind.unauthorized,
        AppFailureKind.unavailable,
        AppFailureKind.validation,
        AppFailureKind.unknown,
      ]);
    });

    final cases = <({String name, AppFailureKind kind, String wireName})>[
      (
        name: 'cancelled resolves from name',
        kind: AppFailureKind.cancelled,
        wireName: 'cancelled',
      ),
      (
        name: 'conflict resolves from name',
        kind: AppFailureKind.conflict,
        wireName: 'conflict',
      ),
      (
        name: 'forbidden resolves from name',
        kind: AppFailureKind.forbidden,
        wireName: 'forbidden',
      ),
      (
        name: 'network resolves from name',
        kind: AppFailureKind.network,
        wireName: 'network',
      ),
      (
        name: 'notFound resolves from name',
        kind: AppFailureKind.notFound,
        wireName: 'notFound',
      ),
      (
        name: 'persistence resolves from name',
        kind: AppFailureKind.persistence,
        wireName: 'persistence',
      ),
      (
        name: 'platform resolves from name',
        kind: AppFailureKind.platform,
        wireName: 'platform',
      ),
      (
        name: 'timeout resolves from name',
        kind: AppFailureKind.timeout,
        wireName: 'timeout',
      ),
      (
        name: 'unauthorized resolves from name',
        kind: AppFailureKind.unauthorized,
        wireName: 'unauthorized',
      ),
      (
        name: 'unavailable resolves from name',
        kind: AppFailureKind.unavailable,
        wireName: 'unavailable',
      ),
      (
        name: 'validation resolves from name',
        kind: AppFailureKind.validation,
        wireName: 'validation',
      ),
      (
        name: 'unknown resolves from name',
        kind: AppFailureKind.unknown,
        wireName: 'unknown',
      ),
    ];

    for (final testCase in cases) {
      test(testCase.name, () {
        expect(testCase.kind.name, testCase.wireName);
        expect(AppFailureKind.values.byName(testCase.wireName), testCase.kind);
      });
    }
  });
}
