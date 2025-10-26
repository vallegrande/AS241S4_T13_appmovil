import 'package:flutter/material.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/models/category.dart';

class CategoryForm extends StatefulWidget {
  final Category? category;
  final String currentSection;
  final VoidCallback onClose;
  final Function(Category) onSaved;

  const CategoryForm({
    super.key,
    this.category,
    required this.currentSection,
    required this.onClose,
    required this.onSaved,
  });

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _categoryService = CategoryService();
  
  late String _name;
  late String _description;
  late String _section;
  late bool _delivery;
  late int? _displayOrder;
  late bool _state;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _name = c?.name ?? '';
    _description = c?.description ?? '';
    _section = c?.section ?? widget.currentSection;
    _delivery = c?.delivery ?? false;
    _displayOrder = c?.displayOrder;
    _state = c?.state ?? true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final category = Category(
        idCategory: widget.category?.idCategory,
        name: _name,
        description: _description,
        section: _section,
        delivery: _delivery,
        displayOrder: _displayOrder,
        state: _state,
        createdAt: widget.category?.createdAt,
      );

      Category savedCategory;
      if (widget.category?.idCategory != null) {
        savedCategory = await _categoryService.update(widget.category!.idCategory!, category);
      } else {
        savedCategory = await _categoryService.create(category);
      }

      widget.onSaved(savedCategory);
      _showSuccess('Categoría ${widget.category != null ? 'actualizada' : 'creada'} correctamente');
    } catch (e) {
      _showError('Error al guardar categoría: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.3))],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Editar Categoría' : 'Nueva Categoría',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sección: $_section',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Nombre
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de Categoría *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es requerido';
                        }
                        return null;
                      },
                      onChanged: (value) => _name = value,
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) => _description = value,
                    ),
                    const SizedBox(height: 16),

                    // Delivery
                    CheckboxListTile(
                      title: const Text('Disponible para Delivery'),
                      value: _delivery,
                      onChanged: (value) => setState(() => _delivery = value ?? false),
                    ),

                    // Orden de visualización
                    TextFormField(
                      initialValue: _displayOrder?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Orden de Visualización',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _displayOrder = int.tryParse(value),
                    ),
                    const SizedBox(height: 16),

                    // Estado
                    CheckboxListTile(
                      title: const Text('Categoría Activa'),
                      value: _state,
                      onChanged: (value) => setState(() => _state = value ?? true),
                    ),
                    const SizedBox(height: 20),

                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _loading ? null : widget.onClose,
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF28a745),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator()
                                : Text(isEdit ? 'Actualizar' : 'Crear'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}