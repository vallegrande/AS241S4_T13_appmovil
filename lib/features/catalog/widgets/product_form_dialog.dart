import 'package:flutter/material.dart';
// CORRECCIÓN: Usar 'hide Department' para evitar el conflicto de clases
import 'package:as241s4_t13_appmovil/core/models/dishes/product.dart' hide Department; 
import 'package:as241s4_t13_appmovil/core/models/dishes/category.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/product_service.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/category_service.dart';
import 'package:as241s4_t13_appmovil/core/services/department/department_service.dart';
import 'package:as241s4_t13_appmovil/core/models/department/department_model.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final VoidCallback onSaved;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.onSaved,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _state = true;
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  bool _isLoadingDepartments = true;

  List<Category> _categories = [];
  Category? _selectedCategory;
  List<Department> _departments = [];
  Department? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _state = widget.product!.state;
    }

    _loadCategories();
    _loadDepartments();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService.getAll();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        if (_categories.isNotEmpty) {
          final catId = widget.product?.category?['idCategory'];
          _selectedCategory = categories.firstWhere(
            (c) => c.idCategory == catId,
            orElse: () => _categories.first,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar categorías.')),
        );
      }
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await DepartmentService().getAllDepartments();
      setState(() {
        _departments = departments;
        _isLoadingDepartments = false;
        if (_departments.isNotEmpty) {
          final deptId = widget.product?.department?['id'];
          _selectedDepartment = departments.firstWhere(
            (Department d) => d.id == deptId, 
            orElse: () => _departments.first,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar departamentos.')),
        );
      }
      setState(() => _isLoadingDepartments = false);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una categoría y un departamento.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final product = Product(
      idProduct: widget.product?.idProduct,
      name: _nameController.text,
      description: _descriptionController.text.trim(),
      state: _state,
      category: {'idCategory': _selectedCategory!.idCategory},
      department: {'id': _selectedDepartment!.id},
    );

    try {
      if (widget.product == null) {
        await ProductService.create(product);
      } else {
        await ProductService.update(widget.product!.idProduct!, product);
      }
      
      // CORRECCIÓN: Cerrar diálogo y llamar callback sin esperar
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar el diálogo
        // Llamar al callback en el siguiente frame para evitar conflictos
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSaved();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar producto: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Crear Producto' : 'Actualizar Producto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      isExpanded: true,
                      onChanged: (Category? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      items: _categories.map((Category category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione una categoría';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 16),

              // Department Dropdown
              _isLoadingDepartments
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Department>(
                      value: _selectedDepartment,
                      decoration: const InputDecoration(labelText: 'Departamento'),
                      isExpanded: true,
                      onChanged: (Department? newValue) {
                        setState(() {
                          _selectedDepartment = newValue;
                        });
                      },
                      items: _departments.map((Department department) { 
                        return DropdownMenuItem<Department>( 
                          value: department,
                          child: Text(department.name),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione un departamento';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 16),
              
              // State Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estado', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _state,
                    onChanged: (bool value) {
                      setState(() {
                        _state = value;
                      });
                    },
                    activeColor: const Color(0xFFFF1100),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF1100),
                        side: const BorderSide(color: Color(0xFFFF1100)),
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
                      onPressed: _isLoading ? null : _saveProduct,
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
                          : Text(widget.product == null ? 'Crear' : 'Actualizar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  } 
}