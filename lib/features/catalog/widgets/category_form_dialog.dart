import 'package:flutter/material.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/category.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/category_service.dart';

class CategoryFormDialog extends StatefulWidget {
  final Category? category;
  final VoidCallback onSaved;

  const CategoryFormDialog({
    super.key,
    this.category,
    required this.onSaved,
  });

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sectionController = TextEditingController();
  final _displayOrderController = TextEditingController();
  
  bool _delivery = false;
  bool _state = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description ?? '';
      _sectionController.text = widget.category!.section ?? '';
      _displayOrderController.text = widget.category!.displayOrder?.toString() ?? '';
      _delivery = widget.category!.delivery ?? false;
      _state = widget.category!.state;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sectionController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final category = Category(
        idCategory: widget.category?.idCategory,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        section: _sectionController.text.trim().isEmpty ? null : _sectionController.text.trim(),
        delivery: _delivery,
        displayOrder: _displayOrderController.text.isEmpty ? null : int.tryParse(_displayOrderController.text),
        state: _state,
      );

      if (widget.category == null) {
        await CategoryService.create(category);
      } else {
        await CategoryService.update(widget.category!.idCategory!, category);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.category == null ? 'Categoría creada' : 'Categoría actualizada'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSaved();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF1100).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.category,
                        color: Color(0xFFFF1100),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category == null ? 'Nueva Categoría' : 'Editar Categoría',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const Text(
                            'Complete la información',
                            style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nombre
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Ej: Pollos, Bebidas, Combos',
                    prefixIcon: const Icon(Icons.label, color: Color(0xFFFF1100)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Sección
                TextFormField(
                  controller: _sectionController,
                  decoration: InputDecoration(
                    labelText: 'Sección',
                    hintText: 'Ej: Platos y Bebidas, Combos, Ofertas',
                    prefixIcon: const Icon(Icons.restaurant_menu, color: Color(0xFFFF1100)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Descripción de la categoría',
                    prefixIcon: const Icon(Icons.description, color: Color(0xFFFF1100)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Orden de visualización
                TextFormField(
                  controller: _displayOrderController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Orden de visualización',
                    hintText: 'Ej: 1, 2, 3...',
                    prefixIcon: const Icon(Icons.sort, color: Color(0xFFFF1100)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (int.tryParse(value) == null) {
                        return 'Debe ser un número válido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Switches
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Disponible para Delivery'),
                        subtitle: const Text('Permitir pedidos a domicilio'),
                        value: _delivery,
                        onChanged: (value) => setState(() => _delivery = value),
                        activeColor: const Color(0xFFFF1100),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Estado'),
                        subtitle: Text(_state ? 'Activo' : 'Inactivo'),
                        value: _state,
                        onChanged: (value) => setState(() => _state = value),
                        activeColor: const Color(0xFFFF1100),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF1100),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(widget.category == null ? 'Crear' : 'Actualizar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}