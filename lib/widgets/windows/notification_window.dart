import 'package:flutter/material.dart';
import 'package:damas_dashboard/core/app_colors.dart';
import 'package:damas_dashboard/core/app_fonts.dart';

class NotificationWindow extends StatelessWidget {
  const NotificationWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter, // Changed from topRight to topCenter
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 350,
            margin: const EdgeInsets.only(
                top:
                    16), // Removed the right margin to keep it perfectly centered
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _Header(),
                SizedBox(height: 12),
                _Divider(),
                SizedBox(height: 8),
                _NotificationItem(
                  title: "New user registered",
                  time: "2 min ago",
                ),
                _NotificationItem(
                  title: "Payment received",
                  time: "10 min ago",
                ),
                _NotificationItem(
                  title: "Server updated",
                  time: "1 hour ago",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// HEADER
//////////////////////////////////////////////////////////////////

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 2,
            fontFamily: AppFonts.english,
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////
// DIVIDER
//////////////////////////////////////////////////////////////////

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.textMuted,
            AppColors.textPrimary,
            AppColors.textMuted,
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// NOTIFICATION ITEM
//////////////////////////////////////////////////////////////////

class _NotificationItem extends StatelessWidget {
  final String title;
  final String time;

  const _NotificationItem({
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// dot indicator
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 10),

          /// text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'RobotoCondensed',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
