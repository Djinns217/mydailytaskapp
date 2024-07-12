import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'activity.g.dart' ; //Référence au fichier généré

@HiveType(typeId: 0)

class Activity extends HiveObject{
  @HiveField(0)
  String? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime? startDate;

  @HiveField(3)
  String? category;

  @HiveField(4)
  int? goalFrequency;

  @HiveField(5)
  String? goalPeriod;

  Activity({
    required this.id,
    required this.name,
    this.category,
    this.startDate,
    this.goalFrequency,
    this.goalPeriod,
  });
}
