import 'package:flutter/material.dart';
import 'widgets/categories_tab.dart';
import 'widgets/products_tab.dart';
import 'widgets/presentations_tab.dart';
import 'widgets/ingredients_tab.dart';

class PanelCatalogScreen extends StatefulWidget {
  const PanelCatalogScreen({super.key});

  @override
  State<PanelCatalogScreen> createState() => _PanelCatalogScreenState();
}

class _PanelCatalogScreenState extends State<PanelCatalogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header con título y pestañas
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título del módulo
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF1100).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Color(0xFFFF1100),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Catálogo de Productos',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Gestiona tu menú por secciones, categorías y presentaciones',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // TabBar perfectamente alineado y con buen espaciado
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: const Color(0xFFFF1100),
                        indicatorWeight: 3,
                        labelColor: const Color(0xFFFF1100),
                        unselectedLabelColor: const Color(0xFF718096),
                        tabAlignment: TabAlignment.start,
                        // 👇 Espaciado equilibrado entre tabs sin afectar alineación
                        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                        labelStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                        tabs: const [
                          Tab(
                            child: Row(
                              children: [
                                Icon(Icons.category, size: 20),
                                SizedBox(width: 8),
                                Text('Categorías'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                Icon(Icons.fastfood, size: 20),
                                SizedBox(width: 8),
                                Text('Productos'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                Icon(Icons.style, size: 20),
                                SizedBox(width: 8),
                                Text('Presentaciones'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                Icon(Icons.kitchen, size: 20),
                                SizedBox(width: 8),
                                Text('Ingredientes'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // 👇 Línea divisoria sutil debajo del TabBar
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE2E8F0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                CategoriesTab(),
                ProductsTab(),
                PresentationsTab(),
                IngredientsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
