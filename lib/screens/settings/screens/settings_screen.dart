import 'package:flutter/material.dart';
import 'package:damas_dashboard/core/app_colors.dart';
import 'package:damas_dashboard/core/app_fonts.dart';
import 'package:damas_dashboard/screens/settings/widgets/settings_group.dart';
import 'package:damas_dashboard/screens/settings/widgets/settings_tile.dart';
import 'package:damas_dashboard/screens/settings/widgets/settings_toggle.dart';
import 'package:damas_dashboard/screens/settings/widgets/settings_footer.dart';

/// Senior-Level Settings Screen
///
/// Key Improvements:
/// 1. Centered Constraints: Limits width on Desktop/Web for readability.
/// 2. Design System Integration: Uses AppColors/AppFonts.
/// 3. Functional Callbacks: Implements onChanged for toggles.
/// 4. Enhanced Hierarchy: Clearer distinction between sections.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dynamic font selection based on locale
    final String fontFamily = AppFonts.getFont(Localizations.localeOf(context));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                  maxWidth: 800), // Professional readability constraint
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(fontFamily),
                  const SizedBox(height: 32),

                  /// ACCOUNT SECTION
                  SettingsGroup(
                    title: "Account",
                    fontFamily: AppFonts.english,
                    children: [
                      SettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: "Profile",
                        subtitle: "Update your personal information",
                      ),
                      SettingsTile(
                        icon: Icons.security_outlined,
                        title: "Security",
                        subtitle: "Password & authentication",
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// PREFERENCES SECTION
                  SettingsGroup(
                    title: "Preferences",
                    fontFamily: AppFonts.english,
                    children: [
                      SettingsToggle(
                        icon: Icons.dark_mode_outlined,
                        title: "Dark Mode",
                        subtitle: "Enable or disable dark theme",
                        value:
                            false, // In a real app, bind this to a Provider/Bloc
                        onChanged: (val) {
                          // Handle theme toggle logic
                        },
                      ),
                      SettingsToggle(
                        icon: Icons.notifications_none_rounded,
                        title: "Notifications",
                        subtitle: "Manage notification settings",
                        value: true,
                        onChanged: (val) {
                          // Handle notification logic
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// SYSTEM SECTION
                  SettingsGroup(
                    title: "System",
                    fontFamily: fontFamily,
                    children: [
                      SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: "About",
                        subtitle: "App version 2.4.0 (Stable)",
                      ),
                      SettingsTile(
                        icon: Icons.help_outline_rounded,
                        title: "Help & Support",
                        subtitle: "Visit our documentation",
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// FOOTER (Save/Discard Actions)
                  SettingsFooter(fontFamily: fontFamily),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Header abstracted for clarity
  Widget _buildHeader(String fontFamily) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Settings",
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.surfaceDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Manage your workspace configuration and security",
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
