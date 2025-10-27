import 'package:flutter/material.dart';

import 'package:as241s4_t13_appmovil/core/models/users/user_model.dart';
import 'package:as241s4_t13_appmovil/core/models/role/role_model.dart';
import 'package:as241s4_t13_appmovil/core/services/users/user_service.dart';
import 'package:as241s4_t13_appmovil/core/services/role/role_service.dart';
import 'package:as241s4_t13_appmovil/widgets/header.dart';

import 'form_user.dart';

class PanelUserScreen extends StatefulWidget {
  const PanelUserScreen({super.key});

  @override
  State<PanelUserScreen> createState() => _PanelUserScreenState();
}

class _PanelUserScreenState extends State<PanelUserScreen> {
  final UserService _userService = UserService();
  final RoleService _roleService = RoleService();

  List<User> users = [];
  List<User> filteredUsers = [];
  bool _isLoading = true;
  String? _error;

  bool? _filterState;
  String? _filterRole;
  List<Role> _roles = [];
  final _searchController = TextEditingController();

  // Color principal (rojo) usado en todo el archivo
  final Color primaryRed = Colors.red.shade700;

  @override
  void initState() {
    super.initState();
    _loadRoles();
    _fetchUsers();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await _roleService.getAllRoles();
      setState(() {
        _roles = roles;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar roles: $e';
        });
      }
    }
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final fetchedUsers = await _userService.getAllUsers();
      setState(() {
        users = fetchedUsers;
        _applyFilters();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al obtener usuarios: $e';
          filteredUsers = [];
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

  void _applyFilters() {
    setState(() {
      filteredUsers = users.where((user) {
        if (_filterState != null && user.state != _filterState) {
          return false;
        }
        if (_filterRole != null && user.role.name != _filterRole) {
          return false;
        }
        final searchText = _searchController.text.toLowerCase();
        if (searchText.isNotEmpty) {
          return user.name.toLowerCase().contains(searchText) ||
              user.surnames.toLowerCase().contains(searchText) ||
              user.documentNumber.toLowerCase().contains(searchText) ||
              user.email.toLowerCase().contains(searchText);
        }
        return true;
      }).toList();
    });
  }

  void _goToForm({User? user}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserForm(user: user),
      ),
    );

    if (result == true) {
      _fetchUsers();
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirm = await _showConfirmDialog(
      '¿Desactivar Usuario?',
      '¿Estás seguro de que deseas desactivar este usuario?',
    );

    if (confirm == true) {
      try {
        await _userService.deleteUser(userId);
        _fetchUsers();
        _showSnackBar('Usuario desactivado correctamente', Colors.orange);
      } catch (e) {
        _showSnackBar('Error al desactivar usuario: $e', Colors.red);
      }
    }
  }

  Future<void> _restoreUser(int userId) async {
    final confirm = await _showConfirmDialog(
      '¿Reactivar Usuario?',
      '¿Estás seguro de que deseas reactivar este usuario?',
    );

    if (confirm == true) {
      try {
        await _userService.restoreUser(userId);
        _fetchUsers();
        _showSnackBar('Usuario reactivado correctamente', Colors.green);
      } catch (e) {
        _showSnackBar('Error al reactivar usuario: $e', Colors.red);
      }
    }
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _userCard(User user, int index) {
    final isActive = user.state ?? false;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? primaryRed : Colors.grey,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isActive ? primaryRed : Colors.grey).withOpacity(0.25),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: user.profilePhoto != null
                          ? Image.network(
                              user.profilePhoto!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => const Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.name} ${user.surnames}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 16, color: primaryRed),
                        const SizedBox(width: 6),
                        Text(
                          user.role.name,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.business, size: 16, color: primaryRed),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            user.department.name,
                            style: TextStyle(color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email, size: 16, color: primaryRed),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            user.email,
                            style: const TextStyle(color: Colors.blueGrey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive ? Colors.green : Colors.red,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        isActive ? 'ACTIVO' : 'INACTIVO',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: primaryRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _goToForm(user: user);
                  } else if (value == 'toggle_state') {
                    isActive ? _deleteUser(user.idUser!) : _restoreUser(user.idUser!);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: primaryRed, size: 20),
                        const SizedBox(width: 10),
                        const Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_state',
                    child: Row(
                      children: [
                        Icon(
                          isActive ? Icons.cancel : Icons.check_circle,
                          color: isActive ? Colors.red : Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isActive ? 'Desactivar' : 'Reactivar',
                          style: TextStyle(
                            color: isActive ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  // Si quieres ocupar literalmente todo el ancho, elimina la siguiente línea:
                  constraints: const BoxConstraints(maxWidth: 1200),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header - ahora en rojo
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryRed, Colors.red.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: primaryRed.withOpacity(0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people, color: Colors.white, size: 32),
                            const SizedBox(width: 15),
                            const Text(
                              'Gestión de Usuarios',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  labelText: 'Buscar por Nombre, Documento o Email',
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: primaryRed,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: primaryRed,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Wrap(
                                spacing: 15,
                                runSpacing: 15,
                                alignment: WrapAlignment.center,
                                children: [
                                  // DROPDOWN SIMPLE DE ROL
                                  Container(
                                    width: 200,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: primaryRed),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        hint: const Text('Filtrar por Rol'),
                                        value: _filterRole,
                                        items: [
                                          const DropdownMenuItem<String>(
                                            value: null,
                                            child: Text('Todos los Roles'),
                                          ),
                                          ..._roles.map((role) => DropdownMenuItem<String>(
                                                value: role.name,
                                                child: Text(role.name),
                                              )),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _filterRole = value;
                                            _applyFilters();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  // DROPDOWN SIMPLE DE ESTADO
                                  Container(
                                    width: 200,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: primaryRed),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<bool?>(
                                        isExpanded: true,
                                        hint: const Text('Filtrar Estado'),
                                        value: _filterState,
                                        items: const [
                                          DropdownMenuItem<bool?>(
                                            value: null,
                                            child: Text('Todos los Estados'),
                                          ),
                                          DropdownMenuItem<bool?>(
                                            value: true,
                                            child: Text(
                                              'Activos',
                                              style: TextStyle(color: Colors.green),
                                            ),
                                          ),
                                          DropdownMenuItem<bool?>(
                                            value: false,
                                            child: Text(
                                              'Inactivos',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _filterState = value;
                                            _applyFilters();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _filterRole = null;
                                        _filterState = null;
                                        _searchController.clear();
                                        _applyFilters();
                                      });
                                    },
                                    icon: const Icon(Icons.clear_all, color: Colors.white),
                                    label: const Text(
                                      'Limpiar Filtros',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: primaryRed,
                              ),
                            )
                          : filteredUsers.isEmpty
                              ? Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(40),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.person_off_outlined,
                                          size: 80,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'No se encontraron usuarios',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Intenta ajustar los filtros de búsqueda',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredUsers.length,
                                  itemBuilder: (context, index) =>
                                      _userCard(filteredUsers[index], index),
                                ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToForm(),
        backgroundColor: primaryRed,
        icon: const Icon(Icons.add_circle, color: Colors.white),
        label: const Text(
          'NUEVO USUARIO',
          style: TextStyle(
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
