import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';

class PersonalityPage extends StatelessWidget {
  const PersonalityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<Category> categoryBox = Hive.box<Category>('categories');
    final categories = categoryBox.values.toList();
    final categoryNames = categories.map((category) => category.name).toList();
    final categoryValues = categories
        .map((category) => category.value?.toDouble() ?? 0.0)
        .toList();

    return Scaffold(
      backgroundColor: Colors.amber[100],
      appBar: AppBar(
        backgroundColor: Colors.amber[100],
        elevation: 0,
        title: const Text(
          "Graphique de l'Identité",
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: RadarChart(
            ticks: const [0,1, 2, 4, 5, 6, 7, 8, 9, 10],
            features: categoryNames,
            data: [categoryValues],
            reverseAxis: false,
            sides: categories.length, // Adjust the number of sides to match the number of categories
            ticksTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            featuresTextStyle: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 14),
            outlineColor: Colors.teal,
            graphColors: [Colors.teal.shade400.withOpacity(0.5)],
          ),
        ),
      ),
    );
  }
}
