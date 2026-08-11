import 'package:equatable/equatable.dart';

/// One point on the revenue time series — a month and its total.
class RevenuePoint extends Equatable {
  const RevenuePoint({required this.month, required this.amount});

  /// Normalised to the first day of the month it represents.
  final DateTime month;
  final double amount;

  @override
  List<Object?> get props => <Object?>[month, amount];
}
