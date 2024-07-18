import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:my_daily_tasks/pages/ActivityPage.dart';
import 'package:my_daily_tasks/pages/HomePage.dart';
import 'package:my_daily_tasks/pages/IntroPage.dart';
import 'package:my_daily_tasks/pages/TodayPage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'models/activity.dart';
import 'models/task.dart';
import 'models/category.dart';

//flutter//
//flutter clean
// flutter pub get
// flutter run
//flutter pub run build_runner build

//git//
//git status
//git add .
//git commit -m "Message du commit"
//git push origin master

void main() async{
  //initialisation de Hive
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await getApplicationCacheDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  Hive.registerAdapter(ActivityAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(CategoryAdapter());

  await Hive.openBox<Category>('categories');
  await Hive.openBox<Activity>('activities');
  await Hive.openBox<Task>('tasks');


  await initializeDateFormatting('fr', null);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroPage(),
      theme: ThemeData(primarySwatch: Colors.teal
      ),

    );
  }
}

