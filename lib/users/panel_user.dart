// Archivo: lib/users/panel_user.dart
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart'; 
// Importa clases auxiliares (User, Role) desde user_service.dart
import '../services/user_service.dart';
// Importa el servicio de roles funcional
import '../services/role_service.dart';
import 'form_user.dart';
import '../widgets/header.dart';

class PanelUserScreen extends StatefulWidget {
  const PanelUserScreen({super.key});

  @override
  State<PanelUserScreen> createState() => _PanelUserScreenState();
}

class _PanelUserScreenState extends State<PanelUserScreen> {
  final UserService _userService = UserService();
  final RoleService _roleService = RoleService(); // Usamos el servicio extraído
  
  List<User> users = [];
  List<User> filteredUsers = [];
  bool _isLoading = true;
  String? _error;

  bool? _filterState;
  String? _filterRole;
  List<Role> _roles = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRoles();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await _roleService.getRoles(); // Usamos RoleService
      if (!mounted) return;
      setState(() {
        _roles = roles;
      });
    } catch (e) {
    }
  }

  // ... (Resto de la lógica sin cambios mayores, ya que usa _userService)
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final fetchedUsers = await _userService.getUsers(
        state: _filterState,
      );

      if (!mounted) return;
      setState(() {
        users = fetchedUsers;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar usuarios: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    filteredUsers = users.where((user) {
      final searchText = _searchController.text.toLowerCase();
      final matchesSearch = searchText.isEmpty ||
          user.name.toLowerCase().contains(searchText) ||
          user.surnames.toLowerCase().contains(searchText) ||
          user.email.toLowerCase().contains(searchText) ||
          user.documentNumber.contains(searchText);

      final matchesRole = _filterRole == null || user.role.name == _filterRole;

      return matchesSearch && matchesRole;
    }).toList();
  }

  void _openUserForm({User? user}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => UserForm(user: user),
          ),
        )
        .then((result) {
      if (result == true) {
        _fetchUsers();
      }
    });
  }

  Future<void> _softDeleteUser(int id) async {
    setState(() { _isLoading = true; });
    try {
      await _userService.softDeleteUser(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchUsers();
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _restoreUser(int id) async {
    setState(() { _isLoading = true; });
    try {
      await _userService.restoreUser(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario restaurado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchUsers();
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Color _getRoleColor(String roleName) {
    final role = roleName.toLowerCase();
    if (role.contains('admin')) return Colors.green;
    if (role.contains('gerente')) return Colors.purple;
    if (role.contains('cocinero') || role.contains('cajero')) return Colors.red;
    if (role.contains('mozo') || role.contains('mesero')) return Colors.orange;
    return Colors.blue;
  }

  Widget _userCard(User user, int index) {
    final isActive = user.state;
    final roleColor = _getRoleColor(user.role.name);

    String? photoUrl;
    if (user.profilePhoto != null && user.profilePhoto!.isNotEmpty) {
      if (user.profilePhoto!.startsWith('http')) {
        photoUrl = user.profilePhoto;
      } else {
        photoUrl = 'http://localhost:8080/uploads/${user.profilePhoto}';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Foto de perfil
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: const Color(0xFFFF1100),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error cargando foto: $error');
                            return Image.asset(
                              'assets/formUser/defaultUser.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/formUser/defaultUser.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.name} ${user.surnames}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Image.asset("assets/card_user/gmail.png", height: 14),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          user.email,
                          style: const TextStyle(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (user.phone != null) ...[
                    Row(
                      children: [
                        Image.asset("assets/card_user/telefono.png", height: 14),
                        const SizedBox(width: 5),
                        Text(user.phone!, style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 2),
                  ],
                  Row(
                    children: [
                      Image.asset("assets/card_user/carnet.png", height: 14),
                      const SizedBox(width: 5),
                      Text(
                        '${user.documentType}: ${user.documentNumber}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? roleColor.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    isActive ? user.role.name : 'Inactivo',
                    style: TextStyle(
                      color: isActive ? roleColor : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _openUserForm(user: user),
                      child: Image.asset(
                        "assets/card_user/editar.png",
                        height: 21,
                      ),
                    ),
                    const SizedBox(width: 9),
                    InkWell(
                      onTap: () {
                        if (isActive) {
                          _softDeleteUser(user.idUser!);
                        } else {
                          _restoreUser(user.idUser!);
                        }
                      },
                      child: Image.asset(
                        isActive
                            ? "assets/card_user/eliminar.png"
                            : "assets/card_user/restaurar.png",
                        height: 21,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const AppHeader(),
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Text(
                                "Panel de usuarios",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.info_outline,
                                color: Colors.red,
                                size: 22,
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => _openUserForm(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(13),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Todos tus usuarios',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Buscar usuarios",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField2<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        isExpanded: true,
                        hint: const Text("Todos los roles"),
                        value: _filterRole,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("Todos los roles", style: TextStyle(fontSize: 15)),
                          ),
                          ..._roles.map((role) => DropdownMenuItem(
                            value: role.name,
                            child: Text(role.name, style: const TextStyle(fontSize: 15)),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterRole = value;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField2<bool?>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        isExpanded: true,
                        hint: const Text("Todos los estados"),
                        value: _filterState,
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text("Todos los estados", style: TextStyle(fontSize: 15)),
                          ),
                          DropdownMenuItem(
                            value: true,
                            child: Text("Activo", style: TextStyle(fontSize: 15)),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text("Inactivo", style: TextStyle(fontSize: 15)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterState = value;
                          });
                          _fetchUsers();
                        },
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Función en desarrollo')),
                            );
                          },
                          child: const Text(
                            "Descargar reporte",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                          style: const TextStyle(color: Colors.red),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _fetchUsers,
                                          child: const Text('Reintentar'),
                                        ),
                                      ],
                                    ),
                                  )
                                : filteredUsers.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.people_outline,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'No hay usuarios que coincidan con los filtros',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: filteredUsers.length,
                                        itemBuilder: (context, index) =>
                                            _userCard(filteredUsers[index], index),
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
    );
  }
}