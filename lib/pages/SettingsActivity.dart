import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';

class SettingsActivity extends StatefulWidget {
  final String? initialActivityName;

  const SettingsActivity({Key? key, this.initialActivityName}) : super(key: key);

  @override
  State<SettingsActivity> createState() => _SettingsActivityState();
}

class _SettingsActivityState extends State<SettingsActivity> {
  final Box<Activity> activityBox = Hive.box<Activity>('activities');

  String? selectedActivityName;
  TextEditingController categoryController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController goalFrequencyController = TextEditingController();
  String? selectedGoalPeriod;

  @override
  void initState() {
    super.initState();
    selectedActivityName = widget.initialActivityName;
    if (selectedActivityName != null) {
      loadActivityDetails(selectedActivityName!);
    }
  }

  void loadActivityDetails(String activityName) {
    final activity = activityBox.values.firstWhere((activity) => activity.name == activityName);
    categoryController.text = activity.category ?? '';
    startDateController.text = activity.startDate != null ? DateFormat.yMd().format(activity.startDate!) : '';
    goalFrequencyController.text = activity.goalFrequency?.toString() ?? '';
    selectedGoalPeriod = activity.goalPeriod;
  }

  void saveActivityDetails() {
    if (selectedActivityName != null) {
      final activity = activityBox.values.firstWhere((activity) => activity.name == selectedActivityName);
      activity.category = categoryController.text;
      activity.startDate = DateFormat.yMd().parse(startDateController.text);
      activity.goalFrequency = int.tryParse(goalFrequencyController.text);
      activity.goalPeriod = selectedGoalPeriod;
      activity.save();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        startDateController.text = DateFormat.yMd().format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activities = activityBox.values.toList();

    return Scaffold(
      backgroundColor: Colors.amber[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Paramètres de l\'activité',
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              hint: const Text("Sélectionner une activité"),
              value: selectedActivityName,
              onChanged: (String? newValue) {
                setState(() {
                  selectedActivityName = newValue;
                  loadActivityDetails(newValue!);
                });
              },
              items: activities.map((activity) {
                return DropdownMenuItem<String>(
                  value: activity.name,
                  child: Text(activity.name),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date de début (MM/JJ/AAAA)',
                  ),
                  keyboardType: TextInputType.datetime,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: goalFrequencyController,
              decoration: const InputDecoration(
                labelText: 'Objectif (fréquence)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              hint: const Text("Période de l'objectif"),
              value: selectedGoalPeriod,
              onChanged: (String? newValue) {
                setState(() {
                  selectedGoalPeriod = newValue;
                });
              },
              items: ['semaine', 'mois'].map((period) {
                return DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveActivityDetails,
              child: const Text(
                'Enregistrer',
                style: TextStyle(
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
