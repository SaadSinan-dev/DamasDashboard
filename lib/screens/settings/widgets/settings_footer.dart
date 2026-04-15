import 'package:flutter/material.dart';
import 'package:damas_dashboard/core/app_colors.dart';
import 'package:damas_dashboard/core/app_fonts.dart';

class SettingsFooter extends StatelessWidget {
  final String fontFamily;

  const SettingsFooter({
    super.key,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    // We use the injected fontFamily to stay consistent with the parent page
    final TextStyle buttonTextStyle = TextStyle(

      fontWeight: FontWeight.bold,
      fontSize: 14,
      letterSpacing: 0.5,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // --- DISCARD BUTTON ---
          // Using a subtle TextButton with a grey tone to prevent visual competition
          TextButton(
            onPressed: () {
              // Add discard logic here
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              foregroundColor: Colors.grey[600],
            ),
            child: Text(
              "Discard Changes",
              style: buttonTextStyle.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          
          const SizedBox(width: 12),

          // --- SAVE BUTTON ---
          // Using your primary branded color with a custom rounded shape
          ElevatedButton(
            onPressed: () {
              // Add save logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: Colors.white,
              elevation: 0, // Senior level: flat design with subtle borders/shadows
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // Subtle "glow" shadow for the primary action
              shadowColor: AppColors.surface.withOpacity(0.9),
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith<double>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) return 4;
                  return 0;
                },
              ),
            ),
            child: Text(
              "Save Changes",
              style: buttonTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}