import 'package:flutter/material.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/product.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/product_service.dart';
import 'product_form_dialog.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final products = await ProductService.getAllWithInactive();
      if (!mounted) return;
      setState(() {
        _products = products;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar productos: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesStatus = _statusFilter == 'all' ||
          (_statusFilter == 'active' && product.state) ||
          (_statusFilter == 'inactive' && !product.state);
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showFormDialog({Product? product}) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        product: product,
        onSaved: () {
          _loadProducts();
        },
      ),
    );
  }

  Future<void> _toggleStatus(Product product) async {
    try {
      if (product.state) {
        await ProductService.disable(product.idProduct!);
      } else {
        await ProductService.restore(product.idProduct!);
      }
      if (!mounted) return;
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(product.state ? 'Producto desactivado' : 'Producto activado'),
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

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar el producto "${product.name}"?'),
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
        await ProductService.delete(product.idProduct!);
        if (!mounted) return;
        _loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado correctamente'),
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

  String _getCategoryName(Product product) {
    // Verificar si category existe y no es null
    if (product.category == null) return 'Con categoría';
    
    // Intentar obtener el nombre de varias formas posibles
    try {
      // Caso 1: Si 'name' existe directamente
      if (product.category!.containsKey('name') && product.category!['name'] != null) {
        return product.category!['name'].toString();
      }
      
      // Caso 2: Si solo viene el ID
      if (product.category!.containsKey('idCategory') && product.category!['idCategory'] != null) {
        return 'Categoría ${product.category!['idCategory']}';
      }
    } catch (e) {
      print('Error al obtener nombre de categoría: $e');
    }
    
    return 'Sin categoría';
  }

  String _getDepartmentName(Product product) {
    // Verificar si department existe y no es null
    if (product.department == null) return 'Sin departamento';
    
    // Intentar obtener el nombre de varias formas posibles
    try {
      // Caso 1: Si 'name' existe directamente
      if (product.department!.containsKey('name') && product.department!['name'] != null) {
        return product.department!['name'].toString();
      }
      
      // Caso 2: Si solo viene el ID
      if (product.department!.containsKey('id') && product.department!['id'] != null) {
        return 'Dpto. ${product.department!['id']}';
      }
    } catch (e) {
      print('Error al obtener nombre de departamento: $e');
    }
    
    return 'Sin departamento';
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
                        hintText: 'Buscar producto...',
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

        // Lista de productos
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fastfood_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No hay productos',
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product);
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

  Widget _buildProductCard(Product product) {
    final categoryName = _getCategoryName(product);
    final departmentName = _getDepartmentName(product);
    final presentationsCount = product.presentations?.length ?? 0;

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
                    color: product.state
                        ? const Color(0xFFFF1100).withOpacity(0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.fastfood,
                    color: product.state ? const Color(0xFFFF1100) : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.category, size: 14, color: Color(0xFF718096)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              categoryName,
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
                    color: product.state ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.state ? 'ACTIVO' : 'INACTIVO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: product.state ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            if (product.description != null && product.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                product.description!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(departmentName, Icons.business),
                      _buildInfoChip('$presentationsCount Presentaciones', Icons.style),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showFormDialog(product: product),
                  tooltip: 'Editar',
                  color: Colors.blue,
                ),
                IconButton(
                  icon: Icon(product.state ? Icons.toggle_on : Icons.toggle_off, size: 28),
                  onPressed: () => _toggleStatus(product),
                  tooltip: product.state ? 'Desactivar' : 'Activar',
                  color: product.state ? Colors.green : Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deleteProduct(product),
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
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}