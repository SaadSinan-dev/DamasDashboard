import 'package:flutter/material.dart';
import 'package:damas_dashboard/widgets/side_bar.dart';
import 'package:damas_dashboard/widgets/app_bar.dart';
import 'package:damas_dashboard/screens/analytics_screen.dart';
import 'package:damas_dashboard/screens/reports_screen.dart';
import 'package:damas_dashboard/screens/settings/screens/settings_screen.dart';
import 'package:damas_dashboard/dashboard/screens/dashboard_screen.dart';
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = const [
   DashboardScreen(),
    AnalysisPage(),
    ReportsPage(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Side_Bar(
          selectedIndex: _selectedIndex, onItemSelected: _onItemSelected),
      appBar: const App_Bar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}
