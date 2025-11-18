// lib/features/tables/panel_table.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:as241s4_t13_appmovil/core/models/table/table_model.dart';
import 'package:as241s4_t13_appmovil/core/services/table/table_service.dart';
import 'package:as241s4_t13_appmovil/features/table/table_form.dart';

class PanelTableScreen extends StatefulWidget {
  const PanelTableScreen({super.key});

  @override
  State<PanelTableScreen> createState() => _PanelTableScreenState();
}

class _PanelTableScreenState extends State<PanelTableScreen> {
  final TableService _tableService = TableService();
  List<TableModel> _tables = [];
  List<TableModel> _filteredTables = [];
  bool _isLoading = true;
  bool _showInactive = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Colores del tema
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color lightOrange = Color(0xFFFF8C42);
  static const Color accentOrange = Color(0xFFFFA556);

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() => _isLoading = true);
    try {
      final tables = await _tableService.getAllTables();
      setState(() {
        _tables = tables;
        _filterTables();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error al cargar las mesas: $e');
    }
  }

  void _filterTables() {
    setState(() {
      _filteredTables = _tables.where((table) {
        final matchesSearch =
            table.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (table.location
                        ?.toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ??
                    false);
        final matchesState = _showInactive ? true : table.isActive;
        return matchesSearch && matchesState;
      }).toList();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showTableDialog({TableModel? table}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TableForm(
          table: table,
          onSave: (newTable) async {
            Navigator.pop(context);
            try {
              if (table == null) {
                await _tableService.createTable(newTable);
                _showSuccessSnackBar('Mesa creada exitosamente');
              } else {
                await _tableService.updateTable(table.idTable!, newTable);
                _showSuccessSnackBar('Mesa actualizada exitosamente');
              }
              _loadTables();
            } catch (e) {
              _showErrorSnackBar('Error al guardar: $e');
            }
          },
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Future<void> _deleteTable(TableModel table) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Confirmar Eliminación'),
          ],
        ),
        content: Text(
          '¿Está seguro de eliminar la mesa "${table.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _tableService.deleteTable(table.idTable!);
        _showSuccessSnackBar('Mesa eliminada exitosamente');
        _loadTables();
      } catch (e) {
        _showErrorSnackBar('Error al eliminar: $e');
      }
    }
  }

  Future<void> _restoreTable(TableModel table) async {
    try {
      await _tableService.restoreTable(table.idTable!);
      _showSuccessSnackBar('Mesa restaurada exitosamente');
      _loadTables();
    } catch (e) {
      _showErrorSnackBar('Error al restaurar: $e');
    }
  }

  void _showTableOptions(TableModel table) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              table.name,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (table.isActive) ...[
              _buildOptionButton(
                icon: Icons.edit_rounded,
                label: 'Editar Mesa',
                color: primaryOrange,
                onTap: () {
                  Navigator.pop(context);
                  _showTableDialog(table: table);
                },
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                icon: Icons.delete_rounded,
                label: 'Eliminar Mesa',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _deleteTable(table);
                },
              ),
            ] else
              _buildOptionButton(
                icon: Icons.restore_rounded,
                label: 'Restaurar Mesa',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _restoreTable(table);
                },
              ),
            const SizedBox(height: 12),
            _buildOptionButton(
              icon: Icons.close_rounded,
              label: 'Cancelar',
              color: Colors.grey,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _buildHeader(isDark),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _isLoading
                ? SliverFillRemaining(child: _buildLoadingState())
                : _filteredTables.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState(isDark))
                    : _buildTableGridSliver(isDark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTableDialog(),
        backgroundColor: primaryOrange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Nueva Mesa',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
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
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: CircularProgressIndicator(
              color: primaryOrange,
              strokeWidth: 3,
            ),
          )
              .animate()
              .scale(duration: 800.ms, curve: Curves.easeInOut)
              .then()
              .shake(hz: 2),
          const SizedBox(height: 24),
          Text(
            'Cargando mesas...',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.table_bar_rounded,
              size: 80,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No se encontraron mesas',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta ajustar los filtros o crear una nueva',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showInactive = false;
                _searchController.clear();
                _searchQuery = '';
                _filterTables();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Limpiar filtros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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

  Widget _buildTableGridSliver(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 100),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          if (constraints.crossAxisExtent > 1200) {
            crossAxisCount = 4;
          } else if (constraints.crossAxisExtent > 900) {
            crossAxisCount = 3;
          } else if (constraints.crossAxisExtent > 600) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 2;
          }

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final table = _filteredTables[index];
                return _buildTableCard(table, isDark, index);
              },
              childCount: _filteredTables.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final activeTables = _tables.where((t) => t.isActive).length;
    final inactiveTables = _tables.where((t) => !t.isActive).length;
    final occupiedTables = _tables.where((t) => t.isOccupied).length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryOrange, lightOrange, accentOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryOrange.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
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
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.table_restaurant_rounded,
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
                          'Gestión de Mesas',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Administra mesas y ocupación del restaurante',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatCard(
                    'Total',
                    _tables.length.toString(),
                    Icons.table_bar_rounded,
                    Colors.white,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Ocupadas',
                    occupiedTables.toString(),
                    Icons.people_rounded,
                    Colors.amber.shade300,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Activas',
                    activeTables.toString(),
                    Icons.check_circle_rounded,
                    Colors.green.shade400,
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOutCubic),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              )
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: primaryOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filtros de Búsqueda',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : const Color(0xFFFAFAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _filterTables();
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o ubicación...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: primaryOrange,
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _filterTables();
                            },
                          )
                        : null,
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredTables.length} mesas encontradas',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _showInactive
                              ? primaryOrange.withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _showInactive
                                ? primaryOrange.withOpacity(0.3)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() => _showInactive = !_showInactive);
                            _filterTables();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _showInactive
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: _showInactive
                                    ? primaryOrange
                                    : Colors.grey.shade600,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _showInactive
                                    ? 'Con inactivas'
                                    : 'Solo activas',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _showInactive
                                      ? primaryOrange
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _loadTables,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: primaryOrange,
                        ),
                        tooltip: 'Actualizar',
                        style: IconButton.styleFrom(
                          backgroundColor: primaryOrange.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideY(begin: 0.2, duration: 600.ms),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(TableModel table, bool isDark, int index) {
    final occupancyPercentage = table.occupancyPercentage;
    Color statusColor = Colors.green;
    String statusText = 'Disponible';
    IconData statusIcon = Icons.check_circle_rounded;

    if (table.isOccupied) {
      if (occupancyPercentage >= 100) {
        statusColor = Colors.red;
        statusText = 'Llena';
        statusIcon = Icons.block_rounded;
      } else {
        statusColor = Colors.orange;
        statusText = 'Ocupada';
        statusIcon = Icons.people_rounded;
      }
    }

    if (!table.isActive) {
      statusColor = Colors.grey;
      statusText = 'Inactiva';
      statusIcon = Icons.power_settings_new_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: table.isActive
                ? statusColor.withOpacity(0.15)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTableOptions(table),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: table.isActive
                  ? (isDark ? const Color(0xFF2D2D2D) : Colors.white)
                  : Colors.grey.withOpacity(0.15),
              border: Border.all(
                color: table.isActive
                    ? statusColor.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header compacto: Icono y badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: table.isActive
                                ? [primaryOrange, lightOrange]
                                : [Colors.grey[600]!, Colors.grey[400]!],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.table_restaurant_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Nombre de la mesa más grande
                  Text(
                    table.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: table.isActive
                          ? (isDark ? Colors.white : Colors.black87)
                          : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Ubicación
                  if (table.location != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            table.location!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 10),

                  // Separador sutil
                  Divider(
                    color: statusColor.withOpacity(0.2),
                    thickness: 1,
                    height: 6,
                  ),

                  const SizedBox(height: 6),

                  // Información de ocupación compacta
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryOrange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.groups_rounded,
                          size: 16,
                          color: primaryOrange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ocupación',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${table.currentOccupancy}/${table.capacity}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Barra de progreso más grande
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor:
                                    (occupancyPercentage / 100).clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Porcentaje
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '${occupancyPercentage.toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
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
    ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).scale(
          begin: const Offset(0.9, 0.9),
          duration: 500.ms,
          delay: (index * 50).ms,
          curve: Curves.easeOutBack,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
