import 'package:flutter/material.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/ingredient.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/ingredient_service.dart';
import 'package:intl/intl.dart';

class IngredientFormDialog extends StatefulWidget {
  final Ingredient? ingredient;
  final VoidCallback onSaved;

  const IngredientFormDialog({
    super.key,
    this.ingredient,
    required this.onSaved,
  });

  @override
  State<IngredientFormDialog> createState() => _IngredientFormDialogState();
}

class _IngredientFormDialogState extends State<IngredientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();
  final _locationController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _supplierController = TextEditingController();
  final _lotNumberController = TextEditingController();
  final _recommendedTempController = TextEditingController();
  final _allergenTypeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  DateTime? _lastPurchaseDate;
  DateTime? _expirationDate;
  DateTime? _productionDate;
  
  bool _requiresRefrigeration = false;
  bool _hasAllergens = false;
  bool _state = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.ingredient != null) {
      _loadIngredientData();
    }
  }

  void _loadIngredientData() {
    final ing = widget.ingredient!;
    _nameController.text = ing.name;
    _codeController.text = ing.code;
    _categoryController.text = ing.category ?? '';
    _descriptionController.text = ing.description ?? '';
    _unitController.text = ing.unit ?? '';
    _quantityController.text = ing.quantity?.toString() ?? '';
    _minStockController.text = ing.minStock?.toString() ?? '';
    _maxStockController.text = ing.maxStock?.toString() ?? '';
    _locationController.text = ing.location ?? '';
    _unitPriceController.text = ing.unitPrice?.toString() ?? '';
    _totalCostController.text = ing.totalCost?.toString() ?? '';
    _supplierController.text = ing.supplier ?? '';
    _lotNumberController.text = ing.lotNumber ?? '';
    _recommendedTempController.text = ing.recommendedTemperature ?? '';
    _allergenTypeController.text = ing.allergenType ?? '';
    _imageUrlController.text = ing.imageUrl ?? '';
    
    _requiresRefrigeration = ing.requiresRefrigeration ?? false;
    _hasAllergens = ing.hasAllergens ?? false;
    _state = ing.state;

    if (ing.lastPurchaseDate != null) {
      _lastPurchaseDate = DateTime.tryParse(ing.lastPurchaseDate!);
    }
    if (ing.expirationDate != null) {
      _expirationDate = DateTime.tryParse(ing.expirationDate!);
    }
    if (ing.productionDate != null) {
      _productionDate = DateTime.tryParse(ing.productionDate!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _locationController.dispose();
    _unitPriceController.dispose();
    _totalCostController.dispose();
    _supplierController.dispose();
    _lotNumberController.dispose();
    _recommendedTempController.dispose();
    _allergenTypeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _calculateTotalCost() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    final total = quantity * unitPrice;
    setState(() {
      _totalCostController.text = total.toStringAsFixed(2);
    });
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    DateTime? currentDate;
    if (field == 'purchase') currentDate = _lastPurchaseDate;
    if (field == 'expiration') currentDate = _expirationDate;
    if (field == 'production') currentDate = _productionDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        if (field == 'purchase') _lastPurchaseDate = picked;
        if (field == 'expiration') _expirationDate = picked;
        if (field == 'production') _productionDate = picked;
      });
    }
  }

  Future<void> _saveIngredient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final ingredient = Ingredient(
      idIngredient: widget.ingredient?.idIngredient,
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
      quantity: _quantityController.text.isEmpty ? null : double.tryParse(_quantityController.text),
      minStock: _minStockController.text.isEmpty ? null : double.tryParse(_minStockController.text),
      maxStock: _maxStockController.text.isEmpty ? null : double.tryParse(_maxStockController.text),
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      unitPrice: _unitPriceController.text.isEmpty ? null : double.tryParse(_unitPriceController.text),
      totalCost: _totalCostController.text.isEmpty ? null : double.tryParse(_totalCostController.text),
      supplier: _supplierController.text.trim().isEmpty ? null : _supplierController.text.trim(),
      lastPurchaseDate: _lastPurchaseDate?.toIso8601String().split('T').first,
      expirationDate: _expirationDate?.toIso8601String().split('T').first,
      productionDate: _productionDate?.toIso8601String().split('T').first,
      lotNumber: _lotNumberController.text.trim().isEmpty ? null : _lotNumberController.text.trim(),
      requiresRefrigeration: _requiresRefrigeration,
      recommendedTemperature: _recommendedTempController.text.trim().isEmpty ? null : _recommendedTempController.text.trim(),
      hasAllergens: _hasAllergens,
      allergenType: _allergenTypeController.text.trim().isEmpty ? null : _allergenTypeController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      state: _state,
    );

    try {
      if (widget.ingredient == null) {
        await IngredientService.create(ingredient);
      } else {
        await IngredientService.update(widget.ingredient!.idIngredient!, ingredient);
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
          SnackBar(content: Text('Error al guardar ingrediente: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
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
                    child: const Icon(Icons.kitchen, color: Color(0xFFFF1100), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ingredient == null ? 'Nuevo Ingrediente' : 'Editar Ingrediente',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const Text('Complete la información', style: TextStyle(fontSize: 14, color: Color(0xFF718096))),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información Básica
                      _buildSectionTitle('Información Básica'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder()),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _codeController,
                              decoration: const InputDecoration(labelText: 'Código *', border: OutlineInputBorder()),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),

                      // Inventario
                      _buildSectionTitle('Inventario'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _unitController,
                              decoration: const InputDecoration(labelText: 'Unidad', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
                              onChanged: (_) => _calculateTotalCost(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minStockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Stock Mínimo', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _maxStockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Stock Máximo', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(labelText: 'Ubicación', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),

                      // Costos
                      _buildSectionTitle('Costos'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _unitPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Precio Unitario', border: OutlineInputBorder()),
                              onChanged: (_) => _calculateTotalCost(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _totalCostController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Costo Total', border: OutlineInputBorder()),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _supplierController,
                        decoration: const InputDecoration(labelText: 'Proveedor', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),

                      // Fechas
                      _buildSectionTitle('Fechas'),
                      _buildDateField('Última Compra', _lastPurchaseDate, 'purchase'),
                      const SizedBox(height: 12),
                      _buildDateField('Fecha de Producción', _productionDate, 'production'),
                      const SizedBox(height: 12),
                      _buildDateField('Fecha de Vencimiento', _expirationDate, 'expiration'),
                      const SizedBox(height: 20),

                      // Detalles Adicionales
                      _buildSectionTitle('Detalles Adicionales'),
                      TextFormField(
                        controller: _lotNumberController,
                        decoration: const InputDecoration(labelText: 'Número de Lote', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _recommendedTempController,
                        decoration: const InputDecoration(labelText: 'Temperatura Recomendada', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _allergenTypeController,
                        decoration: const InputDecoration(labelText: 'Tipo de Alérgeno', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(labelText: 'URL de Imagen', border: OutlineInputBorder()),
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
                              title: const Text('Requiere Refrigeración'),
                              value: _requiresRefrigeration,
                              onChanged: (v) => setState(() => _requiresRefrigeration = v),
                              activeColor: const Color(0xFFFF1100),
                              contentPadding: EdgeInsets.zero,
                            ),
                            SwitchListTile(
                              title: const Text('Contiene Alérgenos'),
                              value: _hasAllergens,
                              onChanged: (v) => setState(() => _hasAllergens = v),
                              activeColor: const Color(0xFFFF1100),
                              contentPadding: EdgeInsets.zero,
                            ),
                            SwitchListTile(
                              title: const Text('Estado'),
                              subtitle: Text(_state ? 'Activo' : 'Inactivo'),
                              value: _state,
                              onChanged: (v) => setState(() => _state = v),
                              activeColor: const Color(0xFFFF1100),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveIngredient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF1100),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                          : Text(widget.ingredient == null ? 'Crear' : 'Actualizar'),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, String field) {
    return InkWell(
      onTap: () => _selectDate(context, field),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(date == null ? 'Seleccionar fecha' : DateFormat('dd/MM/yyyy').format(date)),
      ),
    );
  }
}