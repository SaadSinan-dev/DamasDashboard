import 'package:damas_dashboard/core/error/failure.dart';
import 'package:damas_dashboard/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    const Failure failure = NetworkFailure();

    test('exposes the value only on the success branch', () {
      const Result<int> success = Success<int>(7);
      const Result<int> failed = Failed<int>(failure);

      expect(success.isSuccess, isTrue);
      expect(success.valueOrNull, 7);
      expect(success.failureOrNull, isNull);

      expect(failed.isSuccess, isFalse);
      expect(failed.valueOrNull, isNull);
      expect(failed.failureOrNull, failure);
    });

    test('fold runs exactly one branch', () {
      expect(
        const Success<int>(2).fold(
          onSuccess: (int value) => 'ok:$value',
          onFailure: (_) => 'err',
        ),
        'ok:2',
      );
      expect(
        const Failed<int>(failure).fold(
          onSuccess: (_) => 'ok',
          onFailure: (Failure f) => 'err:${f.runtimeType}',
        ),
        'err:NetworkFailure',
      );
    });

    test('map transforms success and passes failure through unchanged', () {
      expect(
          const Success<int>(3).map((int v) => v * 2), const Success<int>(6));

      final Result<String> mapped =
          const Failed<int>(failure).map((int v) => '$v');
      expect(mapped, const Failed<String>(failure));
      expect(mapped.failureOrNull, same(failure));
    });

    test('results compare by value so Bloc can skip identical emissions', () {
      expect(const Success<int>(1), const Success<int>(1));
      expect(const Success<int>(1), isNot(const Success<int>(2)));
      expect(const Failed<int>(failure), const Failed<int>(NetworkFailure()));
      expect(
        const Failed<int>(NetworkFailure()),
        isNot(const Failed<int>(CacheFailure())),
      );
    });
  });

  group('Failure', () {
    test('distinguishes variants of the same shape', () {
      expect(const NetworkFailure(), isNot(const CacheFailure()));
      expect(
        const ValidationFailure(field: 'title'),
        isNot(const ValidationFailure(field: 'body')),
      );
    });

    test('NotFoundFailure carries the missing resource id', () {
      const Failure failure = NotFoundFailure(resourceId: 'rep_009');
      expect((failure as NotFoundFailure).resourceId, 'rep_009');
    });
  });
}
