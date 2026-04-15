import 'package:flutter/material.dart';
import 'package:damas_dashboard/core/app_colors.dart';
import 'package:damas_dashboard/core/app_fonts.dart';
import 'package:damas_dashboard/widgets/side_bar_items.dart';
// Import the separated item widget

class Side_Bar extends StatelessWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const Side_Bar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });
  void _handleNavigation(BuildContext context, int index) {
    if (selectedIndex != index) {
      onItemSelected(index);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        color: AppColors.surface,
      ),
      padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    color: Color(0xFF0F3D2E),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "My Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: AppFonts.english,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Dashboard",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Divider(
              color: AppColors.textMuted,
              thickness: 1,
            ),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "MENU",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SideBarItem(
            icon: Icons.home_rounded,
            title: "Home",
            isSelected: selectedIndex == 0,
            onTap: () {
              onItemSelected(0);
              Navigator.pop(context);
            },
          ),
          SideBarItem(
            icon: Icons.analytics_rounded,
            title: "Analytics",
            isSelected: selectedIndex == 1,
            onTap: () {
              onItemSelected(1);
              Navigator.pop(context);
            },
          ),
          SideBarItem(
            icon: Icons.report_rounded,
            title: "Reports",
            isSelected: selectedIndex == 2,
            onTap: () {
              onItemSelected(2);
              Navigator.pop(context);
            },
          ),
          SideBarItem(
            icon: Icons.settings_rounded,
            title: "Settings",
            isSelected: selectedIndex == 3,
            onTap: () {
              onItemSelected(3);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
