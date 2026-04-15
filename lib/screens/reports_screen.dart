import 'package:flutter/material.dart';
import 'package:damas_dashboard/core/app_colors.dart';
import 'package:damas_dashboard/core/app_fonts.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Injecting font based on current locale
    final String fontFamily = AppFonts.getFont(Localizations.localeOf(context));

    return Scaffold(
      // Matching the exact background color from the Analysis page
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSection(fontFamily: fontFamily),
              const SizedBox(height: 32),
              _QuickActionsSection(fontFamily: fontFamily),
              const SizedBox(height: 32),
              _RecentReportsSection(fontFamily: fontFamily),
              const SizedBox(height: 24),
              _ScheduledReportsSection(fontFamily: fontFamily),
            ],
          ),
        ),
      ),
    );
  }
}

// --- HEADER SECTION ---
class _HeaderSection extends StatelessWidget {
  final String fontFamily;
  const _HeaderSection({required this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reports",
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.surfaceDark, // Deep branded text
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Generate, download, and schedule system reports",
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

// --- QUICK ACTIONS ---
class _QuickActionsSection extends StatelessWidget {
  final String fontFamily;
  const _QuickActionsSection({required this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _ActionButton(
          fontFamily: fontFamily,
          title: "Generate New Report",
          icon: Icons.add_chart_rounded,
          isPrimary: true,
        ),
        _ActionButton(
          fontFamily: fontFamily,
          title: "Export All Data (CSV)",
          icon: Icons.download_rounded,
          isPrimary: false,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String fontFamily;
  final String title;
  final IconData icon;
  final bool isPrimary;

  const _ActionButton({
    required this.fontFamily,
    required this.title,
    required this.icon,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle action
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.primary.withOpacity(0.2),
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? Colors.white : AppColors.primaryDark,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppColors.surfaceDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- RECENT REPORTS LIST ---
class _RecentReportsSection extends StatelessWidget {
  final String fontFamily;
  const _RecentReportsSection({required this.fontFamily});

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
                "Recent Reports",
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.surfaceDark,
                ),
              ),
              Icon(Icons.filter_list_rounded, color: AppColors.primaryDark),
            ],
          ),
          const SizedBox(height: 20),
          _ReportItem(
            fontFamily: fontFamily,
            title: "Q1 Financial Summary",
            date: "Generated Oct 24, 2023",
            size: "2.4 MB • PDF",
            isReady: true,
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _ReportItem(
            fontFamily: fontFamily,
            title: "User Engagement Metrics",
            date: "Generated Oct 22, 2023",
            size: "1.1 MB • CSV",
            isReady: true,
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _ReportItem(
            fontFamily: fontFamily,
            title: "Annual Server Audit",
            date: "Processing...",
            size: "Estimating size",
            isReady: false,
          ),
        ],
      ),
    );
  }
}

// --- SCHEDULED REPORTS ---
class _ScheduledReportsSection extends StatelessWidget {
  final String fontFamily;
  const _ScheduledReportsSection({required this.fontFamily});

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
            "Scheduled Automated Reports",
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.surfaceDark,
            ),
          ),
          const SizedBox(height: 20),
          _ScheduledItem(
            fontFamily: fontFamily,
            title: "Weekly Revenue Sync",
            schedule: "Every Monday at 08:00 AM",
            recipient: "admin@damas.com",
          ),
        ],
      ),
    );
  }
}

// --- REUSABLE REPORT ITEM ---
class _ReportItem extends StatelessWidget {
  final String fontFamily;
  final String title;
  final String date;
  final String size;
  final bool isReady;

  const _ReportItem({
    required this.fontFamily,
    required this.title,
    required this.date,
    required this.size,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isReady ? AppColors.primary.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isReady ? Icons.insert_drive_file_outlined : Icons.hourglass_empty_rounded,
              size: 24,
              color: isReady ? AppColors.primaryDark : Colors.orange[700],
            ),
          ),
          const SizedBox(width: 16),
          // Text Content
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
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      date,
                      style: TextStyle(fontFamily: fontFamily, color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      size,
                      style: TextStyle(fontFamily: fontFamily, color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Status / Download Button
          if (isReady)
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.download_rounded, color: AppColors.primaryDark),
              tooltip: "Download Report",
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Generating",
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- REUSABLE SCHEDULED ITEM ---
class _ScheduledItem extends StatelessWidget {
  final String fontFamily;
  final String title;
  final String schedule;
  final String recipient;

  const _ScheduledItem({
    required this.fontFamily,
    required this.title,
    required this.schedule,
    required this.recipient,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Icon(Icons.calendar_month_rounded, size: 24, color: Colors.grey),
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
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                schedule,
                style: TextStyle(fontFamily: fontFamily, color: AppColors.primaryDark, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          recipient,
          style: TextStyle(fontFamily: fontFamily, color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }
}