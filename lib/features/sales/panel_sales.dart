// lib/features/sales/panel_sales.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:as241s4_t13_appmovil/core/services/sales/sale_service.dart';
import 'package:as241s4_t13_appmovil/core/models/sales/sale_model.dart';
import 'package:as241s4_t13_appmovil/core/services/customer/customer_service.dart';
import 'widgets/sales_table.dart';
import 'widgets/sales_stats_card.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/presentation_service.dart';


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
    _loadSalesWithRealNames();
  }

  // MÉTODO PRINCIPAL CORREGIDO: Carga ventas con nombres reales
  Future<void> _loadSalesWithRealNames() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    print('\n🔄 INICIANDO CARGA DE VENTAS...');

    // 1. CARGAR VENTAS DESDE EL BACKEND
    final rawSales = await SaleService.getAllSales();
    print('📦 Ventas crudas cargadas: ${rawSales.length}');

    if (rawSales.isEmpty) {
      print('⚠️ No hay ventas para mostrar');
      setState(() {
        _sales = [];
        _filteredSales = [];
        _isLoading = false;
      });
      return;
    }

    // ORDENAR POR ID DESCENDENTE
    rawSales.sort((a, b) => b.idSale.compareTo(a.idSale));

    // 2. CARGAR CLIENTES PARA OBTENER NOMBRES
    print('\n🔍 CARGANDO CLIENTES PARA OBTENER NOMBRES REALES...');
    final Map<int, String> customerNameMap = {};
    
    try {
      final customerService = CustomerService();
      final customerList = await customerService.getCustomersByState(1);
      
      for (var customer in customerList) {
        if (customer.idCustomer != null) {
          // Usar fullName si está disponible, sino nombre y apellido
          String displayName;
          if (customer.fullName.isNotEmpty && customer.fullName != 'null') {
            displayName = customer.fullName;
          } else if (customer.firstName != null && customer.firstName!.isNotEmpty) {
            displayName = '${customer.firstName ?? ''} ${customer.lastName ?? ''}'.trim();
          } else {
            displayName = 'Cliente #${customer.idCustomer}';
          }
          
          if (displayName.isNotEmpty) {
            customerNameMap[customer.idCustomer!] = displayName;
          }
        }
      }
      print('✅ Mapa de clientes creado con ${customerNameMap.length} nombres');
    } catch (e) {
      print('⚠️ Error cargando clientes: $e');
    }

    // 3. CARGAR PRESENTACIONES PARA NOMBRES DE PRODUCTOS
    print('\n🔍 CARGANDO PRESENTACIONES PARA NOMBRES DE PRODUCTOS...');
    final Map<int, String> presentationNameMap = {};
    
    try {
      final presentations = await PresentationService.getAll();
      for (var presentation in presentations) {
        if (presentation.idPresentation != null && presentation.name.isNotEmpty) {
          presentationNameMap[presentation.idPresentation!] = presentation.name;
        }
      }
      print('✅ Mapa de productos creado con ${presentationNameMap.length} nombres');
    } catch (e) {
      print('⚠️ Error cargando presentaciones: $e');
    }

    // 4. ACTUALIZAR VENTAS CON NOMBRES REALES
    print('\n✏️  ASIGNANDO NOMBRES REALES...');
    final List<Sale> finalSales = [];
    
    for (var sale in rawSales) {
      // Obtener nombre real del cliente
      String finalCustomerName = sale.customerName ?? 'Cliente Mostrador';
      
      if (finalCustomerName.startsWith('Cliente #') || 
          finalCustomerName == 'Cliente Mostrador' ||
          finalCustomerName == 'null') {
        
        final realName = customerNameMap[sale.idCustomer];
        if (realName != null && realName.isNotEmpty) {
          finalCustomerName = realName;
        } else {
          finalCustomerName = 'Cliente #${sale.idCustomer}';
        }
      }

      // Obtener nombres reales de productos
      List<SaleDetail>? finalDetails;
      if (sale.details != null && sale.details!.isNotEmpty) {
        finalDetails = [];
        
        for (var detail in sale.details!) {
          String finalProductName = detail.presentationName;
          
          // Si el nombre es genérico, buscar nombre real
          if (finalProductName.startsWith('Producto #') || 
              finalProductName == 'null' ||
              finalProductName.isEmpty) {
            
            final realProductName = presentationNameMap[detail.idPresentation];
            if (realProductName != null && realProductName.isNotEmpty) {
              finalProductName = realProductName;
            }
          }
          
          finalDetails.add(SaleDetail(
            idDetailSale: detail.idDetailSale,
            idSale: detail.idSale,
            idPresentation: detail.idPresentation,
            presentationName: finalProductName,
            amount: detail.amount,
            unitPrice: detail.unitPrice,
            subtotal: detail.subtotal,
          ));
        }
      }

      // Crear venta actualizada con nombres reales
      final updatedSale = Sale(
        idSale: sale.idSale,
        idUser: sale.idUser,
        idCustomer: sale.idCustomer,
        customerName: finalCustomerName, // ← NOMBRE REAL AQUÍ
        customer: sale.customer,
        idOrder: sale.idOrder,
        saleDate: sale.saleDate,
        total: sale.total,
        paymentType: sale.paymentType,
        state: sale.state,
        cashReceived: sale.cashReceived,
        cashChange: sale.cashChange,
        cardType: sale.cardType,
        cardLast4: sale.cardLast4,
        cardOperation: sale.cardOperation,
        posReference: sale.posReference,
        phonePayment: sale.phonePayment,
        transactionCode: sale.transactionCode,
        bankName: sale.bankName,
        bankAccount: sale.bankAccount,
        bankOperation: sale.bankOperation,
        paymentProofUrl: sale.paymentProofUrl,
        details: finalDetails ?? sale.details, // ← PRODUCTOS REALES AQUÍ
      );
      
      finalSales.add(updatedSale);
    }

    // 5. MOSTRAR RESULTADOS EN CONSOLA
    print('\n🎯 RESUMEN FINAL:');
    print('   Ventas procesadas: ${finalSales.length}');
    
    if (finalSales.isNotEmpty) {
      print('\n📋 EJEMPLOS DE VENTAS CON NOMBRES REALES:');
      for (var i = 0; i < finalSales.length && i < 3; i++) {
        final sale = finalSales[i];
        print('   Venta #${sale.idSale}: ${sale.customerName}');
        
        if (sale.details != null && sale.details!.isNotEmpty) {
          for (var j = 0; j < sale.details!.length && j < 2; j++) {
            final detail = sale.details![j];
            print('     - ${detail.presentationName}');
          }
        }
      }
    }

    // 6. ACTUALIZAR ESTADO
    setState(() {
      _sales = finalSales;
      _filteredSales = finalSales;
      _isLoading = false;
    });

  } catch (e) {
    print('❌ ERROR en _loadSalesWithRealNames: $e');
    setState(() {
      _isLoading = false;
      _errorMessage = 'Error al cargar ventas: $e';
    });
  }
}

  Future<void> _debugAndReloadSales() async {
  print('\n🔍 MODO DEBUG ACTIVADO...');
  
  try {
    setState(() {
      _isLoading = true;
    });

    // 1. Forzar recarga desde el backend
    final sales = await SaleService.getAllSales();
    print('📊 TOTAL DE VENTAS EN EL SISTEMA: ${sales.length}');
    
    // Ordenar por ID descendente
    sales.sort((a, b) => b.idSale.compareTo(a.idSale));
    
    if (sales.isNotEmpty) {
      print('\n📋 TODAS LAS VENTAS (ordenadas por ID descendente):');
      for (var i = 0; i < sales.length; i++) {
        final sale = sales[i];
        print('   ${i+1}. Venta #${sale.idSale} - ${sale.formattedDate} - ${sale.displayCustomerName} - S/ ${sale.total}');
      }
      
      print('\n🎯 VENTA MÁS RECIENTE:');
      final newestSale = sales.first;
      print('   - ID: #${newestSale.idSale}');
      print('   - Fecha: ${newestSale.formattedDate}');
      print('   - Cliente: ${newestSale.displayCustomerName}');
      print('   - Total: ${newestSale.formattedTotal}');
      print('   - Estado: ${newestSale.isActive ? "CERRADA" : "ANULADA"}');
      print('   - ID Order: ${newestSale.idOrder}');
    } else {
      print('⚠️  No hay ventas en el sistema');
    }
    
    // 2. Actualizar el estado
    setState(() {
      _sales = sales;
      _filteredSales = sales;
      _isLoading = false;
    });
    
    print('✅ Estado actualizado con ${sales.length} ventas');
    
  } catch (e) {
    print('❌ Error en depuración: $e');
    setState(() {
      _isLoading = false;
      _errorMessage = 'Error al cargar ventas: $e';
    });
  }
}


  // MÉTODO PARA MEJORAR VENTAS CON NOMBRES REALES
  Future<List<Sale>> _enhanceSalesWithCustomerNames(List<Sale> rawSales) async {
    try {
      // 1. IDENTIFICAR TODOS LOS IDs DE CLIENTES ÚNICOS
      final customerIds = rawSales.map((s) => s.idCustomer).toSet();
      print('   📋 IDs de clientes únicos: $customerIds');

      // 2. CARGAR TODOS LOS CLIENTES DE UNA VEZ (más eficiente)
      final customerService = CustomerService();
      final allCustomers = await customerService.getCustomersByState(1);
      print('   👥 Clientes cargados desde API: ${allCustomers.length}');

      // 3. CREAR MAPA ID -> NOMBRE COMPLETO
      final customerNameMap = <int, String>{};
      for (var customer in allCustomers) {
        String displayName;
        
        if (customer.fullName.isNotEmpty) {
          displayName = customer.fullName;
        } else if (customer.firstName != null && customer.firstName!.isNotEmpty) {
          displayName = '${customer.firstName} ${customer.lastName ?? ""}'.trim();
        } else {
          displayName = 'Cliente #${customer.idCustomer}';
        }
        
        if (displayName.isNotEmpty && displayName != 'Cliente #${customer.idCustomer}') {
          customerNameMap[customer.idCustomer!] = displayName;
          print('     ✅ Cliente #${customer.idCustomer} → $displayName');
        }
      }

      // 4. CREAR VENTAS ACTUALIZADAS CON NOMBRES REALES
      final List<Sale> enhancedSales = [];
      int ventasActualizadas = 0;
      
      for (var sale in rawSales) {
        Sale updatedSale = sale;
        
        // Si la venta no tiene nombre real, buscarlo en el mapa
        if (sale.displayCustomerName.startsWith('Cliente #') || 
            sale.customerName == 'Cliente Mostrador') {
          
          final realName = customerNameMap[sale.idCustomer];
          
          if (realName != null && realName.isNotEmpty) {
            // Crear nueva venta con nombre real
            updatedSale = Sale(
              idSale: sale.idSale,
              idUser: sale.idUser,
              idCustomer: sale.idCustomer,
              customerName: realName,
              customer: sale.customer,
              idOrder: sale.idOrder,
              saleDate: sale.saleDate,
              total: sale.total,
              paymentType: sale.paymentType,
              state: sale.state,
              cashReceived: sale.cashReceived,
              cashChange: sale.cashChange,
              cardType: sale.cardType,
              cardLast4: sale.cardLast4,
              cardOperation: sale.cardOperation,
              posReference: sale.posReference,
              phonePayment: sale.phonePayment,
              transactionCode: sale.transactionCode,
              bankName: sale.bankName,
              bankAccount: sale.bankAccount,
              bankOperation: sale.bankOperation,
              paymentProofUrl: sale.paymentProofUrl,
              details: sale.details,
            );
            
            ventasActualizadas++;
            print('     ✨ Venta #${sale.idSale}: "${sale.customerName}" → "$realName"');
          }
        }
        
        enhancedSales.add(updatedSale);
      }

      print('   📈 Ventas actualizadas con nombres reales: $ventasActualizadas/${rawSales.length}');
      return enhancedSales;
      
    } catch (e) {
      print('   ❌ Error mejorando ventas: $e');
      return rawSales; // Si falla, devolver ventas originales
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
                  onRefresh: _loadSalesWithRealNames,
                ),
                // Pestaña Ventas Realizadas  
                _CompletedSalesTab(
                  sales: _filteredSales,
                  isLoading: _isLoading,
                  onRefresh: _loadSalesWithRealNames,
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
                      fontSize: 22,
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
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Botón Refresh
            Row(
              children: [
                // Botón de depuración (temporal)
                Container(
                  margin: EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: _debugAndReloadSales,
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bug_report_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Debug',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Botón Refresh original
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    maxWidth: 120,
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
                    onTap: _loadSalesWithRealNames,
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
class _CompletedSalesTab extends StatefulWidget {
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
  __CompletedSalesTabState createState() => __CompletedSalesTabState();
}

class __CompletedSalesTabState extends State<_CompletedSalesTab> {
  List<Sale> _currentSales = [];

  @override
  void initState() {
    super.initState();
    _currentSales = widget.sales;
  }

  @override
  void didUpdateWidget(_CompletedSalesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sales != oldWidget.sales) {
      setState(() {
        _currentSales = widget.sales;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Métricas
          SalesStatsCard(sales: _currentSales),
          const SizedBox(height: 20),
          // Tabla de ventas
          SalesTable(
            isPending: false,
            sales: _currentSales,
            isLoading: widget.isLoading,
            onRefresh: widget.onRefresh,
            errorMessage: widget.errorMessage,
          ),
        ],
      ),
    );
  }
}