import 'package:flutter/material.dart';
import 'package:damas_dashboard/core/app_colors.dart';
import 'package:damas_dashboard/core/app_fonts.dart';

/// A production-ready, highly polished toggle component.
/// 
/// Senior Level Features:
/// 1. Decoupled Logic: Accepts [onChanged] callback.
/// 2. Design System: Bound to [AppColors] and [AppFonts].
/// 3. Visual Hierarchy: Iconography is contained in a branded secondary container.
/// 4. Platform Adaptive: Uses [.adaptive] for native feel on iOS/Android.
class SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggle({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final String fontFamily = AppFonts.getFont(Localizations.localeOf(context));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Subtle border to match the "Linear/Stripe" aesthetic
        border: Border.all(
          color: AppColors.surface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        activeColor: AppColors.surface,
        activeTrackColor: AppColors.primary.withOpacity(0.2),
        // Secondary widget allows us to style the icon inside a branded circle
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryDark,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
         
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.surfaceDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
         
            fontSize: 12,
            color: Colors.grey[500],
            height: 1.4,
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}