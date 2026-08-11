import '../../../../core/data/json_parsing.dart';
import '../../domain/entities/metric.dart';

/// Wire representation of a metric.
///
/// Kept separate from [Metric] so that a rename or reshape on the transport side
/// is absorbed here, in `toEntity`, instead of rippling through the domain and
/// every widget that reads it.
class MetricDto {
  const MetricDto({
    required this.id,
    required this.value,
    required this.previousValue,
  });

  factory MetricDto.fromJson(Map<String, dynamic> json) => MetricDto(
        id: json.requireString('id'),
        value: json.requireDouble('value'),
        previousValue: json.requireDouble('previousValue'),
      );

  final String id;
  final double value;
  final double previousValue;

  Metric toEntity() => Metric(
        id: enumByName(MetricId.values, id, field: 'metric.id'),
        value: value,
        previousValue: previousValue,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'value': value,
        'previousValue': previousValue,
      };
}
