import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/settings_section.dart';

/// Preferences screen.
///
/// The theme and language controls are wired to a persisted cubit, so changing
/// either updates the whole app immediately and survives a restart. Rows without
/// an implementation say so plainly instead of silently doing nothing.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, AppSettings>(
      builder: (BuildContext context, AppSettings settings) {
        final SettingsCubit cubit = context.read<SettingsCubit>();

        return PageBody(
          children: <Widget>[
            PageHeader(
              title: context.l10n.settingsTitle,
              subtitle: context.l10n.settingsSubtitle,
            ),
            const SizedBox(height: AppSpacing.xl),
            SettingsSection(
              title: context.l10n.settingsSectionAppearance,
              children: <Widget>[
                SettingsChoiceTile<AppThemeMode>(
                  icon: Icons.contrast_rounded,
                  title: context.l10n.settingsTheme,
                  subtitle: context.l10n.settingsThemeSubtitle,
                  values: AppThemeMode.values,
                  selected: settings.themeMode,
                  labelBuilder: (AppThemeMode mode) => switch (mode) {
                    AppThemeMode.system => context.l10n.settingsThemeSystem,
                    AppThemeMode.light => context.l10n.settingsThemeLight,
                    AppThemeMode.dark => context.l10n.settingsThemeDark,
                  },
                  onChanged: cubit.setThemeMode,
                ),
                SettingsChoiceTile<AppLanguage>(
                  icon: Icons.translate_rounded,
                  title: context.l10n.settingsLanguage,
                  subtitle: context.l10n.settingsLanguageSubtitle,
                  values: AppLanguage.values,
                  selected: settings.language,
                  labelBuilder: (AppLanguage language) => switch (language) {
                    AppLanguage.system => context.l10n.settingsLanguageSystem,
                    AppLanguage.english => context.l10n.settingsLanguageEnglish,
                    AppLanguage.arabic => context.l10n.settingsLanguageArabic,
                  },
                  onChanged: cubit.setLanguage,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SettingsSection(
              title: context.l10n.settingsSectionAccount,
              children: <Widget>[
                SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: context.l10n.settingsProfile,
                  subtitle: context.l10n.settingsProfileSubtitle,
                  onTap: () => _notifyUnavailable(
                    context,
                    context.l10n.settingsProfile,
                  ),
                ),
                SettingsTile(
                  icon: Icons.shield_outlined,
                  title: context.l10n.settingsSecurity,
                  subtitle: context.l10n.settingsSecuritySubtitle,
                  onTap: () => _notifyUnavailable(
                    context,
                    context.l10n.settingsSecurity,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SettingsSection(
              title: context.l10n.settingsSectionSystem,
              children: <Widget>[
                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: context.l10n.settingsAbout,
                  subtitle: context.l10n.settingsAboutSubtitle(
                    AppConfig.version,
                  ),
                  onTap: () => _showAbout(context),
                ),
                SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: context.l10n.settingsHelp,
                  subtitle: context.l10n.settingsHelpSubtitle,
                  onTap: () =>
                      _notifyUnavailable(context, context.l10n.settingsHelp),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _notifyUnavailable(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settingsNotAvailable(feature))),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: context.l10n.appTitle,
      applicationVersion: AppConfig.version,
      applicationIcon: Icon(
        Icons.insights_rounded,
        size: 40,
        color: context.colors.primary,
      ),
      children: <Widget>[Text(context.l10n.appTagline)],
    );
  }
}
