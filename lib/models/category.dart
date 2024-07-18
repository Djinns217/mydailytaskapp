import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart' ; //Référence au fichier généré

@HiveType(typeId: 2)

class Category extends HiveObject{
  @HiveField(0)
  String? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int? value;

  Category({
    required this.id,
    required this.name,
    this.value = 0,
  });

  void setValue(int newValue) {
    if (newValue >= 0 && newValue <= 10) {
      value = newValue;
      save();
    } else {
      throw RangeError("La valeur doit être dans 0 et 10");
    }
  }
}
