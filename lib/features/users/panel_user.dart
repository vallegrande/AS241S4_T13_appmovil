// lib/features/users/panel_user.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:as241s4_t13_appmovil/core/models/users/user_model.dart';
import 'package:as241s4_t13_appmovil/core/models/role/role_model.dart';
import 'package:as241s4_t13_appmovil/core/services/users/user_service.dart';
import 'package:as241s4_t13_appmovil/core/services/role/role_service.dart';
import 'package:as241s4_t13_appmovil/features/users/form_user.dart';
import 'package:as241s4_t13_appmovil/config/environment.dart';

class PanelUserScreen extends StatefulWidget {
  const PanelUserScreen({super.key});

  @override
  State<PanelUserScreen> createState() => _PanelUserScreenState();
}

class _PanelUserScreenState extends State<PanelUserScreen>
    with TickerProviderStateMixin {
  final UserService _userService = UserService();
  final RoleService _roleService = RoleService();

  List<User> users = [];
  List<User> filteredUsers = [];
  bool _isLoading = true;
  String? _error;

  String? _filterState;
  String? _filterRole;
  List<Role> _roles = [];
  final _searchController = TextEditingController();

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);
  final Color surfaceBg = const Color(0xFFFAFAFC);
  final Color cardBg = Colors.white;

  late AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _loadRoles();
    _fetchUsers();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  // 🔥 MÉTODO HELPER PARA CONSTRUIR URL COMPLETA DE LA FOTO
  String _buildPhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return '';

    // Si ya es una URL completa, retornarla tal cual
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return photoPath;
    }

    // Construir URL completa desde el nombre del archivo
    // Asumiendo que el backend expone las fotos en /uploads/users/
    return '${Environment.apiUrl}/uploads/User/$photoPath';
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await _roleService.getAllRoles();
      if (mounted) setState(() => _roles = roles);
    } catch (e) {
      if (mounted) setState(() => _error = 'Error al cargar roles: $e');
    }
  }

  Future<void> _fetchUsers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final fetchedUsers = await _userService.getAllUsers();
      if (mounted) {
        users = fetchedUsers;
        _applyFilters();
        _fabAnimController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al obtener usuarios: $e';
          filteredUsers = [];
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        if (_filterState != null && _filterState != 'Todos') {
          final wantsActive = _filterState == 'Activos';
          if ((user.state ?? false) != wantsActive) return false;
        }

        if (_filterRole != null && _filterRole != 'Todos') {
          if (user.role.name != _filterRole) return false;
        }

        if (query.isNotEmpty) {
          return user.name.toLowerCase().contains(query) ||
              user.surnames.toLowerCase().contains(query) ||
              user.documentNumber.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);
        }
        return true;
      }).toList();
    });
  }

  void _goToForm({User? user}) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UserForm(user: user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
    if (result == true) _fetchUsers();
  }

  Future<void> _deleteUser(int userId) async {
    final confirm = await _showConfirmDialog(
      'Desactivar usuario',
      '¿Seguro que deseas desactivar este usuario?',
      Icons.person_off_rounded,
      Colors.orange.shade700,
    );
    if (confirm == true) {
      try {
        await _userService.deleteUser(userId);
        _fetchUsers();
        _showSnackBar('Usuario desactivado exitosamente', primaryOrange,
            Icons.check_circle_rounded);
      } catch (e) {
        _showSnackBar('Error al desactivar: $e', Colors.red.shade600,
            Icons.error_rounded);
      }
    }
  }

  Future<void> _restoreUser(int userId) async {
    final confirm = await _showConfirmDialog(
      'Reactivar usuario',
      '¿Deseas reactivar este usuario?',
      Icons.check_circle_rounded,
      Colors.green.shade600,
    );
    if (confirm == true) {
      try {
        await _userService.restoreUser(userId);
        _fetchUsers();
        _showSnackBar('Usuario reactivado exitosamente', Colors.green.shade600,
            Icons.check_circle_rounded);
      } catch (e) {
        _showSnackBar(
            'Error al reactivar: $e', Colors.red.shade600, Icons.error_rounded);
      }
    }
  }

  Future<bool?> _showConfirmDialog(
      String title, String content, IconData icon, Color color) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: cardBg,
        elevation: 8,
        contentPadding: const EdgeInsets.all(0),
        title: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28)),
            const SizedBox(width: 16),
            Expanded(
                child: Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: const Color(0xFF1A1A2E)))),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Text(content,
              style: GoogleFonts.inter(
                  fontSize: 15, color: Colors.grey.shade700, height: 1.5)),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text('Cancelar',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    fontSize: 15)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text('Confirmar',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fade(),
    );
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
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
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [primaryOrange, lightOrange, const Color(0xFFFFA556)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: primaryOrange.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 2)),
                child: const Icon(Icons.people_alt_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gestión de Usuarios',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Administra perfiles y permisos del sistema',
                        style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard('Total', users.length.toString(),
                  Icons.people_rounded, Colors.white),
              const SizedBox(width: 12),
              _buildStatCard(
                  'Activos',
                  users.where((u) => u.state == true).length.toString(),
                  Icons.check_circle_rounded,
                  Colors.green.shade400),
              const SizedBox(width: 12),
              _buildStatCard(
                  'Inactivos',
                  users.where((u) => u.state == false).length.toString(),
                  Icons.cancel_rounded,
                  Colors.red.shade400),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  Text(label,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.filter_list_rounded,
                    color: primaryOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Filtros de Búsqueda',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: TextField(
              controller: _searchController,
              style:
                  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, documento o email...',
                hintStyle: GoogleFonts.inter(
                    fontSize: 13, color: Colors.grey.shade400),
                prefixIcon:
                    Icon(Icons.search_rounded, color: primaryOrange, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded,
                            color: Colors.grey.shade400, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                filled: false,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClipRect(
            child: Row(
              children: [
                Expanded(
                  child: _buildCustomDropdown<String?>(
                    value: _filterRole,
                    hint: 'Roles',
                    icon: Icons.badge_rounded,
                    items: [
                      const DropdownMenuItem<String?>(
                          value: 'Todos', child: Text('Todos')),
                      ..._roles.map((r) => DropdownMenuItem<String?>(
                          value: r.name,
                          child: Text(r.name, style: GoogleFonts.inter()))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterRole = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCustomDropdown<String?>(
                    value: _filterState,
                    hint: 'Estados',
                    icon: Icons.toggle_on_rounded,
                    items: const [
                      DropdownMenuItem<String?>(
                          value: 'Todos', child: Text('Todos')),
                      DropdownMenuItem<String?>(
                          value: 'Activos', child: Text('Activos')),
                      DropdownMenuItem<String?>(
                          value: 'Inactivos', child: Text('Inactivos')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _filterState = v;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _filterRole = null;
                      _filterState = null;
                      _searchController.clear();
                      _applyFilters();
                    });
                  },
                  icon: const Icon(Icons.clear_all_rounded, size: 18),
                  label: Text('Limpiar',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.2, duration: 600.ms);
  }

  Widget _buildCustomDropdown<T>({
    required T value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    Widget displayed;
    if (value == null) {
      displayed = Text(hint,
          style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500));
    } else {
      Widget? found;
      for (var item in items) {
        if (item.value == value) {
          found = item.child;
          break;
        }
      }
      displayed = found ??
          Text(hint,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500));
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<T>(
          isExpanded: true,
          value: value,
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Flexible(child: displayed),
            ],
          ),
          items: items,
          onChanged: onChanged,
          buttonStyleData: ButtonStyleData(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          ),
          dropdownStyleData: DropdownStyleData(
            width: 250,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            offset: const Offset(0, 8),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.expand_more_rounded),
            iconSize: 22,
            iconEnabledColor: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _userCard(User user, int index) {
    final isActive = user.state ?? false;
    // 🔥 CONSTRUIR URL COMPLETA DE LA FOTO
    final photoUrl = _buildPhotoUrl(user.profilePhoto);

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        verticalOffset: 30,
        curve: Curves.easeOutCubic,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _goToForm(user: user),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  colors: [
                                    primaryOrange.withOpacity(0.2),
                                    const Color(0xFFFFA556).withOpacity(0.1)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                              boxShadow: [
                                BoxShadow(
                                    color: primaryOrange.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: ClipOval(
                              child: photoUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: photoUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          _buildDefaultAvatar(user),
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey.shade100,
                                        child: Center(
                                            child: CircularProgressIndicator(
                                                color: primaryOrange,
                                                strokeWidth: 2.5)),
                                      ),
                                    )
                                  : _buildDefaultAvatar(user),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.shade500
                                    : Colors.red.shade500,
                                shape: BoxShape.circle,
                                border: Border.all(color: cardBg, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          (isActive ? Colors.green : Colors.red)
                                              .withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2))
                                ],
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
                              style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A2E),
                                  letterSpacing: -0.3),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildInfoChip(
                                    icon: Icons.badge_rounded,
                                    label: user.role.name,
                                    color: primaryOrange),
                                _buildInfoChip(
                                    icon: Icons.business_rounded,
                                    label: user.department.name,
                                    color: Colors.blue.shade600),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.email_rounded,
                                    size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 6),
                                Expanded(
                                    child: Text(user.email,
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                            color: primaryOrange.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12)),
                        child: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert_rounded,
                              color: primaryOrange, size: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          offset: const Offset(-10, 40),
                          onSelected: (value) {
                            if (value == 'edit') _goToForm(user: user);
                            if (value == 'toggle_state') {
                              isActive
                                  ? _deleteUser(user.idUser!)
                                  : _restoreUser(user.idUser!);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: primaryOrange.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Icon(Icons.edit_rounded,
                                          color: primaryOrange, size: 18)),
                                  const SizedBox(width: 12),
                                  Text('Editar usuario',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(height: 8),
                            PopupMenuItem(
                              value: 'toggle_state',
                              child: Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: (isActive
                                                  ? Colors.red
                                                  : Colors.green)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Icon(
                                          isActive
                                              ? Icons.person_off_rounded
                                              : Icons.check_circle_rounded,
                                          color: isActive
                                              ? Colors.red.shade600
                                              : Colors.green.shade600,
                                          size: 18)),
                                  const SizedBox(width: 12),
                                  Text(isActive ? 'Desactivar' : 'Reactivar',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: isActive
                                              ? Colors.red.shade700
                                              : Colors.green.shade700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 WIDGET HELPER PARA AVATAR POR DEFECTO
  Widget _buildDefaultAvatar(User user) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [primaryOrange, lightOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)),
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [Colors.red.shade50, Colors.red.shade100]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.red.shade600, shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded,
                  color: Colors.white, size: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error al cargar datos',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade900,
                        fontSize: 16)),
                const SizedBox(height: 2),
                Text(_error!,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade800,
                        fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _error = null),
            icon: Icon(Icons.close_rounded, color: Colors.red.shade700),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    ).animate().shake(hz: 4, duration: 500.ms).fadeIn();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.grey.shade50, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                shape: BoxShape.circle),
            child: Icon(Icons.person_search_rounded,
                size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text('No se encontraron usuarios',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text('Intenta ajustar los filtros o crear uno nuevo',
              style:
                  GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _filterRole = null;
                _filterState = null;
                _searchController.clear();
                _applyFilters();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Limpiar filtros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: primaryOrange.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            child:
                CircularProgressIndicator(color: primaryOrange, strokeWidth: 3),
          )
              .animate()
              .scale(duration: 800.ms, curve: Curves.easeInOut)
              .then()
              .shake(hz: 2),
          const SizedBox(height: 24),
          Text('Cargando usuarios...',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : surfaceBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 12),
                  _buildFilters(context),
                  const SizedBox(height: 12),
                  if (_error != null) _buildErrorBanner(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            SliverFillRemaining(
              child: _buildLoadingState(),
            ),
          if (!_isLoading && filteredUsers.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            ),
          if (!_isLoading && filteredUsers.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _userCard(filteredUsers[index], index),
                  childCount: filteredUsers.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimController,
        child: FloatingActionButton.extended(
          onPressed: () => _goToForm(),
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(Icons.person_add_rounded, size: 24),
          label: Text(
            'Nuevo Usuario',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
