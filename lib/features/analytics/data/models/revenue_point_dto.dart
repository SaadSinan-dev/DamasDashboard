import '../../../../core/data/json_parsing.dart';
import '../../domain/entities/revenue_point.dart';

/// Wire representation of one point on the revenue series.
///
/// The payload stores an offset (`monthsAgo`) rather than an absolute date, so
/// the bundled demo data never goes stale. [toEntity] resolves it against an
/// injected `now`, which is also what makes the mapping testable.
class RevenuePointDto {
  const RevenuePointDto({required this.monthsAgo, required this.amount});

  factory RevenuePointDto.fromJson(Map<String, dynamic> json) =>
      RevenuePointDto(
        monthsAgo: json.requireInt('monthsAgo'),
        amount: json.requireDouble('amount'),
      );

  final int monthsAgo;
  final double amount;

  RevenuePoint toEntity(DateTime now) => RevenuePoint(
        // Normalised to the first of the month; DateTime handles the rollover
        // when `now.month - monthsAgo` goes below 1.
        month: DateTime(now.year, now.month - monthsAgo),
        amount: amount,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'monthsAgo': monthsAgo,
        'amount': amount,
      };
}
