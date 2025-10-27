import 'package:flutter/material.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/category.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/category_service.dart';
import 'category_form_dialog.dart';

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all'; // all, active, inactive

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await CategoryService.getAllWithInactive();
      setState(() {
        _categories = categories;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar categorías: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredCategories = _categories.where((category) {
      final matchesSearch = category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (category.section?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesStatus = _statusFilter == 'all' ||
          (_statusFilter == 'active' && category.state) ||
          (_statusFilter == 'inactive' && !category.state);
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showFormDialog({Category? category}) {
    showDialog(
      context: context,
      builder: (context) => CategoryFormDialog(
        category: category,
        onSaved: () {
          _loadCategories();
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _toggleStatus(Category category) async {
    try {
      if (category.state) {
        await CategoryService.disable(category.idCategory!);
      } else {
        await CategoryService.restore(category.idCategory!);
      }
      _loadCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(category.state ? 'Categoría desactivada' : 'Categoría activada'),
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

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar la categoría "${category.name}"?'),
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
        await CategoryService.delete(category.idCategory!);
        _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Categoría eliminada correctamente'),
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
                        hintText: 'Buscar categoría...',
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
              // Filtros de estado
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

        // Lista de categorías
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredCategories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No hay categorías',
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = _filteredCategories[index];
                        return _buildCategoryCard(category);
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

  Widget _buildCategoryCard(Category category) {
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
                    color: category.state
                        ? const Color(0xFFFF1100).withOpacity(0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.category,
                    color: category.state ? const Color(0xFFFF1100) : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      if (category.section != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.restaurant_menu, size: 14, color: Color(0xFF718096)),
                            const SizedBox(width: 4),
                            Text(
                              category.section!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Badge de estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: category.state ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.state ? 'ACTIVO' : 'INACTIVO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: category.state ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            if (category.description != null && category.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                category.description!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (category.delivery != null)
                  _buildInfoChip(
                    category.delivery! ? 'Delivery' : 'Sin Delivery',
                    category.delivery! ? Icons.delivery_dining : Icons.close,
                  ),
                if (category.displayOrder != null) ...[
                  const SizedBox(width: 8),
                  _buildInfoChip('Orden: ${category.displayOrder}', Icons.sort),
                ],
                const Spacer(),
                // Botones de acción
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showFormDialog(category: category),
                  tooltip: 'Editar',
                  color: Colors.blue,
                ),
                IconButton(
                  icon: Icon(category.state ? Icons.toggle_on : Icons.toggle_off, size: 28),
                  onPressed: () => _toggleStatus(category),
                  tooltip: category.state ? 'Desactivar' : 'Activar',
                  color: category.state ? Colors.green : Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deleteCategory(category),
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