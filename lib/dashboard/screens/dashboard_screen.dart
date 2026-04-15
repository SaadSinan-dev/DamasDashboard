import 'package:flutter/material.dart';
import 'package:damas_dashboard/dashboard/widgets/dashboard_header.dart';
import 'package:damas_dashboard/dashboard/widgets/stat_card.dart';
import 'package:damas_dashboard/dashboard/widgets/analytics_chart.dart';
import 'package:damas_dashboard/dashboard/widgets/activity_section.dart';
import 'package:damas_dashboard/core/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔝 Header
              const DashboardHeader(),

              const SizedBox(height: 32),

              /// 📊 STATS ROW
              GridView.count(
                crossAxisCount: 2, // 🔵 عمودين
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4, // تقدر تعدلها حسب التصميم

                children: const [
                  StatCard(
                    title: "Net Revenue",
                    value: "\$84,200",
                    trend: "+14.2%",
                    icon: Icons.account_balance_wallet_outlined,
                    fontFamily: "English",
                  ),
                  StatCard(
                    title: "Subscriptions",
                    value: "1,240",
                    trend: "+5.1%",
                    icon: Icons.subscriptions_outlined,
                    fontFamily: "English",
                  ),
                  StatCard(
                    title: "Churn Rate",
                    value: "2.4%",
                    trend: "-0.8%",
                    icon: Icons.trending_down_rounded,
                    fontFamily: "English",
                    isNegative: true,
                  ),
                  StatCard(
                    title: "Active Users",
                    value: "12.4K",
                    trend: "+8.3%",
                    icon: Icons.people_alt_outlined,
                    fontFamily: "English",
                  ),
                ],
              ),
              const SizedBox(height: 32),

              /// 📈 CHART
              const AnalyticsChartSection(),

              const SizedBox(height: 32),

              /// 📋 ACTIVITY
              const ActivitySection(),
            ],
          ),
        ),
      ),
    );
  }
}
