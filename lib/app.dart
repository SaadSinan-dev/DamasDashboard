import 'package:damas_dashboard/screens/analytics_screen.dart';
import 'package:damas_dashboard/screens/home_screen.dart';
import 'package:damas_dashboard/screens/settings/screens/settings_screen.dart';
import 'package:damas_dashboard/widgets/windows/notification_window.dart';
import 'package:flutter/material.dart';
import 'package:damas_dashboard/screens/reports_screen.dart';
import 'package:damas_dashboard/screens/splash/splash_screen.dart';


class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'RobotoCondensed'),
      home: SplashScreen(),
      routes: {
        '/home': (context) => const Homescreen(),
        '/analytics': (context) => const AnalysisPage(),
        '/notification': (context) => const NotificationWindow(),
       '/settings': (context) => const SettingsScreen(),
       '/reports' :(context) => const ReportsPage(),
      },
    );
  }
}