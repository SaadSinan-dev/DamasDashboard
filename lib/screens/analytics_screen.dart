import 'package:flutter/material.dart';
import 'package:damas_dashboard/core/app_colors.dart';
import 'package:damas_dashboard/core/app_fonts.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String fontFamily = AppFonts.getFont(Localizations.localeOf(context));

    return Scaffold(
      // Clean, light background
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSection(fontFamily: fontFamily),
              const SizedBox(height: 32),
              _StatsGrid(fontFamily: fontFamily),
              const SizedBox(height: 24),
              _PerformanceChart(fontFamily: fontFamily),
              const SizedBox(height: 24),
              _RecentActivitySection(fontFamily: fontFamily),
            ],
          ),
        ),
      ),
    );
  }
}

// --- HEADER ---
class _HeaderSection extends StatelessWidget {
  final String fontFamily;
  const _HeaderSection({required this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Analytics",
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            // Using your dark surface color for high-contrast, branded text
            color: AppColors.surfaceDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "System performance overview & metrics",
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            color: Colors.grey[600], // Softened for light mode
          ),
        ),
      ],
    );
  }
}

// --- STATS GRID ---
class _StatsGrid extends StatelessWidget {
  final String fontFamily;
  const _StatsGrid({required this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = constraints.maxWidth < 600;

      final List<Widget> cards = [
        StatCard(
          fontFamily: fontFamily,
          title: "Total Users",
          value: "24,802",
          icon: Icons.group_outlined,
          trend: "+12%",
        ),
        StatCard(
          fontFamily: fontFamily,
          title: "Revenue",
          value: "\$142,400",
          icon: Icons.payments_outlined,
          trend: "+8.4%",
        ),
        StatCard(
          fontFamily: fontFamily,
          title: "Growth",
          value: "22.5%",
          icon: Icons.insights_rounded,
          trend: "+2.1%",
        ),
      ];

      if (isMobile) {
        return Column(
          children:
              cards.expand((c) => [c, const SizedBox(height: 16)]).toList()
                ..removeLast(),
        );
      }

      return Row(
        children: cards
            .map((c) => Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: c,
                )))
            .toList(),
      );
    });
  }
}

// --- REUSABLE STAT CARD ---
class StatCard extends StatelessWidget {
  final String fontFamily;
  final String title;
  final String value;
  final String trend;
  final IconData icon;

  const StatCard({
    super.key,
    required this.fontFamily,
    required this.title,
    required this.value,
    required this.icon,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        // Soft green-tinted border for the light theme
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryDark, size: 18),
              ),
              Text(
                trend,
                style: TextStyle(
                  fontFamily: fontFamily,
                  color: AppColors
                      .primaryDark, // Darker green for readability on light
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
                fontFamily: fontFamily, color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: fontFamily,
              color: AppColors.surfaceDark, // Deep branded text
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// --- CHART SECTION ---
class _PerformanceChart extends StatelessWidget {
  final String fontFamily;
  const _PerformanceChart({required this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Performance Overview",
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.surfaceDark,
                ),
              ),
              Icon(Icons.show_chart_rounded, color: AppColors.primaryDark),
            ],
          ),
          const Spacer(),
          Center(
            child: Text(
              "Chart visualization integrated here",
              style: TextStyle(
                  fontFamily: fontFamily,
                  color: Colors.grey[400],
                  fontSize: 12),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// --- RECENT ACTIVITY ---
class _RecentActivitySection extends StatelessWidget {
  final String fontFamily;
  const _RecentActivitySection({required this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Activity",
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.surfaceDark,
            ),
          ),
          const SizedBox(height: 20),
          _ActivityItem(
            fontFamily: fontFamily,
            title: "Payment Received",
            subtitle: "Invoice #DAM-992 paid by Sarah",
            time: "2m ago",
            icon: Icons.check_circle_outline,
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _ActivityItem(
            fontFamily: fontFamily,
            title: "New Registration",
            subtitle: "A new developer joined the dashboard",
            time: "1h ago",
            icon: Icons.person_add_outlined,
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String fontFamily;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  const _ActivityItem({
    required this.fontFamily,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    color: AppColors.surfaceDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.grey[500],
                      fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
                fontFamily: fontFamily, color: Colors.grey[400], fontSize: 10),
          ),
        ],
      ),
    );
  }
}
