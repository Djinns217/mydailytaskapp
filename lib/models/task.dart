import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'task.g.dart' ; //Référence au fichier généré

@HiveType(typeId: 1)

class Task extends HiveObject{
  @HiveField(0)
  String? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime? date;

  @HiveField(3)
  bool isCompleted;

  Task({
    required this.id,
    required this.name,
    required this.date,
    this.isCompleted = false,
  });
}
