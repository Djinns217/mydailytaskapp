import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../components/StatCard.dart';
import '../models/activity.dart';
import '../models/task.dart';
import 'SettingsActivity.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final Box<Activity> activityBox = Hive.box<Activity>('activities');
  final Box<Task> taskBox = Hive.box<Task>('tasks');

  String selectedActivity= '';
  String? selectedActivityName;

  List<Activity> allActivities = [];
  List<Activity> filteredActivities = [];

  DateTime today = DateTime.now();
  late String monthName;
  late int year;

  @override
  void initState() {
    super.initState();
    monthName = DateFormat.MMMM('fr').format(today);
    year = today.year;
  }

  // calcul des jours consécutifs
  int calculateConsecutiveDays(Activity activity, List<Task> tasks) {
    if (tasks.isEmpty) return 0;

    final taskListReduced = taskBox.values.where(
            (task) {
                return task.name == activity.name &&
                    task.isCompleted == true;
    }).toList();

    taskListReduced.sort((a,b) => b.date!.compareTo(a.date!));
    int consecutiveDays = 0;
    if (taskListReduced.isNotEmpty) {
      if (taskListReduced[0].date!.day == today.day &&
          taskListReduced[0].date!.month == today.month &&
          taskListReduced[0].date!.year == today.year) {
        consecutiveDays++;
        for (int i = 1; i < taskListReduced.length; i++) {
          if (taskListReduced[i-1].date!.day
              - taskListReduced[i].date!.day
              == 1
          ){
            consecutiveDays++;
          } else {
            break;
          }
        }
      } else {}
    } else{}

    return consecutiveDays;
  }


  //calcul du pourcentage de réussite
  double calculateSuccessPercentage(Activity activity, List<Task> tasks) {
    if (activity.goalFrequency == null || activity.goalPeriod == null) return 0.0;
    int completedTasks = tasks.length;
    DateTime startDate = activity.startDate ?? DateTime.now();
    int totalDays = today.difference(startDate).inDays + 1;

    double goal;
    if (activity.goalPeriod == 'jour') {
      goal = ((completedTasks / 30) * 100 ) / activity.goalFrequency!;
    } else if (activity.goalPeriod == 'semaine') {
      goal = ((completedTasks / 4) * 100 ) / activity.goalFrequency!;
    } else {
      goal = (completedTasks * 100) / activity.goalFrequency!;
    }

    return goal;
  }

  // calcul du nombre de completed tasks dans un mois
  int calculateCompletedDaysInMonth(List<Task> tasks) {
    DateTime firstDayOfMonth = DateTime(today.year, today.month, 1);
    DateTime lastDayOfMonth = DateTime(today.year, today.month + 1, 0);
    return tasks
        .where((task) =>
    task.date!.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
        task.date!.isBefore(lastDayOfMonth.add(const Duration(days: 1))))
        .length;
  }

  // calcul du nombre de completed tasks dans une année
  int calculateCompletedDaysInYear(List<Task> tasks) {
    DateTime firstDayOfYear = DateTime(today.year, 1, 1);
    DateTime lastDayOfYear = DateTime(today.year, 12, 31);
    return tasks
        .where((task) =>
    task.date!.isAfter(firstDayOfYear.subtract(const Duration(days: 1))) &&
        task.date!.isBefore(lastDayOfYear.add(const Duration(days: 1))))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    Activity? selectedActivityDetails;

    if(selectedActivityName != "") {
      selectedActivityDetails = activityBox.values.firstWhere(
          (activity) => activity.name == selectedActivityName,
              orElse: () => Activity(
                  id: "",
                  name: "")
      );
    }


    final activities = activityBox.values.toList();
    final tasks = taskBox.values.where(
            (task) {
              if (selectedActivityName == null) {
                return task.isCompleted == true;
              } else {
                return task.name == selectedActivityName &&
                    task.date?.month == today.month &&
                    task.date?.year == today.year &&
                    task.isCompleted == true;
              }
    }).toList();

    return Scaffold(
      backgroundColor: Colors.amber[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
            'Statistiques',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DropdownButton<String>(
                    hint: const Text("Sélectionner une activité"),
                    value: selectedActivityName,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedActivityName = newValue;
                      });
                    },
                    items: activities.map((activity) {
                      return DropdownMenuItem<String>(
                        value: activity.name,
                        child: Text(activity.name),
                      );
                    }).toList(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsActivity(initialActivityName: selectedActivityName),
                        ),
                      );
                      },
                  )
              ]),
              const SizedBox(height: 16),
              Text(
                "$monthName - $year",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                child: Table(
                  children: _buildCalendar(tasks),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Résultats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 310,
                  height: 290,
                  child: GridView.count(
                      crossAxisCount: 2,
                      children: [
                        StatCard(
                          icon: Icons.change_circle_rounded,
                          value: calculateConsecutiveDays(selectedActivityDetails!,tasks).toString(),
                          label: 'Consécutifs',
                        ),
                        StatCard(
                          icon: Icons.check_circle_outline_outlined,
                          value: selectedActivityDetails != null
                              ? '${calculateSuccessPercentage(selectedActivityDetails, tasks).round()}'
                              : '0',
                          label: 'Réussite (%)',
                        ),
                        StatCard(
                          icon: Icons.calendar_month,
                          value:
                          calculateCompletedDaysInMonth(tasks).toString(),
                          label: 'dans le mois',
                        ),
                        StatCard(
                          icon: Icons.calendar_today_outlined,
                          value:
                          calculateCompletedDaysInYear(tasks).toString(),
                          label: "dans l'année",
                        ),
                      ],
                    ),
                ),
              ),
              ]
          ),
        ),
      ),
    );
  }

  List<TableRow> _buildCalendar(List<Task> tasks) {
    final List<TableRow> rows = [];

    // Header row - jour de la semaine
    rows.add(
      TableRow(
        children: List.generate(7, (index) {
          return Center(
            child: Text(
              DateFormat.EEEE('fr').format(DateTime(2023, 1, index + 2)).substring(0, 3),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }),
      ),
    );

    // Days of the month
    int daysInMonth = DateUtils.getDaysInMonth(today.year, today.month);
    int firstDayOfMonth = DateTime(today.year, today.month, 1).weekday;

    List<Widget> dayWidgets = [];
    for (int i = 1; i < firstDayOfMonth; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      bool hasTask = tasks.any((task) => task.date?.day == day);

      dayWidgets.add(
        Center(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: hasTask ? Colors.tealAccent : null,
              shape: BoxShape.circle,
            ),
            child: Text(
              day.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      if ((dayWidgets.length) % 7 == 0) {
        rows.add(TableRow(children: dayWidgets));
        dayWidgets = [];
      }

    }

    if (dayWidgets.isNotEmpty) {
      while (dayWidgets.length < 7) {
        dayWidgets.add(const SizedBox.shrink());
      }
      rows.add(TableRow(children: dayWidgets));
    }

    return rows;
  }
}
