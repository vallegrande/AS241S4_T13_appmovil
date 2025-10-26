// Archivo: lib/Dishes/Forms/ingredient_form.dart
import 'package:flutter/material.dart';
import 'package:myapp/models/ingredient.dart';
import 'package:myapp/services/ingredient_service.dart';

class IngredientForm extends StatefulWidget {
  final Ingredient? ingredient;
  final VoidCallback onClose;
  final Function(Ingredient) onSaved;

  const IngredientForm({
    super.key,
    this.ingredient,
    required this.onClose,
    required this.onSaved,
  });

  @override
  _IngredientFormState createState() => _IngredientFormState();
}

class _IngredientFormState extends State<IngredientForm> {
  final _formKey = GlobalKey<FormState>();
  final _ingredientService = IngredientService();

  // Campos básicos
  late String _name;
  late String _code;
  late String? _category;
  late String? _unit;
  late double _quantity;
  late double? _minStock;
  late double? _maxStock;
  late String? _location;

  // Campos económicos
  late double? _unitPrice;
  late double? _totalCost;
  late String? _supplier;
  late String? _lastPurchaseDate;

  // Fechas y lote
  late String? _expirationDate;
  late String? _productionDate;
  late String? _lotNumber;

  // Características
  late bool _requiresRefrigeration;
  late String? _recommendedTemperature;
  late bool _hasAllergens;
  late String? _allergenType;

  // Otros
  late String? _description;
  late String? _imageUrl;
  late bool _state;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final ing = widget.ingredient;
    
    _name = ing?.name ?? '';
    _code = ing?.code ?? '';
    _category = ing?.category;
    _unit = ing?.unit;
    _quantity = ing?.quantity ?? 0.0;
    _minStock = ing?.minStock;
    _maxStock = ing?.maxStock;
    _location = ing?.location;
    
    _unitPrice = ing?.unitPrice;
    _totalCost = ing?.totalCost;
    _supplier = ing?.supplier;
    _lastPurchaseDate = ing?.lastPurchaseDate;
    
    _expirationDate = ing?.expirationDate;
    _productionDate = ing?.productionDate;
    _lotNumber = ing?.lotNumber;
    
    _requiresRefrigeration = ing?.requiresRefrigeration ?? false;
    _recommendedTemperature = ing?.recommendedTemperature;
    _hasAllergens = ing?.hasAllergens ?? false;
    _allergenType = ing?.allergenType;
    
    _description = ing?.description;
    _imageUrl = ing?.imageUrl;
    _state = ing?.state ?? true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // Calcular costo total si hay precio unitario y cantidad
      if (_unitPrice != null && _quantity > 0) {
        _totalCost = _unitPrice! * _quantity;
      }

      final ingredient = Ingredient(
        idIngredient: widget.ingredient?.idIngredient,
        name: _name,
        code: _code,
        category: _category,
        unit: _unit,
        quantity: _quantity,
        minStock: _minStock,
        maxStock: _maxStock,
        location: _location,
        unitPrice: _unitPrice,
        totalCost: _totalCost,
        supplier: _supplier,
        lastPurchaseDate: _lastPurchaseDate,
        expirationDate: _expirationDate,
        productionDate: _productionDate,
        lotNumber: _lotNumber,
        requiresRefrigeration: _requiresRefrigeration,
        recommendedTemperature: _recommendedTemperature,
        hasAllergens: _hasAllergens,
        allergenType: _allergenType,
        description: _description,
        imageUrl: _imageUrl,
        state: _state,
      );

      Ingredient savedIngredient;
      if (widget.ingredient?.idIngredient != null) {
        savedIngredient = await _ingredientService.update(
          widget.ingredient!.idIngredient!,
          ingredient,
        );
      } else {
        savedIngredient = await _ingredientService.create(ingredient);
      }

      widget.onSaved(savedIngredient);
      _showSuccess('Insumo ${widget.ingredient != null ? "actualizado" : "creado"} correctamente');
    } catch (e) {
      _showError('Error al guardar insumo: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.ingredient != null;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 900,
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'Editar Insumo' : 'Nuevo Insumo',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isEdit && widget.ingredient?.name != null)
                            Text(
                              widget.ingredient!.name,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Form scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSection(
                              'Información Básica',
                              Icons.inventory,
                              [
                                _buildRow([
                                  _buildTextField(
                                    label: 'Nombre del Insumo *',
                                    initialValue: _name,
                                    onChanged: (value) => _name = value,
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Campo requerido'
                                        : null,
                                  ),
                                  _buildTextField(
                                    label: 'Código *',
                                    initialValue: _code,
                                    onChanged: (value) => _code = value,
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Campo requerido'
                                        : null,
                                  ),
                                ]),
                                _buildRow([
                                  _buildTextField(
                                    label: 'Categoría',
                                    initialValue: _category,
                                    onChanged: (value) => _category = value,
                                  ),
                                  _buildTextField(
                                    label: 'Unidad de Medida',
                                    initialValue: _unit,
                                    onChanged: (value) => _unit = value,
                                    hint: 'kg, lt, unidad, etc.',
                                  ),
                                ]),
                                _buildTextField(
                                  label: 'Ubicación',
                                  initialValue: _location,
                                  onChanged: (value) => _location = value,
                                  hint: 'Almacén frío, estante A3, etc.',
                                ),
                              ],
                            ),

                            _buildSection(
                              'Cantidades y Stock',
                              Icons.storage,
                              [
                                _buildRow([
                                  _buildNumberField(
                                    label: 'Cantidad Actual *',
                                    initialValue: _quantity.toString(),
                                    onChanged: (value) => _quantity =
                                        double.tryParse(value) ?? 0.0,
                                    validator: (value) =>
                                        (double.tryParse(value ?? '') ?? 0) <= 0
                                            ? 'Debe ser mayor a 0'
                                            : null,
                                  ),
                                  _buildNumberField(
                                    label: 'Stock Mínimo',
                                    initialValue: _minStock?.toString(),
                                    onChanged: (value) =>
                                        _minStock = double.tryParse(value),
                                  ),
                                ]),
                                _buildNumberField(
                                  label: 'Stock Máximo',
                                  initialValue: _maxStock?.toString(),
                                  onChanged: (value) =>
                                      _maxStock = double.tryParse(value),
                                ),
                              ],
                            ),

                            _buildSection(
                              'Información Económica',
                              Icons.attach_money,
                              [
                                _buildRow([
                                  _buildNumberField(
                                    label: 'Precio Unitario',
                                    initialValue: _unitPrice?.toString(),
                                    onChanged: (value) =>
                                        _unitPrice = double.tryParse(value),
                                    prefix: 'S/ ',
                                  ),
                                  _buildNumberField(
                                    label: 'Costo Total (calculado)',
                                    initialValue: _totalCost?.toStringAsFixed(2),
                                    onChanged: (value) {}, // Campo de solo lectura
                                    enabled: false,
                                    prefix: 'S/ ',
                                  ),
                                ]),
                                _buildTextField(
                                  label: 'Proveedor',
                                  initialValue: _supplier,
                                  onChanged: (value) => _supplier = value,
                                ),
                                _buildDateField(
                                  label: 'Última Compra',
                                  initialValue: _lastPurchaseDate,
                                  onChanged: (value) => _lastPurchaseDate = value,
                                ),
                              ],
                            ),

                            _buildSection(
                              'Fechas y Lote',
                              Icons.calendar_today,
                              [
                                _buildRow([
                                  _buildDateField(
                                    label: 'Fecha de Producción',
                                    initialValue: _productionDate,
                                    onChanged: (value) => _productionDate = value,
                                  ),
                                  _buildDateField(
                                    label: 'Fecha de Vencimiento',
                                    initialValue: _expirationDate,
                                    onChanged: (value) => _expirationDate = value,
                                  ),
                                ]),
                                _buildTextField(
                                  label: 'Número de Lote',
                                  initialValue: _lotNumber,
                                  onChanged: (value) => _lotNumber = value,
                                ),
                              ],
                            ),

                            _buildSection(
                              'Características',
                              Icons.info_outline,
                              [
                                CheckboxListTile(
                                  title: const Text('Requiere Refrigeración'),
                                  value: _requiresRefrigeration,
                                  onChanged: (value) => setState(
                                    () => _requiresRefrigeration = value ?? false,
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                if (_requiresRefrigeration)
                                  _buildTextField(
                                    label: 'Temperatura Recomendada',
                                    initialValue: _recommendedTemperature,
                                    onChanged: (value) =>
                                        _recommendedTemperature = value,
                                    hint: '2-5°C',
                                  ),
                                CheckboxListTile(
                                  title: const Text('Contiene Alérgenos'),
                                  value: _hasAllergens,
                                  onChanged: (value) => setState(
                                    () => _hasAllergens = value ?? false,
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                if (_hasAllergens)
                                  _buildTextField(
                                    label: 'Tipo de Alérgenos',
                                    initialValue: _allergenType,
                                    onChanged: (value) => _allergenType = value,
                                    hint: 'Gluten, lactosa, frutos secos, etc.',
                                  ),
                                _buildTextField(
                                  label: 'Descripción',
                                  initialValue: _description,
                                  onChanged: (value) => _description = value,
                                  maxLines: 3,
                                ),
                              ],
                            ),

                            if (isEdit)
                              CheckboxListTile(
                                title: const Text('Insumo Activo'),
                                value: _state,
                                onChanged: (value) =>
                                    setState(() => _state = value ?? true),
                              ),
                          ],
                        ),
                      ),
                    ),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
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
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFd67628)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFd67628),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      children: children
          .map((child) => Expanded(child: child))
          .toList()
          .fold<List<Widget>>(
            [],
            (list, item) => list.isEmpty
                ? [item]
                : [...list, const SizedBox(width: 12), item],
          ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    String? initialValue,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    String? prefix,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade200,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        enabled: enabled,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    String? initialValue,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            final dateStr =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            onChanged(dateStr);
            setState(() {});
          }
        },
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}