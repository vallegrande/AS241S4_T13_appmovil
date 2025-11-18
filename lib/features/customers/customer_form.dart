// lib/features/customers/customer_form.dart
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:as241s4_t13_appmovil/core/models/customer/customer_model.dart';
import 'package:as241s4_t13_appmovil/core/services/customer/customer_service.dart';

class CustomerForm extends StatefulWidget {
  final Customer? customer;
  const CustomerForm({super.key, this.customer});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final CustomerService _customerService = CustomerService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Dropdowns
  String? _selectedDocumentType;
  String? _selectedCustomerType;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isEditing => widget.customer != null;

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);

  final List<String> _documentTypes = ['DNI', 'CE', 'PASAPORTE', 'RUC'];
  final List<String> _customerTypes = ['NATURAL', 'JURIDICO'];

  static const double _fieldHeight = 56.0;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadCustomerData();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _documentNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadCustomerData() {
    final customer = widget.customer!;
    _firstNameController.text = customer.firstName;
    _lastNameController.text = customer.lastName;
    _documentNumberController.text = customer.documentNumber;
    _emailController.text = customer.email ?? '';
    _phoneController.text = customer.phone;
    _addressController.text = customer.address ?? '';
    _selectedDocumentType = customer.documentType;
    _selectedCustomerType = customer.customerType;
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDocumentType == null || _selectedCustomerType == null) {
      _showErrorSnackBar(
          'Debe seleccionar tipo de documento y tipo de cliente.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final customerToSave = Customer(
        idCustomer: widget.customer?.idCustomer,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        documentType: _selectedDocumentType!,
        documentNumber: _documentNumberController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        customerType: _selectedCustomerType!,
        state: widget.customer?.state ?? 1,
        createdAt: widget.customer?.createdAt,
      );

      if (kDebugMode) {
        print('📤 Enviando cliente: ${customerToSave.toJson()}');
      }

      if (isEditing) {
        await _customerService.updateCustomer(
            widget.customer!.idCustomer!, customerToSave);
      } else {
        await _customerService.createCustomer(customerToSave);
      }

      if (!mounted) return;
      _showSuccessSnackBar(
          '${isEditing ? 'Actualizado' : 'Creado'} correctamente');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Este campo es obligatorio';
    if (value.trim().length < 2) return 'Debe tener al menos 2 caracteres';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Email opcional
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
      return 'Email inválido';
    return null;
  }

  String? _validateDocument(String? value, String? type) {
    if (value == null || value.trim().isEmpty)
      return 'El documento es obligatorio';
    if (type == 'DNI' && !RegExp(r'^\d{8}$').hasMatch(value))
      return 'DNI debe tener 8 dígitos';
    if (type == 'CE' && !RegExp(r'^\d{9}$').hasMatch(value))
      return 'CE debe tener 9 dígitos';
    if (type == 'RUC' && !RegExp(r'^\d{11}$').hasMatch(value))
      return 'RUC debe tener 11 dígitos';
    if (type == 'PASAPORTE' && (value.length < 6 || value.length > 12))
      return 'Pasaporte entre 6-12 caracteres';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'El teléfono es obligatorio';
    if (!RegExp(r'^\d{9}$').hasMatch(value))
      return 'Teléfono debe tener 9 dígitos';
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
  }) {
    return SizedBox(
      height: maxLines == 1 ? _fieldHeight : null,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        style: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.inter(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: primaryOrange, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryOrange, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: GoogleFonts.inter(fontSize: 12, height: 0.8),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? selectedValue,
    required List<T> items,
    required String labelText,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
    required IconData icon,
  }) {
    return SizedBox(
      height: _fieldHeight,
      child: DropdownButtonFormField2<T>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.inter(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: primaryOrange, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryOrange, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: GoogleFonts.inter(fontSize: 12, height: 0.8),
        ),
        isExpanded: true,
        hint: Text('Seleccionar',
            style:
                GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
        items: items
            .map((T item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item),
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87),
                    overflow: TextOverflow.ellipsis)))
            .toList(),
        validator: (value) => value == null ? 'Seleccione una opción' : null,
        onChanged: onChanged,
        buttonStyleData: const ButtonStyleData(
            height: 56, padding: EdgeInsets.only(right: 10)),
        iconStyleData: IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryOrange),
            iconSize: 24),
        dropdownStyleData: DropdownStyleData(
            maxHeight: 250,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: Colors.white),
            elevation: 8,
            offset: const Offset(0, -5)),
        menuItemStyleData: const MenuItemStyleData(
            height: 48, padding: EdgeInsets.symmetric(horizontal: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 56,
        leading: IconButton(
            icon:
                Icon(Icons.arrow_back_rounded, color: primaryOrange, size: 24),
            onPressed: () => Navigator.pop(context)),
        title: Text(isEditing ? 'Editar Cliente' : 'Nuevo Cliente',
            style: GoogleFonts.poppins(
                color: const Color(0xFF1A1A2E),
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header con icono
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [primaryOrange, lightOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      boxShadow: [
                        BoxShadow(
                            color: primaryOrange.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8))
                      ]),
                  child: const Icon(Icons.person_rounded,
                      size: 50, color: Colors.white),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _firstNameController,
                labelText: 'Nombres *',
                icon: Icons.person_rounded,
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastNameController,
                labelText: 'Apellidos *',
                icon: Icons.person_outline_rounded,
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                selectedValue: _selectedDocumentType,
                items: _documentTypes,
                labelText: 'Tipo de Documento *',
                icon: Icons.credit_card_rounded,
                itemLabel: (doc) => doc,
                onChanged: (v) {
                  setState(() => _selectedDocumentType = v);
                  _documentNumberController.clear();
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _documentNumberController,
                labelText: 'Número de Documento *',
                icon: Icons.badge_rounded,
                keyboardType: TextInputType.number,
                validator: (v) => _validateDocument(v, _selectedDocumentType),
                inputFormatters: _selectedDocumentType == 'PASAPORTE'
                    ? null
                    : [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email (opcional)',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                labelText: 'Teléfono *',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9)
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                labelText: 'Dirección (opcional)',
                icon: Icons.location_on_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                selectedValue: _selectedCustomerType,
                items: _customerTypes,
                labelText: 'Tipo de Cliente *',
                icon: Icons.business_center_rounded,
                itemLabel: (t) => t == 'NATURAL' ? 'Natural' : 'Jurídico',
                onChanged: (v) => setState(() => _selectedCustomerType = v),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ]),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.close_rounded, size: 20),
                      const SizedBox(width: 6),
                      Text('Cancelar',
                          style: GoogleFonts.inter(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: primaryOrange.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 20),
                            const SizedBox(width: 6),
                            Text(
                                isEditing ? 'Guardar Cambios' : 'Crear Cliente',
                                style: GoogleFonts.inter(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .slideY(begin: 1, duration: 400.ms, curve: Curves.easeOutCubic),
    );
  }
}
