import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware formatting for the numbers the dashboard displays.
///
/// Built once per locale and read from the widget tree, because constructing an
/// [NumberFormat] parses a pattern each time and these run inside list item
/// builders. Formatting through `intl` rather than string interpolation is also
/// what gives the Arabic locale its own digits, grouping and decimal separator.
@immutable
class ValueFormatter {
  ValueFormatter(this.locale)
      : _compact = NumberFormat.compact(locale: locale),
        _decimal = NumberFormat.decimalPattern(locale),
        _percent = NumberFormat.decimalPercentPattern(
          locale: locale,
          decimalDigits: 1,
        ),
        _compactCurrency = NumberFormat.compactCurrency(
          locale: locale,
          symbol: r'$',
          decimalDigits: 1,
        ),
        _currency = NumberFormat.currency(
          locale: locale,
          symbol: r'$',
          decimalDigits: 0,
        );

  /// The formatter for the active locale.
  ///
  /// Cached because constructing one parses five [NumberFormat] patterns, and
  /// this is called from list item builders that run on every frame of a scroll.
  /// The cache is bounded by the number of supported locales.
  factory ValueFormatter.of(BuildContext context) {
    final String tag = Localizations.localeOf(context).toLanguageTag();
    return _cache[tag] ??= ValueFormatter(tag);
  }

  static final Map<String, ValueFormatter> _cache = <String, ValueFormatter>{};

  final String locale;
  final NumberFormat _compact;
  final NumberFormat _decimal;
  final NumberFormat _percent;
  final NumberFormat _compactCurrency;
  final NumberFormat _currency;

  /// `$84,200` — used where the exact figure matters.
  String currency(double value) => _currency.format(value);

  /// `$84.2K` — used in constrained tiles.
  String compactCurrency(double value) => _compactCurrency.format(value);

  /// `12.4K`
  String compactNumber(double value) => _compact.format(value);

  /// `1,240`
  String number(double value) => _decimal.format(value);

  /// Formats a ratio (0.142) as `14.2%`.
  String percentFromRatio(double ratio) => _percent.format(ratio);

  /// Formats a value already expressed in percentage points (2.4) as `2.4%`.
  String percentFromPoints(double points) => _percent.format(points / 100);

  /// Signed change, e.g. `+14.2%` / `−25.0%`.
  ///
  /// Uses a real minus sign (U+2212) rather than a hyphen so the glyph aligns
  /// with digits, and prefixes with the locale's own plus sign.
  String signedPercentFromRatio(double ratio) {
    final String magnitude = _percent.format(ratio.abs());
    return ratio < 0 ? '−$magnitude' : '+$magnitude';
  }

  /// Human-readable byte size — `2.4 MB`.
  String fileSize(int bytes) {
    if (bytes <= 0) return '0 ${_byteUnits.first}';
    final int exponent = math.min(
      (math.log(bytes) / math.log(1024)).floor(),
      _byteUnits.length - 1,
    );
    final double size = bytes / math.pow(1024, exponent);
    // Bytes and KB read better without a decimal; MB and up need one.
    final String rendered = exponent < 2
        ? _decimal.format(size.round())
        : NumberFormat('#,##0.0', locale).format(size);
    return '$rendered ${_byteUnits[exponent]}';
  }

  static const List<String> _byteUnits = <String>['B', 'KB', 'MB', 'GB', 'TB'];
}
