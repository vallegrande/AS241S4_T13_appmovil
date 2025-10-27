import 'package:flutter/material.dart';

import 'package:as241s4_t13_appmovil/core/models/role/role_model.dart';
import 'package:as241s4_t13_appmovil/core/models/department/department_model.dart';

import 'package:as241s4_t13_appmovil/core/services/role/role_service.dart';
import 'package:as241s4_t13_appmovil/core/services/department/department_service.dart';

import 'form_rolAndDepartament.dart';

enum EntityType { role, department }

class PanelRolAndDepartament extends StatefulWidget {
  const PanelRolAndDepartament({super.key});

  @override
  State<PanelRolAndDepartament> createState() => _PanelRolAndDepartamentState();
}

class _PanelRolAndDepartamentState extends State<PanelRolAndDepartament> {
  // 🎨 PALETA DE COLORES
  static const Color primaryActionColor = Color(0xFFFF4500); // Un rojo/naranja vibrante
  static const Color backgroundColor = Color(0xFFF8F9FA); // Fondo limpio
  static const Color secondaryTextColor = Color(0xFF2D3142); // Texto oscuro

  final RoleService _roleService = RoleService();
  final DepartmentService _departmentService = DepartmentService();

  EntityType _currentEntity = EntityType.role;
  List<Role> _roles = [];
  List<Department> _departments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_currentEntity == EntityType.role) {
        final roles = await _roleService.getAllRoles();
        if (mounted) {
          setState(() {
            _roles = roles;
          });
        }
      } else {
        final departments = await _departmentService.getAllDepartments();
        if (mounted) {
          setState(() {
            _departments = departments;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar los datos: ${e.toString()}';
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

  void _switchEntity(EntityType type) {
    if (_currentEntity != type) {
      setState(() {
        _currentEntity = type;
      });
      _fetchData();
    }
  }

  void _goToForm({dynamic entity}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FormRolAndDepartament(
          entityType: _currentEntity,
          entity: entity,
        ),
      ),
    );

    if (result == true) {
      _fetchData();
    }
  }

  // Método para eliminar con diálogo de confirmación
  Future<void> _deleteEntity(int id, String name) async {
    final entityName = _currentEntity == EntityType.role ? 'Rol' : 'Departamento';

    // Mostrar diálogo de confirmación
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
              const SizedBox(width: 10),
              const Text('Confirmar eliminación'),
            ],
          ),
          content: Text(
            '¿Estás seguro de eliminar "$name"?\n\nEsta acción no se puede deshacer.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'CANCELAR',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Rojo fuerte para la acción peligrosa
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'ELIMINAR',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    // Si el usuario no confirmó, salir
    if (confirmed != true) return;

    // Mostrar indicador de carga
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: const CircularProgressIndicator(color: primaryActionColor),
      ),
    );

    try {
      // Eliminar según el tipo
      if (_currentEntity == EntityType.role) {
        await _roleService.deleteRole(id);
      } else {
        await _departmentService.deleteDepartment(id);
      }

      if (!mounted) return;
      
      // Cerrar el diálogo de carga
      Navigator.of(context).pop();

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$entityName eliminado correctamente',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Recargar datos
      _fetchData();
    } catch (e) {
      if (!mounted) return;
      
      // Cerrar el diálogo de carga
      Navigator.of(context).pop();

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al eliminar: ${e.toString()}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildList<T>({
    required List<T> items, 
    required Function(T) getName, 
    required Function(T) getId,
  }) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryActionColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
            const SizedBox(height: 15),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryActionColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _currentEntity == EntityType.role 
                  ? Icons.badge_outlined 
                  : Icons.business_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'No hay ${entityName.toLowerCase()}s registrados',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Presiona el botón + para crear uno',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final id = getId(item);
        final name = getName(item);
        
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // Diseño en blanco limpio
              color: Colors.white,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryActionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _currentEntity == EntityType.role 
                      ? Icons.badge_outlined 
                      : Icons.business_outlined,
                  color: primaryActionColor,
                  size: 28,
                ),
              ),
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: secondaryTextColor,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'ID: $id',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón Editar
                  IconButton(
                    icon: const Icon(Icons.edit, color: primaryActionColor),
                    tooltip: 'Editar',
                    onPressed: () => _goToForm(entity: item),
                  ),
                  // Botón Eliminar
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar',
                    onPressed: () => _deleteEntity(id, name),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get _buildBody {
    if (_currentEntity == EntityType.role) {
      return _buildList<Role>(
        items: _roles,
        getName: (role) => role.name,
        getId: (role) => role.id,
      );
    } else {
      return _buildList<Department>(
        items: _departments,
        getName: (dept) => dept.name,
        getId: (dept) => dept.id,
      );
    }
  }

  String get entityName => _currentEntity == EntityType.role ? 'ROL' : 'DEPARTAMENTO';

  Widget _buildTabButton(EntityType type, String title) {
    final isSelected = _currentEntity == type;
    return Expanded(
      child: InkWell(
        onTap: () => _switchEntity(type),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            // Degradado con el color primario
            gradient: isSelected
                ? const LinearGradient(
                    colors: [primaryActionColor, Color(0xFFFF694F)], 
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white, // Fondo blanco cuando no está seleccionado
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryActionColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                  BoxShadow( // Sombra suave para los no seleccionados
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                ],
            border: isSelected ? null : Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == EntityType.role ? Icons.badge : Icons.business,
                color: isSelected ? Colors.white : secondaryTextColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                _buildTabButton(EntityType.role, 'Roles'),
                const SizedBox(width: 15),
                _buildTabButton(EntityType.department, 'Departamentos'),
              ],
            ),
          ),
          
          // Contenido
          Expanded(
            child: _buildBody,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToForm(),
        backgroundColor: primaryActionColor,
        icon: const Icon(Icons.add_circle, color: Colors.white, size: 24),
        label: Text(
          'NUEVO $entityName',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 8,
      ),
    );
  }
}