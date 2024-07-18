import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart' ; //Référence au fichier généré

@HiveType(typeId: 2)

class Task extends HiveObject{
  @HiveField(0)
  String? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int? value;

  Task({
    required this.id,
    required this.name,
    this.value,
  });
}
