import 'package:flutter/material.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/presentation.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/presentation_service.dart';
import 'presentation_form_dialog.dart';

class PresentationsTab extends StatefulWidget {
  const PresentationsTab({super.key});

  @override
  State<PresentationsTab> createState() => _PresentationsTabState();
}

class _PresentationsTabState extends State<PresentationsTab> {
  List<Presentation> _presentations = [];
  List<Presentation> _filteredPresentations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadPresentations();
  }

  Future<void> _loadPresentations() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final presentations = await PresentationService.getAllWithInactive();
      if (!mounted) return;
      setState(() {
        _presentations = presentations;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar presentaciones: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredPresentations = _presentations.where((presentation) {
      final matchesSearch = presentation.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (presentation.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
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
        onSaved: () {
          _loadPresentations();
        },
      ),
    );
  }

  Future<void> _toggleStatus(Presentation presentation) async {
    try {
      if (presentation.state) {
        await PresentationService.disable(presentation.idPresentation!);
      } else {
        await PresentationService.restore(presentation.idPresentation!);
      }
      if (!mounted) return;
      _loadPresentations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(presentation.state ? 'Presentación desactivada' : 'Presentación activada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deletePresentation(Presentation presentation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar la presentación "${presentation.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await PresentationService.delete(presentation.idPresentation!);
        if (!mounted) return;
        _loadPresentations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Presentación eliminada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  String _getProductName(Presentation presentation) {
    // Verificar si product existe y no es null
    if (presentation.product == null) return 'Con producto';
    
    // Intentar obtener el nombre de varias formas posibles
    try {
      // Caso 1: Si 'name' existe directamente
      if (presentation.product!.containsKey('name') && presentation.product!['name'] != null) {
        return presentation.product!['name'].toString();
      }
      
      // Caso 2: Si solo viene el ID
      if (presentation.product!.containsKey('idProduct') && presentation.product!['idProduct'] != null) {
        return 'Producto ${presentation.product!['idProduct']}';
      }
    } catch (e) {
      print('Error al obtener nombre de producto: $e');
    }
    
    return 'Sin producto';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda y filtros
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar presentación...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF718096)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showFormDialog(),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Agregar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF1100),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Filtrar:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  _buildFilterChip('Todos', 'all'),
                  _buildFilterChip('Activos', 'active'),
                  _buildFilterChip('Inactivos', 'inactive'),
                ],
              ),
            ],
          ),
        ),

        // Lista de presentaciones
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredPresentations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.style_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No hay presentaciones',
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredPresentations.length,
                      itemBuilder: (context, index) {
                        final presentation = _filteredPresentations[index];
                        return _buildPresentationCard(presentation);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _statusFilter = value;
            _applyFilters();
          });
        },
        selectedColor: const Color(0xFFFF1100).withOpacity(0.2),
        checkmarkColor: const Color(0xFFFF1100),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFFFF1100) : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPresentationCard(Presentation presentation) {
    final productName = _getProductName(presentation);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: presentation.state
                        ? const Color(0xFFFF1100).withOpacity(0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.style,
                    color: presentation.state ? const Color(0xFFFF1100) : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        presentation.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.fastfood, size: 14, color: Color(0xFF718096)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              productName,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF718096)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: presentation.state ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    presentation.state ? 'ACTIVO' : 'INACTIVO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: presentation.state ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            if (presentation.description != null && presentation.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                presentation.description!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
              ),
            ],
            const SizedBox(height: 12),
            // Precios
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPriceChip('Precio', presentation.price, Icons.attach_money),
                if (presentation.deliveryPrice != null)
                  _buildPriceChip('Delivery', presentation.deliveryPrice!, Icons.delivery_dining),
                if (presentation.takeoutPrice != null)
                  _buildPriceChip('Para llevar', presentation.takeoutPrice!, Icons.shopping_bag),
                if (presentation.promoPrice != null)
                  _buildPriceChip('Promoción', presentation.promoPrice!, Icons.local_offer, isPromo: true),
                if (presentation.preparationTime != null)
                  _buildInfoChip('${presentation.preparationTime} min', Icons.timer),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showFormDialog(presentation: presentation),
                  tooltip: 'Editar',
                  color: Colors.blue,
                ),
                IconButton(
                  icon: Icon(presentation.state ? Icons.toggle_on : Icons.toggle_off, size: 28),
                  onPressed: () => _toggleStatus(presentation),
                  tooltip: presentation.state ? 'Desactivar' : 'Activar',
                  color: presentation.state ? Colors.green : Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deletePresentation(presentation),
                  tooltip: 'Eliminar',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChip(String label, double price, IconData icon, {bool isPromo = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPromo ? Colors.orange.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPromo ? Colors.orange.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isPromo ? Colors.orange.shade700 : Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            '$label: S/ ${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPromo ? Colors.orange.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}