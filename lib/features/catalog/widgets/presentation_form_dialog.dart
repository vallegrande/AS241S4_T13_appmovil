import 'package:flutter/material.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/presentation.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/product.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/ingredient.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/product_ingredient.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/presentation_service.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/product_service.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/ingredient_service.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/product_ingredient_service.dart';

class PresentationFormDialog extends StatefulWidget {
  final Presentation? presentation;
  final VoidCallback onSaved;

  const PresentationFormDialog({
    super.key,
    this.presentation,
    required this.onSaved,
  });

  @override
  State<PresentationFormDialog> createState() => _PresentationFormDialogState();
}

class _PresentationFormDialogState extends State<PresentationFormDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _deliveryPriceController = TextEditingController();
  final _takeoutPriceController = TextEditingController();
  final _promoPriceController = TextEditingController();
  final _preparationTimeController = TextEditingController();

  
  bool _state = true;
  bool _isLoading = false;
  bool _isLoadingData = true;
  
  List<Product> _products = [];
  Product? _selectedProduct;
  
  // Para gestionar ingredientes del producto
  List<ProductIngredient> _productIngredients = [];
  List<Ingredient> _availableIngredients = [];
  bool _isLoadingIngredients = false;

  late TabController _tabController;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // 🔥 Carga los productos con sus presentaciones usando /all
      final products = await ProductService.getAllWithInactive();

      // Intenta cargar ingredientes
      List<Ingredient> ingredients = [];
      try {
        ingredients = await IngredientService.getAll();
      } catch (_) {
        ingredients = [];
      }

      if (!mounted) return;
      setState(() {
        _products = products;
        _availableIngredients = ingredients;
        _isLoadingData = false;
      });

      // Si se está editando una presentación
      if (widget.presentation != null) {
        _nameController.text = widget.presentation!.name;
        _descriptionController.text = widget.presentation!.description ?? '';
        _priceController.text = widget.presentation!.price.toString();
        _deliveryPriceController.text = widget.presentation!.deliveryPrice?.toString() ?? '';
        _takeoutPriceController.text = widget.presentation!.takeoutPrice?.toString() ?? '';
        _promoPriceController.text = widget.presentation!.promoPrice?.toString() ?? '';
        _preparationTimeController.text = widget.presentation!.preparationTime?.toString() ?? '';
        _state = widget.presentation!.state;

        // 🔥 BUSCAR el producto que contiene esta presentación
        final presentationId = widget.presentation!.idPresentation;
        
        if (presentationId != null && _products.isNotEmpty) {
          // Buscar en qué producto está esta presentación
          for (var product in _products) {
            if (product.presentations != null && product.presentations!.isNotEmpty) {
              // Buscar si alguna presentación coincide con el ID
              final found = product.presentations!.any((p) {
                if (p is Map<String, dynamic>) {
                  return p['idPresentation'] == presentationId;
                }
                return false;
              });
              
              if (found) {
                setState(() {
                  _selectedProduct = product;
                });
                
                // Cargar ingredientes del producto encontrado
                if (product.idProduct != null) {
                  await _loadProductIngredients(product.idProduct!);
                  
                  final prodCategoryName = product.category?['name'] ?? 'Sin categoría';
                  setState(() {
                    _selectedCategoryName = prodCategoryName;
                  });
                }
                break; // Salir del loop cuando encontremos el producto
              }
            }
          }

          // Si no se encontró el producto, mostrar advertencia
          if (_selectedProduct == null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo encontrar el producto de esta presentación'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      // Si no hay productos, muestra advertencia
      if (_products.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay productos disponibles. Registre uno primero.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  Future<void> _loadProductIngredients(int productId) async {
    setState(() => _isLoadingIngredients = true);
    try {
      final ingredients = await ProductIngredientService.getIngredientsByProduct(productId);
      if (!mounted) return;
      setState(() {
        _productIngredients = ingredients;
        _isLoadingIngredients = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingIngredients = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ingredientes: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _deliveryPriceController.dispose();
    _takeoutPriceController.dispose();
    _promoPriceController.dispose();
    _preparationTimeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _savePresentation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un producto')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final presentation = Presentation(
        idPresentation: widget.presentation?.idPresentation,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        deliveryPrice: _deliveryPriceController.text.isEmpty 
            ? null 
            : double.tryParse(_deliveryPriceController.text),
        takeoutPrice: _takeoutPriceController.text.isEmpty 
            ? null 
            : double.tryParse(_takeoutPriceController.text),
        promoPrice: _promoPriceController.text.isEmpty 
            ? null 
            : double.tryParse(_promoPriceController.text),
        preparationTime: _preparationTimeController.text.isEmpty 
            ? null 
            : int.tryParse(_preparationTimeController.text),
        state: _state,
        product: {'idProduct': _selectedProduct!.idProduct},
      );

      if (widget.presentation == null) {
        await PresentationService.create(presentation);
      } else {
        await PresentationService.update(widget.presentation!.idPresentation!, presentation);
      }

      if (mounted) {
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSaved();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.presentation == null ? 'Presentación creada' : 'Presentación actualizada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddIngredientDialog() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un producto primero')),
      );
      return;
    }

    Ingredient? selectedIngredient;
    final quantityController = TextEditingController();
    final unitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Añadir Ingrediente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Ingredient>(
                  value: selectedIngredient,
                  decoration: const InputDecoration(
                    labelText: 'Ingrediente *',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableIngredients.map((ingredient) {
                    final isAlreadyAdded = _productIngredients.any(
                      (pi) => pi.id.idIngredient == ingredient.idIngredient
                    );
                    return DropdownMenuItem(
                      value: ingredient,
                      enabled: !isAlreadyAdded,
                      child: Text(
                        ingredient.name,
                        style: TextStyle(
                          color: isAlreadyAdded ? Colors.grey : null,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedIngredient = value;
                      if (value != null && value.unit != null) {
                        unitController.text = value.unit!;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Cantidad *',
                    border: OutlineInputBorder(),
                    hintText: '0.0',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unidad *',
                    border: OutlineInputBorder(),
                    hintText: 'kg, unidad, litro, etc.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedIngredient == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seleccione un ingrediente')),
                  );
                  return;
                }
                
                final quantity = double.tryParse(quantityController.text);
                if (quantity == null || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese una cantidad válida')),
                  );
                  return;
                }

                if (unitController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese una unidad')),
                  );
                  return;
                }

                try {
                  final productIngredient = ProductIngredient(
                    id: ProductIngredientId(
                      idProduct: _selectedProduct!.idProduct!,
                      idIngredient: selectedIngredient!.idIngredient!,
                    ),
                    quantity: quantity,
                    unit: unitController.text.trim(),
                  );

                  await ProductIngredientService.create(productIngredient);
                  
                  if (mounted) {
                    Navigator.pop(context);
                    await _loadProductIngredients(_selectedProduct!.idProduct!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingrediente añadido correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al añadir ingrediente: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF1100),
                foregroundColor: Colors.white,
              ),
              child: const Text('Añadir'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditIngredientDialog(ProductIngredient pi) {
    final quantityController = TextEditingController(text: pi.quantity.toString());
    final unitController = TextEditingController(text: pi.unit ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${_getIngredientName(pi)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cantidad *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: 'Unidad *',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text);
              if (quantity == null || quantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrese una cantidad válida')),
                );
                return;
              }

              if (unitController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrese una unidad')),
                );
                return;
              }

              try {
                await ProductIngredientService.delete(
                  pi.id.idProduct,
                  pi.id.idIngredient,
                );

                final updatedPI = ProductIngredient(
                  id: pi.id,
                  quantity: quantity,
                  unit: unitController.text.trim(),
                );

                await ProductIngredientService.create(updatedPI);
                
                if (mounted) {
                  Navigator.pop(context);
                  await _loadProductIngredients(_selectedProduct!.idProduct!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ingrediente actualizado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1100),
              foregroundColor: Colors.white,
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteIngredient(ProductIngredient pi) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar "${_getIngredientName(pi)}" del producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ProductIngredientService.delete(
          pi.id.idProduct,
          pi.id.idIngredient,
        );
        
        if (mounted) {
          await _loadProductIngredients(_selectedProduct!.idProduct!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ingrediente eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  String _getIngredientName(ProductIngredient pi) {
    if (pi.ingredient != null && pi.ingredient!['name'] != null) {
      return pi.ingredient!['name'].toString();
    }
    return 'Ingrediente ID: ${pi.id.idIngredient}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 750),
        child: _isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF1100).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.style,
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
                                widget.presentation == null ? 'Nueva Presentación' : 'Editar Presentación',
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
                  ),

                  // TabBar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xFFFF1100),
                      labelColor: const Color(0xFFFF1100),
                      unselectedLabelColor: const Color(0xFF718096),
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, size: 18),
                              SizedBox(width: 8),
                              Text('Información'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.kitchen, size: 18),
                              SizedBox(width: 8),
                              Text('Ingredientes'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline, size: 18),
                              SizedBox(width: 8),
                              Text('Gestionar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TabBarView
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildInformationTab(),
                        _buildIngredientsTab(),
                        _buildManageIngredientsTab(),
                      ],
                    ),
                  ),

                  // Botones de acción
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
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
                            onPressed: _isLoading ? null : _savePresentation,
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
                                : Text(widget.presentation == null ? 'Crear' : 'Actualizar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInformationTab() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<Product>(
              value: _selectedProduct,
              isDense: true,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Producto *',
                prefixIcon: const Icon(Icons.fastfood, color: Color(0xFFFF1100)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _products.map((product) {
                return DropdownMenuItem(
                  value: product,
                  child: Text(product.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedProduct = value);
                if (value != null && value.idProduct != null) {
                  _loadProductIngredients(value.idProduct!);
                }
              },
              validator: (value) {
                if (value == null) return 'Debe seleccionar un producto';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre *',
                hintText: 'Ej: Personal, Familiar, 1/4 de pollo',
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

            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Descripción de la presentación',
                prefixIcon: const Icon(Icons.description, color: Color(0xFFFF1100)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Precios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Precio Base *',
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFFF1100)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El precio es obligatorio';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un precio válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _deliveryPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Delivery',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.delivery_dining, color: Color(0xFFFF1100)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _takeoutPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Para Llevar',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.shopping_bag, color: Color(0xFFFF1100)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _promoPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Promoción',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.local_offer, color: Colors.orange),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _preparationTimeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Tiempo (min)',
                      hintText: '0',
                      prefixIcon: const Icon(Icons.timer, color: Color(0xFFFF1100)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                        return 'Tiempo inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Estado
            Row(
              children: [
                const Icon(Icons.toggle_on, color: Color(0xFFFF1100)),
                const SizedBox(width: 12),
                const Text(
                  'Estado',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Switch(
                  value: _state,
                  onChanged: (value) => setState(() => _state = value),
                  activeColor: const Color(0xFFFF1100),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsTab() {
    if (_selectedProduct == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Seleccione un producto en la pestaña "Información" para ver sus ingredientes',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF718096)),
          ),
        ),
      );
    }

    if (_isLoadingIngredients) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_productIngredients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.kitchen_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay ingredientes registrados',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Añade ingredientes en la pestaña "Gestionar"',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _productIngredients.length,
      itemBuilder: (context, index) {
        final pi = _productIngredients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFF1100).withOpacity(0.1),
              child: const Icon(Icons.restaurant, color: Color(0xFFFF1100)),
            ),
            title: Text(
              _getIngredientName(pi),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text('${pi.quantity} ${pi.unit ?? ''}'),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
    );
  }

  Widget _buildManageIngredientsTab() {
    if (_selectedProduct == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Seleccione un producto en la pestaña "Información" para gestionar ingredientes',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF718096)),
          ),
        ),
      );
    }

    if (_isLoadingIngredients) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Botón añadir
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showAddIngredientDialog,
            icon: const Icon(Icons.add),
            label: const Text('Añadir Ingrediente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1100),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Lista de ingredientes
        Expanded(
          child: _productIngredients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.kitchen_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay ingredientes',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _productIngredients.length,
                  itemBuilder: (context, index) {
                    final pi = _productIngredients[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFF1100).withOpacity(0.1),
                          child: const Icon(Icons.restaurant, color: Color(0xFFFF1100)),
                        ),
                        title: Text(
                          _getIngredientName(pi),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text('${pi.quantity} ${pi.unit ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFFFF1100)),
                              onPressed: () => _showEditIngredientDialog(pi),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteIngredient(pi),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}