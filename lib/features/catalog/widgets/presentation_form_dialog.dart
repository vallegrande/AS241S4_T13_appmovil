import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dropdown_button2/dropdown_button2.dart';
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

class _PresentationFormDialogState extends State<PresentationFormDialog>
    with SingleTickerProviderStateMixin {
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

  List<ProductIngredient> _productIngredients = [];
  List<Ingredient> _availableIngredients = [];
  bool _isLoadingIngredients = false;

  late TabController _tabController;
  String? _selectedCategoryName;

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);
  static const double _inputHeight = 56.0;
  File? _selectedImage;
  String? _existingImageUrl;
  String? _imageFileName;
  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final products = await ProductService.getAllWithInactive();

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

      if (widget.presentation != null) {
        _nameController.text = widget.presentation!.name;
        _descriptionController.text = widget.presentation!.description ?? '';
        _priceController.text = widget.presentation!.price.toString();
        _deliveryPriceController.text =
            widget.presentation!.deliveryPrice?.toString() ?? '';
        _takeoutPriceController.text =
            widget.presentation!.takeoutPrice?.toString() ?? '';
        _promoPriceController.text =
            widget.presentation!.promoPrice?.toString() ?? '';
        _preparationTimeController.text =
            widget.presentation!.preparationTime?.toString() ?? '';
        _state = widget.presentation!.state;

        // ✅ NUEVO: Cargar imagen existente
        if (widget.presentation!.dishPhotoUrl != null &&
            widget.presentation!.dishPhotoUrl!.isNotEmpty) {
          setState(() {
            _existingImageUrl = PresentationService.getPhotoUrl(
                widget.presentation!.dishPhotoUrl);
          });
        }

        final presentationId = widget.presentation!.idPresentation;

        if (presentationId != null && _products.isNotEmpty) {
          for (var product in _products) {
            if (product.presentations != null &&
                product.presentations!.isNotEmpty) {
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

                if (product.idProduct != null) {
                  await _loadProductIngredients(product.idProduct!);

                  final prodCategoryName =
                      product.category?['name'] ?? 'Sin categoría';
                  setState(() {
                    _selectedCategoryName = prodCategoryName;
                  });
                }
                break;
              }
            }
          }

          if (_selectedProduct == null && mounted) {
            _showSnackBar(
              'No se pudo encontrar el producto de esta presentación',
              Colors.orange.shade600,
              Icons.warning_rounded,
            );
          }
        }
      }

      if (_products.isEmpty && mounted) {
        _showSnackBar(
          'No hay productos disponibles. Registre uno primero.',
          Colors.orange.shade600,
          Icons.warning_rounded,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      _showSnackBar('Error al cargar datos: $e', Colors.red.shade600,
          Icons.error_rounded);
    }
  }

  Future<void> _loadProductIngredients(int productId) async {
    setState(() => _isLoadingIngredients = true);
    try {
      final ingredients =
          await ProductIngredientService.getIngredientsByProduct(productId);
      if (!mounted) return;
      setState(() {
        _productIngredients = ingredients;
        _isLoadingIngredients = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingIngredients = false);
      _showSnackBar('Error al cargar ingredientes: $e', Colors.red.shade600,
          Icons.error_rounded);
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
      _showSnackBar('Debe seleccionar un producto', Colors.orange.shade600,
          Icons.warning_rounded);
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

      // Crear o actualizar la presentación
      Presentation savedPresentation;
      if (widget.presentation == null) {
        savedPresentation = await PresentationService.create(presentation);
      } else {
        savedPresentation = await PresentationService.update(
            widget.presentation!.idPresentation!, presentation);
      }

      // ✅ MODIFICADO: Subir la imagen (funciona para web y móvil)
      if (savedPresentation.idPresentation != null) {
        if (kIsWeb && _webImage != null) {
          // Para Web: usar bytes directamente
          try {
            await PresentationService.uploadPhotoBytes(
              savedPresentation.idPresentation!,
              _webImage!,
              _imageFileName ?? 'image.jpg',
            );
          } catch (e) {
            if (mounted) {
              _showSnackBar(
                'Presentación guardada, pero hubo un error al subir la imagen: $e',
                Colors.orange.shade600,
                Icons.warning_rounded,
              );
            }
          }
        } else if (_selectedImage != null) {
          // Para móvil/desktop: usar File directamente
          try {
            await PresentationService.uploadPhoto(
              savedPresentation.idPresentation!,
              _selectedImage!,
            );
          } catch (e) {
            if (mounted) {
              _showSnackBar(
                'Presentación guardada, pero hubo un error al subir la imagen: $e',
                Colors.orange.shade600,
                Icons.warning_rounded,
              );
            }
          }
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSaved();
        });

        _showSnackBar(
          widget.presentation == null
              ? 'Presentación creada exitosamente'
              : 'Presentación actualizada exitosamente',
          Colors.green.shade600,
          Icons.check_circle_rounded,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Error: $e', Colors.red.shade600, Icons.error_rounded);
      }
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  void _showAddIngredientDialog() {
    if (_selectedProduct == null) {
      _showSnackBar('Seleccione un producto primero', Colors.orange.shade600,
          Icons.warning_rounded);
      return;
    }

    Ingredient? selectedIngredient;
    final quantityController = TextEditingController();
    final unitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.add_circle_rounded,
                    color: primaryOrange, size: 24),
              ),
              const SizedBox(width: 16),
              // FIX del desbordamiento anterior
              Expanded(
                child: Text(
                  'Añadir Ingrediente',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Ingredient>(
                  value: selectedIngredient,
                  decoration: InputDecoration(
                    labelText: 'Ingrediente *',
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                    prefixIcon: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.restaurant_rounded,
                          color: primaryOrange, size: 18),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.shade200, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.shade200, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryOrange, width: 2),
                    ),
                  ),
                  items: _availableIngredients.map((ingredient) {
                    final isAlreadyAdded = _productIngredients.any(
                        (pi) => pi.id.idIngredient == ingredient.idIngredient);
                    return DropdownMenuItem(
                      value: ingredient,
                      enabled: !isAlreadyAdded,
                      child: Text(
                        ingredient.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isAlreadyAdded
                              ? Colors.grey.shade400
                              : const Color(0xFF1A1A2E),
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
                TextFormField(
                  controller: quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A2E),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Cantidad *',
                    hintText: '0.0',
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.inventory_2_rounded,
                          color: primaryOrange, size: 18),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.shade200, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.shade200, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryOrange, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: unitController,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A2E),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Unidad *',
                    hintText: 'kg, unidad, litro, etc.',
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.straighten_rounded,
                          color: primaryOrange, size: 18),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.shade200, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.shade200, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryOrange, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actionsPadding:
              const EdgeInsets.only(right: 16, bottom: 16, left: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    fontSize: 15),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                if (selectedIngredient == null) {
                  _showSnackBar('Seleccione un ingrediente',
                      Colors.orange.shade600, Icons.warning_rounded);
                  return;
                }

                final quantity = double.tryParse(quantityController.text);
                if (quantity == null || quantity <= 0) {
                  _showSnackBar('Ingrese una cantidad válida',
                      Colors.orange.shade600, Icons.warning_rounded);
                  return;
                }

                if (unitController.text.trim().isEmpty) {
                  _showSnackBar('Ingrese una unidad', Colors.orange.shade600,
                      Icons.warning_rounded);
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
                    _showSnackBar('Ingrediente añadido correctamente',
                        Colors.green.shade600, Icons.check_circle_rounded);
                  }
                } catch (e) {
                  if (mounted) {
                    _showSnackBar('Error al añadir ingrediente: $e',
                        Colors.red.shade600, Icons.error_rounded);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Añadir',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ],
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fade(),
      ),
    );
  }

  void _showEditIngredientDialog(ProductIngredient pi) {
    final quantityController =
        TextEditingController(text: pi.quantity.toString());
    final unitController = TextEditingController(text: pi.unit ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.edit_rounded, color: primaryOrange, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Editar ${_getIngredientName(pi)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: quantityController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A2E),
              ),
              decoration: InputDecoration(
                labelText: 'Cantidad *',
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
                prefixIcon: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.inventory_2_rounded,
                      color: primaryOrange, size: 18),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryOrange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: unitController,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A2E),
              ),
              decoration: InputDecoration(
                labelText: 'Unidad *',
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
                prefixIcon: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.straighten_rounded,
                      color: primaryOrange, size: 18),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryOrange, width: 2),
                ),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text);
              if (quantity == null || quantity <= 0) {
                _showSnackBar('Ingrese una cantidad válida',
                    Colors.orange.shade600, Icons.warning_rounded);
                return;
              }

              if (unitController.text.trim().isEmpty) {
                _showSnackBar('Ingrese una unidad', Colors.orange.shade600,
                    Icons.warning_rounded);
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
                  _showSnackBar('Ingrediente actualizado correctamente',
                      Colors.green.shade600, Icons.check_circle_rounded);
                }
              } catch (e) {
                if (mounted) {
                  _showSnackBar('Error al actualizar: $e', Colors.red.shade600,
                      Icons.error_rounded);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Actualizar',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fade(),
    );
  }

  Future<void> _deleteIngredient(ProductIngredient pi) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_rounded,
                  color: Colors.red.shade600, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Confirmar eliminación',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Está seguro de eliminar "${_getIngredientName(pi)}" del producto?',
          style: GoogleFonts.inter(
              fontSize: 15, color: Colors.grey.shade700, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Eliminar',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fade(),
    );

    if (confirmed == true) {
      try {
        await ProductIngredientService.delete(
          pi.id.idProduct,
          pi.id.idIngredient,
        );

        if (mounted) {
          await _loadProductIngredients(_selectedProduct!.idProduct!);
          _showSnackBar('Ingrediente eliminado correctamente',
              Colors.green.shade600, Icons.check_circle_rounded);
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Error al eliminar: $e', Colors.red.shade600,
              Icons.error_rounded);
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        // Para Flutter Web: leer como bytes
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFileName = image.name;
          _selectedImage = null; // Limpiar la imagen de archivo
        });
      } else {
        // Para móvil/desktop: usar File
        setState(() {
          _selectedImage = File(image.path);
          _webImage = null; // Limpiar los bytes web
          _imageFileName = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        // ⭐ FIX 1: Aumento del tamaño del modal (de 700 a 800)
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 750),
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
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryOrange.withOpacity(0.2),
                                primaryOrange.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryOrange.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.style_rounded,
                              color: primaryOrange, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.presentation == null
                                    ? 'Nueva Presentación'
                                    : 'Editar Presentación',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A2E),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Complete la información requerida',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: Colors.grey.shade600),
                          onPressed: () => Navigator.pop(context),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.2, end: 0),

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
                      indicatorColor: primaryOrange,
                      labelColor: primaryOrange,
                      unselectedLabelColor: Colors.grey.shade600,
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, size: 18),
                              // ⭐ FIX 2: Reducción de espaciado para evitar overflow
                              const SizedBox(width: 4),
                              Text('Información'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.kitchen, size: 18),
                              // ⭐ FIX 2: Reducción de espaciado para evitar overflow
                              const SizedBox(width: 4),
                              Text('Ingredientes'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline, size: 18),
                              // ⭐ FIX 2: Reducción de espaciado para evitar overflow
                              const SizedBox(width: 4),
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
                        top: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                  color: Colors.grey.shade300, width: 1.5),
                            ),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _savePresentation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              shadowColor: primaryOrange.withOpacity(0.3),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_rounded, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.presentation == null
                                            ? 'Crear Presentación'
                                            : 'Actualizar',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: primaryOrange,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: _inputHeight,
          child: TextFormField(
            controller: controller,
            maxLines: 1,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A2E),
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              prefixIcon: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryOrange, size: 18),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 56, minHeight: 56),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryOrange, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
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
            _buildSectionTitle('Información Básica'),
            SizedBox(
              height: _inputHeight,
              child: DropdownButtonFormField2<Product>(
                value: _selectedProduct,
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Selecciona un producto',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.fastfood_rounded,
                        color: primaryOrange, size: 18),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 56, minHeight: 56),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade200, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade200, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                ),
                items: _products.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text(
                      product.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
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
                buttonStyleData: ButtonStyleData(
                  height: _inputHeight,
                  padding: const EdgeInsets.only(right: 12),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 300,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  offset: const Offset(0, -4),
                ),
                menuItemStyleData: MenuItemStyleData(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                iconStyleData: IconStyleData(
                  icon: const Icon(Icons.expand_more_rounded),
                  iconSize: 22,
                  iconEnabledColor: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameController,
              label: 'Nombre',
              hint: 'Ej: Personal, Familiar, 1/4 de pollo',
              icon: Icons.label_rounded,
              required: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              label: 'Descripción',
              hint: 'Descripción de la presentación',
              icon: Icons.description_rounded,
            ),
            const SizedBox(height: 20),

// REEMPLAZA ESTE BLOQUE COMPLETO en _buildInformationTab():
// Desde "// ---------------- IMAGEN DE LA PRESENTACIÓN ----------------"
// Hasta "// --------------------------------------------------------------"

// ---------------- IMAGEN DE LA PRESENTACIÓN ----------------
            _buildSectionTitle('Imagen de la Presentación'),

            const SizedBox(height: 10),

            Stack(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey.shade100,
                    ),
                    child: kIsWeb && _webImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _webImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : !kIsWeb && _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _existingImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _existingImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.broken_image_rounded,
                                                  size: 45,
                                                  color: Colors.grey.shade400),
                                              const SizedBox(height: 6),
                                              Text(
                                                "Error al cargar imagen",
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            color: primaryOrange,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_rounded,
                                            size: 45,
                                            color:
                                                primaryOrange.withOpacity(0.6)),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Seleccionar Imagen",
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Toca para elegir una foto",
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                  ),
                ),

                // Botón para eliminar imagen (actualizado para incluir _webImage)
                if (_selectedImage != null ||
                    _webImage != null ||
                    _existingImageUrl != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                            _webImage = null;
                            _imageFileName = null;
                            _existingImageUrl = null;
                          });
                          _showSnackBar(
                            'Imagen eliminada',
                            Colors.green.shade600,
                            Icons.check_circle_rounded,
                          );
                        },
                        tooltip: 'Eliminar imagen',
                        padding: const EdgeInsets.all(8),
                        constraints:
                            const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Precios'),
            _buildTextField(
              controller: _priceController,
              label: 'Precio Base',
              hint: '0.00',
              icon: Icons.attach_money_rounded,
              required: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
                  child: _buildTextField(
                    controller: _deliveryPriceController,
                    label: 'Delivery',
                    hint: '0.00',
                    icon: Icons.delivery_dining_rounded,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _takeoutPriceController,
                    label: 'Para Llevar',
                    hint: '0.00',
                    icon: Icons.shopping_bag_rounded,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
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
                  child: _buildTextField(
                    controller: _promoPriceController,
                    label: 'Promoción',
                    hint: '0.00',
                    icon: Icons.local_offer_rounded,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _preparationTimeController,
                    label: 'Tiempo (min)',
                    hint: '0',
                    icon: Icons.timer_rounded,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          int.tryParse(value) == null) {
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _state
                          ? primaryOrange.withOpacity(0.1)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.toggle_on_rounded,
                      color: _state ? primaryOrange : Colors.grey.shade500,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado de la Presentación',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          _state ? 'Activa' : 'Inactiva',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _state,
                    onChanged: (value) => setState(() => _state = value),
                    activeColor: primaryOrange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsTab() {
    if (_selectedProduct == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade50, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.kitchen_outlined,
                    size: 64, color: Colors.grey.shade300),
              ),
              const SizedBox(height: 24),
              Text(
                'Seleccione un producto',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vaya a la pestaña "Información" para\nseleccionar un producto',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(duration: 400.ms, curve: Curves.easeOutBack);
    }

    if (_isLoadingIngredients) {
      return Center(
          child:
              CircularProgressIndicator(color: primaryOrange, strokeWidth: 3));
    }

    if (_productIngredients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade50, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.kitchen_outlined,
                    size: 64, color: Colors.grey.shade300),
              ),
              const SizedBox(height: 24),
              Text(
                'Sin ingredientes',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Este producto no tiene ingredientes.\nAgréguelos en la pestaña "Gestionar"',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(duration: 400.ms, curve: Curves.easeOutBack);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _productIngredients.length,
      itemBuilder: (context, index) {
        final pi = _productIngredients[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryOrange.withOpacity(0.2),
                    primaryOrange.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.restaurant_rounded,
                  color: primaryOrange, size: 24),
            ),
            title: Text(
              _getIngredientName(pi),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            subtitle: Text(
              '${pi.quantity} ${pi.unit ?? ''}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: Colors.green.shade600, size: 20),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildManageIngredientsTab() {
    if (_selectedProduct == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade50, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.kitchen_outlined,
                    size: 64, color: Colors.grey.shade300),
              ),
              const SizedBox(height: 24),
              Text(
                'Seleccione un producto',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vaya a la pestaña "Información" para\nseleccionar un producto',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(duration: 400.ms, curve: Curves.easeOutBack);
    }

    if (_isLoadingIngredients) {
      return Center(
          child:
              CircularProgressIndicator(color: primaryOrange, strokeWidth: 3));
    }

    return Column(
      children: [
        // Botón añadir
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: ElevatedButton.icon(
            onPressed: _showAddIngredientDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              'Añadir Ingrediente',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: primaryOrange.withOpacity(0.3),
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
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey.shade50, Colors.grey.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.kitchen_outlined,
                            size: 64, color: Colors.grey.shade300),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Sin ingredientes',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Presione el botón de arriba para\nañadir ingredientes',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(duration: 400.ms, curve: Curves.easeOutBack)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _productIngredients.length,
                  itemBuilder: (context, index) {
                    final pi = _productIngredients[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.grey.shade100, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryOrange.withOpacity(0.2),
                                primaryOrange.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.restaurant_rounded,
                              color: primaryOrange, size: 24),
                        ),
                        title: Text(
                          _getIngredientName(pi),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        subtitle: Text(
                          '${pi.quantity} ${pi.unit ?? ''}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: primaryOrange.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.edit_rounded,
                                    color: primaryOrange, size: 20),
                                onPressed: () => _showEditIngredientDialog(pi),
                                tooltip: 'Editar',
                                // FIX del 0.199px overflow anterior
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 40, minHeight: 40),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.delete_rounded,
                                    color: Colors.red.shade600, size: 20),
                                onPressed: () => _deleteIngredient(pi),
                                tooltip: 'Eliminar',
                                // FIX del 0.199px overflow anterior
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 40, minHeight: 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                ),
        ),
      ],
    );
  }
}
