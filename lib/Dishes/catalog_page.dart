// lib/Dishes/catalog_page.dart
import 'package:flutter/material.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/services/presentation_service.dart';
import 'package:myapp/services/ingredient_service.dart';
import 'package:myapp/services/token_manager.dart';
import 'package:myapp/models/category.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/models/presentation.dart';
import 'package:myapp/models/ingredient.dart';
import 'package:myapp/Dishes/Forms/category_form.dart';
import 'package:myapp/Dishes/Forms/product_form.dart';
import 'package:myapp/Dishes/Forms/presentation_form.dart';
import 'package:myapp/Dishes/Forms/ingredient_form.dart'; 
import 'package:myapp/Dishes/Widgets/categories_panel.dart';
import 'package:myapp/Dishes/Widgets/products_panel.dart';
import 'package:myapp/Dishes/Widgets/presentations_panel.dart';
import 'package:myapp/Dishes/Widgets/ingredients_table.dart';
import 'dart:convert';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final List<String> _sections = [
    'Platos y Bebidas',
    'Combos',
    'Ofertas', 
    'Insumos',
  ];

  String _selectedSection = 'Platos y Bebidas';
  Category? _selectedCategory;
  Product? _selectedProduct;
  Presentation? _selectedPresentation;
  Ingredient? _selectedIngredient; 

  List<Category> _categories = [];
  List<Product> _products = [];
  List<Presentation> _presentations = [];
  List<Ingredient> _ingredients = [];

  bool _showCategoryForm = false;
  bool _showProductForm = false;
  bool _showPresentationForm = false;
  bool _showIngredientForm = false;

  bool _isLoadingCategories = false;
  bool _isLoadingProducts = false;
  bool _isLoadingPresentations = false;
  bool _isLoadingIngredients = false;

  final _categoryService = CategoryService();
  final _productService = ProductService();
  final _presentationService = PresentationService();
  final _ingredientService = IngredientService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _waitForAuthAndLoad();
    });
  }

  Future<void> _waitForAuthAndLoad() async {
    int attempts = 0;
    while (TokenManager.getToken() == null && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    // DEBUG: Imprimir información del token
    final token = TokenManager.getToken();
    final role = TokenManager.getUserRole();
    
    debugPrint('═══════════════════════════════════════');
    debugPrint('🔐 DEBUG TOKEN - CATALOG PAGE');
    debugPrint('═══════════════════════════════════════');
    debugPrint('Token existe: ${token != null}');
    debugPrint('Token length: ${token?.length ?? 0}');
    debugPrint('Rol de usuario: $role');
    
    // VERIFICACIÓN EXTRA: Probar getAuthHeaders
    final headers = TokenManager.getAuthHeaders();
    debugPrint('Headers disponibles: $headers');
    debugPrint('═══════════════════════════════════════');

    if (token != null) {
      debugPrint('✅ Token disponible, cargando datos...');
      _debugTokenPayload();
      _loadInitialData();
    } else {
      debugPrint('❌ Token no disponible después de esperar');
      _showError('Error de autenticación: No se pudo cargar el token.');
    }
  }

  void _debugTokenPayload() {
    final token = TokenManager.getToken();
    if (token == null) return;
    
    try {
      final parts = token.split('.');
      if (parts.length != 3) return;
      
      String payload = parts[1];
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2: payload += '=='; break;
        case 3: payload += '='; break;
      }
      
      final decoded = utf8.decode(base64.decode(payload));
      final jsonPayload = jsonDecode(decoded);
      
      debugPrint('🔍 PAYLOAD DEL TOKEN - DETALLADO:');
      debugPrint('   - Subject: ${jsonPayload['sub']}');
      debugPrint('   - Role: ${jsonPayload['role']}');
      debugPrint('   - Authorities: ${jsonPayload['authorities']}');
      debugPrint('   - Todos los campos: ${jsonPayload.keys}');
      if (jsonPayload.containsKey('exp')) {
        final exp = DateTime.fromMillisecondsSinceEpoch(jsonPayload['exp'] * 1000);
        debugPrint('   - Expira: $exp');
      }
      debugPrint('═══════════════════════════════════════');
    } catch (e) {
      debugPrint('❌ Error decodificando token: $e');
    }
  }

  Future<void> _loadInitialData() async {
    if (_selectedSection == 'Insumos') {
      await _loadIngredients();
    } else {
      await _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categories = await _categoryService.getAll();
      if (!mounted) return;
      
      final currentCategories = categories.where((cat) => cat.section == _selectedSection).toList();
      
      setState(() {
        _categories = currentCategories;
        
        if (_selectedCategory != null && !_categories.any((c) => c.idCategory == _selectedCategory!.idCategory)) {
          _selectedCategory = null;
          _selectedProduct = null;
          _products = [];
          _presentations = [];
        }
      });
      
      if (_selectedCategory != null) {
        await _loadProductsForCategory(_selectedCategory!);
      }
      
    } catch (e) {
      debugPrint('❌ Error al cargar categorías: $e');
      _showError('Error al cargar categorías: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  void _selectSection(String section) {
    setState(() {
      _selectedSection = section;
      _selectedCategory = null;
      _selectedProduct = null;
      _selectedIngredient = null;
      _products = [];
      _presentations = [];
      _ingredients = [];
    });

    if (section == 'Insumos') {
      _loadIngredients();
    } else {
      _loadCategories();
    }
  }

  void _selectCategory(Category category) {
    setState(() {
      _selectedCategory = category;
      _selectedProduct = null;
      _presentations = [];
    });
    _loadProductsForCategory(category);
  }

  Future<void> _loadProductsForCategory(Category category) async {
    setState(() => _isLoadingProducts = true);
    try {
      debugPrint('🔄 Cargando productos para categoría: ${category.name} (ID: ${category.idCategory})');
      
      // USAR EL MÉTODO NORMAL PRIMERO
      final products = await _productService.getAll();
      
      debugPrint('✅ Productos cargados exitosamente: ${products.length}');
      
      if (!mounted) return;
      
      final currentProducts = products.where((product) => product.category.idCategory == category.idCategory).toList();
      
      debugPrint('🎯 Productos filtrados para categoría ${category.idCategory}: ${currentProducts.length}');
      
      setState(() {
        _products = currentProducts;

        if (_selectedProduct != null && !_products.any((p) => p.idProduct == _selectedProduct!.idProduct)) {
          _selectedProduct = null;
          _presentations = [];
        }
      });

      if (_selectedProduct != null) {
        _loadPresentationsForProduct(_selectedProduct!);
      }
      
    } catch (e) {
      debugPrint('❌ Error detallado al cargar productos:');
      debugPrint('   - Categoría: ${category.name} (ID: ${category.idCategory})');
      debugPrint('   - Error: $e');
      debugPrint('   - Tipo: ${e.runtimeType}');
      
      // Mensaje de error específico para el problema de hasRole vs hasAuthority
      if (e.toString().contains('403')) {
        _showError('''
No tiene permisos para acceder a los productos.

🔍 Problema identificado:
• El backend está configurado con: hasRole("ADMIN")
• Spring Security busca: ROLE_ADMIN
• Pero el token JWT contiene: "role": "ADMIN"

🎯 Solución requerida:
Contacte al administrador para modificar el SecurityConfig.java
y cambiar hasRole("ADMIN") por hasAuthority("ADMIN")
''');
      } else {
        _showError('Error al cargar productos: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  // Método temporal para forzar el token
  Future<void> _loadProductsForCategoryForced(Category category) async {
    setState(() => _isLoadingProducts = true);
    try {
      debugPrint('🔄 Cargando productos con headers forzados para categoría: ${category.name}');
      
      // USAR MÉTODO CON HEADERS FORZADOS
      final products = await _productService.getAllWithForcedHeaders();
      
      debugPrint('✅ Productos cargados con headers forzados: ${products.length}');
      
      if (!mounted) return;
      
      final currentProducts = products.where((product) => product.category.idCategory == category.idCategory).toList();
      
      debugPrint('🎯 Productos filtrados: ${currentProducts.length}');
      
      setState(() {
        _products = currentProducts;
        _selectedProduct = null;
        _presentations = [];
      });
      
    } catch (e) {
      debugPrint('❌ Error con headers forzados: $e');
      _showError('Error al cargar productos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
    });
    _loadPresentationsForProduct(product);
  }

  Future<void> _loadPresentationsForProduct(Product product) async {
    setState(() => _isLoadingPresentations = true);
    try {
      final presentations = await _presentationService.getByProductId(product.idProduct!);
      if (!mounted) return;
      setState(() {
        _presentations = presentations;
      });
    } catch (e) {
      debugPrint('❌ Error al cargar presentaciones: $e');
      _showError('Error al cargar presentaciones: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPresentations = false);
      }
    }
  }

  Future<void> _loadIngredients() async {
    setState(() => _isLoadingIngredients = true);
    try {
      debugPrint('🔄 Cargando insumos...');
      final ingredients = await _ingredientService.getAll();
      debugPrint('✅ Insumos cargados: ${ingredients.length}');
      if (!mounted) return;
      setState(() {
        _ingredients = ingredients;
      });
    } catch (e) {
      debugPrint('❌ Error al cargar insumos: $e');
      _showError('Error al cargar insumos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingIngredients = false);
      }
    }
  }

  bool _isMobile() {
    return MediaQuery.of(context).size.width < 768;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildContent()),
            ],
          ),
          if (_showCategoryForm) _buildCategoryForm(),
          if (_showProductForm) _buildProductForm(),
          if (_showPresentationForm) _buildPresentationForm(),
          if (_showIngredientForm) _buildIngredientForm(),
        ],
      ),
    );
  }

  // ... (Los métodos de UI restantes se mantienen igual que antes)

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  if (_isMobile())
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  Expanded(
                    child: Text(
                      'Catálogo',
                      style: TextStyle(
                        fontSize: _isMobile() ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _sections.map((section) {
                  final isActive = _selectedSection == section;
                  return _buildSectionButton(section, isActive);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionButton(String section, bool isActive) {
    IconData icon;
    switch (section) {
      case 'Platos y Bebidas': icon = Icons.restaurant; break;
      case 'Combos': icon = Icons.lunch_dining; break;
      case 'Ofertas': icon = Icons.local_offer; break;
      case 'Insumos': icon = Icons.inventory_2; break;
      default: icon = Icons.category;
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectSection(section),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFd67628) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive ? const Color(0xFFd67628) : Colors.grey[300]!,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: isActive ? Colors.white : Colors.grey[600], size: 20),
                  const SizedBox(height: 4),
                  Text(
                    section,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedSection == 'Insumos') {
      return _buildIngredientsContent();
    } else {
      return _buildCatalogContent();
    }
  }

  Widget _buildCatalogContent() {
    if (_isMobile()) {
      return _buildMobileCatalog();
    } else {
      return _buildDesktopCatalog();
    }
  }

  Widget _buildDesktopCatalog() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CategoriesPanel(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: _selectCategory,
              onAddCategory: () => setState(() {
                _selectedCategory = null;
                _showCategoryForm = true;
              }),
              onEditCategory: (category) => setState(() {
                _selectedCategory = category;
                _showCategoryForm = true;
              }),
              onDeleteCategory: _confirmDeleteCategory,
              isLoading: _isLoadingCategories,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ProductsPanel(
              products: _products,
              selectedCategory: _selectedCategory,
              selectedProduct: _selectedProduct,
              onProductSelected: _selectProduct,
              onAddProduct: () {
                if (_selectedCategory != null) {
                  setState(() {
                    _selectedProduct = null;
                    _showProductForm = true;
                  });
                } else {
                  _showError('Selecciona una categoría primero');
                }
              },
              onEditProduct: (product) => setState(() {
                _selectedProduct = product;
                _showProductForm = true;
              }),
              onDeleteProduct: _confirmDeleteProduct,
              isLoading: _isLoadingProducts,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PresentationsPanel(
              presentations: _presentations,
              selectedProduct: _selectedProduct,
              onAddPresentation: () {
                if (_selectedProduct != null) {
                  setState(() {
                    _selectedPresentation = null;
                    _showPresentationForm = true;
                  });
                } else {
                  _showError('Selecciona un producto primero');
                }
              },
              onEditPresentation: (presentation) => setState(() {
                _selectedPresentation = presentation;
                _showPresentationForm = true;
              }),
              onDeletePresentation: _confirmDeletePresentation,
              isLoading: _isLoadingPresentations,
            ),
          ),
        ],
      ),
    );
  }

  // ... (Los métodos restantes de UI se mantienen igual)

  Widget _buildMobileCatalog() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (_selectedCategory != null || _selectedProduct != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedProduct != null 
                          ? 'Producto: ${_selectedProduct!.name}'
                          : 'Categoría: ${_selectedCategory!.name}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  if (_selectedProduct != null)
                    IconButton(
                      onPressed: () => setState(() => _selectedProduct = null),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      padding: EdgeInsets.zero,
                    ),
                  if (_selectedCategory != null && _selectedProduct == null)
                    IconButton(
                      onPressed: () => setState(() => _selectedCategory = null),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                _buildMobileSection(
                  title: 'Categorías',
                  count: _categories.length,
                  onAdd: () => setState(() => _showCategoryForm = true),
                  child: _categories.isEmpty
                      ? _buildEmptyState('No hay categorías', Icons.category)
                      : Column(
                          children: _categories.map((category) {
                            return _buildMobileItem(
                              title: category.name,
                              subtitle: category.description,
                              icon: Icons.category,
                              isSelected: _selectedCategory?.idCategory == category.idCategory,
                              onTap: () => _selectCategory(category),
                              onEdit: () => setState(() {
                                _selectedCategory = category;
                                _showCategoryForm = true;
                              }),
                              onDelete: () => _confirmDeleteCategory(category),
                              state: category.state,
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 12),
                if (_selectedCategory != null)
                  _buildMobileSection(
                    title: 'Productos',
                    count: _products.length,
                    onAdd: () {
                      if (_selectedCategory != null) {
                        setState(() => _showProductForm = true);
                      }
                    },
                    child: _products.isEmpty
                        ? _buildEmptyState('No hay productos', Icons.restaurant)
                        : Column(
                            children: _products.map((product) {
                              return _buildMobileItem(
                                title: product.name,
                                subtitle: product.description,
                                icon: Icons.restaurant,
                                isSelected: _selectedProduct?.idProduct == product.idProduct,
                                onTap: () => _selectProduct(product),
                                onEdit: () => setState(() {
                                  _selectedProduct = product;
                                  _showProductForm = true;
                                }),
                                onDelete: () => _confirmDeleteProduct(product),
                                state: product.state,
                              );
                            }).toList(),
                          ),
                  ),
                if (_selectedCategory != null) const SizedBox(height: 12),
                if (_selectedProduct != null)
                  _buildMobileSection(
                    title: 'Presentaciones',
                    count: _presentations.length,
                    onAdd: () {
                      if (_selectedProduct != null) {
                        setState(() => _showPresentationForm = true);
                      }
                    },
                    child: _presentations.isEmpty
                        ? _buildEmptyState('No hay presentaciones', Icons.view_carousel)
                        : Column(
                            children: _presentations.map((presentation) {
                              return _buildMobileItem(
                                title: presentation.name,
                                subtitle: 'S/ ${presentation.price.toStringAsFixed(2)} - ${presentation.description}',
                                icon: Icons.view_carousel,
                                isSelected: false,
                                onTap: () {},
                                onEdit: () => setState(() {
                                  _selectedPresentation = presentation;
                                  _showPresentationForm = true;
                                }),
                                onDelete: () => _confirmDeletePresentation(presentation),
                                state: presentation.state ?? true,
                              );
                            }).toList(),
                          ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSection({
    required String title,
    required int count,
    required VoidCallback onAdd,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFd67628),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, color: Color(0xFFd67628), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildMobileItem({
    required String title,
    required String? subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required bool state,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? Colors.orange[50] : Colors.white,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? const Color(0xFFd67628) : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? const Color(0xFFd67628) : Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? const Color(0xFFd67628) : Colors.black87,
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: state ? Colors.green[500] : Colors.red[500],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state ? 'Activo' : 'Inactivo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2, color: Color(0xFFd67628), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestión de Insumos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${_ingredients.length} insumos registrados',
                        style: const TextStyle(
                          color: Color(0xFF6b7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _selectedIngredient = null;
                    _showIngredientForm = true;
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd67628),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: _isLoadingIngredients
                  ? const Center(child: CircularProgressIndicator())
                  : IngredientsTable(
                      ingredients: _ingredients,
                      onEdit: (ingredient) {
                        setState(() {
                          _selectedIngredient = ingredient;
                          _showIngredientForm = true;
                        });
                      },
                      onDisable: (ingredient) {
                        _confirmDisableIngredient(ingredient);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Formularios modales
  Widget _buildCategoryForm() {
    return CategoryForm(
      category: _selectedCategory,
      currentSection: _selectedSection,
      onClose: () {
        setState(() {
          _showCategoryForm = false;
          _selectedCategory = null;
        });
      },
      onSaved: (savedCategory) {
        setState(() {
          _showCategoryForm = false;
          _selectedCategory = savedCategory;
        });
        _loadCategories();
      },
    );
  }

  Widget _buildProductForm() {
    return ProductForm(
      product: _selectedProduct,
      category: _selectedCategory!,
      onClose: () {
        setState(() {
          _showProductForm = false;
          _selectedProduct = null;
        });
      },
      onSaved: (savedProduct) {
        setState(() {
          _showProductForm = false;
          _selectedProduct = savedProduct;
        });
        if (_selectedCategory != null) {
          _loadProductsForCategory(_selectedCategory!);
        }
      },
    );
  }

  Widget _buildPresentationForm() {
    return PresentationForm(
      presentation: _selectedPresentation,
      product: _selectedProduct!,
      onClose: () {
        setState(() {
          _showPresentationForm = false;
          _selectedPresentation = null;
        });
      },
      onSaved: (savedPresentation) {
        setState(() {
          _showPresentationForm = false;
          _selectedPresentation = null;
        });
        if (_selectedProduct != null) {
          _loadPresentationsForProduct(_selectedProduct!);
        }
      },
    );
  }

  Widget _buildIngredientForm() {
    return IngredientForm(
      ingredient: _selectedIngredient,
      onClose: () {
        setState(() {
          _showIngredientForm = false;
          _selectedIngredient = null;
        });
      },
      onSaved: (savedIngredient) {
        setState(() {
          _showIngredientForm = false;
          _selectedIngredient = null;
        });
        _loadIngredients();
        _showSuccess('Insumo ${savedIngredient.idIngredient != null ? "actualizado" : "creado"} con éxito');
      },
    );
  }

  // Diálogos y notificaciones
  void _confirmDeleteCategory(Category category) {
    _showConfirmationDialog(
      title: 'Confirmar Eliminación',
      content: '¿Estás seguro de que quieres eliminar la categoría "${category.name}"?',
      onConfirm: () async {
        try {
          await _categoryService.delete(category.idCategory!);
          _showSuccess('Categoría eliminada con éxito');
          if (_selectedCategory?.idCategory == category.idCategory) {
            setState(() {
              _selectedCategory = null;
              _selectedProduct = null;
              _products = [];
              _presentations = [];
            });
          }
          _loadCategories();
        } catch (e) {
          _showError('Error al eliminar categoría: $e');
        }
      },
    );
  }

  void _confirmDeleteProduct(Product product) {
    _showConfirmationDialog(
      title: 'Confirmar Eliminación',
      content: '¿Estás seguro de que quieres eliminar el producto "${product.name}"?',
      onConfirm: () async {
        try {
          await _productService.delete(product.idProduct!);
          _showSuccess('Producto eliminado con éxito');
          if (_selectedProduct?.idProduct == product.idProduct) {
             setState(() {
              _selectedProduct = null;
              _presentations = [];
            });
          }
          if (_selectedCategory != null) {
            _loadProductsForCategory(_selectedCategory!);
          }
        } catch (e) {
          _showError('Error al eliminar producto: $e');
        }
      },
    );
  }

  void _confirmDeletePresentation(Presentation presentation) {
    _showConfirmationDialog(
      title: 'Confirmar Eliminación',
      content: '¿Estás seguro de que quieres eliminar la presentación "${presentation.name}"?',
      onConfirm: () async {
        try {
          await _presentationService.delete(presentation.idPresentation!);
          _showSuccess('Presentación eliminada con éxito');
          if (_selectedProduct != null) {
            _loadPresentationsForProduct(_selectedProduct!);
          }
        } catch (e) {
          _showError('Error al eliminar presentación: $e');
        }
      },
    );
  }

  void _confirmDisableIngredient(Ingredient ingredient) {
    final action = ingredient.state ? 'Deshabilitar' : 'Restaurar';
    final serviceCall = ingredient.state 
        ? _ingredientService.disable(ingredient.idIngredient!)
        : _ingredientService.restore(ingredient.idIngredient!);

    _showConfirmationDialog(
      title: 'Confirmar $action',
      content: '¿Estás seguro de que quieres $action el insumo "${ingredient.name}"?',
      onConfirm: () async {
        try {
          await serviceCall;
          _showSuccess('Insumo ${ingredient.state ? "deshabilitado" : "restaurado"} con éxito');
          _loadIngredients();
        } catch (e) {
          _showError('Error al $action insumo: $e');
        }
      },
      confirmButtonColor: ingredient.state ? Colors.orange : Colors.green,
      confirmButtonText: action,
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
    Color confirmButtonColor = Colors.red,
    String confirmButtonText = 'Eliminar',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: confirmButtonColor),
            child: Text(confirmButtonText),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}