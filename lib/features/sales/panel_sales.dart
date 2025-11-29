// lib/features/sales/panel_sales.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:as241s4_t13_appmovil/core/services/sales/sale_service.dart';
import 'package:as241s4_t13_appmovil/core/models/sales/sale_model.dart';
import 'widgets/sales_table.dart';
import 'widgets/sales_stats_card.dart';

class PanelSales extends StatefulWidget {
  const PanelSales({super.key});

  @override
  State<PanelSales> createState() => _PanelSalesState();
}

class _PanelSalesState extends State<PanelSales> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Sale> _sales = [];
  List<Sale> _filteredSales = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);
  final Color darkText = const Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSales();
  }

  Future<void> _loadSales() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final sales = await SaleService.getAllSales();
      setState(() {
        _sales = sales;
        _filteredSales = sales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar ventas: $e';
      });
      print('❌ Error en _loadSales: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 16),
          // Tabs
          _buildTabs(),
          // Error message
          if (_errorMessage.isNotEmpty) _buildErrorWidget(),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pestaña Pedidos Pendientes
                _PendingOrdersTab(
                  onRefresh: _loadSales,
                ),
                // Pestaña Ventas Realizadas  
                _CompletedSalesTab(
                  sales: _filteredSales,
                  isLoading: _isLoading,
                  onRefresh: _loadSales,
                  errorMessage: _errorMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y botón en fila
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de Ventas',
                    style: GoogleFonts.poppins(
                      fontSize: 22, // Reducido ligeramente
                      fontWeight: FontWeight.w800,
                      color: darkText,
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Control y seguimiento de ventas',
                    style: GoogleFonts.inter(
                      fontSize: 13, // Reducido ligeramente
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Botón Refresh - tamaño más compacto
            Container(
              constraints: const BoxConstraints(
                minWidth: 100, // Ancho mínimo
                maxWidth: 120, // Ancho máximo
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryOrange,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: primaryOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: InkWell(
                onTap: _loadSales,
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, 
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Actualizar',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, duration: 500.ms);
}

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        labelColor: primaryOrange,
        unselectedLabelColor: Colors.grey.shade600,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: primaryOrange.withOpacity(0.1),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pending_actions_rounded, size: 20),
                const SizedBox(width: 8),
                Text('Pendientes de Cobro'),
              ],
            ),
          ),
          Tab(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, size: 20),
                const SizedBox(width: 8),
                Text('Ventas Realizadas'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.red.shade50,
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: GoogleFonts.inter(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: Colors.red.shade600),
            onPressed: () {
              setState(() {
                _errorMessage = '';
              });
            },
          ),
        ],
      ),
    );
  }
}

// Pestaña de Pedidos Pendientes
class _PendingOrdersTab extends StatelessWidget {
  final VoidCallback onRefresh;

  const _PendingOrdersTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Aquí irá la tabla de pedidos pendientes (conectar con OrderService)
          SalesTable(
            isPending: true,
            onRefresh: onRefresh,
          ),
        ],
      ),
    );
  }
}

// Pestaña de Ventas Realizadas  
class _CompletedSalesTab extends StatelessWidget {
  final List<Sale> sales;
  final bool isLoading;
  final VoidCallback onRefresh;
  final String errorMessage;

  const _CompletedSalesTab({
    required this.sales,
    required this.isLoading,
    required this.onRefresh,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Métricas
          SalesStatsCard(sales: sales),
          const SizedBox(height: 20),
          // Tabla de ventas
          SalesTable(
            isPending: false,
            sales: sales,
            isLoading: isLoading,
            onRefresh: onRefresh,
            errorMessage: errorMessage,
          ),
        ],
      ),
    );
  }
}