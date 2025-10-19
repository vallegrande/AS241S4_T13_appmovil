import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../widgets/header.dart';
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
  final UserService _userService = UserService();
  late TextEditingController _nameController;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isEditing => widget.entity != null;
  String get entityName =>
      widget.entityType == EntityType.role ? 'Rol' : 'Departamento';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    if (isEditing) {
      if (widget.entityType == EntityType.role) {
        _nameController.text = (widget.entity as Role).name;
      } else {
        _nameController.text = (widget.entity as Department).name;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleRoleSave() async {
    final name = _nameController.text.trim();
    final roleId = isEditing ? (widget.entity as Role).id : null;
    final newRole = Role(id: roleId, name: name);
    await _userService.saveRole(newRole);
  }

  Future<void> _handleDepartmentSave() async {
    final name = _nameController.text.trim();
    final deptId = isEditing ? (widget.entity as Department).id : null;
    final newDept = Department(id: deptId, name: name);
    await _userService.saveDepartment(newDept);
  }

  Future<void> _saveEntity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.entityType == EntityType.role) {
        await _handleRoleSave();
      } else {
        await _handleDepartmentSave();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('$entityName ${isEditing ? "actualizado" : "registrado"} con éxito'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop(true);
    } on ConflictException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al guardar el $entityName: ${e.toString()}';
        _isLoading = false;
      });
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF1100).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isEditing ? Icons.edit : Icons.add_circle,
                                      color: const Color(0xFFFF1100),
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isEditing ? 'Editar $entityName' : 'Nuevo $entityName',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isEditing
                                              ? 'Actualiza la información'
                                              : 'Completa los datos',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red[700]),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nombre del $entityName',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      hintText: 'Ej: ${widget.entityType == EntityType.role ? "Administrador" : "Recursos Humanos"}',
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFFF1100),
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Colors.red),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'El nombre es requerido';
                                      }
                                      if (value.length < 3) {
                                        return 'El nombre debe tener al menos 3 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () => Navigator.of(context).pop(),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        side: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      child: const Text(
                                        'CANCELAR',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _saveEntity,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF1100),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  isEditing ? Icons.save : Icons.add_circle,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  isEditing ? 'GUARDAR' : 'REGISTRAR',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
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
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppHeader(
              showBackButton: true,
            ),
          ),
        ],
      ),
    );
  }
}