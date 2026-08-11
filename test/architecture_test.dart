import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Executable architecture rules.
///
/// Layering is a convention until something checks it. These tests read every
/// file under `lib/` and fail the build the moment a dependency points the wrong
/// way — which is cheaper than finding out during a review six months from now,
/// and it means the diagram in the README cannot quietly go out of date.
void main() {
  final List<_SourceFile> sources = _loadSources();

  test('lib/ was found and scanned', () {
    expect(
      sources,
      isNotEmpty,
      reason: 'the architecture rules below would pass vacuously otherwise',
    );
  });

  group('domain layer is pure', () {
    test('never imports Flutter', () {
      final List<String> offenders = sources
          .where((_SourceFile f) => f.isDomain)
          .where(
            (_SourceFile f) =>
                f.imports.any((String i) => i.startsWith('package:flutter')),
          )
          .map((_SourceFile f) => f.path)
          .toList();

      expect(
        offenders,
        isEmpty,
        reason: 'Domain entities and rules must stay testable without a widget '
            'tree. Move UI concerns to presentation/.',
      );
    });

    test('never imports the data or presentation layers', () {
      final List<String> offenders = sources
          .where((_SourceFile f) => f.isDomain)
          .where(
            (_SourceFile f) => f.imports.any(
              (String i) =>
                  i.contains('/data/') || i.contains('/presentation/'),
            ),
          )
          .map((_SourceFile f) => f.path)
          .toList();

      expect(
        offenders,
        isEmpty,
        reason: 'Dependencies point inward. The data layer implements domain '
            'contracts, never the reverse.',
      );
    });

    test('never imports a serialization or storage package', () {
      const List<String> infrastructure = <String>[
        'package:shared_preferences',
        'package:fl_chart',
        'package:go_router',
        'package:get_it',
        'package:flutter_bloc',
      ];

      final List<String> offenders = sources
          .where((_SourceFile f) => f.isDomain)
          .where(
            (_SourceFile f) => f.imports.any(
              (String i) => infrastructure.any(i.startsWith),
            ),
          )
          .map((_SourceFile f) => f.path)
          .toList();

      expect(offenders, isEmpty);
    });
  });

  group('presentation layer', () {
    test('never reaches into the data layer directly', () {
      final List<String> offenders = sources
          .where((_SourceFile f) => f.isPresentation)
          .where(
            (_SourceFile f) =>
                f.imports.any((String i) => i.contains('/data/')),
          )
          .map((_SourceFile f) => f.path)
          .toList();

      expect(
        offenders,
        isEmpty,
        reason: 'Widgets and cubits depend on domain contracts; concrete data '
            'sources are wired up in core/di only.',
      );
    });
  });

  group('feature isolation', () {
    test('no feature imports another feature', () {
      final List<String> offenders = <String>[];

      for (final _SourceFile file in sources) {
        final String? owner = file.feature;
        if (owner == null) continue;

        for (final String import in file.imports) {
          final RegExpMatch? match = _featureImport.firstMatch(import);
          if (match == null) continue;
          if (match.group(1) != owner) {
            offenders.add('${file.path} -> $import');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'Cross-feature coupling is what turns a feature-first layout back '
            'into a ball of mud. Share through core/ instead.',
      );
    });
  });

  group('core layer', () {
    test('only the composition roots know about features', () {
      // core/ is meant to be reusable by any feature, so it must not depend on
      // one — except where wiring happens, which is exactly what these two files
      // are for.
      const Set<String> compositionRoots = <String>{
        'lib/core/di/injector.dart',
        'lib/core/router/app_router.dart',
      };

      final List<String> offenders = sources
          .where((_SourceFile f) => f.isCore)
          .where((_SourceFile f) => !compositionRoots.contains(f.path))
          .where(
            (_SourceFile f) =>
                f.imports.any((String i) => i.contains('features/')),
          )
          .map((_SourceFile f) => f.path)
          .toList();

      expect(offenders, isEmpty);
    });
  });

  test('no debugging leftovers reach production code', () {
    final List<String> offenders = sources
        .where(
          (_SourceFile f) =>
              f.body.contains(RegExp(r'\bprint\(')) ||
              f.body.contains('debugPrint('),
        )
        .map((_SourceFile f) => f.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason: 'Use AppLogger, which has levels and is stripped in release.',
    );
  });

  test('hex colors live only in the palette', () {
    // Keeping literals in one file is what makes the light and dark schemes
    // auditable; everything else reads from ColorScheme or the theme extension.
    const Set<String> allowed = <String>{
      'lib/core/theme/app_palette.dart',
      'lib/core/theme/app_semantic_colors.dart',
      'lib/features/splash/presentation/widgets/splash_backdrop.dart',
    };

    final List<String> offenders = sources
        .where((_SourceFile f) => !allowed.contains(f.path))
        .where((_SourceFile f) => f.body.contains(RegExp(r'Color\(0x')))
        .map((_SourceFile f) => f.path)
        .toList();

    expect(offenders, isEmpty);
  });
}

final RegExp _featureImport = RegExp('features/([a-z_]+)/');
final RegExp _importStatement = RegExp("""import\\s+['"]([^'"]+)['"]""");

class _SourceFile {
  _SourceFile({required this.path, required this.body, required this.imports});

  final String path;
  final String body;
  final List<String> imports;

  bool get isDomain => path.contains('/domain/');

  bool get isPresentation => path.contains('/presentation/');

  bool get isCore => path.startsWith('lib/core/');

  /// The feature this file belongs to, or `null` when it is outside `features/`.
  String? get feature => _featureImport.firstMatch(path)?.group(1);
}

List<_SourceFile> _loadSources() {
  final Directory lib = Directory('lib');
  if (!lib.existsSync()) return const <_SourceFile>[];

  return lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      // Generated localizations are machine output and not subject to review.
      .where((File f) =>
          !f.path.contains('l10n${Platform.pathSeparator}generated'))
      .map((File file) {
    final String body = file.readAsStringSync();
    return _SourceFile(
      path: file.path.replaceAll(r'\', '/'),
      body: body,
      imports: _importStatement
          .allMatches(body)
          .map((RegExpMatch m) => m.group(1)!)
          .toList(),
    );
  }).toList();
}
