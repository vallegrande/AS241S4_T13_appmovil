import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import 'package:as241s4_t13_appmovil/core/models/users/user_model.dart';
import 'package:as241s4_t13_appmovil/core/models/role/role_model.dart';
import 'package:as241s4_t13_appmovil/core/models/department/department_model.dart';
import 'package:as241s4_t13_appmovil/core/services/users/user_service.dart';
import 'package:as241s4_t13_appmovil/core/services/role/role_service.dart';
import 'package:as241s4_t13_appmovil/core/services/department/department_service.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';

class UserForm extends StatefulWidget {
  final User? user;
  const UserForm({super.key, this.user});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
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

  final List<String> _documentTypes = ['DNI', 'CE', 'Pasaporte'];
  final List<String> _genders = ['Masculino', 'Femenino', 'Otro'];
  final List<String> _turnos = ['Mañana', 'Tarde', 'Noche', 'Mixto'];

  @override
  void initState() {
    super.initState();
    _loadFormData();
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
      setState(() {
        _errorMessage = 'Debe seleccionar un Rol y un Departamento.';
      });
      return;
    }
    if (!isEditing && _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'La contraseña es requerida para un nuevo usuario.';
      });
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
        // Si se está editando y el campo de contraseña está vacío,
        // se envía una cadena vacía ("") en lugar de null.
        password:
            isEditing && _passwordController.text.isEmpty ? "" : _passwordController.text,
        role: _selectedRole!,
        department: _selectedDepartment!,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        adress: _adressController.text.isEmpty ? null : _adressController.text,
        gender: genderCode,
        state: widget.user?.state ?? true,
        profilePhoto: widget.user?.profilePhoto,
        registrationDate: widget.user?.registrationDate,
        horaInicio: _horaInicioController.text.isEmpty ? null : _horaInicioController.text,
        horaFin: _horaFinController.text.isEmpty ? null : _horaFinController.text,
        plannedHours: double.tryParse(_plannedHoursController.text),
        turno: _selectedTurno,
        hourlyRate: double.tryParse(_hourlyRateController.text),
      );

      if (kDebugMode) {
        print('📤 Enviando usuario:');
        print(userToSave.toJson());
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${isEditing ? 'Actualizado' : 'Creado'} correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildDropdown<T>({
    required T? selectedValue,
    required List<T> items,
    required String labelText,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
    required IconData icon,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.red),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
      ),
      value: selectedValue,
      isExpanded: true,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Seleccione una opción' : null,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !_passwordVisible,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.red),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
              )
            : null,
      ),
      validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Obligatorio' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Usuario' : 'Nuevo Usuario'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _roles.isEmpty
          ? Center(child: CircularProgressIndicator(color: Colors.red.shade700))
          : SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Foto y título
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.red.shade700, width: 3),
                                ),
                                child: ClipOval(
                                  child: _imageFile != null
                                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                                      : _imageBytes != null
                                          ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                          : Icon(Icons.camera_alt, size: 48, color: Colors.grey[600]),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isEditing ? 'Editar Usuario' : 'Crear Usuario',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),

                      // Campos (ancho completo)
                      _buildTextField(
                        controller: _nombresController,
                        labelText: 'Nombres',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _apellidosController,
                        labelText: 'Apellidos',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 12),

                      _buildDropdown<String>(
                        selectedValue: _selectedDocumentType,
                        items: _documentTypes,
                        labelText: 'Tipo Doc',
                        icon: Icons.credit_card,
                        itemLabel: (doc) => doc,
                        onChanged: (v) => setState(() => _selectedDocumentType = v),
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _numeroDocumentoController,
                        labelText: 'Número Doc',
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        labelText: 'Contraseña ${isEditing ? '(Nueva)' : ''}',
                        controller: _passwordController,
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (v) => !isEditing && (v == null || v.isEmpty) ? 'Requerida' : null,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _phoneController,
                        labelText: 'Teléfono',
                        icon: Icons.phone,
                        validator: (v) => null,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _adressController,
                        labelText: 'Dirección',
                        icon: Icons.location_on,
                        validator: (v) => null,
                      ),
                      const SizedBox(height: 12),

                      _buildDropdown<String>(
                        selectedValue: _selectedGender,
                        items: _genders,
                        labelText: 'Género',
                        icon: Icons.wc,
                        itemLabel: (g) => g,
                        onChanged: (v) => setState(() => _selectedGender = v),
                      ),
                      const SizedBox(height: 12),

                      _buildDropdown<Role>(
                        selectedValue: _selectedRole,
                        items: _roles,
                        labelText: 'Rol',
                        icon: Icons.badge,
                        itemLabel: (r) => r.name,
                        onChanged: (v) => setState(() => _selectedRole = v),
                      ),
                      const SizedBox(height: 12),

                      _buildDropdown<Department>(
                        selectedValue: _selectedDepartment,
                        items: _departments,
                        labelText: 'Departamento',
                        icon: Icons.business,
                        itemLabel: (d) => d.name,
                        onChanged: (v) => setState(() => _selectedDepartment = v),
                      ),
                      const SizedBox(height: 12),

                      _buildDropdown<String>(
                        selectedValue: _selectedTurno,
                        items: _turnos,
                        labelText: 'Turno',
                        icon: Icons.schedule,
                        itemLabel: (t) => t,
                        onChanged: (v) => setState(() => _selectedTurno = v),
                      ),
                      const SizedBox(height: 12),

                      // Horas inicio/fin en una fila
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _horaInicioController,
                              labelText: 'Hora Inicio',
                              icon: Icons.access_time,
                              validator: (v) => null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _horaFinController,
                              labelText: 'Hora Fin',
                              icon: Icons.access_time,
                              validator: (v) => null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _plannedHoursController,
                        labelText: 'Horas Planificadas',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        validator: (v) => null,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _hourlyRateController,
                        labelText: 'Tarifa/Hora',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (v) => null,
                      ),
                      const SizedBox(height: 16),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // Botones (ancho completo)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('CANCELAR', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      isEditing ? 'GUARDAR' : 'CREAR',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
