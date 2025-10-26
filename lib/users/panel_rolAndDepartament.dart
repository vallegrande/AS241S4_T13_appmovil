// Archivo: lib/users/panel_rolAndDepartament.dart
import 'package:flutter/material.dart';
// Importa las clases de modelo y auxiliares desde user_service.dart (archivo intocable)
import '../services/user_service.dart'; 
// Importa los servicios funcionales extraídos
import '../services/role_service.dart'; 
import '../services/department_service.dart';
import 'form_rolAndDepartament.dart';
import '../widgets/header.dart';

enum EntityType { role, department }

class PanelRolAndDepartament extends StatefulWidget {
  const PanelRolAndDepartament({super.key});

  @override
  State<PanelRolAndDepartament> createState() => _PanelRolAndDepartamentState();
}

class _PanelRolAndDepartamentState extends State<PanelRolAndDepartament> {
  // Usamos los servicios funcionales nuevos
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
      // Llamada a los servicios funcionales
      final fetchedRoles = await _roleService.getRoles(); 
      final fetchedDepartments = await _departmentService.getDepartments();
      
      if (!mounted) return;
      setState(() {
        _roles = fetchedRoles;
        _departments = fetchedDepartments;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar los datos: $e';
        _isLoading = false;
      });
    }
  }

  // ... (Resto de la UI y métodos sin cambios) ...
  void _openForm({dynamic entity, required EntityType type}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => FormRolAndDepartament(
              entityType: type,
              entity: entity,
            ),
          ),
        )
        .then((result) {
      if (result == true) {
        _fetchData();
      }
    });
  }

  Widget _buildEntityCard(dynamic item, int index) {
    final id = _currentEntity == EntityType.role ? (item as Role).id : (item as Department).id;
    final name = _currentEntity == EntityType.role ? (item as Role).name : (item as Department).name;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFF1100).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  id.toString(),
                  style: const TextStyle(
                    color: Color(0xFFFF1100),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentEntity == EntityType.role ? 'Rol del sistema' : 'Departamento',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF1100).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Image.asset(
                  'assets/card_user/editar.png',
                  width: 24,
                  height: 24,
                  color: const Color(0xFFFF1100),
                ),
                onPressed: () => _openForm(entity: item, type: _currentEntity),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _currentEntity == EntityType.role ? _roles : _departments;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestión de Roles y Departamentos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTabButton(EntityType.role, 'Roles'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTabButton(EntityType.department, 'Departamentos'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF1100),
                          ),
                        )
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : list.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.folder_open,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No hay ${_currentEntity == EntityType.role ? "roles" : "departamentos"} registrados',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(top: 16, bottom: 100),
                                  itemCount: list.length,
                                  itemBuilder: (context, index) =>
                                      _buildEntityCard(list[index], index),
                                ),
                ),
              ],
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppHeader(),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: _isLoading ? null : () => _openForm(type: _currentEntity),
              backgroundColor: const Color(0xFFFF1100),
              elevation: 6,
              icon: const Icon(Icons.add, color: Colors.white, size: 28),
              label: Text(
                'AGREGAR ${_currentEntity == EntityType.role ? "ROL" : "DEPTO"}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(EntityType type, String title) {
    final isSelected = _currentEntity == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentEntity = type;
        });
        _fetchData();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF1100) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF1100).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}