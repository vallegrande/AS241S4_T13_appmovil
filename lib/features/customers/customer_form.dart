// lib/features/customers/form_customer.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomerForm extends StatefulWidget {
  final dynamic customer; // Cambiar a CustomerModel cuando esté disponible
  const CustomerForm({super.key, this.customer});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _documentoController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _companyController = TextEditingController();
  final _notesController = TextEditingController();

  // Dropdowns
  String? _selectedDocumentType;
  String? _selectedGender;
  String? _selectedCustomerType;

  bool _isLoading = false;
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _errorMessage;

  bool get isEditing => widget.customer != null;

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);

  final List<String> _documentTypes = ['DNI', 'CE', 'Pasaporte', 'RUC'];
  final List<String> _genders = ['Masculino', 'Femenino', 'Otro'];
  final List<String> _customerTypes = ['Individual', 'Empresa', 'Gobierno'];

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
    _nombresController.dispose();
    _apellidosController.dispose();
    _documentoController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadCustomerData() {
    // TODO: Implementar carga de datos cuando el modelo esté disponible
    // final customer = widget.customer;
    // _nombresController.text = customer.name;
    // etc...
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFile = null;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = null;
        });
      }
    }
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implementar guardado cuando el backend esté listo
      // await _customerService.createCustomer(customer);
      // await _customerService.updateCustomer(customer);

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

  String? _validateNombre(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Este campo es obligatorio';
    if (value.trim().length < 2) return 'Debe tener al menos 2 caracteres';
    if (!RegExp(r'^[a-zA-Záéíóúñ\s]+$').hasMatch(value))
      return 'Solo se permiten letras';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'El email es obligatorio';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
      return 'Email inválido';
    return null;
  }

  String? _validateDocumento(String? value, String? tipo) {
    if (value == null || value.trim().isEmpty)
      return 'El documento es obligatorio';
    if (tipo == 'DNI' && !RegExp(r'^\d{8}$').hasMatch(value))
      return 'DNI debe tener 8 dígitos';
    if (tipo == 'CE' && !RegExp(r'^\d{9}$').hasMatch(value))
      return 'CE debe tener 9 dígitos';
    if (tipo == 'RUC' && !RegExp(r'^\d{11}$').hasMatch(value))
      return 'RUC debe tener 11 dígitos';
    if (tipo == 'Pasaporte' && (value.length < 6 || value.length > 12))
      return 'Pasaporte entre 6-12 caracteres';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: GoogleFonts.inter(fontSize: 12, height: 0.8),
        ),
        validator: validator ??
            (value) =>
                (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: primaryOrange.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8))
                  ]),
              child: _imageFile != null || _imageBytes != null
                  ? ClipOval(
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : Image.memory(_imageBytes!, fit: BoxFit.cover))
                  : Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              colors: [primaryOrange, lightOrange],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight)),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 40, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryOrange.withOpacity(0.2))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.touch_app_rounded, color: primaryOrange, size: 14),
              const SizedBox(width: 6),
              Text('Toca para cambiar foto',
                  style: GoogleFonts.inter(
                      color: primaryOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(duration: 400.ms, curve: Curves.easeOutBack);
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
              _buildPhotoSection(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nombresController,
                labelText: 'Nombres',
                icon: Icons.person_rounded,
                validator: _validateNombre,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _apellidosController,
                labelText: 'Apellidos',
                icon: Icons.person_outline_rounded,
                validator: _validateNombre,
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                selectedValue: _selectedDocumentType,
                items: _documentTypes,
                labelText: 'Tipo de Documento',
                icon: Icons.credit_card_rounded,
                itemLabel: (doc) => doc,
                onChanged: (v) => setState(() => _selectedDocumentType = v),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _documentoController,
                labelText: 'Número de Documento',
                icon: Icons.badge_rounded,
                keyboardType: TextInputType.number,
                validator: (v) => _validateDocumento(v, _selectedDocumentType),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                labelText: 'Teléfono',
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
                labelText: 'Dirección',
                icon: Icons.location_on_rounded,
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                selectedValue: _selectedGender,
                items: _genders,
                labelText: 'Género',
                icon: Icons.wc_rounded,
                itemLabel: (g) => g,
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                selectedValue: _selectedCustomerType,
                items: _customerTypes,
                labelText: 'Tipo de Cliente',
                icon: Icons.business_rounded,
                itemLabel: (t) => t,
                onChanged: (v) => setState(() => _selectedCustomerType = v),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _companyController,
                labelText: 'Empresa',
                icon: Icons.domain_rounded,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _notesController,
                labelText: 'Notas',
                icon: Icons.note_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
