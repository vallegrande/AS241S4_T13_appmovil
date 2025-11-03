// lib/features/users/form_user.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:as241s4_t13_appmovil/core/models/users/user_model.dart';
import 'package:as241s4_t13_appmovil/core/models/role/role_model.dart';
import 'package:as241s4_t13_appmovil/core/models/department/department_model.dart';
import 'package:as241s4_t13_appmovil/core/services/users/user_service.dart';
import 'package:as241s4_t13_appmovil/core/services/role/role_service.dart';
import 'package:as241s4_t13_appmovil/core/services/department/department_service.dart';

class UserForm extends StatefulWidget {
  final User? user;
  const UserForm({super.key, this.user});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final RoleService _roleService = RoleService();
  final DepartmentService _departmentService = DepartmentService();
  final _formKey = GlobalKey<FormState>();

  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _numeroDocumentoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adressController = TextEditingController();
  final _horaInicioController = TextEditingController();
  final _horaFinController = TextEditingController();
  final _plannedHoursController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  String? _selectedDocumentType;
  String? _selectedGender;
  Role? _selectedRole;
  Department? _selectedDepartment;
  String? _selectedTurno;

  List<Role> _roles = [];
  List<Department> _departments = [];

  bool _isLoading = false;
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _errorMessage;
  bool _passwordVisible = false;

  bool get isEditing => widget.user != null;

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);

  final List<String> _documentTypes = ['DNI', 'CE', 'Pasaporte'];
  final List<String> _genders = ['Masculino', 'Femenino', 'Otro'];
  final List<String> _turnos = ['Mañana', 'Tarde', 'Noche', 'Mixto'];

  static const double _fieldHeight = 56.0;

  @override
  void initState() {
    super.initState();
    _loadFormData();
    _horaInicioController.addListener(_calculateTurnoAndHours);
    _horaFinController.addListener(_calculateTurnoAndHours);
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _numeroDocumentoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _adressController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();
    _plannedHoursController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final roles = await _roleService.getAllRoles();
      final departments = await _departmentService.getAllDepartments();
      if (!mounted) return;
      setState(() {
        _roles = roles;
        _departments = departments;
      });

      if (isEditing) {
        final user = widget.user!;
        _nombresController.text = user.name;
        _apellidosController.text = user.surnames;
        _numeroDocumentoController.text = user.documentNumber;
        _emailController.text = user.email;
        _phoneController.text = user.phone ?? '';
        _adressController.text = user.adress ?? '';
        _horaInicioController.text = user.horaInicio ?? '';
        _horaFinController.text = user.horaFin ?? '';
        _plannedHoursController.text = user.plannedHours?.toString() ?? '';
        _hourlyRateController.text = user.hourlyRate?.toString() ?? '';
        _selectedDocumentType = user.documentType;
        if (user.gender == 'M') {
          _selectedGender = 'Masculino';
        } else if (user.gender == 'F') {
          _selectedGender = 'Femenino';
        } else {
          _selectedGender = user.gender;
        }
        _selectedTurno = user.turno;

        try {
          _selectedRole = _roles.firstWhere((r) => r.id == user.role.id);
        } catch (_) {
          if (_roles.isNotEmpty) _selectedRole = _roles.first;
        }
        try {
          _selectedDepartment =
              _departments.firstWhere((d) => d.id == user.department.id);
        } catch (_) {
          if (_departments.isNotEmpty) _selectedDepartment = _departments.first;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar datos iniciales: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTimeInput(String input) {
    String cleaned = input.replaceAll(RegExp(r'[^0-9:]'), '');

    if (!cleaned.contains(':')) {
      if (cleaned.isEmpty) return '';
      int? hour = int.tryParse(cleaned);
      if (hour != null && hour >= 0 && hour <= 23) {
        return '${hour.toString().padLeft(2, '0')}:00';
      }
    }

    if (cleaned.contains(':')) {
      List<String> parts = cleaned.split(':');
      if (parts.length == 2) {
        int? hour = int.tryParse(parts[0]);
        int? minute = int.tryParse(parts[1]);

        if (hour != null && minute != null) {
          if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
            return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          }
        }
      }
    }
    return cleaned;
  }

  void _calculateTurnoAndHours() {
    String inicio = _horaInicioController.text;
    String fin = _horaFinController.text;

    if (inicio.isEmpty || fin.isEmpty) return;

    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$');
    if (!timeRegex.hasMatch(inicio) || !timeRegex.hasMatch(fin)) return;

    try {
      List<String> inicioSplit = inicio.split(':');
      List<String> finSplit = fin.split(':');

      int horaInicio = int.parse(inicioSplit[0]);
      int minInicio = int.parse(inicioSplit[1]);
      int horaFin = int.parse(finSplit[0]);
      int minFin = int.parse(finSplit[1]);

      int minutosInicio = horaInicio * 60 + minInicio;
      int minutosFin = horaFin * 60 + minFin;

      if (minutosFin <= minutosInicio) {
        minutosFin += 24 * 60;
      }

      int minutosTrabajar = minutosFin - minutosInicio;
      double horasTrabajadas = minutosTrabajar / 60.0;

      String turno;
      if (horaInicio >= 6 && horaInicio < 14) {
        turno = 'Mañana';
      } else if (horaInicio >= 14 && horaInicio < 22) {
        turno = 'Tarde';
      } else if (horaInicio >= 22 || horaInicio < 6) {
        turno = 'Noche';
      } else {
        turno = 'Mixto';
      }

      if (horasTrabajadas > 10 || (horaInicio < 14 && horaFin > 22)) {
        turno = 'Mixto';
      }

      setState(() {
        _selectedTurno = turno;
        _plannedHoursController.text = horasTrabajadas.toStringAsFixed(1);
      });
    } catch (e) {}
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

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null || _selectedDepartment == null) {
      _showErrorSnackBar('Debe seleccionar un Rol y un Departamento.');
      return;
    }
    if (!isEditing && _passwordController.text.isEmpty) {
      _showErrorSnackBar('La contraseña es requerida para un nuevo usuario.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? genderCode;
      if (_selectedGender == 'Masculino') {
        genderCode = 'M';
      } else if (_selectedGender == 'Femenino') {
        genderCode = 'F';
      } else {
        genderCode = _selectedGender;
      }

      final userToSave = User(
        idUser: widget.user?.idUser,
        documentType: _selectedDocumentType!,
        documentNumber: _numeroDocumentoController.text,
        name: _nombresController.text,
        surnames: _apellidosController.text,
        email: _emailController.text,
        password: isEditing && _passwordController.text.isEmpty
            ? ""
            : _passwordController.text,
        role: _selectedRole!,
        department: _selectedDepartment!,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        adress: _adressController.text.isEmpty ? null : _adressController.text,
        gender: genderCode,
        state: widget.user?.state ?? true,
        profilePhoto: widget.user?.profilePhoto,
        registrationDate: widget.user?.registrationDate,
        horaInicio: _horaInicioController.text.isEmpty
            ? null
            : _horaInicioController.text,
        horaFin:
            _horaFinController.text.isEmpty ? null : _horaFinController.text,
        plannedHours: double.tryParse(_plannedHoursController.text),
        turno: _selectedTurno,
        hourlyRate: double.tryParse(_hourlyRateController.text),
      );

      if (kDebugMode) {
        print('📤 Enviando usuario: ${userToSave.toJson()}');
      }

      if (isEditing) {
        await _userService.updateUser(userToSave);
      } else {
        await _userService.createUser(userToSave);
      }

      if ((_imageFile != null && !kIsWeb) || (_imageBytes != null && kIsWeb)) {
        final userId = isEditing
            ? widget.user!.idUser!
            : (await _userService.getLatestUserId());
        if (userId != null) {
          final photoUrl = kIsWeb
              ? await _userService.uploadUserPhotoWeb(userId, _imageBytes!)
              : await _userService.uploadUserPhoto(userId, _imageFile!);
          if (kDebugMode) print('📸 Foto: $photoUrl');
        }
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

  String? _validateTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$').hasMatch(value))
      return 'Formato inválido (HH:mm)';
    return null;
  }

  String? _validateNumber(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty)
      return required ? 'Campo obligatorio' : null;
    if (double.tryParse(value) == null) return 'Debe ser un número válido';
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return SizedBox(
      height: _fieldHeight,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && !_passwordVisible,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
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
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: Colors.grey.shade600,
                      size: 20),
                  onPressed: () =>
                      setState(() => _passwordVisible = !_passwordVisible))
              : null,
        ),
        validator: validator ??
            (value) =>
                (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
      ),
    );
  }

  Widget _buildDropdown2<T>({
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
            offset: const Offset(0, -5),
            scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: WidgetStateProperty.all(6),
                thumbVisibility: WidgetStateProperty.all(true))),
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

  Widget _buildUserForm() {
    return SingleChildScrollView(
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
              validator: _validateNombre),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _apellidosController,
              labelText: 'Apellidos',
              icon: Icons.person_outline_rounded,
              validator: _validateNombre),
          const SizedBox(height: 16),
          _buildDropdown2<String>(
              selectedValue: _selectedDocumentType,
              items: _documentTypes,
              labelText: 'Tipo de Documento',
              icon: Icons.credit_card_rounded,
              itemLabel: (doc) => doc,
              onChanged: (v) => setState(() => _selectedDocumentType = v)),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _numeroDocumentoController,
              labelText: 'Número de Documento',
              icon: Icons.badge_rounded,
              keyboardType: TextInputType.number,
              validator: (v) => _validateDocumento(v, _selectedDocumentType),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _emailController,
              labelText: 'Email',
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail),
          const SizedBox(height: 16),
          _buildTextField(
              labelText:
                  'Contraseña ${isEditing ? '(dejar vacío para mantener)' : ''}',
              controller: _passwordController,
              icon: Icons.lock_rounded,
              isPassword: true,
              validator: (v) {
                if (!isEditing && (v == null || v.isEmpty))
                  return 'Contraseña requerida';
                if (v != null && v.isNotEmpty && v.length < 6)
                  return 'Mínimo 6 caracteres';
                return null;
              }),
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
              ]),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _adressController,
              labelText: 'Dirección',
              icon: Icons.location_on_rounded,
              validator: (v) =>
                  (v != null && v.isNotEmpty && v.trim().length < 5)
                      ? 'Dirección muy corta'
                      : null),
          const SizedBox(height: 16),
          _buildDropdown2<String>(
              selectedValue: _selectedGender,
              items: _genders,
              labelText: 'Género',
              icon: Icons.wc_rounded,
              itemLabel: (g) => g,
              onChanged: (v) => setState(() => _selectedGender = v)),
          const SizedBox(height: 16),
          _buildDropdown2<Role>(
              selectedValue: _selectedRole,
              items: _roles,
              labelText: 'Rol',
              icon: Icons.badge_rounded,
              itemLabel: (r) => r.name,
              onChanged: (v) => setState(() => _selectedRole = v)),
          const SizedBox(height: 16),
          _buildDropdown2<Department>(
              selectedValue: _selectedDepartment,
              items: _departments,
              labelText: 'Departamento',
              icon: Icons.business_rounded,
              itemLabel: (d) => d.name,
              onChanged: (v) => setState(() => _selectedDepartment = v)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.access_time_rounded,
                      color: primaryOrange, size: 20),
                  const SizedBox(width: 8),
                  Text('Horario Laboral',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: _buildTextField(
                          controller: _horaInicioController,
                          labelText: 'Hora Inicio',
                          icon: Icons.schedule_rounded,
                          keyboardType: TextInputType.number,
                          validator: _validateTime,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:]')),
                            LengthLimitingTextInputFormatter(5)
                          ],
                          onChanged: (value) {
                            if (value.length >= 1 && !value.contains(':')) {
                              String formatted = _formatTimeInput(value);
                              if (formatted != value && formatted.isNotEmpty) {
                                _horaInicioController.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                        offset: formatted.length));
                              }
                            }
                          })),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextField(
                          controller: _horaFinController,
                          labelText: 'Hora Fin',
                          icon: Icons.access_time_filled_rounded,
                          keyboardType: TextInputType.number,
                          validator: _validateTime,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:]')),
                            LengthLimitingTextInputFormatter(5)
                          ],
                          onChanged: (value) {
                            if (value.length >= 1 && !value.contains(':')) {
                              String formatted = _formatTimeInput(value);
                              if (formatted != value && formatted.isNotEmpty) {
                                _horaFinController.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                        offset: formatted.length));
                              }
                            }
                          })),
                ]),
                const SizedBox(height: 16),
                _buildDropdown2<String>(
                    selectedValue: _selectedTurno,
                    items: _turnos,
                    labelText: 'Turno (Auto-calculado)',
                    icon: Icons.wb_sunny_rounded,
                    itemLabel: (t) => t,
                    onChanged: (v) => setState(() => _selectedTurno = v)),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _plannedHoursController,
                    labelText: 'Horas Planificadas (Auto-calculado)',
                    icon: Icons.timer_rounded,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => _validateNumber(v, required: false)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _hourlyRateController,
              labelText: 'Tarifa por Hora (S/)',
              icon: Icons.attach_money_rounded,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => _validateNumber(v, required: false),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ]),
          const SizedBox(height: 24),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
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
        title: Text(isEditing ? 'Editar Perfil' : 'Crear Perfil',
            style: GoogleFonts.poppins(
                color: const Color(0xFF1A1A2E),
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: _isLoading && _roles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: primaryOrange, strokeWidth: 3),
                  const SizedBox(height: 16),
                  Text('Cargando datos...',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600)),
                ],
              ),
            )
          : Form(key: _formKey, child: _buildUserForm()),
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
                  onPressed: _isLoading ? null : _saveUser,
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
                            Text(isEditing ? 'Guardar Cambios' : 'Crear Perfil',
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
