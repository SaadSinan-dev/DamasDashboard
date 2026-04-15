import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:damas_dashboard/core/app_colors.dart';
import 'package:damas_dashboard/core/app_fonts.dart';
import 'package:damas_dashboard/widgets/windows/notification_window.dart';

class App_Bar extends StatelessWidget implements PreferredSizeWidget {
  const App_Bar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: AppColors.surface, // Glass effect
          elevation: 0,
          centerTitle: true,

          // Subtle bottom border for that "Linear" SaaS look
          shape: const Border(
            bottom: BorderSide(color: AppColors.surface, width: 1),
          ),

          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(
              child: Builder(
                builder: (context) {
                  return Material(
                    color: const Color.fromARGB(0, 255, 255, 255),
                    child: InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.textPrimary.withOpacity(0.2),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notes_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Damas Dashboard",
                style: TextStyle(
                  fontFamily: AppFonts.english,
                  fontSize: 22,
                  letterSpacing: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          actions: [
            // Search Icon with subtle hover/touch area
            IconButton(
              onPressed: () {
                showGeneralDialog(
                  context: context,
                  barrierLabel: "Notifications",
                  barrierDismissible: true,
                  barrierColor: Colors.transparent,
                  transitionDuration: const Duration(milliseconds: 200),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return const NotificationWindow();
                  },
                  transitionBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        alignment: Alignment.topRight,
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                        child: child,
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.notifications_rounded,
                color: AppColors.textPrimary,
                size: 25,
              ),
            ),

            SizedBox(width: 32),
          ],

          /// ⚡ Actions
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
