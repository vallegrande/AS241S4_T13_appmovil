import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:as241s4_t13_appmovil/core/models/order/order_model.dart';
import 'package:as241s4_t13_appmovil/core/models/order/orderDetail_model.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/presentation.dart';
import 'package:as241s4_t13_appmovil/core/services/order/order_service.dart';
import 'package:as241s4_t13_appmovil/core/services/order/orderDetail_service.dart';
import 'package:intl/intl.dart';
import 'modal_presentations.dart';

class WaiterOrdersView extends StatefulWidget {
  final OrderService orderService;
  final OrderDetailService orderDetailService;

  const WaiterOrdersView({
    super.key,
    required this.orderService,
    required this.orderDetailService,
  });

  @override
  State<WaiterOrdersView> createState() => _WaiterOrdersViewState();
}

class _WaiterOrdersViewState extends State<WaiterOrdersView>
    with AutomaticKeepAliveClientMixin {
  List<Order> _pendingOrders = [];
  List<Order> _inPreparationOrders = [];
  List<Order> _readyOrders = [];
  List<Order> _deliveredOrders = [];
  bool _isLoading = true;

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);
  final Color surfaceBg = const Color(0xFFFAFAFC);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final pending = await widget.orderService.getOrdersByStatus('PENDIENTE');
      final inPreparation =
          await widget.orderService.getOrdersByStatus('EN_PREPARACION');
      final ready = await widget.orderService.getOrdersByStatus('LISTO');
      final delivered =
          await widget.orderService.getOrdersByStatus('ENTREGADO');

      if (mounted) {
        setState(() {
          _pendingOrders = pending;
          _inPreparationOrders = inPreparation;
          _readyOrders = ready;
          _deliveredOrders = delivered;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pedidos: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'LOCAL':
        return 'Local';
      case 'TAKEOUT':
        return 'Takeout';
      case 'DELIVERY':
        return 'Delivery';
      default:
        return type;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'LOCAL':
        return Icons.restaurant_rounded;
      case 'TAKEOUT':
        return Icons.takeout_dining_rounded;
      case 'DELIVERY':
        return Icons.delivery_dining_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'LOCAL':
        return Colors.blue;
      case 'TAKEOUT':
        return Colors.green;
      case 'DELIVERY':
        return Colors.purple;
      default:
        return primaryOrange;
    }
  }

  double _getPriceByOrderType(Presentation p, String orderType) {
    switch (orderType.toUpperCase()) {
      case 'DELIVERY':
        return p.deliveryPrice ?? p.price;
      case 'TAKEOUT':
        return p.takeoutPrice ?? p.price;
      case 'PROMO':
        return p.promoPrice ?? p.price;
      default:
        return p.price;
    }
  }

  bool _canModifyOrder(String orderStatus) {
    return orderStatus == 'PENDIENTE' || orderStatus == 'EN_PREPARACION';
  }

  Future<void> _addPresentationToOrder(Order order) async {
    if (order.idOrder == null) return;

    if (!_canModifyOrder(order.orderStatus)) {
      _showErrorMessage(
        'No se pueden agregar productos. El pedido está en estado: ${order.orderStatus}. Solo se permiten modificaciones en estados PENDIENTE o EN_PREPARACION.',
      );
      return;
    }

    try {
      final selectedPresentation = await showPresentationSelectionModal(
        context,
        orderType: order.typeOfConsumption,
      );

      if (selectedPresentation == null) return;

      final amount = await _showAmountDialog(selectedPresentation.name);
      if (amount == null || amount <= 0) return;

      final newDetail = OrderDetail(
        idOrder: order.idOrder,
        idPresentation: selectedPresentation.idPresentation,
        presentationName: selectedPresentation.name,
        amount: amount,
        unitPrice:
            _getPriceByOrderType(selectedPresentation, order.typeOfConsumption),
      );

      await widget.orderDetailService.createOrderDetail(newDetail);

      if (mounted) {
        _showSuccessMessage(
          '${selectedPresentation.name} agregado al pedido',
        );
        await _loadOrders();
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(_extractErrorMessage(e.toString()));
      }
    }
  }

  Future<void> _editDetailAmount(Order order, OrderDetail detail) async {
    if (detail.idDetail == null) return;

    if (!_canModifyOrder(order.orderStatus)) {
      _showErrorMessage(
        'No se puede editar. El pedido está en estado: ${order.orderStatus}. Solo se permiten modificaciones en estados PENDIENTE o EN_PREPARACION.',
      );
      return;
    }

    try {
      final newAmount = await _showAmountDialog(
        detail.presentationName ?? 'Producto',
        currentAmount: detail.amount,
      );

      if (newAmount == null || newAmount <= 0) return;

      // ✅ Creamos un OrderDetail actualizado con idPresentation
      final updatedDetail = OrderDetail(
        idDetail: detail.idDetail,
        idOrder: detail.idOrder,
        idPresentation: detail.idPresentation,
        presentationName: detail.presentationName,
        amount: newAmount,
        unitPrice: detail.unitPrice,
      );

      await widget.orderDetailService.updateOrderDetail(
        detail.idDetail!,
        updatedDetail,
      );

      if (mounted) {
        _showSuccessMessage('Cantidad actualizada');
        await _loadOrders();
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(_extractErrorMessage(e.toString()));
      }
    }
  }

  Future<void> _deleteDetail(Order order, OrderDetail detail) async {
    if (detail.idDetail == null) return;

    if (!_canModifyOrder(order.orderStatus)) {
      _showErrorMessage(
        'No se puede eliminar. El pedido está en estado: ${order.orderStatus}. Solo se permiten modificaciones en estados PENDIENTE o EN_PREPARACION.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded,
                color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Eliminar Producto',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de eliminar este producto del pedido?',
                style: GoogleFonts.inter(fontSize: 15)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.presentationName ?? 'Producto',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cantidad: ${detail.amount}',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta acción no se puede deshacer.',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Eliminar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.orderDetailService.deleteOrderDetail(detail.idDetail!);

        if (mounted) {
          _showSuccessMessage('Producto eliminado del pedido');
          await _loadOrders();
        }
      } catch (e) {
        if (mounted) {
          _showErrorMessage(_extractErrorMessage(e.toString()));
        }
      }
    }
  }

  // ✅ Helper para extraer mensaje de error limpio
  String _extractErrorMessage(String error) {
    // Eliminar "Exception: " del inicio
    error = error.replaceAll('Exception: ', '');

    // Si el error ya contiene el mensaje completo, retornarlo
    if (error.contains('Solo se permiten modificaciones')) {
      return error;
    }

    return error;
  }

  // ✅ Helper para mostrar mensajes de error
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ✅ Helper para mostrar mensajes de éxito
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<int?> _showAmountDialog(String productName,
      {int? currentAmount}) async {
    final controller =
        TextEditingController(text: currentAmount?.toString() ?? '1');

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.shopping_cart_rounded,
                  color: primaryOrange, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                currentAmount != null ? 'Editar Cantidad' : 'Cantidad',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(productName,
                style: GoogleFonts.inter(
                    fontSize: 14, color: Colors.grey.shade700)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Cantidad',
                labelStyle: GoogleFonts.inter(color: primaryOrange),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryOrange, width: 2),
                ),
                prefixIcon:
                    Icon(Icons.add_shopping_cart_rounded, color: primaryOrange),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              Navigator.pop(context, amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Confirmar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _deliverOrder(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: primaryOrange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Entregar Pedido',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Confirmar entrega del pedido #${order.idOrder}?',
                style: GoogleFonts.inter(fontSize: 15)),
            const SizedBox(height: 16),
            if (order.idTable != null)
              _InfoChip(
                  icon: Icons.table_restaurant_rounded,
                  label: 'Mesa ${order.idTable}'),
            if (order.customer != null) ...[
              const SizedBox(height: 8),
              _InfoChip(
                  icon: Icons.person_rounded, label: order.customer!.fullName),
            ],
            const SizedBox(height: 8),
            _InfoChip(
                icon: _getTypeIcon(order.typeOfConsumption),
                label: _getTypeLabel(order.typeOfConsumption)),
            if (order.details != null && order.details!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Productos:',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...order.details!.take(3).map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                              color: primaryOrange, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            detail.presentationName ?? 'Producto',
                            style: GoogleFonts.inter(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'x${detail.amount}',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: primaryOrange),
                        ),
                      ],
                    ),
                  )),
              if (order.details!.length > 3) ...[
                const SizedBox(height: 4),
                Text(
                  '+ ${order.details!.length - 3} productos más...',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.normal),
                ),
              ],
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Entregar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.orderService
            .updateOrderStatus(order.idOrder!, 'ENTREGADO');

        if (mounted) {
          _showSuccessMessage(
              'Pedido #${order.idOrder} entregado exitosamente');
          await _loadOrders();
        }
      } catch (e) {
        if (mounted) {
          _showErrorMessage(_extractErrorMessage(e.toString()));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryOrange));
    }

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryOrange, lightOrange]),
              boxShadow: [
                BoxShadow(
                  color: primaryOrange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600),
              isScrollable: true,
              tabs: [
                Tab(
                  icon: Badge(
                    label: Text('${_pendingOrders.length}'),
                    isLabelVisible: _pendingOrders.isNotEmpty,
                    backgroundColor: Colors.white,
                    textColor: primaryOrange,
                    child: const Icon(Icons.pending_actions_rounded, size: 20),
                  ),
                  text: 'Pendientes',
                ),
                Tab(
                  icon: Badge(
                    label: Text('${_inPreparationOrders.length}'),
                    isLabelVisible: _inPreparationOrders.isNotEmpty,
                    backgroundColor: Colors.white,
                    textColor: primaryOrange,
                    child: const Icon(Icons.soup_kitchen_rounded, size: 20),
                  ),
                  text: 'En Preparación',
                ),
                Tab(
                  icon: Badge(
                    label: Text('${_readyOrders.length}'),
                    isLabelVisible: _readyOrders.isNotEmpty,
                    backgroundColor: Colors.white,
                    textColor: primaryOrange,
                    child: const Icon(Icons.restaurant_menu_rounded, size: 20),
                  ),
                  text: 'Listos',
                ),
                Tab(
                  icon: Badge(
                    label: Text('${_deliveredOrders.length}'),
                    isLabelVisible: _deliveredOrders.isNotEmpty,
                    backgroundColor: Colors.white,
                    textColor: primaryOrange,
                    child: const Icon(Icons.check_circle_rounded, size: 20),
                  ),
                  text: 'Entregados',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrdersList(_pendingOrders,
                    canModify: true, canDeliver: false),
                _buildOrdersList(_inPreparationOrders,
                    canModify: true, canDeliver: false),
                _buildOrdersList(_readyOrders,
                    canModify: false, canDeliver: true),
                _buildOrdersList(_deliveredOrders,
                    canModify: false, canDeliver: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders,
      {required bool canModify, required bool canDeliver}) {
    if (orders.isEmpty) {
      String emptyMessage;
      IconData emptyIcon;

      if (canDeliver) {
        emptyMessage = 'No hay pedidos listos';
        emptyIcon = Icons.restaurant_menu_rounded;
      } else if (canModify) {
        emptyMessage = 'No hay pedidos en este estado';
        emptyIcon = Icons.pending_actions_rounded;
      } else {
        emptyMessage = 'No hay pedidos entregados';
        emptyIcon = Icons.check_circle_outline_rounded;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(emptyIcon, size: 64, color: primaryOrange),
            ),
            const SizedBox(height: 20),
            Text(
              emptyMessage,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text('Los pedidos aparecerán aquí',
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _WaiterOrderCard(
            order: order,
            onDeliver: canDeliver ? () => _deliverOrder(order) : null,
            onAddProduct:
                canModify ? () => _addPresentationToOrder(order) : null,
            onEditDetail:
                canModify ? (detail) => _editDetailAmount(order, detail) : null,
            onDeleteDetail:
                canModify ? (detail) => _deleteDetail(order, detail) : null,
            primaryOrange: primaryOrange,
            lightOrange: lightOrange,
            getTypeLabel: _getTypeLabel,
            getTypeIcon: _getTypeIcon,
            getTypeColor: _getTypeColor,
          );
        },
      ),
    );
  }
}

// [El resto del código _WaiterOrderCard, _InfoRow, _InfoChip permanece exactamente igual que en la versión anterior]
class _WaiterOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onDeliver;
  final VoidCallback? onAddProduct;
  final Function(OrderDetail)? onEditDetail;
  final Function(OrderDetail)? onDeleteDetail;
  final Color primaryOrange;
  final Color lightOrange;
  final String Function(String) getTypeLabel;
  final IconData Function(String) getTypeIcon;
  final Color Function(String) getTypeColor;

  const _WaiterOrderCard({
    required this.order,
    this.onDeliver,
    this.onAddProduct,
    this.onEditDetail,
    this.onDeleteDetail,
    required this.primaryOrange,
    required this.lightOrange,
    required this.getTypeLabel,
    required this.getTypeIcon,
    required this.getTypeColor,
  });

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return DateFormat('dd/MM HH:mm').format(date);
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'EN_PREPARACION':
        return 'En Preparación';
      case 'LISTO':
        return 'Listo';
      case 'ENTREGADO':
        return 'Entregado';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDIENTE':
        return Icons.pending_actions_rounded;
      case 'EN_PREPARACION':
        return Icons.soup_kitchen_rounded;
      case 'LISTO':
        return Icons.restaurant_menu_rounded;
      case 'ENTREGADO':
        return Icons.check_circle_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDIENTE':
        return Colors.amber;
      case 'EN_PREPARACION':
        return Colors.blue;
      case 'LISTO':
        return Colors.green;
      case 'ENTREGADO':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = getTypeColor(order.typeOfConsumption);
    final statusColor = _getStatusColor(order.orderStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primaryOrange.withOpacity(0.2), width: 2),
      ),
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
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(getTypeIcon(order.typeOfConsumption),
                      color: typeColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Pedido #${order.idOrder}',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              getTypeLabel(order.typeOfConsumption),
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: typeColor),
                            ),
                          ),
                          if (order.idTable != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: primaryOrange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.table_restaurant_rounded,
                                      size: 12, color: primaryOrange),
                                  const SizedBox(width: 4),
                                  Text('Mesa ${order.idTable}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: primaryOrange)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(_getTimeAgo(order.orderDate),
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(order.orderStatus),
                          size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(_getStatusLabel(order.orderStatus),
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.customer != null) ...[
                        _InfoRow(
                            icon: Icons.person_rounded,
                            label: order.customer!.fullName),
                        const SizedBox(height: 6),
                      ],
                      if (order.numberOfPeople > 1) ...[
                        _InfoRow(
                            icon: Icons.people_rounded,
                            label: '${order.numberOfPeople} personas'),
                        const SizedBox(height: 6),
                      ],
                      if (order.deliveryAddress != null) ...[
                        _InfoRow(
                            icon: Icons.location_on_rounded,
                            label: order.deliveryAddress!,
                            maxLines: 1),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey.shade600)),
                    Text('S/ ${order.total.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: primaryOrange)),
                  ],
                ),
              ],
            ),
            if (order.details != null && order.details!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Productos:',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700)),
                  if (onAddProduct != null)
                    TextButton.icon(
                      onPressed: onAddProduct,
                      icon: Icon(Icons.add_circle_rounded,
                          size: 18, color: primaryOrange),
                      label: Text('Agregar',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryOrange)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ...order.details!.map((detail) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: primaryOrange, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.presentationName ?? 'Producto',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'S/ ${detail.unitPrice.toStringAsFixed(2)} c/u',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'x${detail.amount}',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: primaryOrange),
                          ),
                        ),
                        if (onEditDetail != null || onDeleteDetail != null) ...[
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded,
                                size: 20, color: Colors.grey.shade600),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            itemBuilder: (context) => [
                              if (onEditDetail != null)
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_rounded,
                                          size: 18,
                                          color: Colors.blue.shade600),
                                      const SizedBox(width: 10),
                                      Text('Editar cantidad',
                                          style:
                                              GoogleFonts.inter(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              if (onDeleteDetail != null)
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_rounded,
                                          size: 18, color: Colors.red.shade600),
                                      const SizedBox(width: 10),
                                      Text('Eliminar',
                                          style:
                                              GoogleFonts.inter(fontSize: 13)),
                                    ],
                                  ),
                                ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit' && onEditDetail != null) {
                                onEditDetail!(detail);
                              } else if (value == 'delete' &&
                                  onDeleteDetail != null) {
                                onDeleteDetail!(detail);
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
            if (order.customerNotes != null &&
                order.customerNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note_rounded,
                        size: 18, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(order.customerNotes!,
                          style: GoogleFonts.inter(
                              fontSize: 13, fontStyle: FontStyle.normal)),
                    ),
                  ],
                ),
              ),
            ],
            if (onDeliver != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onDeliver,
                  icon: const Icon(Icons.check_circle_rounded, size: 22),
                  label: Text('Marcar como Entregado',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int maxLines;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style:
                  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
