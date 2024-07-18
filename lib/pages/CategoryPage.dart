import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:my_daily_tasks/models/task.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../models/category.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  final Box<Category> categoryBox = Hive.box<Category>('categories');

  TextEditingController categoryController = TextEditingController();
  TextEditingController categoryValueController = TextEditingController();

  void addCategory(String categoryName) {
    final newCategory = Category(
        id: Uuid().v4(),
        name: categoryName);

    categoryBox.add(newCategory);
  }

  void removeCategory(Category category) {
    category.delete();
  }

  void updateCategoryValue(Category category, int newValue) {
    try {
      category.setValue(newValue);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter une categorie"),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(hintText: "Nom de la catégorie"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (categoryController.text.isNotEmpty) {
                  addCategory(categoryController.text);
                  categoryController.clear();
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
                categoryController.clear();
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

  void showEditValueDialog(Category category) {
    categoryValueController.text = category.value.toString();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modifier la valeur de ${category.name}"),
          content: TextField(
            controller: categoryValueController,
            decoration: const InputDecoration(hintText: "Nouvelle valeur"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (categoryValueController.text.isNotEmpty) {
                  updateCategoryValue(category, int.parse(categoryValueController.text));
                }
                Navigator.of(context).pop();
              },
              child: const Text(
                "Mettre à jour",
                style: TextStyle(
                  color: Colors.teal,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                categoryValueController.clear();
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
          'Liste des Catégories',
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
          valueListenable: categoryBox.listenable(),
          builder: (context, Box<Category> box, _) {
            final categories = box.values.toList();

            return Column(
              children: [
                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  removeCategory(category);
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
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      category.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => showEditValueDialog(category),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.teal,
                                        border: Border.all(color: Colors.teal),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        category.value.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
        onPressed: showAddCategoryDialog,
        backgroundColor: Colors.tealAccent,
        child: const Icon(
          Icons.add,
          color: Colors.teal,
        ),
      ),
    );
  }
}
