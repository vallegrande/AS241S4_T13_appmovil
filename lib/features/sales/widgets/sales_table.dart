// lib/features/sales/widgets/sales_table.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:as241s4_t13_appmovil/core/models/sales/sale_model.dart';
import 'package:as241s4_t13_appmovil/core/models/order/order_model.dart';
import 'package:as241s4_t13_appmovil/core/services/sales/sale_service.dart';
import 'package:as241s4_t13_appmovil/core/services/order/order_service.dart';
import 'sale_detail_modal.dart';
import 'payment_modal.dart';

class SalesTable extends StatefulWidget {
  final bool isPending;
  final List<Sale>? sales;
  final bool isLoading;
  final VoidCallback onRefresh;
  final String errorMessage;

  const SalesTable({
    super.key,
    required this.isPending,
    this.sales,
    this.isLoading = false,
    required this.onRefresh,
    this.errorMessage = '',
  });

  @override
  State<SalesTable> createState() => _SalesTableState();
}

class _SalesTableState extends State<SalesTable> {
  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color darkText = const Color(0xFF1A1A2E);

  List<Order> _pendingOrders = [];
  bool _isLoadingOrders = false;
  String _ordersErrorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.isPending) {
      _loadPendingOrders();
    }
  }

  Future<void> _loadPendingOrders() async {
    try {
      setState(() {
        _isLoadingOrders = true;
        _ordersErrorMessage = '';
      });
      
      print('🔄 Cargando pedidos entregados...');
      final orders = await OrderService().getOrdersByStatus('ENTREGADO');
      
      setState(() {
        _pendingOrders = orders;
        _isLoadingOrders = false;
      });
      
      print('✅ Pedidos entregados cargados: ${orders.length}');
    } catch (e) {
      setState(() {
        _isLoadingOrders = false;
        _ordersErrorMessage = 'Error al cargar pedidos: $e';
      });
      print('❌ Error cargando pedidos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.isPending ? _pendingOrders : (widget.sales ?? []);
    final isLoading = widget.isPending ? _isLoadingOrders : widget.isLoading;
    final errorMessage = widget.isPending ? _ordersErrorMessage : widget.errorMessage;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error message
          if (errorMessage.isNotEmpty) _buildErrorWidget(errorMessage),
          // Header de la tabla
          _buildTableHeader(),
          // Loading state
          if (isLoading) _buildLoadingState(),
          // Lista de items
          if (!isLoading && data.isEmpty && errorMessage.isEmpty) _buildEmptyState(),
          if (!isLoading && data.isNotEmpty) ..._buildTableRows(data),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              widget.isPending ? 'Pedido' : 'Venta',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Cliente',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Total',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Estado',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const Expanded(flex: 1, child: SizedBox()), // Espacio para acciones
        ],
      ),
    );
  }

  List<Widget> _buildTableRows(List<dynamic> data) {
    if (widget.isPending) {
      return data.map((order) => _buildPendingOrderRow(order as Order)).toList();
    } else {
      return data.map((sale) => _buildSaleRow(sale as Sale)).toList();
    }
  }

  Widget _buildPendingOrderRow(Order order) {
    final customerName = order.customer?.fullName ?? 'Cliente Mostrador';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '#${order.idOrder}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              customerName,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              order.formattedTotal,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildOrderStatusBadge(order.orderStatus),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.payment_rounded,
                color: primaryOrange,
                size: 20,
              ),
              onPressed: () => _openPaymentModal(order),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleRow(Sale sale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '#${sale.idSale}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              sale.customerName,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              sale.formattedTotal,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildSaleStatusBadge(sale),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.visibility_rounded,
                color: primaryOrange,
                size: 20,
              ),
              onPressed: () => _openDetailModal(sale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case 'ENTREGADO':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        text = 'ENTREGADO';
        break;
      case 'CERRADO':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        text = 'CERRADO';
        break;
      case 'PENDIENTE':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade700;
        text = 'PENDIENTE';
        break;
      case 'PREPARACION':
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple.shade700;
        text = 'PREPARACIÓN';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey.shade700;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSaleStatusBadge(Sale sale) {
    Color backgroundColor;
    Color textColor;
    String text;

    if (sale.isActive) {
      backgroundColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green.shade700;
      text = 'CERRADA';
    } else {
      backgroundColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red.shade700;
      text = 'ANULADA';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            widget.isPending ? 'Cargando pedidos...' : 'Cargando ventas...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            widget.isPending 
                ? 'No hay pedidos pendientes de cobro'
                : 'No se encontraron ventas',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isPending
                ? 'Los pedidos en estado ENTREGADO aparecerán aquí'
                : 'Intenta ajustar los filtros o el rango de fechas',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.isPending) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPendingOrders,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- MÉTODO ACTUALIZADO ---
  void _openPaymentModal(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentModal(
        order: order,
        onPaymentSuccess: () {
          print('🔄 Recargando datos después de pago exitoso...');
          // Recargar tanto pedidos como ventas después del pago exitoso
          if (widget.isPending) {
            _loadPendingOrders();
          }
          widget.onRefresh(); // Esto recargará las ventas en la otra pestaña
        },
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    final isAuthError = errorMessage.contains('denegado') || 
                     errorMessage.contains('autenticado') ||
                     errorMessage.contains('403') ||
                     errorMessage.contains('401');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAuthError ? Colors.orange.shade50 : Colors.red.shade50,
        border: Border(bottom: BorderSide(
          color: isAuthError ? Colors.orange.shade200 : Colors.red.shade200
        )),
      ),
      child: Row(
        children: [
          Icon(
            isAuthError ? Icons.warning_amber_rounded : Icons.error_outline_rounded,
            color: isAuthError ? Colors.orange.shade600 : Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMessage,
                  style: GoogleFonts.inter(
                    color: isAuthError ? Colors.orange.shade700 : Colors.red.shade700,
                    fontSize: 14,
                  ),
                ),
                if (isAuthError) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Verifica que tengas los permisos necesarios',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isAuthError ? Colors.orange.shade600 : Colors.red.shade600,
            ),
            onPressed: widget.isPending ? _loadPendingOrders : widget.onRefresh,
          ),
        ],
      ),
    );
  }

  void _openDetailModal(Sale sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaleDetailModal(sale: sale),
    );
  }
}