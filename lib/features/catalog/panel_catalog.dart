import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/category_service.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/product_service.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/presentation_service.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/ingredient_service.dart';
import 'widgets/categories_tab.dart';
import 'widgets/products_tab.dart';
import 'widgets/presentations_tab.dart';
import 'widgets/ingredients_tab.dart';

class PanelCatalogScreen extends StatefulWidget {
  const PanelCatalogScreen({super.key});

  @override
  State<PanelCatalogScreen> createState() => _PanelCatalogScreenState();
}

class _PanelCatalogScreenState extends State<PanelCatalogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);
  final Color accentOrange = const Color(0xFFFFA556);

  // Estadísticas
  int _totalCategories = 0;
  int _totalProducts = 0;
  int _totalPresentations = 0;
  int _totalIngredients = 0;
  int _lowStockIngredients = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoadingStats = true);
    try {
      // Usar /all para obtener información completa
      final categories = await CategoryService.getAll();
      final products = await ProductService.getAll();
      final presentations = await PresentationService.getAll();
      final ingredients = await IngredientService.getAll();

      // Contar ingredientes con stock bajo
      int lowStock = 0;
      for (var ingredient in ingredients) {
        if (ingredient.state &&
            (ingredient.quantity ?? 0) <= (ingredient.minStock ?? 0)) {
          lowStock++;
        }
      }

      if (mounted) {
        setState(() {
          _totalCategories = categories.where((c) => c.state).length;
          _totalProducts = products.where((p) => p.state).length;
          _totalPresentations = presentations.where((p) => p.state).length;
          _totalIngredients = ingredients.where((i) => i.state).length;
          _lowStockIngredients = lowStock;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header con diseño moderno y estadísticas
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryOrange, lightOrange, accentOrange],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryOrange.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del módulo
              Padding(
                padding: const EdgeInsets.all(24),
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
                            Icons.restaurant_menu,
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
                                'Catálogo de Productos',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gestiona tu menú por secciones, categorías y presentaciones',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Estadísticas
                    _isLoadingStats
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildStatCard(
                                  'Categorías',
                                  _totalCategories.toString(),
                                  Icons.category_rounded,
                                  Colors.white,
                                ),
                                const SizedBox(width: 12),
                                _buildStatCard(
                                  'Productos',
                                  _totalProducts.toString(),
                                  Icons.fastfood_rounded,
                                  Colors.blue.shade300,
                                ),
                                const SizedBox(width: 12),
                                _buildStatCard(
                                  'Presentaciones',
                                  _totalPresentations.toString(),
                                  Icons.style_rounded,
                                  Colors.purple.shade300,
                                ),
                                const SizedBox(width: 12),
                                _buildStatCard(
                                  'Ingredientes',
                                  _totalIngredients.toString(),
                                  Icons.kitchen_rounded,
                                  Colors.green.shade300,
                                ),
                                if (_lowStockIngredients > 0) ...[
                                  const SizedBox(width: 12),
                                  _buildAlertCard(
                                    'Stock Bajo',
                                    _lowStockIngredients.toString(),
                                    Icons.warning_rounded,
                                    Colors.red.shade400,
                                  ),
                                ],
                              ],
                            ),
                          ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(
                    begin: -0.3,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),

              // TabBar moderno
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: primaryOrange,
                      indicatorWeight: 3,
                      labelColor: primaryOrange,
                      unselectedLabelColor: Colors.grey.shade600,
                      tabAlignment: TabAlignment.start,
                      labelPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(
                          child: Row(
                            children: [
                              Icon(Icons.category_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Categorías'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            children: [
                              Icon(Icons.fastfood_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Productos'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            children: [
                              Icon(Icons.style_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Presentaciones'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            children: [
                              Icon(Icons.kitchen_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Ingredientes'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Línea divisoria
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Contenido de las pestañas
        Expanded(
          child: Container(
            color: const Color(0xFFF8F9FA),
            child: TabBarView(
              controller: _tabController,
              children: [
                CategoriesTab(onDataChanged: _loadStatistics),
                ProductsTab(onDataChanged: _loadStatistics),
                PresentationsTab(onDataChanged: _loadStatistics),
                IngredientsTab(onDataChanged: _loadStatistics),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
        ],
      ),
    );
  }

  Widget _buildAlertCard(
      String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: iconColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: iconColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().shake(hz: 2, duration: 500.ms);
  }
}
