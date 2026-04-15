import 'package:flutter/material.dart';
import 'package:damas_dashboard/core/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final String fontFamily;
  final bool isNegative;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.fontFamily,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),

      child: Row(
        children: [
          /// LEFT SIDE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: fontFamily,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// RIGHT SIDE (ICON + TREND)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 💎 ICON CONTAINER (NEW PREMIUM STYLE)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primaryDark,
                ),
              ),

              const SizedBox(height: 10),

              /// TREND BADGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNegative
                      ? Colors.red.withOpacity(0.08)
                      : Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isNegative ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}