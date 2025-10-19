import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../services/user_service.dart';
import '../widgets/header.dart';
import 'dart:typed_data';

class UserForm extends StatefulWidget {
  final User? user;
  const UserForm({super.key, this.user});
  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final UserService _userService = UserService();
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

  File? _imageFile;
  Uint8List? _webImage;
  String? _imageFileName;
  String? _selectedTipoDocumento;
  List<Role> _roles = [];
  List<Department> _departments = [];
  Role? _selectedRole;
  Department? _selectedDepartment;
  String? _selectedGender;
  String? _selectedTurno;
  bool _isLoading = false;
  String? _errorMessage;
  bool _passwordVisible = false;
  bool get isEditing => widget.user != null;

  final List<String> _documentTypes = ['DNI', 'CE'];
  final List<String> _genders = ['M', 'F'];
  final List<String> _turnos = ['Mañana', 'Tarde', 'Noche'];

  @override
  void initState() {
    super.initState();
    _loadRolesAndDepartments();
    if (isEditing) _initializeFields(widget.user!);
    _horaInicioController.addListener(_calculatePlannedHours);
    _horaFinController.addListener(_calculatePlannedHours);
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

  void _initializeFields(User user) {
    _nombresController.text = user.name;
    _apellidosController.text = user.surnames;
    _numeroDocumentoController.text = user.documentNumber;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
    _adressController.text = user.adress ?? '';
    _selectedTipoDocumento = user.documentType;
    _selectedGender = user.gender;
    _horaInicioController.text = user.horaInicio ?? '';
    _horaFinController.text = user.horaFin ?? '';
    _plannedHoursController.text = user.plannedHours?.toString() ?? '';
    _selectedTurno = user.turno;
    _hourlyRateController.text = user.hourlyRate?.toString() ?? '';
  }

  void _calculatePlannedHours() {
    final inicio = _horaInicioController.text.trim();
    final fin = _horaFinController.text.trim();
    if (inicio.isEmpty || fin.isEmpty) return;
    try {
      final startTime = _parseTime(inicio);
      final endTime = _parseTime(fin);
      if (startTime != null && endTime != null) {
        int hours = endTime.hour - startTime.hour;
        int minutes = endTime.minute - startTime.minute;
        if (hours < 0 || (hours == 0 && minutes < 0)) hours += 24;
        final totalHours = hours + (minutes / 60.0);
        setState(() {
          _plannedHoursController.text = totalHours.toStringAsFixed(0);
          _selectedTurno = _determineTurno(startTime);
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error al calcular horas: $e');
    }
  }

  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String _determineTurno(TimeOfDay startTime) {
    final hour = startTime.hour;
    if (hour >= 6 && hour < 14) return 'Mañana';
    else if (hour >= 14 && hour < 22) return 'Tarde';
    else return 'Noche';
  }

  Future<void> _loadRolesAndDepartments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedRoles = await _userService.getRoles();
      final fetchedDepartments = await _userService.getDepartments();
      if (!mounted) return;
      setState(() {
        _roles = fetchedRoles;
        _departments = fetchedDepartments;
        if (isEditing) {
          _selectedRole = _roles.firstWhere((r) => r.id == widget.user!.role.id, orElse: () => _roles.first);
          _selectedDepartment = _departments.firstWhere((d) => d.id == widget.user!.department.id, orElse: () => _departments.first);
        } else {
          _selectedRole = _roles.isNotEmpty ? _roles.first : null;
          _selectedDepartment = _departments.isNotEmpty ? _departments.first : null;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar datos: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _searchDni() async {
    final dni = _numeroDocumentoController.text.trim();
    if (_selectedTipoDocumento == 'DNI' && dni.length == 8) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final dniData = await _userService.getDniData(dni);
        if (!mounted) return;
        setState(() {
          _nombresController.text = dniData.nombres;
          _apellidosController.text = '${dniData.apellidoPaterno} ${dniData.apellidoMaterno}';
          _isLoading = false;
        });
      } on NotFoundException catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Error al consultar DNI: $e';
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
          _webImage = bytes;
          _imageFileName = pickedFile.name;
          _imageFile = null;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageFileName = pickedFile.name;
          _webImage = null;
        });
      }
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (controller.text.isNotEmpty) {
      final parsed = _parseTime(controller.text);
      if (parsed != null) initialTime = parsed;
    }
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF1100),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null || _selectedDepartment == null) {
      setState(() => _errorMessage = 'Seleccione un Rol y un Departamento');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final newUser = User(
      idUser: isEditing ? widget.user!.idUser : null,
      documentType: _selectedTipoDocumento!,
      documentNumber: _numeroDocumentoController.text.trim(),
      name: _nombresController.text.trim(),
      surnames: _apellidosController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.isEmpty && isEditing ? null : _passwordController.text.trim(),
      role: _selectedRole!,
      department: _selectedDepartment!,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      adress: _adressController.text.trim().isEmpty ? null : _adressController.text.trim(),
      gender: _selectedGender,
      profilePhoto: _imageFile == null && _webImage == null && isEditing ? widget.user!.profilePhoto : null,
      state: isEditing ? widget.user!.state : true,
      registrationDate: isEditing ? widget.user!.registrationDate : null,
      horaInicio: _horaInicioController.text.trim().isEmpty ? null : _horaInicioController.text.trim(),
      horaFin: _horaFinController.text.trim().isEmpty ? null : _horaFinController.text.trim(),
      plannedHours: _plannedHoursController.text.trim().isEmpty ? null : int.tryParse(_plannedHoursController.text.trim()),
      turno: _selectedTurno,
      hourlyRate: _hourlyRateController.text.trim().isEmpty ? null : double.tryParse(_hourlyRateController.text.trim()),
    );
    try {
      User savedUser = await _userService.saveUser(newUser);
      if (kIsWeb && _webImage != null && _imageFileName != null) {
        try {
          await _userService.uploadProfilePhotoWeb(savedUser.idUser!, _webImage!, _imageFileName!);
        } catch (e) {
          if (kDebugMode) print('Error al subir foto: $e');
        }
      } else if (!kIsWeb && _imageFile != null) {
        try {
          await _userService.uploadProfilePhoto(savedUser.idUser!, _imageFile!);
        } catch (e) {
          if (kDebugMode) print('Error al subir foto: $e');
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario ${isEditing ? 'actualizado' : 'registrado'} correctamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true);
    } on ConflictException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error de formato: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
      if (kDebugMode) print('Error completo en _saveUser: $e');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFF1100), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: suffixIcon,
            counterText: '',
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildImageWidget(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFFFF1100), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (kIsWeb && _webImage != null) {
      return Image.memory(_webImage!, fit: BoxFit.cover);
    } else if (!kIsWeb && _imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (isEditing && widget.user!.profilePhoto != null) {
      return Image.network(
        widget.user!.profilePhoto!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/formUser/defaultUser.png', fit: BoxFit.cover),
      );
    } else {
      return Image.asset('assets/formUser/defaultUser.png', fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(isEditing ? 'Editar Usuario' : 'Crear perfil de usuario', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                              child: const Icon(Icons.info_outline, size: 16, color: Color(0xFFFF1100)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildProfileImage(),
                        const SizedBox(height: 4),
                        const Center(child: Text('Editar foto de perfil', style: TextStyle(fontSize: 11, color: Colors.grey))),
                        const SizedBox(height: 14),
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red[200]!)),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red[700], size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red[700], fontSize: 12))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        const Text('Tipo de documento *', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField2<String>(
                          decoration: InputDecoration(
                            hintText: 'Elige un tipo de doc...',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          isExpanded: true,
                          value: _selectedTipoDocumento,
                          items: _documentTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                          onChanged: (value) => setState(() {
                            _selectedTipoDocumento = value;
                            _numeroDocumentoController.clear();
                          }),
                          validator: (value) => value == null ? 'Seleccione tipo de documento' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _numeroDocumentoController,
                          label: 'Número de documento *',
                          keyboardType: TextInputType.number,
                          maxLength: _selectedTipoDocumento == 'DNI' ? 8 : 12,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Ingrese número de documento';
                            if (_selectedTipoDocumento == 'DNI' && value!.length != 8) return 'DNI debe tener 8 dígitos';
                            if (_selectedTipoDocumento == 'CE' && (value!.length < 9 || value.length > 12)) return 'CE debe tener entre 9-12 dígitos';
                            return null;
                          },
                          suffixIcon: _selectedTipoDocumento == 'DNI' ? IconButton(
                            icon: const Icon(Icons.search, color: Color(0xFFFF1100)),
                            onPressed: _searchDni,
                            tooltip: 'Buscar en RENIEC',
                          ) : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _nombresController,
                          label: 'Nombres *',
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))],
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Ingrese los nombres';
                            if (value!.length < 2) return 'Mínimo 2 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _apellidosController,
                          label: 'Apellidos *',
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))],
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Ingrese los apellidos';
                            if (value!.length < 2) return 'Mínimo 2 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text('Género *', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField2<String>(
                          decoration: InputDecoration(
                            hintText: 'Elige un género',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          isExpanded: true,
                          value: _selectedGender,
                          items: _genders.map((gender) => DropdownMenuItem(value: gender, child: Text(gender == 'M' ? 'Masculino' : 'Femenino'))).toList(),
                          onChanged: (value) => setState(() => _selectedGender = value),
                          validator: (value) => value == null ? 'Seleccione un género' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email *',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Ingrese el email';
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value!)) return 'Email inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isEditing ? 'Contraseña (vacío = no cambiar)' : 'Contraseña *', style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                hintText: 'Contraseña',
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFF1100), width: 2)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                suffixIcon: IconButton(
                                  icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                                ),
                              ),
                              validator: (value) {
                                if (!isEditing && (value?.isEmpty ?? true)) return 'Ingrese una contraseña';
                                if (value != null && value.isNotEmpty && value.length < 6) return 'Mínimo 6 caracteres';
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Rol asignado *', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField2<Role>(
                          decoration: InputDecoration(
                            hintText: 'Seleccione un rol',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          isExpanded: true,
                          value: _selectedRole,
                          items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role.name))).toList(),
                          onChanged: (value) => setState(() => _selectedRole = value),
                          validator: (value) => value == null ? 'Seleccione un rol' : null,
                        ),
                        const SizedBox(height: 12),
                        const Text('Departamento *', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField2<Department>(
                          decoration: InputDecoration(
                            hintText: 'Seleccione un departamento',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          isExpanded: true,
                          value: _selectedDepartment,
                          items: _departments.map((dept) => DropdownMenuItem(value: dept, child: Text(dept.name))).toList(),
                          onChanged: (value) => setState(() => _selectedDepartment = value),
                          validator: (value) => value == null ? 'Seleccione un departamento' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Teléfono',
                          keyboardType: TextInputType.phone,
                          maxLength: 9,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value != null && value.isNotEmpty && value.length < 5) return 'Mínimo 5 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Horas planificadas y turno se calcularán automáticamente',
                                  style: TextStyle(color: Colors.blue[700], fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hora Inicio', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _horaInicioController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'Seleccione hora de inicio',
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFF1100), width: 2)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                suffixIcon: const Icon(Icons.access_time, color: Color(0xFFFF1100)),
                              ),
                              onTap: () => _selectTime(_horaInicioController),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hora Fin', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _horaFinController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'Seleccione hora de fin',
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFF1100), width: 2)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                suffixIcon: const Icon(Icons.access_time, color: Color(0xFFFF1100)),
                              ),
                              onTap: () => _selectTime(_horaFinController),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _plannedHoursController,
                          label: 'Horas Planificadas (calculado automático)',
                          keyboardType: TextInputType.number,
                          enabled: false,
                        ),
                        const SizedBox(height: 12),
                        const Text('Turno (automático)', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField2<String>(
                          decoration: InputDecoration(
                            hintText: 'Se determina según hora de inicio',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
                            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          isExpanded: true,
                          value: _selectedTurno,
                          items: _turnos.map((turno) => DropdownMenuItem(value: turno, child: Text(turno))).toList(),
                          onChanged: null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _hourlyRateController,
                          label: 'Tarifa Horaria (S/.)',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final rate = double.tryParse(value);
                              if (rate == null || rate <= 0) return 'Ingrese tarifa válida mayor a 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('* Campos obligatorios', style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  side: const BorderSide(color: Color(0xFFFF1100)),
                                ),
                                child: const Text('Cancelar', style: TextStyle(color: Color(0xFFFF1100), fontSize: 14, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Aceptar', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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
          ),
          const Positioned(top: 0, left: 0, right: 0, child: AppHeader(showBackButton: true)),
        ],
      ),
    );
  }
}