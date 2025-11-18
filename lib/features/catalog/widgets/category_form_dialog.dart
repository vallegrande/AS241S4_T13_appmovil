import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
  bool _isLoading = false;

  final Color primaryOrange = const Color(0xFFFF6B35);

  final List<_SectionOption> _sections = const [
    _SectionOption('Platos y Bebidas', Icons.fastfood),
    _SectionOption('Combos', Icons.shopping_basket),
    _SectionOption('Ofertas', Icons.local_offer),
  ];

  static const double _inputHeight = 56.0;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description ?? '';
      _sectionController.text = widget.category!.section ?? '';
      _displayOrderController.text =
          widget.category!.displayOrder?.toString() ?? '';
      _delivery = widget.category!.delivery ?? false;
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
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        section: _sectionController.text.trim().isEmpty
            ? null
            : _sectionController.text.trim(),
        delivery: _delivery,
        displayOrder: _displayOrderController.text.isEmpty
            ? null
            : int.tryParse(_displayOrderController.text),
        state: widget.category?.state ?? true,
      );

      if (widget.category == null) {
        await CategoryService.create(category);
      } else {
        await CategoryService.update(widget.category!.idCategory!, category);
      }

      if (mounted) {
        // Llamamos al callback que cierra el diálogo y recarga datos
        widget.onSaved();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
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
                    child: Icon(Icons.category_rounded,
                        color: primaryOrange, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category == null
                              ? 'Nueva Categoría'
                              : 'Editar Categoría',
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
                        hint: 'Ej: Pollos, Bebidas, Combos',
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

                      _buildSectionDropdown(),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Descripción',
                        hint: 'Descripción de la categoría',
                        icon: Icons.description_rounded,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _displayOrderController,
                        label: 'Orden de visualización',
                        hint: '1, 2, 3...',
                        icon: Icons.sort_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.tryParse(value) == null) {
                              return 'Debe ser un número válido';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Switch Delivery
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
                                color: _delivery
                                    ? primaryOrange.withOpacity(0.1)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.delivery_dining_rounded,
                                color: _delivery
                                    ? primaryOrange
                                    : Colors.grey.shade500,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Disponible para Delivery',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  Text(
                                    'Permitir pedidos a domicilio',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _delivery,
                              onChanged: (value) =>
                                  setState(() => _delivery = value),
                              activeColor: primaryOrange,
                            ),
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
                      onPressed: _isLoading ? null : _saveCategory,
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
                                  widget.category == null
                                      ? 'Crear Categoría'
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
    int maxLines = 1,
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

  Widget _buildSectionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Sección',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
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
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: _inputHeight,
          child: DropdownButtonFormField2<String>(
            isExpanded: true,
            value: _sectionController.text.isEmpty
                ? null
                : _sectionController.text,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Selecciona una sección',
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
                child: Icon(Icons.dashboard_rounded,
                    color: primaryOrange, size: 18),
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
            items: _sections.map((s) {
              return DropdownMenuItem<String>(
                value: s.label,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(s.icon, color: primaryOrange, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      s.label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _sectionController.text = value ?? '';
              });
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
      ],
    );
  }
}

class _SectionOption {
  final String label;
  final IconData icon;
  const _SectionOption(this.label, this.icon);
}
