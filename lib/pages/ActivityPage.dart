import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:my_daily_tasks/models/task.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final DateTime todayDate = DateTime.now();

  final Box<Activity> activityBox = Hive.box<Activity>('activities');
  final Box<Task> taskBox = Hive.box<Task>('tasks');

  TextEditingController activityController = TextEditingController();

  void addActivity(String activityName) {
    final newActivity = Activity(
      id: Uuid().v4(),
      name: activityName,
    );
    final newTask = Task(
        id: Uuid().v4(),
        name: activityName,
        date: todayDate);

    activityBox.add(newActivity);
    taskBox.add(newTask);
  }

  void removeActivity(Activity activity) {
    activity.delete();

    final tasksToDelete = taskBox.keys.where((key) {
      final task = taskBox.get(key);
      return task != null && task.name == activity.name && task.isCompleted == false;
    }).toList();

    for (var key in tasksToDelete) {
      taskBox.delete(key);
    }

  }

  void showAddActivityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter une activité"),
          content: TextField(
            controller: activityController,
            decoration: const InputDecoration(hintText: "Nom de l'activité"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (activityController.text.isNotEmpty) {
                  addActivity(activityController.text);
                  activityController.clear();
                }
                Navigator.of(context).pop();
              },
              child: const Text(
                "Ajouter",
                style: TextStyle(
                  color: Colors.teal,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                activityController.clear();
                Navigator.of(context).pop();
              },
              child: const Text(
                "Annuler",
                style: TextStyle(
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Liste des Activités',
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: activityBox.listenable(),
        builder: (context, Box<Activity> box, _) {
          final activities = box.values.toList();

          return Column(
            children: [
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Slidable(
                        endActionPane: ActionPane(
                          motion: const StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                removeActivity(activity);
                              },
                              icon: Icons.delete,
                              backgroundColor: Colors.red.shade300,
                              borderRadius: BorderRadius.circular(10),
                            )
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              activity.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            onTap: () {
                              // Naviguer vers les détails de l'activité ou effectuer une action
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddActivityDialog,
        backgroundColor: Colors.tealAccent,
        child: const Icon(
          Icons.add,
          color: Colors.teal,
        ),
      ),
    );
  }
}
