import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

List<DateTime> getCurrentWeekDates() {
  DateTime today = DateTime.now();
  int currentWeekday = today.weekday;

  DateTime firstDayOfWeek = today.subtract(Duration(days: currentWeekday - 1));
  return List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
}

class WeekDaysWidget extends StatelessWidget {

  final List<DateTime> weekDates;

  WeekDaysWidget({Key? key})
      : weekDates = getCurrentWeekDates(),
        super(key: key);

  static List<DateTime> getCurrentWeekDates() {
    DateTime today = DateTime.now();
    int currentWeekday = today.weekday;

    DateTime firstDayOfWeek = today.subtract(Duration(days: currentWeekday - 1));
    return List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }

  Box<Task> taskBox = Hive.box<Task>('tasks');

  List<Task> getCompletedTasksForDate(DateTime date) {
    return taskBox.values.where((task) =>
    task.date?.year == date.year &&
        task.date?.month == date.month &&
        task.date?.day == date.day &&
        task.isCompleted == true
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.teal[200]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDates.map((date) {
          bool isToday = date.day == today.day && date.month == today.month && date.year == today.year;
          return GestureDetector(
            onTap: (){
              List<Task> completedTasks = getCompletedTasksForDate(date);
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text(
                        'Tâches réalisées le ${DateFormat.yMd('fr_FR').format(date)}',
                        style: const TextStyle(
                          color: Colors.teal,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: completedTasks.map((task) {
                          return ListTile(
                            title: Text(task.name),
                            subtitle: Text('Heure: ${task.date != null ? DateFormat.Hm().format(task.date!) : 'Non spécifiée'}'),
                          );
                        }).toList(),
                      ),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Fermer',
                              style: TextStyle(
                                color: Colors.teal,
                              ),
                            ))
                      ],
                    );
                  }
                  );
            },
            child: Column(
              children: [
                Text(
                  DateFormat.E().format(date), // Lundi, Mardi, etc.
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.teal.shade700 : Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.teal.shade700 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

