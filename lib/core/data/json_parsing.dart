import '../error/exceptions.dart';

/// Strict accessors for decoded JSON.
///
/// `jsonDecode` hands back `dynamic`, and reading it with plain casts turns a
/// malformed payload into a `TypeError` thrown deep inside a widget build. These
/// helpers fail at the parse boundary instead, with a message naming the field,
/// and always as a [CacheException] the repository layer already handles.
extension JsonMapX on Map<String, dynamic> {
  String requireString(String key) {
    final Object? value = this[key];
    if (value is String) return value;
    throw CacheException('Expected string at "$key", got ${value.runtimeType}');
  }

  double requireDouble(String key) {
    final Object? value = this[key];
    if (value is num) return value.toDouble();
    throw CacheException('Expected number at "$key", got ${value.runtimeType}');
  }

  double? optionalDouble(String key) {
    final Object? value = this[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    throw CacheException('Expected number or null at "$key"');
  }

  int requireInt(String key) {
    final Object? value = this[key];
    if (value is num) return value.toInt();
    throw CacheException(
        'Expected integer at "$key", got ${value.runtimeType}');
  }

  int? optionalInt(String key) {
    final Object? value = this[key];
    if (value == null) return null;
    if (value is num) return value.toInt();
    throw CacheException('Expected integer or null at "$key"');
  }

  bool requireBool(String key) {
    final Object? value = this[key];
    if (value is bool) return value;
    throw CacheException(
        'Expected boolean at "$key", got ${value.runtimeType}');
  }

  /// Reads a nested list of JSON objects.
  List<Map<String, dynamic>> requireObjectList(String key) {
    final Object? value = this[key];
    if (value is! List) {
      throw CacheException('Expected list at "$key", got ${value.runtimeType}');
    }
    return value.map((Object? element) {
      if (element is Map<String, dynamic>) return element;
      throw CacheException('Expected objects inside "$key"');
    }).toList(growable: false);
  }

  /// Reads a nested JSON object.
  Map<String, dynamic> requireObject(String key) {
    final Object? value = this[key];
    if (value is Map<String, dynamic>) return value;
    throw CacheException('Expected object at "$key", got ${value.runtimeType}');
  }
}

/// Resolves an enum member by its `name`, failing loudly on an unknown value.
///
/// A silent fallback to `values.first` would quietly mislabel every record the
/// backend adds a new variant to; failing here surfaces the mismatch instead.
T enumByName<T extends Enum>(
  List<T> values,
  String name, {
  required String field,
}) {
  for (final T value in values) {
    if (value.name == name) return value;
  }
  throw CacheException(
    'Unknown value "$name" for $field; expected one of '
    '${values.map((T v) => v.name).join(', ')}',
  );
}
