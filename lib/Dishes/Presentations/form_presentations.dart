// lib/Dishes/Presentations/form_presentations.dart
import 'package:flutter/material.dart';

class FormPresentations extends StatefulWidget {
  const FormPresentations({super.key});

  @override
  State<FormPresentations> createState() => _FormPresentationsState();
}

class _FormPresentationsState extends State<FormPresentations> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  double price = 0.0;
  int time = 0;
  bool active = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Presentación')),
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
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                onChanged: (value) => price = double.tryParse(value) ?? 0.0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tiempo (min)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => time = int.tryParse(value) ?? 0,
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