import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  void Function(int)? onTabChange;
  MyBottomNavBar({
    super.key,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber[200]
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GNav(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        color: Colors.amber[400],
        activeColor: Colors.amber.shade900,
        tabActiveBorder: Border.all(color: Colors.amber),
        tabBackgroundColor: Colors.amber.shade300,
        tabBorderRadius: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        onTabChange: (value) => onTabChange!(value),
        tabs: const [
          GButton(
            icon: Icons.today,
            text: "Aujourd'hui",
          ),
          GButton(
            icon: Icons.format_list_bulleted,
            text: 'Activités',
          ),
          GButton(
              icon: Icons.bar_chart_outlined,
              text: "Statistique"
          ),
          GButton(
            icon: Icons.calendar_month,
            text: 'Historique'
          )
        ],
      )
    );
  }
}
