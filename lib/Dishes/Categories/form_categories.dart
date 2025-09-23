// lib/Dishes/Categories/form_categories.dart
import 'package:flutter/material.dart';

class FormCategories extends StatefulWidget {
  const FormCategories({super.key});

  @override
  State<FormCategories> createState() => _FormCategoriesState();
}

class _FormCategoriesState extends State<FormCategories> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  bool active = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Categoría')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (value) => name = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                onChanged: (value) => description = value,
              ),
              SwitchListTile(
                title: const Text('Activo'),
                value: active,
                onChanged: (value) => setState(() => active = value),
              ),
              ElevatedButton(
                onPressed: () {
                  // Guardar lógica aquí
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}