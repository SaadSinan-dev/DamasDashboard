import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../error/exceptions.dart';

/// Loads and decodes bundled JSON payloads.
///
/// Wrapping [AssetBundle] here does two things: it converts asset and parse
/// errors into the [AppException] family the repositories already handle, and it
/// makes the bundle injectable so tests can supply fixtures without touching the
/// real asset manifest.
class JsonAssetReader {
  JsonAssetReader({AssetBundle? bundle, this.latency = Duration.zero})
      : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Artificial delay applied before returning, so loading and refreshing states
  /// are actually observable in a build with no network. Zero in tests.
  final Duration latency;

  Future<Map<String, dynamic>> readObject(String assetPath) async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }

    final String raw;
    try {
      raw = await _bundle.loadString(assetPath);
    } on Exception catch (error) {
      throw NotFoundException(
        'Asset $assetPath could not be loaded: $error',
        resourceId: assetPath,
      );
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw CacheException('$assetPath is not a JSON object');
      }
      return decoded;
    } on FormatException catch (error) {
      throw CacheException(
          '$assetPath contains invalid JSON: ${error.message}');
    }
  }
}
