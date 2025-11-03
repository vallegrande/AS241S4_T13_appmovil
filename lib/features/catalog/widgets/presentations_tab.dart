import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/presentation.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/category.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/presentation_service.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/category_service.dart';
import 'presentation_form_dialog.dart';

class PresentationsTab extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const PresentationsTab({super.key, this.onDataChanged});

  @override
  State<PresentationsTab> createState() => _PresentationsTabState();
}

class _PresentationsTabState extends State<PresentationsTab> {
  List<Presentation> _presentations = [];
  List<Presentation> _filteredPresentations = [];
  Map<int, String> _presentationProductMap = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);
  final Color cardBg = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadPresentations();
  }

  Future<void> _loadPresentations() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        CategoryService.getAllWithInactive(),
        PresentationService.getAllWithInactive(),
      ]);

      final categories = results[0] as List<Category>;
      final presentations = results[1] as List<Presentation>;

      final Map<int, String> productMap = {};
      for (var category in categories) {
        if (category.products != null) {
          for (var productData in category.products!) {
            if (productData is Map<String, dynamic>) {
              final productName = productData['name'] as String?;
              final presentationsData =
                  productData['presentations'] as List<dynamic>?;

              if (productName != null && presentationsData != null) {
                for (var presentationData in presentationsData) {
                  if (presentationData is Map<String, dynamic>) {
                    final presentationId =
                        presentationData['idPresentation'] as int?;
                    if (presentationId != null) {
                      productMap[presentationId] = productName;
                    }
                  }
                }
              }
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _presentations = presentations;
        _presentationProductMap = productMap;
        _applyFilters();
        _isLoading = false;
      });
      widget.onDataChanged?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Error al cargar presentaciones', Colors.red.shade600,
          Icons.error_rounded);
    }
  }

  void _applyFilters() {
    _filteredPresentations = _presentations.where((presentation) {
      final matchesSearch = presentation.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (presentation.description
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);

      final matchesStatus = _statusFilter == 'all' ||
          (_statusFilter == 'active' && presentation.state) ||
          (_statusFilter == 'inactive' && !presentation.state);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showFormDialog({Presentation? presentation}) {
    showDialog(
      context: context,
      builder: (context) => PresentationFormDialog(
        presentation: presentation,
        onSaved: () => _loadPresentations(),
      ),
    );
  }

  Future<void> _toggleStatus(Presentation presentation) async {
    try {
      if (presentation.state) {
        await PresentationService.disable(presentation.idPresentation!);
        _showSnackBar('Presentación desactivada', primaryOrange,
            Icons.check_circle_rounded);
      } else {
        await PresentationService.restore(presentation.idPresentation!);
        _showSnackBar('Presentación reactivada', Colors.green.shade600,
            Icons.check_circle_rounded);
      }
      _loadPresentations();
    } catch (e) {
      _showSnackBar('No se pudo cambiar el estado', Colors.red.shade600,
          Icons.error_rounded);
    }
  }

  Future<void> _deletePresentation(Presentation presentation) async {
    final confirmed = await _showConfirmDialog(
      'Eliminar presentación',
      '¿Está seguro de eliminar "${presentation.name}"? Esta acción no se puede deshacer.',
      Icons.delete_rounded,
      Colors.red.shade600,
    );

    if (confirmed == true) {
      try {
        await PresentationService.delete(presentation.idPresentation!);
        _loadPresentations();
        _showSnackBar('Presentación eliminada exitosamente', primaryOrange,
            Icons.check_circle_rounded);
      } catch (e) {
        _showSnackBar('No se pudo eliminar la presentación',
            Colors.red.shade600, Icons.error_rounded);
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
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: GoogleFonts.inter(
              fontSize: 15, color: Colors.grey.shade700, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
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
              child: Text(
                message,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
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

  String _getProductName(Presentation presentation) {
    if (presentation.idPresentation != null &&
        _presentationProductMap.containsKey(presentation.idPresentation)) {
      return _presentationProductMap[presentation.idPresentation]!;
    }
    return 'Sin producto';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Colors.grey.shade200, width: 1.5),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar presentación...',
                          hintStyle: GoogleFonts.inter(
                              color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: primaryOrange, size: 22),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showFormDialog(),
                    icon: const Icon(Icons.add_rounded),
                    label: Text('Agregar',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('Todos', 'all'),
                  _buildFilterChip('Activos', 'active'),
                  _buildFilterChip('Inactivos', 'inactive'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: primaryOrange, strokeWidth: 3))
              : _filteredPresentations.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredPresentations.length,
                      itemBuilder: (context, index) {
                        final presentation = _filteredPresentations[index];
                        return _buildPresentationCard(presentation, index);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = value;
          _applyFilters();
        });
      },
      backgroundColor: Colors.white,
      selectedColor: primaryOrange.withOpacity(0.15),
      checkmarkColor: primaryOrange,
      labelStyle: TextStyle(
        color: isSelected ? primaryOrange : Colors.grey.shade600,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color:
            isSelected ? primaryOrange.withOpacity(0.3) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildPresentationCard(Presentation presentation, int index) {
    final isActive = presentation.state;
    final productName = _getProductName(presentation);

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        verticalOffset: 30,
        curve: Curves.easeOutCubic,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showFormDialog(presentation: presentation),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isActive
                                ? [
                                    primaryOrange.withOpacity(0.2),
                                    lightOrange.withOpacity(0.1)
                                  ]
                                : [Colors.grey.shade200, Colors.grey.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: primaryOrange.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          Icons.style_rounded,
                          color:
                              isActive ? primaryOrange : Colors.grey.shade400,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              presentation.name,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildInfoChip(
                                  icon: Icons.fastfood_rounded,
                                  label: productName,
                                  color: Colors.blue.shade600,
                                ),
                                _buildPriceChip(
                                    'S/ ${presentation.price.toStringAsFixed(2)}',
                                    Colors.green.shade600),
                              ],
                            ),
                            if (presentation.description != null &&
                                presentation.description!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                presentation.description!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: primaryOrange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert_rounded,
                              color: primaryOrange, size: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          offset: const Offset(-10, 40),
                          onSelected: (value) {
                            if (value == 'edit')
                              _showFormDialog(presentation: presentation);
                            if (value == 'toggle_state')
                              _toggleStatus(presentation);
                            if (value == 'delete')
                              _deletePresentation(presentation);
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
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.edit_rounded,
                                        color: primaryOrange, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('Editar',
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
                                              ? Colors.orange
                                              : Colors.green)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isActive
                                          ? Icons.toggle_off_rounded
                                          : Icons.toggle_on_rounded,
                                      color: isActive
                                          ? Colors.orange.shade700
                                          : Colors.green.shade600,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    isActive ? 'Desactivar' : 'Activar',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? Colors.orange.shade700
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(height: 8),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.delete_rounded,
                                        color: Colors.red.shade600, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Eliminar',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
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

  Widget _buildPriceChip(String price, Color color) {
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
          Icon(Icons.attach_money_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(price,
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
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
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.style_outlined,
                size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text(
            'No se encontraron presentaciones',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta ajustar los filtros o crear una nueva',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(duration: 400.ms, curve: Curves.easeOutBack);
  }
}
