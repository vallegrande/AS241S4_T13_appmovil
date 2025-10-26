// Archivo: lib/Dishes/Forms/recipe_form.dart
import 'package:flutter/material.dart';
import 'package:myapp/services/ingredient_service.dart';
import 'package:myapp/services/product_ingredient_service.dart';
import 'package:myapp/models/ingredient.dart'; 
import 'package:myapp/models/product_ingredient.dart'; 
import 'package:myapp/services/user_service.dart'; // Importa clases base (ConflictException, NotFoundException)

class RecipeForm extends StatefulWidget {
  final int productId;
  final bool isEditing;

  const RecipeForm({
    super.key,
    required this.productId,
    required this.isEditing,
  });

  @override
  RecipeFormState createState() => RecipeFormState();
}

class RecipeFormState extends State<RecipeForm> { 
  final _ingredientService = IngredientService();
  final _productIngredientService = ProductIngredientService();
  
  bool _hasRecipe = false;
  bool get hasRecipe => _hasRecipe; 
  
  bool _loadingIngredients = false;
  bool _loadingRecipe = false;
  
  List<Ingredient> _allIngredients = [];
  List<Map<String, dynamic>> _ingredients = [];
  
  List<ProductIngredientId> _deletedAssociations = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableIngredients();
    if (widget.isEditing && widget.productId != 0) {
      _loadProductRecipe();
    }
  }

  Future<void> _loadAvailableIngredients() async {
    setState(() => _loadingIngredients = true);
    try {
      final ingredients = await _ingredientService.getAll(); 
      setState(() => _allIngredients = ingredients);
    } catch (e) {
      _showError('Error al cargar insumos disponibles: $e');
    } finally {
      setState(() => _loadingIngredients = false);
    }
  }

  Future<void> _loadProductRecipe() async {
    if (!widget.isEditing || widget.productId == 0) return;

    setState(() => _loadingRecipe = true);
    try {
      final recipe = await _productIngredientService.getIngredientsByProductId(widget.productId);
      
      if (recipe.isNotEmpty) {
        setState(() {
          _hasRecipe = true;
          _ingredients = recipe.map((item) {
            return {
              'idIngredient': item.id.idIngredient,
              'name': item.ingredient?.name ?? 'Insumo Eliminado',
              'quantity': item.quantity,
              'unit': item.unit ?? item.ingredient?.unit ?? '',
              'isExisting': true,
              'isMarkedForDeletion': false,
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error cargando receta: $e');
      _showError('Error al cargar la receta existente.');
    } finally {
      setState(() => _loadingRecipe = false);
    }
  }

  void _toggleRecipe(bool value) {
    setState(() {
      _hasRecipe = value;
      if (!value) {
        // Al deshabilitar, marcar todos los existentes para eliminación
        _ingredients.where((ing) => ing['isExisting'] == true).forEach((ing) {
          _markForDeletion(ing);
        });
        _ingredients.clear();
      } else if (_ingredients.isEmpty) {
        _addIngredient();
      }
    });
  }

  void _addIngredient() {
    if (!_hasRecipe) return;
    
    setState(() {
      _ingredients.add({
        'idIngredient': null,
        'name': '',
        'quantity': 0.0,
        'unit': '',
        'isExisting': false,
        'isMarkedForDeletion': false,
      });
    });
  }

  void _markForDeletion(Map<String, dynamic> ingredient) {
    if (widget.productId != 0 && ingredient['isExisting'] == true && ingredient['idIngredient'] != null) {
      final newId = ProductIngredientId(
        idProduct: widget.productId,
        idIngredient: ingredient['idIngredient'] as int,
      );
      if (!_deletedAssociations.any((id) => id.idIngredient == newId.idIngredient)) {
        _deletedAssociations.add(newId);
      }
    }
  }

  void _removeIngredient(int index) {
    final ingredient = _ingredients[index];
    
    _markForDeletion(ingredient);
    
    setState(() {
      _ingredients.removeAt(index);
      if (_ingredients.isEmpty && !widget.isEditing) {
        _hasRecipe = false;
      }
    });
  }

  Future<void> executeDeletions() async { 
    if (_deletedAssociations.isEmpty) return;
    
    final batchToDelete = List<ProductIngredientId>.from(_deletedAssociations);
    _deletedAssociations.clear(); 

    for (final id in batchToDelete) {
      try {
        await _productIngredientService.deleteAssociation(id);
      } catch (e) {
        print('Error eliminando asociación ${id.idIngredient}: $e');
      }
    }
  }

  void _updateIngredient(int index, String field, dynamic value) {
    setState(() {
      _ingredients[index][field] = value;
      
      if (field == 'idIngredient' && value != null) {
        final selected = _allIngredients.firstWhere(
          (ing) => ing.idIngredient == value,
          orElse: () => Ingredient(
            idIngredient: 0,
            name: '',
            code: '',
            quantity: 0.0,
            requiresRefrigeration: false,
            hasAllergens: false,
            state: true,
          ),
        );
        if (selected.idIngredient != 0) {
          _ingredients[index]['unit'] = selected.unit ?? '';
          _ingredients[index]['name'] = selected.name;
        }
      }
    });
  }

  bool _isIngredientUsed(int ingredientId, int currentIndex) {
    return _ingredients.asMap().entries.any(
      (entry) => entry.key != currentIndex && entry.value['idIngredient'] == ingredientId,
    );
  }

  bool validateRecipe() { 
    if (!_hasRecipe) return true; 
    
    if (_ingredients.isEmpty) {
      return false; 
    }
    
    for (final ingredient in _ingredients) {
      if (ingredient['idIngredient'] == null || (ingredient['quantity'] as double) <= 0) {
        return false;
      }
    }
    
    return true;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFf9f9f9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text(
            'Receta/Ingredientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFdc3545),
            ),
          ),
          const SizedBox(height: 16),

          // Checkbox de tiene receta
          CheckboxListTile(
            title: const Text(
              '¿Este producto tiene receta/insumos?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            value: _hasRecipe,
            onChanged: (value) => _toggleRecipe(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),

          if (_hasRecipe) ...[
            // Loading overlay
            if (_loadingRecipe || _loadingIngredients)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Lista de ingredientes
            ..._buildIngredientList(),

            // Mensaje si no hay ingredientes
            if (_ingredients.isEmpty && !_loadingRecipe && !_loadingIngredients)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'Añade los insumos necesarios para esta receta.',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
              ),

            // Mensajes de error
            if (!validateRecipe() && _hasRecipe) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8d7da),
                  border: Border.all(color: const Color(0xFFf5c6cb)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Debe agregar al menos un ingrediente válido a la receta (insumo seleccionado y cantidad > 0).',
                  style: TextStyle(color: Color(0xFF721c24), fontSize: 12),
                ),
              ),
            ],

            // Botón agregar ingrediente
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addIngredient,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF28a745),
              ),
              child: const Text('+ Añadir Insumo'),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildIngredientList() {
    return _ingredients.asMap().entries.map((entry) {
      final index = entry.key;
      final ingredient = entry.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Select de insumo
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Insumo *',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<int?>(
                    value: ingredient['idIngredient'],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      errorText: ingredient['idIngredient'] == null && _hasRecipe ? 'Requerido' : null,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('-- Selecciona un insumo --'),
                      ),
                      ..._allIngredients.map((ing) {
                        final isUsed = _isIngredientUsed(ing.idIngredient!, index);
                        return DropdownMenuItem(
                          value: ing.idIngredient,
                          enabled: !isUsed,
                          child: Opacity(
                            opacity: isUsed ? 0.5 : 1.0,
                            child: Text(
                              '${ing.name} (${ing.unit ?? "sin unidad"})',
                              style: TextStyle(
                                color: isUsed ? Colors.grey : null,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      if (value != null && !_isIngredientUsed(value, index)) {
                        _updateIngredient(index, 'idIngredient', value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Cantidad
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cantidad *',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    initialValue: (ingredient['quantity'] as double).toString(),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      errorText: (ingredient['quantity'] as double) <= 0 && _hasRecipe ? 'Debe ser > 0' : null,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final quantity = double.tryParse(value) ?? 0.0;
                      _updateIngredient(index, 'quantity', quantity);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Unidad (ReadOnly)
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unidad',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    initialValue: ingredient['unit'],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    readOnly: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Botón eliminar
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: IconButton(
                onPressed: () => _removeIngredient(index),
                icon: const Icon(Icons.delete, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Map<String, dynamic>> getRecipeData() {
    if (!_hasRecipe) return [];
    
    return _ingredients
        .where((ing) => ing['idIngredient'] != null && (ing['quantity'] as double) > 0)
        .map((ing) => ({
              'idIngredient': ing['idIngredient'],
              'quantity': ing['quantity'],
              'unit': ing['unit'] ?? 'unidad',
            }))
        .toList();
  }
}