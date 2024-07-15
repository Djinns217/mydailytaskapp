import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:my_daily_tasks/components/top_week_day_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';


import '../models/activity.dart';
import '../models/task.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});


  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final DateTime todayDate = DateTime.now();

  TextEditingController taskController = TextEditingController();

  final Box<Task> taskBox = Hive.box<Task>('tasks');
  final Box<Activity> activityBox = Hive.box<Activity>('activities');


  @override
  void initState() {
    super.initState();
    print(todayDate);
    if (taskBox.isNotEmpty) {
      Task? lastTask = taskBox.getAt(taskBox.length - 1);
      if (lastTask?.date.toString().substring(0,10) != todayDate.toString().substring(0,10)){
        deleteOldNotCompletedTasks();
        addNewTodayTask();
      }
    } else {}
  }

  void deleteOldNotCompletedTasks() {
    final tasksToDelete = taskBox.keys.where((key) {
      final task = taskBox.get(key);
      return task != null && task.isCompleted == false;
    }).toList();

    for (var key in tasksToDelete) {
      taskBox.delete(key);
    }
  }

  // à faire à chaque nouveau jour
  void addNewTodayTask(){
    final activityList = activityBox.values.toList();

    activityList.forEach(
            (activity) {
          Task newTask = Task(
            id: Uuid().v4(),
            name: activity.name,
            date: todayDate,
          );

          taskBox.add(newTask);
        }
    );

  }

  void addTask(String taskName) {
    final newTask = Task(
      id: Uuid().v4(),
      name: taskName,
      date: DateTime.now(),
      isCompleted: true,
    );
    taskBox.add(newTask);
  }

  void completeTask(Task task) {
    setState(() {
      task.isCompleted = true;
      task.date = todayDate;
      task.save();
    });
  }

  void removeCompletedTask(Task task) {
    setState(() {
      task.isCompleted = false;
      task.save();
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                child: Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
              )),
        ),
        title: const Text(
          "Aujourd'hui",
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: Colors.amber[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //logo
            DrawerHeader(
                child: Image.asset(
                  'lib/photos/intro.png',
                )
            )
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box<Task> box, _) {

          final completedTasks = box.values.where(
                (task) =>
                task.date?.toString().substring(0,10) ==
                    todayDate.toString().substring(0,10) &&
              task.isCompleted == true,
          ).toList();

          final availableTask = box.values.where(
              (task) =>
                  task.isCompleted == false
          ).toList();



          return Column(
            children: [

              const SizedBox(height: 20,),

              WeekDaysWidget(),

              const SizedBox(height: 20,),

              const Text(
                "Réalisées",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.teal,
                ),
              ),

              Expanded(
                  child: ListView.builder(
                      itemCount: completedTasks.length,
                      itemBuilder: (context, index) {
                        final task = completedTasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                          child: Slidable(
                              endActionPane: ActionPane(
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                        removeCompletedTask(task);
                                      },
                                    icon: Icons.keyboard_arrow_down,
                                    backgroundColor: Colors.red.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  )
                                ],
                              ),
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade500,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: ListTile(
                                    title: Text(
                                        task.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                      },
                  ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Activités",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.teal
                ),
              ),

              Expanded(
                  child: ListView.builder(
                    itemCount: availableTask.length,
                    itemBuilder: (context, index) {
                      final task = availableTask[index];
                      return GestureDetector(
                        onTap: () => completeTask(task),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Card(
                              child: ListTile(
                                title: Text(
                                  task.name,
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold
                                  ),

                                ),
                              )
                          ),
                        )
                      );
                    },
                  )
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: taskController,
                          decoration: const InputDecoration(
                            hintText: "Tâche que pour aujourd'hui",
                          ),
                          onSubmitted: (text) {
                            if (text.isNotEmpty) {
                              addTask(text);
                            }
                          },
                        )
                    ),
                    IconButton(
                        onPressed: () {
                          if (taskController.text.isNotEmpty) {
                            addTask(taskController.text);
                            taskController.clear();
                          }
                        },
                        icon: const Icon(Icons.add)
                    )
                  ],
                ),
              )
            ],
          );
        }
      ),
    );
  }
}
