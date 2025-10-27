import 'package:flutter/material.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/ingredient.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/ingredient_service.dart';
import 'ingredient_form_dialog.dart';

class IngredientsTab extends StatefulWidget {
  const IngredientsTab({super.key});

  @override
  State<IngredientsTab> createState() => _IngredientsTabState();
}

class _IngredientsTabState extends State<IngredientsTab> {
  List<Ingredient> _ingredients = [];
  List<Ingredient> _filteredIngredients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _alertFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final ingredients = await IngredientService.getAllWithInactive();
      if (!mounted) return;
      setState(() {
        _ingredients = ingredients;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ingredientes: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredIngredients = _ingredients.where((ingredient) {
      final matchesSearch = ingredient.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (ingredient.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesStatus = _statusFilter == 'all' ||
          (_statusFilter == 'active' && ingredient.state) ||
          (_statusFilter == 'inactive' && !ingredient.state);

      bool matchesAlert = true;
      if (_alertFilter == 'expired' && ingredient.expirationDate != null) {
        try {
          final expDate = DateTime.parse(ingredient.expirationDate!);
          matchesAlert = DateTime.now().isAfter(expDate);
        } catch (_) {
          matchesAlert = false;
        }
      } else if (_alertFilter == 'expiring' && ingredient.expirationDate != null) {
        try {
          final expDate = DateTime.parse(ingredient.expirationDate!);
          matchesAlert = expDate.isAfter(DateTime.now()) &&
              expDate.isBefore(DateTime.now().add(const Duration(days: 7)));
        } catch (_) {
          matchesAlert = false;
        }
      } else if (_alertFilter == 'low_stock') {
        matchesAlert = (ingredient.quantity ?? 0) <= (ingredient.minStock ?? 0);
      }

      return matchesSearch && matchesStatus && matchesAlert;
    }).toList();
  }

  void _showFormDialog({Ingredient? ingredient}) {
    showDialog(
      context: context,
      builder: (context) => IngredientFormDialog(
        ingredient: ingredient,
        onSaved: () {
          _loadIngredients();
        },
      ),
    );
  }

  Future<void> _toggleStatus(Ingredient ingredient) async {
    try {
      if (ingredient.state) {
        await IngredientService.disable(ingredient.idIngredient!);
      } else {
        await IngredientService.restore(ingredient.idIngredient!);
      }
      if (!mounted) return;
      _loadIngredients();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ingredient.state ? 'Ingrediente desactivado' : 'Ingrediente activado'),
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

  Future<void> _deleteIngredient(Ingredient ingredient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar el ingrediente "${ingredient.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
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
        await IngredientService.delete(ingredient.idIngredient!);
        if (!mounted) return;
        _loadIngredients();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ingrediente eliminado correctamente'),
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

  Color _getStockColor(Ingredient ingredient) {
    final qty = ingredient.quantity ?? 0;
    final minStock = ingredient.minStock ?? 0;
    if (qty <= 0) return Colors.red;
    if (qty <= minStock) return Colors.orange;
    return Colors.green;
  }

  String _getStockStatus(Ingredient ingredient) {
    final qty = ingredient.quantity ?? 0;
    final minStock = ingredient.minStock ?? 0;
    if (qty <= 0) return 'SIN STOCK';
    if (qty <= minStock) return 'STOCK BAJO';
    return 'STOCK OK';
  }

  String _getExpirationStatus(Ingredient ingredient) {
    if (ingredient.expirationDate == null) return '';
    try {
      final expDate = DateTime.parse(ingredient.expirationDate!);
      final now = DateTime.now();
      final daysUntilExpiration = expDate.difference(now).inDays;
      if (daysUntilExpiration < 0) return 'VENCIDO';
      if (daysUntilExpiration <= 3) return 'VENCE HOY';
      if (daysUntilExpiration <= 7) return 'POR VENCER';
      return '';
    } catch (_) {
      return '';
    }
  }

  Color _getExpirationColor(Ingredient ingredient) {
    if (ingredient.expirationDate == null) return Colors.grey;
    try {
      final expDate = DateTime.parse(ingredient.expirationDate!);
      final now = DateTime.now();
      final daysUntilExpiration = expDate.difference(now).inDays;
      if (daysUntilExpiration < 0) return Colors.red;
      if (daysUntilExpiration <= 7) return Colors.orange;
      return Colors.grey;
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === BUSCADOR Y BOTÓN ===
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar ingrediente...',
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

              // === FILTROS EN DOS LÍNEAS ===
              Row(
                children: [
                  const Text('Estado:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  _buildFilterChip('Todos', 'all', _statusFilter, (value) {
                    setState(() {
                      _statusFilter = value;
                      _applyFilters();
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Activos', 'active', _statusFilter, (value) {
                    setState(() {
                      _statusFilter = value;
                      _applyFilters();
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Inactivos', 'inactive', _statusFilter, (value) {
                    setState(() {
                      _statusFilter = value;
                      _applyFilters();
                    });
                  }),
                ],
              ),

              const SizedBox(height: 10), // salto fijo entre grupos

              Row(
                children: [
                  const Text('Alertas:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  _buildFilterChip('Todos', 'all', _alertFilter, (value) {
                    setState(() {
                      _alertFilter = value;
                      _applyFilters();
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Vencidos', 'expired', _alertFilter, (value) {
                    setState(() {
                      _alertFilter = value;
                      _applyFilters();
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Por vencer', 'expiring', _alertFilter, (value) {
                    setState(() {
                      _alertFilter = value;
                      _applyFilters();
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Stock bajo', 'low_stock', _alertFilter, (value) {
                    setState(() {
                      _alertFilter = value;
                      _applyFilters();
                    });
                  }),
                ],
              ),
            ],
          ),
        ),

        // === LISTADO DE INGREDIENTES ===
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredIngredients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.kitchen_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('No hay ingredientes',
                              style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredIngredients.length,
                      itemBuilder: (context, index) {
                        final ingredient = _filteredIngredients[index];
                        return _buildIngredientCard(ingredient);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
      String label, String value, String currentFilter, Function(String) onSelected) {
    final isSelected = currentFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(value),
      selectedColor: const Color(0xFFFF1100).withOpacity(0.2),
      checkmarkColor: const Color(0xFFFF1100),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFFF1100) : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(color: Colors.grey.shade300),
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    final stockColor = _getStockColor(ingredient);
    final stockStatus = _getStockStatus(ingredient);
    final expirationStatus = _getExpirationStatus(ingredient);
    final hasExpiration = ingredient.expirationDate != null;

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
                    color: ingredient.state
                        ? const Color(0xFFFF1100).withOpacity(0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.kitchen,
                    color: ingredient.state
                        ? const Color(0xFFFF1100)
                        : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.inventory_2,
                              size: 14, color: Color(0xFF718096)),
                          const SizedBox(width: 4),
                          Text(
                            ingredient.unit ?? 'N/A',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF718096)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ingredient.state
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ingredient.state ? 'ACTIVO' : 'INACTIVO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ingredient.state
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                    if (expirationStatus.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getExpirationColor(ingredient).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getExpirationColor(ingredient).withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning,
                                size: 12, color: _getExpirationColor(ingredient)),
                            const SizedBox(width: 4),
                            Text(
                              expirationStatus,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getExpirationColor(ingredient),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (ingredient.description != null &&
                ingredient.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(ingredient.description!,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF718096))),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStockChip(
                  'Stock: ${(ingredient.quantity ?? 0).toStringAsFixed(1)} ${ingredient.unit ?? ''}',
                  Icons.inventory,
                  stockColor,
                  stockStatus,
                ),
                _buildInfoChip(
                  'Mín: ${(ingredient.minStock ?? 0).toStringAsFixed(1)}',
                  Icons.warning_amber,
                  Colors.orange,
                ),
                _buildInfoChip(
                  'Costo: S/ ${(ingredient.unitPrice ?? 0).toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
                if (hasExpiration)
                  _buildInfoChip(
                    'Vence: ${_formatDate(ingredient.expirationDate!)}',
                    Icons.calendar_today,
                    _getExpirationColor(ingredient),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showFormDialog(ingredient: ingredient),
                    tooltip: 'Editar',
                    color: Colors.blue),
                IconButton(
                  icon: Icon(
                      ingredient.state
                          ? Icons.toggle_on
                          : Icons.toggle_off,
                      size: 28),
                  onPressed: () => _toggleStatus(ingredient),
                  tooltip:
                      ingredient.state ? 'Desactivar' : 'Activar',
                  color: ingredient.state ? Colors.green : Colors.grey,
                ),
                IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _deleteIngredient(ingredient),
                    tooltip: 'Eliminar',
                    color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockChip(
      String label, IconData icon, Color color, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color)),
          const SizedBox(width: 6),
          Text(status,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return 'Fecha inválida';
    }
  }
}
