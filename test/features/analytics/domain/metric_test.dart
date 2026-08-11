import 'package:damas_dashboard/features/analytics/domain/entities/metric.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Metric.trend', () {
    test('reports the direction of change', () {
      expect(
        const Metric(id: MetricId.netRevenue, value: 110, previousValue: 100)
            .trend,
        MetricTrend.up,
      );
      expect(
        const Metric(id: MetricId.netRevenue, value: 90, previousValue: 100)
            .trend,
        MetricTrend.down,
      );
      expect(
        const Metric(id: MetricId.netRevenue, value: 100, previousValue: 100)
            .trend,
        MetricTrend.flat,
      );
    });

    test('treats floating-point noise as flat', () {
      // 0.1 + 0.2 != 0.3 in binary floating point; that must not render as a
      // change of "+0.0%".
      const Metric metric = Metric(
        id: MetricId.growth,
        value: 0.1 + 0.2,
        previousValue: 0.3,
      );
      expect(metric.trend, MetricTrend.flat);
    });
  });

  group('Metric.changeRatio', () {
    test('is the fractional change against the previous period', () {
      const Metric metric =
          Metric(id: MetricId.netRevenue, value: 114.2, previousValue: 100);
      expect(metric.changeRatio, closeTo(0.142, 1e-9));
    });

    test('is null when there is no baseline, rather than zero or infinity', () {
      const Metric metric =
          Metric(id: MetricId.subscriptions, value: 50, previousValue: 0);
      expect(metric.changeRatio, isNull);
    });

    test('uses the magnitude of the baseline so sign comes from the change',
        () {
      const Metric metric =
          Metric(id: MetricId.growth, value: 0, previousValue: -20);
      expect(metric.changeRatio, closeTo(1.0, 1e-9));
    });
  });

  group('Metric.isFavourable', () {
    test('rising is good for metrics where higher is better', () {
      const Metric metric =
          Metric(id: MetricId.netRevenue, value: 110, previousValue: 100);
      expect(metric.trend, MetricTrend.up);
      expect(metric.isFavourable, isTrue);
    });

    test('falling churn is good news even though the trend points down', () {
      // The screen this replaced painted this case red, which told the user a
      // genuine improvement was a problem.
      const Metric metric =
          Metric(id: MetricId.churnRate, value: 2.4, previousValue: 3.2);
      expect(metric.trend, MetricTrend.down);
      expect(metric.isFavourable, isTrue);
    });

    test('rising churn is bad news', () {
      const Metric metric =
          Metric(id: MetricId.churnRate, value: 4.0, previousValue: 3.2);
      expect(metric.trend, MetricTrend.up);
      expect(metric.isFavourable, isFalse);
    });

    test('no change is never reported as unfavourable', () {
      for (final MetricId id in MetricId.values) {
        expect(
          Metric(id: id, value: 10, previousValue: 10).isFavourable,
          isTrue,
          reason: '$id flat should not be unfavourable',
        );
      }
    });
  });

  test('every metric declares a unit', () {
    for (final MetricId id in MetricId.values) {
      expect(Metric(id: id, value: 1, previousValue: 1).unit, id.unit);
    }
  });
}
