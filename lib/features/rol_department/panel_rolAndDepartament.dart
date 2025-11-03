// lib/features/roles_departments/panel_rolAndDepartament.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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

class _PanelRolAndDepartamentState extends State<PanelRolAndDepartament>
    with TickerProviderStateMixin {
  final RoleService _roleService = RoleService();
  final DepartmentService _departmentService = DepartmentService();

  EntityType _currentEntity = EntityType.role;
  List<Role> _roles = [];
  List<Department> _departments = [];
  bool _isLoading = true;
  String? _error;

  late AnimationController _fabController;

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);
  final Color surfaceBg = const Color(0xFFFAFAFC);
  final Color cardBg = Colors.white;

  final List<String> _predefinedRoles = [
    'ADMIN',
    'CAJERO',
    'COCINERO',
    'HORNERO',
    'BARTENDER',
    'MOZO',
    'REPARTIDOR'
  ];

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
    _fabController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fetchData();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = _currentEntity == EntityType.role
          ? await _roleService.getAllRoles()
          : await _departmentService.getAllDepartments();

      if (mounted) {
        setState(() {
          if (_currentEntity == EntityType.role) {
            _roles = data as List<Role>;
          } else {
            _departments = data as List<Department>;
          }
        });
        _fabController.forward();
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _switchEntity(EntityType type) {
    if (_currentEntity != type) {
      setState(() => _currentEntity = type);
      _fetchData();
    }
  }

  void _goToForm() async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, _, __) =>
            FormRolAndDepartament(entityType: _currentEntity),
        transitionsBuilder: (context, animation, _, child) {
          final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeInOutCubic));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
    if (result == true) _fetchData();
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
              child: Text(message,
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w600))),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String get entityName =>
      _currentEntity == EntityType.role ? 'Rol' : 'Departamento';

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [primaryOrange, lightOrange, const Color(0xFFFFA556)]),
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
                      color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: Icon(
                  _currentEntity == EntityType.role
                      ? Icons.badge_rounded
                      : Icons.business_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de $entityName${_currentEntity == EntityType.role ? 'es' : 's'}',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Solo se pueden crear elementos predefinidos',
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.9), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3);
  }

  Widget _buildTabButton(EntityType type, String title, IconData icon) {
    final isSelected = _currentEntity == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchEntity(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [primaryOrange, lightOrange])
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: primaryOrange.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6))
                  ]
                : [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  size: 22),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.grey.shade700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntityCard(dynamic item, int index) {
    final String name = item is Role ? item.name : item.name;
    final int id = item is Role ? item.id : item.id;
    final bool isPredefined = (_currentEntity == EntityType.role &&
            _predefinedRoles.contains(name)) ||
        (_currentEntity == EntityType.department &&
            _predefinedDepartments.contains(name));

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 475),
      child: SlideAnimation(
        verticalOffset: 50,
        child: FadeInAnimation(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(
                  _currentEntity == EntityType.role
                      ? Icons.badge_rounded
                      : Icons.business_rounded,
                  color: primaryOrange,
                  size: 28,
                ),
              ),
              title: Text(name,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E))),
              subtitle: Row(
                children: [
                  Text('ID: $id',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.grey.shade600)),
                  if (isPredefined) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('PREDEFINIDO',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            ),
          ).animate().shimmer(duration: 1200.ms),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _currentEntity == EntityType.role ? _roles : _departments;

    return Column(
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTabButton(EntityType.role, 'Roles', Icons.badge_rounded),
              _buildTabButton(EntityType.department, 'Departamentos',
                  Icons.business_rounded),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_error != null)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(children: [
              Icon(Icons.error_rounded, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(_error!,
                      style: GoogleFonts.inter(color: Colors.red.shade800))),
            ]),
          ).animate().shake().fadeIn(),
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: primaryOrange)
                      .animate()
                      .scale()
                      .shimmer())
              : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _currentEntity == EntityType.role
                                ? Icons.badge_outlined
                                : Icons.business_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay ${entityName.toLowerCase()}s',
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 8),
                          Text('Crea uno nuevo con el botón +',
                              style: GoogleFonts.inter(
                                  color: Colors.grey.shade500)),
                        ],
                      ).animate().fadeIn().scale(curve: Curves.easeOutBack),
                    )
                  : AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: items.length,
                        itemBuilder: (context, index) =>
                            _buildEntityCard(items[index], index),
                      ),
                    ),
        ),
      ],
    );
  }
}
