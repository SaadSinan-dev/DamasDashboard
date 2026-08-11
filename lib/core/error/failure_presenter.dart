import '../l10n/generated/app_localizations.dart';
import 'failure.dart';

/// Localized, user-facing text for a [Failure].
class FailureMessage {
  const FailureMessage({required this.title, required this.body});

  final String title;
  final String body;
}

/// Translates domain failures into text a user can act on.
///
/// This lives in `core/error` rather than in the domain layer on purpose: it is
/// the single boundary where a failure *type* becomes a failure *message*, so
/// adding a new [Failure] variant produces a compile error here — the exhaustive
/// switch will not compile until the new case is translated.
extension FailureL10n on Failure {
  FailureMessage localize(AppL10n l10n) => switch (this) {
        NetworkFailure() => FailureMessage(
            title: l10n.errorNetworkTitle,
            body: l10n.errorNetworkBody,
          ),
        CacheFailure() => FailureMessage(
            title: l10n.errorCacheTitle,
            body: l10n.errorCacheBody,
          ),
        NotFoundFailure() => FailureMessage(
            title: l10n.errorNotFoundTitle,
            body: l10n.errorNotFoundBody,
          ),
        ValidationFailure() => FailureMessage(
            title: l10n.errorValidationTitle,
            body: l10n.errorUnexpectedBody,
          ),
        UnexpectedFailure() => FailureMessage(
            title: l10n.errorUnexpectedTitle,
            body: l10n.errorUnexpectedBody,
          ),
      };
}
