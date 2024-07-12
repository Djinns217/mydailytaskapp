import 'package:flutter/material.dart';

import '../components/bottom_nav_bar.dart';
import 'ActivityPage.dart';
import 'HistoryPage.dart';
import 'SettingsActivity.dart';
import 'StatsPage.dart';
import 'TodayPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 0;

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //page à affichée
  final List<Widget> _pages = [
    //page du jour
    const TodayPage(),

    //page d'activités
    const ActivityPage(),

    //page des statistiques
    const StatsPage(),

    //page de l'historique
    const HistoryPage(),

    const SettingsActivity(),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) =>
            navigateBottomBar(index),
      ),
      body: _pages[_selectedIndex]
    );
  }
}
