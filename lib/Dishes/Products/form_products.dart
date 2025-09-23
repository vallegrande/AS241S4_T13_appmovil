// lib/Dishes/Products/form_products.dart
import 'package:flutter/material.dart';

class FormProducts extends StatefulWidget {
  const FormProducts({super.key});

  @override
  State<FormProducts> createState() => _FormProductsState();
}

class _FormProductsState extends State<FormProducts> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  bool active = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Producto')),
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
              // Agregar más campos como imagen, etc.
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