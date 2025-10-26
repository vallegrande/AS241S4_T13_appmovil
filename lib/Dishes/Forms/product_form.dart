// Archivo: lib/Dishes/Forms/product_form.dart
import 'package:flutter/material.dart';
import 'package:myapp/services/product_service.dart';
// Importamos los servicios funcionales
import 'package:myapp/services/department_service.dart';
import 'package:myapp/services/product_ingredient_service.dart';
import 'package:myapp/models/category.dart';
import 'package:myapp/models/product.dart';
// Importamos el Department del user_service para la lista interna (fuente de datos)
import 'package:myapp/services/user_service.dart' show Department; 
// Importamos el Department del modelo para la construcción de objetos a guardar, usando alias
import 'package:myapp/models/department.dart' as model; 
import 'package:myapp/models/product_ingredient.dart';
import 'package:myapp/Dishes/Forms/recipe_form.dart';


class ProductForm extends StatefulWidget {
  final Product? product;
  final Category category;
  final VoidCallback onClose;
  final Function(Product) onSaved;

  const ProductForm({
    super.key,
    this.product,
    required this.category,
    required this.onClose,
    required this.onSaved,
  });

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _recipeFormKey = GlobalKey<RecipeFormState>(); 
  final _productService = ProductService();
  final DepartmentService _departmentService = DepartmentService(); 
  final _productIngredientService = ProductIngredientService(); 

  late String _name;
  late String _description;
  late int? _departmentId;
  late bool _state;
  
  bool _loading = false;
  bool _loadingDepartments = false;
  
  // Usamos el tipo Department de user_service.dart
  List<Department> _departments = []; 
  
  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _description = widget.product?.description ?? '';
    _departmentId = widget.product?.department?.id;
    _state = widget.product?.state ?? true;
    
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() => _loadingDepartments = true);
    try {
      final departments = await _departmentService.getDepartments(); 
      if (mounted) {
        setState(() {
          // Asignación ya no causa error de tipo
          _departments = departments; 
          
          if (widget.product == null && departments.isNotEmpty && _departmentId == null) {
            _departmentId = departments.first.id;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al cargar departamentos: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loadingDepartments = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final recipeState = _recipeFormKey.currentState;

    if (recipeState != null && !recipeState.validateRecipe()) {
      _showError('Por favor, complete todos los campos requeridos en la receta (insumo seleccionado y cantidad > 0 si la receta está activa).');
      return;
    }

    setState(() => _loading = true);

    try {
      // Usamos el alias 'model.Department' para crear el objeto a enviar al backend
      final productToSave = Product(
        idProduct: widget.product?.idProduct,
        name: _name,
        description: _description,
        state: _state,
        category: widget.category,
        department: model.Department(id: _departmentId!, name: ''),
      );

      // 1. Guardar/Actualizar Producto
      Product savedProduct;
      if (widget.product?.idProduct != null) {
        savedProduct = await _productService.update(widget.product!.idProduct!, productToSave);
      } else {
        savedProduct = await _productService.create(productToSave);
      }
      
      // 2. Sincronizar Receta
      if (recipeState != null) {
        await recipeState.executeDeletions(); 
        
        if (recipeState.hasRecipe) {
          await _saveRecipe(savedProduct.idProduct!);
        }
      } 
      
      _showSuccess('Producto ${widget.product != null ? 'actualizado' : 'creado'} correctamente.');
      widget.onSaved(savedProduct);
      
    } catch (e) {
      _showError('Error al guardar producto: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _saveRecipe(int idProduct) async {
    final recipeToSave = _recipeFormKey.currentState!.getRecipeData();

    for (final item in recipeToSave) {
      final productIngredient = ProductIngredient(
        id: ProductIngredientId(
          idProduct: idProduct, 
          idIngredient: item['idIngredient'] as int,
        ),
        quantity: item['quantity'] as double,
        unit: item['unit'] as String?,
      );
      
      await _productIngredientService.create(productIngredient);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: SingleChildScrollView(
              child: Container(
                width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 800, 
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.3))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Editar Producto' : 'Nuevo Producto',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Categoría: ${widget.category.name}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // ************* SECCIÓN DE FORMULARIO BÁSICO *************
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Nombre
                          TextFormField(
                            initialValue: _name,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del Producto *',
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
                              labelText: 'Descripción *',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              return null;
                            },
                            onChanged: (value) => _description = value,
                          ),
                          const SizedBox(height: 16),

                          // Departamento
                          DropdownButtonFormField<int?>(
                            value: _departmentId,
                            decoration: InputDecoration(
                              labelText: 'Departamento/Área *',
                              border: const OutlineInputBorder(),
                              suffix: _loadingDepartments 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : null,
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('-- Selecciona un departamento --'),
                              ),
                              ..._departments.map<DropdownMenuItem<int?>>((dept) { 
                                return DropdownMenuItem<int?>(
                                  value: dept.id,
                                  child: Text(dept.name),
                                );
                              }).toList(),
                            ],
                            validator: (value) {
                              if (value == null) {
                                return 'Este campo es requerido';
                              }
                              return null;
                            },
                            onChanged: _loadingDepartments ? null : (value) => setState(() => _departmentId = value),
                          ),
                          const SizedBox(height: 16),

                          // Estado
                          CheckboxListTile(
                            title: const Text('Producto Activo'),
                            value: _state,
                            onChanged: (value) => setState(() => _state = value ?? true),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // ************* SECCIÓN DE RECETA *************
                    RecipeForm(
                      key: _recipeFormKey,
                      productId: widget.product?.idProduct ?? 0,
                      isEditing: isEdit,
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
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(isEdit ? 'Actualizar Producto' : 'Crear Producto'),
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