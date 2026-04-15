import 'package:flutter/material.dart';
import 'package:damas_dashboard/core/app_colors.dart';
import 'package:damas_dashboard/core/app_fonts.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final font = AppFonts.getFont(Localizations.localeOf(context));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dashboard Overview",
          style: TextStyle(
            fontFamily: font,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.surfaceDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Real-time monitoring and business intelligence",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }
}