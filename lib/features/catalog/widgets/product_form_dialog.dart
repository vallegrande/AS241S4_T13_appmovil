import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/product.dart'
    hide Department;
import 'package:as241s4_t13_appmovil/core/models/dishes/category.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/product_service.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/category_service.dart';
import 'package:as241s4_t13_appmovil/core/services/department/department_service.dart';
import 'package:as241s4_t13_appmovil/core/models/department/department_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final VoidCallback onSaved;
  final int? categoryId; // NUEVO: recibir el ID de categoría

  const ProductFormDialog({
    super.key,
    this.product,
    required this.onSaved,
    this.categoryId, // NUEVO
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

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);

  static const double _inputHeight = 56.0;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _state = widget.product!.state;

      // DEBUG: Imprimir lo que viene en el producto
      print('========== DEBUG PRODUCT ==========');
      print('Product ID: ${widget.product!.idProduct}');
      print('Product Name: ${widget.product!.name}');
      print('Product Category Field: ${widget.product!.category}');
      print('CategoryId passed: ${widget.categoryId}');
      print('===================================');
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
      });
      _applyDefaultsIfReady();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Error al cargar categorías.'),
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
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await DepartmentService().getAllDepartments();
      setState(() {
        _departments = departments;
        _isLoadingDepartments = false;
      });
      _applyDefaultsIfReady();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Error al cargar departamentos.'),
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
      setState(() => _isLoadingDepartments = false);
    }
  }

  void _applyDefaultsIfReady() {
    if (_isLoadingCategories || _isLoadingDepartments) return;

    setState(() {
      // Configurar departamento
      if (_departments.isNotEmpty && _selectedDepartment == null) {
        final deptId = widget.product?.department?['id'];
        _selectedDepartment = deptId != null
            ? _departments.firstWhere(
                (d) => d.id == deptId,
                orElse: () => _departments.first,
              )
            : _departments.first;
      }

      // Configurar categoría - USAR EL categoryId PASADO COMO PARÁMETRO
      if (_categories.isNotEmpty && _selectedCategory == null) {
        int? categoryIdToUse;

        // Prioridad 1: Usar categoryId pasado explícitamente
        if (widget.categoryId != null) {
          categoryIdToUse = widget.categoryId;
          print('Using categoryId from parameter: $categoryIdToUse');
        }
        // Prioridad 2: Intentar obtener del campo category del producto
        else if (widget.product?.category?['idCategory'] != null) {
          categoryIdToUse = widget.product!.category!['idCategory'] as int?;
          print('Using categoryId from product.category: $categoryIdToUse');
        }

        if (categoryIdToUse != null) {
          try {
            _selectedCategory = _categories.firstWhere(
              (c) => c.idCategory == categoryIdToUse,
            );
            print(
                'Found category: ${_selectedCategory?.name} (ID: ${_selectedCategory?.idCategory})');
          } catch (e) {
            print('Category not found for ID: $categoryIdToUse');
            _selectedCategory = _categories.first;
          }
        } else {
          // Para productos nuevos o si no hay categoría
          _selectedCategory = _categories.first;
          print('Using first category as default: ${_selectedCategory?.name}');
        }
      }
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Debe seleccionar una categoría y un departamento.'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
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
                  widget.product == null
                      ? 'Producto creado exitosamente'
                      : 'Producto actualizado exitosamente',
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
                Expanded(child: Text('Error al guardar producto: $e')),
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
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
                    child: Icon(Icons.fastfood_rounded,
                        color: primaryOrange, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product == null
                              ? 'Nuevo Producto'
                              : 'Editar Producto',
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
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nombre',
                        hint: 'Ej: Pollo a la Brasa',
                        icon: Icons.label_rounded,
                        required: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ingrese el nombre'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _isLoadingCategories
                          ? const Center(child: CircularProgressIndicator())
                          : _buildDropdown(
                              label: 'Categoría',
                              hint: 'Selecciona una categoría',
                              icon: Icons.category_rounded,
                              required: true,
                              value: _selectedCategory,
                              items: _categories,
                              displayText: (cat) => cat.name,
                              onChanged: (newValue) =>
                                  setState(() => _selectedCategory = newValue),
                              validator: (value) => value == null
                                  ? 'Seleccione una categoría'
                                  : null,
                            ),
                      const SizedBox(height: 12),
                      _isLoadingDepartments
                          ? const Center(child: CircularProgressIndicator())
                          : _buildDropdown(
                              label: 'Departamento',
                              hint: 'Selecciona un departamento',
                              icon: Icons.apartment_rounded,
                              required: true,
                              value: _selectedDepartment,
                              items: _departments,
                              displayText: (dept) => dept.name,
                              onChanged: (newValue) => setState(
                                  () => _selectedDepartment = newValue),
                              validator: (value) => value == null
                                  ? 'Seleccione un departamento'
                                  : null,
                            ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Descripción',
                        hint: 'Descripción del producto',
                        icon: Icons.description_rounded,
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
                      onPressed: _isLoading ? null : _saveProduct,
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
                                  widget.product == null
                                      ? 'Crear Producto'
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

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required IconData icon,
    required bool required,
    required T? value,
    required List<T> items,
    required String Function(T) displayText,
    required Function(T?) onChanged,
    required String? Function(T?) validator,
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
          child: DropdownButtonFormField2<T>(
            isExpanded: true,
            value: value,
            items: items
                .map((item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        displayText(item),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            validator: validator,
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
          ),
        ),
      ],
    );
  }
}
