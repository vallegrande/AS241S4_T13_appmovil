import 'package:flutter/material.dart';

import 'package:as241s4_t13_appmovil/core/models/role/role_model.dart';
import 'package:as241s4_t13_appmovil/core/models/department/department_model.dart';

import 'package:as241s4_t13_appmovil/core/services/role/role_service.dart';
import 'package:as241s4_t13_appmovil/core/services/department/department_service.dart';

import 'panel_rolAndDepartament.dart';

class FormRolAndDepartament extends StatefulWidget {
  final EntityType entityType;
  final dynamic entity; // Puede ser Role o Department

  const FormRolAndDepartament({
    super.key,
    required this.entityType,
    this.entity,
  });

  @override
  State<FormRolAndDepartament> createState() => _FormRolAndDepartamentState();
}

class _FormRolAndDepartamentState extends State<FormRolAndDepartament> {
  // 🎨 PALETA DE COLORES
  static const Color primaryActionColor = Color(0xFFFF4500); // Un rojo/naranja vibrante
  static const Color backgroundColor = Color(0xFFF8F9FA); // Fondo limpio

  final _formKey = GlobalKey<FormState>();
  final RoleService _roleService = RoleService();
  final DepartmentService _departmentService = DepartmentService();

  late TextEditingController _nameController;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isEditing => widget.entity != null;
  String get entityName => widget.entityType == EntityType.role ? 'Rol' : 'Departamento';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: isEditing 
          ? (widget.entityType == EntityType.role 
              ? (widget.entity as Role).name 
              : (widget.entity as Department).name)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveEntity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.entityType == EntityType.role) {
        final roleName = _nameController.text.trim();
        if (isEditing) {
          final role = widget.entity as Role;
          final updatedRole = Role(id: role.id, name: roleName);
          await _roleService.updateRole(updatedRole);
        } else {
          // ID 0 para crear nuevo
          final newRole = Role(id: 0, name: roleName);
          await _roleService.createRole(newRole);
        }
      } else { 
        final departmentName = _nameController.text.trim();
        if (isEditing) {
          final department = widget.entity as Department;
          final updatedDepartment = Department(id: department.id, name: departmentName);
          await _departmentService.updateDepartment(updatedDepartment);
        } else {
          final newDepartment = Department(id: 0, name: departmentName);
          await _departmentService.createDepartment(newDepartment);
        }
      }

      if (!mounted) return;
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${isEditing ? 'Actualizado' : 'Creado'} correctamente',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      Navigator.of(context).pop(true);

    } catch (e) {
      if (!mounted) return;
      setState(() {
        // Mensaje de error más descriptivo
        String errorMsg = e.toString();
        if (errorMsg.contains('SocketException')) {
          _errorMessage = 'Error de conexión. Verifica tu internet o el servidor.';
        } else if (errorMsg.contains('401') || errorMsg.contains('403')) {
          _errorMessage = 'No tienes autorización. Inicia sesión nuevamente.';
        } else if (errorMsg.contains('409')) {
          _errorMessage = 'Ya existe un ${entityName.toLowerCase()} con ese nombre.';
        } else {
          _errorMessage = 'Error al ${isEditing ? 'actualizar' : 'crear'} el $entityName: $errorMsg';
        }
        _isLoading = false;
      });
      
      // Debug: imprimir error completo
      debugPrint('❌ Error completo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar $entityName' : 'Nuevo $entityName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryActionColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título con diseño moderno
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      // Degradado con color primario
                      gradient: const LinearGradient(
                        colors: [primaryActionColor, Color(0xFFFF694F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: primaryActionColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.entityType == EntityType.role 
                              ? Icons.badge 
                              : Icons.business,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            isEditing ? 'Editar $entityName' : 'Nuevo $entityName',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Card con el formulario
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Campo de Nombre
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre del $entityName',
                              hintText: 'Ej: ${widget.entityType == EntityType.role ? 'ADMIN, CAJERO, MESERO' : 'COCINA, ALMACÉN, VENTAS'}',
                              prefixIcon: Icon(
                                widget.entityType == EntityType.role 
                                    ? Icons.badge_outlined 
                                    : Icons.business_outlined,
                                color: primaryActionColor, // Icono con color primario
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: primaryActionColor, // Borde enfocado con color primario
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es obligatorio';
                              }
                              if (value.trim().length < 3) {
                                return 'El nombre debe tener al menos 3 caracteres';
                              }
                              return null;
                            },
                            textCapitalization: TextCapitalization.characters,
                          ),
                          const SizedBox(height: 20),
                          
                          // Mensaje de ayuda (se mantiene azul por convención)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.blue.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.entityType == EntityType.role
                                        ? 'Define los roles de tu personal (ej: ADMIN, MESERO, COCINERO)'
                                        : 'Define las áreas de trabajo (ej: COCINA, CAJA, ALMACÉN)',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Mensaje de Error
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.cancel, color: Colors.white),
                          label: const Text(
                            'CANCELAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveEntity,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18, 
                                  height: 18, 
                                  child: CircularProgressIndicator(
                                    color: Colors.white, 
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  isEditing ? Icons.save : Icons.add_circle,
                                  color: Colors.white,
                                ),
                          label: Text(
                            _isLoading 
                                ? 'PROCESANDO...' 
                                : (isEditing ? 'GUARDAR' : 'CREAR'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryActionColor, // Botón con color primario
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
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
}