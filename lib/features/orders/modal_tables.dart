import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:as241s4_t13_appmovil/core/models/table/table_model.dart';
import 'package:as241s4_t13_appmovil/core/services/table/table_service.dart';

class TableSelectionModal extends StatefulWidget {
  final int numberOfPeople;

  const TableSelectionModal({
    Key? key,
    required this.numberOfPeople,
  }) : super(key: key);

  @override
  State<TableSelectionModal> createState() => _TableSelectionModalState();
}

class _TableSelectionModalState extends State<TableSelectionModal> {
  final TableService _tableService = TableService();
  List<TableModel> _tables = [];
  List<TableModel> _filteredTables = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color surfaceBg = const Color(0xFFFAFAFC);

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    try {
      setState(() => _isLoading = true);
      final tables = await _tableService.getTablesByState(true);
      setState(() {
        _tables = tables;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _applyFilters() {
    var filtered = _tables;

    if (_filterType == 'AVAILABLE') {
      filtered = filtered.where((t) => !t.isOccupied).toList();
    } else if (_filterType == 'OCCUPIED') {
      filtered = filtered.where((t) => t.isOccupied).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.name.toLowerCase().contains(_searchQuery) ||
            (t.location?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    setState(() => _filteredTables = filtered);
  }

  void _filterTables(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _applyFilters();
    });
  }

  bool _canSelectTable(TableModel table) {
    if (!table.isActive) return false;
    final available = table.capacity - table.currentOccupancy;
    return available >= widget.numberOfPeople;
  }

  Color _getTableColor(TableModel table) {
    if (!table.isOccupied) return Colors.green;
    if (table.currentOccupancy >= table.capacity) return Colors.red;
    return Colors.orange;
  }

  String _getTableStatus(TableModel table) {
    if (!table.isOccupied) return 'Disponible';
    if (table.currentOccupancy >= table.capacity) return 'Llena';
    return 'Ocupada (${table.currentOccupancy}/${table.capacity})';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryOrange, const Color(0xFFFF8C42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.table_restaurant,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seleccionar Mesa',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Personas: ${widget.numberOfPeople}',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Filtros
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildFilterChip('Todas', 'ALL'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Disponibles', 'AVAILABLE'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Ocupadas', 'OCCUPIED'),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar mesa...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: primaryOrange),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterTables('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: _filterTables,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Grid
            Flexible(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryOrange),
                    )
                  : _filteredTables.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.9,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredTables.length,
                          itemBuilder: (context, index) {
                            final table = _filteredTables[index];
                            return _buildTableCard(table);
                          },
                        ),
            ),

            // Leyenda
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegend(Colors.green, 'Disponible'),
                  _buildLegend(Colors.orange, 'Ocupada'),
                  _buildLegend(Colors.red, 'Llena'),
                ],
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _filterType = value;
          _applyFilters();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryOrange : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryOrange : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard(TableModel table) {
    final canSelect = _canSelectTable(table);
    final available = table.capacity - table.currentOccupancy;
    final color = _getTableColor(table);

    return Container(
      decoration: BoxDecoration(
        color: canSelect ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canSelect ? color.withOpacity(0.4) : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: canSelect
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: canSelect
              ? () => Navigator.pop(context, table)
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Espacio insuficiente. Disponible: $available, Necesario: ${widget.numberOfPeople}',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.table_restaurant,
                  size: 36,
                  color: canSelect ? color : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  table.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: canSelect ? Colors.black87 : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: canSelect
                        ? color.withOpacity(0.15)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getTableStatus(table),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: canSelect ? color : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cap: ${table.capacity} | Disp: $available',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_restaurant_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No hay mesas disponibles',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

Future<TableModel?> showTableSelectionModal(
  BuildContext context, {
  required int numberOfPeople,
}) {
  return showDialog<TableModel>(
    context: context,
    barrierDismissible: false,
    builder: (context) => TableSelectionModal(numberOfPeople: numberOfPeople),
  );
}
