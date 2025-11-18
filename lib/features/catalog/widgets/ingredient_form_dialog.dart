import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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

  final Color primaryOrange = const Color(0xFFFF6B35);

  static const double _inputHeight = 56.0;

  final List<String> _categories = [
    'Carnes',
    'Pollos',
    'Vegetales',
    'Lácteos',
    'Granos',
    'Condimentos',
    'Bebidas'
  ];
  final List<String> _units = [
    'kg',
    'g',
    'L',
    'mL',
    'unidad',
    'paquete',
    'caja'
  ];

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryOrange,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        );
      },
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
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      unit: _unitController.text.trim().isEmpty
          ? null
          : _unitController.text.trim(),
      quantity: _quantityController.text.isEmpty
          ? null
          : double.tryParse(_quantityController.text),
      minStock: _minStockController.text.isEmpty
          ? null
          : double.tryParse(_minStockController.text),
      maxStock: _maxStockController.text.isEmpty
          ? null
          : double.tryParse(_maxStockController.text),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      unitPrice: _unitPriceController.text.isEmpty
          ? null
          : double.tryParse(_unitPriceController.text),
      totalCost: _totalCostController.text.isEmpty
          ? null
          : double.tryParse(_totalCostController.text),
      supplier: _supplierController.text.trim().isEmpty
          ? null
          : _supplierController.text.trim(),
      lastPurchaseDate: _lastPurchaseDate?.toIso8601String().split('T').first,
      expirationDate: _expirationDate?.toIso8601String().split('T').first,
      productionDate: _productionDate?.toIso8601String().split('T').first,
      lotNumber: _lotNumberController.text.trim().isEmpty
          ? null
          : _lotNumberController.text.trim(),
      requiresRefrigeration: _requiresRefrigeration,
      recommendedTemperature: _recommendedTempController.text.trim().isEmpty
          ? null
          : _recommendedTempController.text.trim(),
      hasAllergens: _hasAllergens,
      allergenType: _allergenTypeController.text.trim().isEmpty
          ? null
          : _allergenTypeController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      state: _state,
    );

    try {
      if (widget.ingredient == null) {
        await IngredientService.create(ingredient);
      } else {
        await IngredientService.update(
            widget.ingredient!.idIngredient!, ingredient);
      }

      if (mounted) {
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSaved();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  widget.ingredient == null
                      ? 'Ingrediente creado exitosamente'
                      : 'Ingrediente actualizado exitosamente',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error: $e',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
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
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
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
                    child: Icon(Icons.kitchen_rounded,
                        color: primaryOrange, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ingredient == null
                              ? 'Nuevo Ingrediente'
                              : 'Editar Ingrediente',
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
                    icon:
                        Icon(Icons.close_rounded, color: Colors.grey.shade600),
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
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),

            // Form Content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información Básica
                      _buildSectionTitle('Información Básica'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _nameController,
                              label: 'Nombre',
                              hint: 'Ej: Pollo entero',
                              icon: Icons.label_rounded,
                              required: true,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _codeController,
                              label: 'Código',
                              hint: 'Ej: ING-001',
                              icon: Icons.qr_code_rounded,
                              required: true,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        label: 'Categoría',
                        hint: 'Selecciona una categoría',
                        icon: Icons.category_rounded,
                        value: _categoryController.text.isEmpty
                            ? null
                            : _categoryController.text,
                        items: _categories,
                        onChanged: (value) {
                          setState(() {
                            _categoryController.text = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Descripción',
                        hint: 'Descripción del ingrediente',
                        icon: Icons.description_rounded,
                      ),
                      const SizedBox(height: 20),

                      // Inventario
                      _buildSectionTitle('Inventario'),
                      _buildDropdown(
                        label: 'Unidad',
                        hint: 'Selecciona unidad',
                        icon: Icons.straighten_rounded,
                        value: _unitController.text.isEmpty
                            ? null
                            : _unitController.text,
                        items: _units,
                        onChanged: (value) {
                          setState(() {
                            _unitController.text = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _quantityController,
                        label: 'Cantidad',
                        hint: '0.0',
                        icon: Icons.inventory_2_rounded,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotalCost(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _minStockController,
                              label: 'Stock Mínimo',
                              hint: '0.0',
                              icon: Icons.trending_down_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _maxStockController,
                              label: 'Stock Máximo',
                              hint: '0.0',
                              icon: Icons.trending_up_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _locationController,
                        label: 'Ubicación',
                        hint: 'Ej: Almacén A, Estante 3',
                        icon: Icons.location_on_rounded,
                      ),
                      const SizedBox(height: 20),

                      // Costos
                      _buildSectionTitle('Costos'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _unitPriceController,
                              label: 'Precio Unitario',
                              hint: '0.00',
                              icon: Icons.attach_money_rounded,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _calculateTotalCost(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _totalCostController,
                              label: 'Costo Total',
                              hint: '0.00',
                              icon: Icons.calculate_rounded,
                              keyboardType: TextInputType.number,
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _supplierController,
                        label: 'Proveedor',
                        hint: 'Nombre del proveedor',
                        icon: Icons.business_rounded,
                      ),
                      const SizedBox(height: 20),

                      // Fechas
                      _buildSectionTitle('Fechas'),
                      _buildDateField(
                          'Última Compra', _lastPurchaseDate, 'purchase'),
                      const SizedBox(height: 12),
                      _buildDateField(
                          'Fecha de Producción', _productionDate, 'production'),
                      const SizedBox(height: 12),
                      _buildDateField('Fecha de Vencimiento', _expirationDate,
                          'expiration'),
                      const SizedBox(height: 20),

                      // Detalles Adicionales
                      _buildSectionTitle('Detalles Adicionales'),
                      _buildTextField(
                        controller: _lotNumberController,
                        label: 'Número de Lote',
                        hint: 'Ej: L-2024-001',
                        icon: Icons.confirmation_number_rounded,
                      ),
                      const SizedBox(height: 20),

                      // Switches y Campos Condicionales
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              'Requiere Refrigeración',
                              'Debe almacenarse en frío',
                              Icons.ac_unit_rounded,
                              _requiresRefrigeration,
                              (v) {
                                setState(() {
                                  _requiresRefrigeration = v;
                                  if (!v) {
                                    _recommendedTempController.clear();
                                  }
                                });
                              },
                            ),
                            if (_requiresRefrigeration) ...[
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _recommendedTempController,
                                label: 'Temperatura Recomendada',
                                hint: 'Ej: 4°C',
                                icon: Icons.thermostat_rounded,
                                enabled: true,
                              ),
                            ],
                            const SizedBox(height: 12),
                            _buildSwitchTile(
                              'Contiene Alérgenos',
                              'Puede causar reacciones alérgicas',
                              Icons.warning_amber_rounded,
                              _hasAllergens,
                              (v) {
                                setState(() {
                                  _hasAllergens = v;
                                  if (!v) {
                                    _allergenTypeController.clear();
                                  }
                                });
                              },
                            ),
                            if (_hasAllergens) ...[
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _allergenTypeController,
                                label: 'Tipo de Alérgeno',
                                hint: 'Ej: Lácteos, Gluten',
                                icon: Icons.warning_rounded,
                                enabled: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
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
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side:
                            BorderSide(color: Colors.grey.shade300, width: 1.5),
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
                      onPressed: _isLoading ? null : _saveIngredient,
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  widget.ingredient == null
                                      ? 'Crear Ingrediente'
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    bool readOnly = false,
    bool enabled = true,
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
            readOnly: readOnly,
            enabled: enabled,
            maxLines: 1,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: enabled ? const Color(0xFF1A1A2E) : Colors.grey.shade400,
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
                  color: enabled
                      ? primaryOrange.withOpacity(0.1)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon,
                    color: enabled ? primaryOrange : Colors.grey.shade400,
                    size: 18),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 56, minHeight: 56),
              filled: true,
              fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
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

  Widget _buildDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool required = false,
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
          child: DropdownButtonFormField2<String>(
            isExpanded: true,
            value: value,
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
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
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
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, String field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, field),
          child: Container(
            height: _inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.calendar_today_rounded,
                      color: primaryOrange, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date == null
                        ? 'Seleccionar fecha'
                        : DateFormat('dd/MM/yyyy').format(date),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: date == null
                          ? Colors.grey.shade400
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded,
                    color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color:
                  value ? primaryOrange.withOpacity(0.1) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? primaryOrange : Colors.grey.shade500,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryOrange,
          ),
        ],
      ),
    );
  }
}
