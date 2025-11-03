// lib/features/roles_departments/form_rolAndDepartament.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:as241s4_t13_appmovil/core/models/role/role_model.dart';
import 'package:as241s4_t13_appmovil/core/models/department/department_model.dart';
import 'package:as241s4_t13_appmovil/core/services/role/role_service.dart';
import 'package:as241s4_t13_appmovil/core/services/department/department_service.dart';

import 'panel_rolAndDepartament.dart';

class FormRolAndDepartament extends StatefulWidget {
  final EntityType entityType;
  final dynamic entity;

  const FormRolAndDepartament({
    super.key,
    required this.entityType,
    this.entity,
  });

  @override
  State<FormRolAndDepartament> createState() => _FormRolAndDepartamentState();
}

class _FormRolAndDepartamentState extends State<FormRolAndDepartament> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final RoleService _roleService = RoleService();
  final DepartmentService _departmentService = DepartmentService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedValue;

  bool get isEditing => widget.entity != null;
  String get entityName =>
      widget.entityType == EntityType.role ? 'Rol' : 'Departamento';

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);

  // ROLES PREDEFINIDOS
  final List<String> _predefinedRoles = [
    'ADMIN',
    'CAJERO',
    'COCINERO',
    'HORNERO',
    'BARTENDER',
    'MOZO',
    'REPARTIDOR'
  ];

  // DEPARTAMENTOS PREDEFINIDOS
  final List<String> _predefinedDepartments = [
    'COCINA',
    'BARRA',
    'CAJA',
    'SALÓN',
    'DELIVERY',
    'LIMPIEZA',
    'GERENCIA'
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final name = widget.entityType == EntityType.role
          ? (widget.entity as Role).name
          : (widget.entity as Department).name;
      _selectedValue = name;
      _nameController.text = name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim().toUpperCase();

    // Validar que sea predefinido
    if (widget.entityType == EntityType.role &&
        !_predefinedRoles.contains(name)) {
      setState(() => _errorMessage = 'Solo se permiten roles predefinidos');
      return;
    }
    if (widget.entityType == EntityType.department &&
        !_predefinedDepartments.contains(name)) {
      setState(
          () => _errorMessage = 'Solo se permiten departamentos predefinidos');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.entityType == EntityType.role) {
        await _roleService.createRole(Role(id: 0, name: name));
      } else {
        await _departmentService
            .createDepartment(Department(id: 0, name: name));
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('$entityName creado',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _errorMessage =
          e.toString().contains('409') ? 'Ya existe' : 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRole = widget.entityType == EntityType.role;
    final predefinedList = isRole ? _predefinedRoles : _predefinedDepartments;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: primaryOrange),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nuevo $entityName',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [primaryOrange, lightOrange]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: primaryOrange.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Row(
                  children: [
                    Icon(isRole ? Icons.badge_rounded : Icons.business_rounded,
                        color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Text(
                      'Crear $entityName',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),
              const SizedBox(height: 24),

              // CARD ORIGINAL
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: DropdownButtonFormField2<String>(
                    value: _selectedValue,
                    decoration: InputDecoration(
                      labelText:
                          'Selecciona un${isRole ? ' rol' : ' departamento'}',
                      prefixIcon: Icon(
                          isRole ? Icons.badge_rounded : Icons.business_rounded,
                          color: primaryOrange),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryOrange, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    items: predefinedList.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item,
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value;
                        _nameController.text = value!;
                      });
                    },
                    validator: (v) =>
                        v == null ? 'Selecciona una opción' : null,
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 300,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white),
                      elevation: 8,
                      offset: const Offset(0, -8),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

              // Mensaje informativo
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_rounded,
                          color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Solo se permiten elementos predefinidos.\nNo se pueden editar ni eliminar.',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red)),
                  child: Row(children: [
                    const Icon(Icons.error_rounded, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(_errorMessage!,
                            style: GoogleFonts.inter(
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.w600))),
                  ]),
                ).animate().shake().fadeIn(),

              const SizedBox(height: 32),
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
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Cancelar',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('Crear',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
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
