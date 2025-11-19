import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:as241s4_t13_appmovil/core/models/order/order_model.dart';
import 'package:as241s4_t13_appmovil/core/services/order/order_service.dart';
import 'package:intl/intl.dart';

class CookOrdersView extends StatefulWidget {
  final OrderService orderService;

  const CookOrdersView({super.key, required this.orderService});

  @override
  State<CookOrdersView> createState() => _CookOrdersViewState();
}

class _CookOrdersViewState extends State<CookOrdersView>
    with AutomaticKeepAliveClientMixin {
  List<Order> _pendingOrders = [];
  List<Order> _preparingOrders = [];
  List<Order> _readyOrders = [];
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
      final preparing =
          await widget.orderService.getOrdersByStatus('EN_PREPARACION');
      final ready = await widget.orderService.getOrdersByStatus('LISTO');

      if (mounted) {
        setState(() {
          _pendingOrders = pending;
          _preparingOrders = preparing;
          _readyOrders = ready;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pedidos: $e'),
            backgroundColor: primaryOrange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    try {
      await widget.orderService.updateOrderStatus(order.idOrder!, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido #${order.idOrder} actualizado a $newStatus'),
            backgroundColor: primaryOrange,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      await _loadOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: primaryOrange,
          ),
        );
      }
    }
  }

  void _handleQuickAction(Order order) {
    String newStatus;
    String actionMessage;

    switch (order.orderStatus) {
      case 'PENDIENTE':
        newStatus = 'EN_PREPARACION';
        actionMessage = '¿Comenzar a preparar este pedido?';
        break;
      case 'EN_PREPARACION':
        newStatus = 'LISTO';
        actionMessage = '¿Marcar este pedido como listo?';
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: primaryOrange, size: 28),
            const SizedBox(width: 12),
            Text('Pedido #${order.idOrder}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(actionMessage, style: GoogleFonts.inter(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order, newStatus);
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryOrange));
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryOrange, lightOrange],
              ),
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
                  fontSize: 13, fontWeight: FontWeight.w600),
              tabs: [
                Tab(
                  icon: Badge(
                    label: Text('${_pendingOrders.length}'),
                    isLabelVisible: _pendingOrders.isNotEmpty,
                    backgroundColor: Colors.white,
                    textColor: primaryOrange,
                    child: const Icon(Icons.schedule_rounded),
                  ),
                  text: 'Pendientes',
                ),
                Tab(
                  icon: Badge(
                    label: Text('${_preparingOrders.length}'),
                    isLabelVisible: _preparingOrders.isNotEmpty,
                    backgroundColor: Colors.white,
                    textColor: primaryOrange,
                    child: const Icon(Icons.restaurant_rounded),
                  ),
                  text: 'En Preparación',
                ),
                Tab(
                  icon: Badge(
                    label: Text('${_readyOrders.length}'),
                    isLabelVisible: _readyOrders.isNotEmpty,
                    backgroundColor: Colors.white,
                    textColor: primaryOrange,
                    child: const Icon(Icons.check_circle_rounded),
                  ),
                  text: 'Listos',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrdersList(_pendingOrders, 'PENDIENTE'),
                _buildOrdersList(_preparingOrders, 'EN_PREPARACION'),
                _buildOrdersList(_readyOrders, 'LISTO'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, String status) {
    if (orders.isEmpty) {
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
              child: Icon(Icons.receipt_long_rounded,
                  size: 64, color: primaryOrange),
            ),
            const SizedBox(height: 20),
            Text('No hay pedidos $status',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('Los nuevos pedidos aparecerán aquí',
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
          return _CookOrderCard(
            order: order,
            onAction: () => _handleQuickAction(order),
            primaryOrange: primaryOrange,
            lightOrange: lightOrange,
          );
        },
      ),
    );
  }
}

class _CookOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onAction;
  final Color primaryOrange;
  final Color lightOrange;

  const _CookOrderCard({
    required this.order,
    required this.onAction,
    required this.primaryOrange,
    required this.lightOrange,
  });

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }

  Color _getUrgencyColor(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes > 30) return Colors.red;
    if (diff.inMinutes > 15) return Colors.orange;
    return Colors.grey.shade600;
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

  @override
  Widget build(BuildContext context) {
    final showActionButton = order.orderStatus != 'LISTO';
    final urgencyColor = _getUrgencyColor(order.orderDate);
    final typeColor = _getTypeColor(order.typeOfConsumption);

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
            // Encabezado
            Row(
              children: [
                // Icono de tipo
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getTypeIcon(order.typeOfConsumption),
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
                          // Badge de tipo
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getTypeLabel(order.typeOfConsumption),
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
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 14, color: urgencyColor),
                          const SizedBox(width: 4),
                          Text(_getTimeAgo(order.orderDate),
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: urgencyColor,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showActionButton)
                  ElevatedButton.icon(
                    onPressed: onAction,
                    icon: Icon(
                        order.orderStatus == 'PENDIENTE'
                            ? Icons.play_arrow_rounded
                            : Icons.check_rounded,
                        size: 18),
                    label: Text(order.orderStatus == 'PENDIENTE'
                        ? 'Comenzar'
                        : 'Listo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                  ),
              ],
            ),

            const Divider(height: 20),

            // Información del pedido
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
                          label: order.customer!.fullName,
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (order.deliveryAddress != null)
                        _InfoRow(
                          icon: Icons.location_on_rounded,
                          label: order.deliveryAddress!,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Lista de productos
            if (order.details != null && order.details!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Productos:',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              Column(
                children: order.details!.take(3).map((detail) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${detail.presentationName ?? 'Producto'}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'x${detail.amount}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (order.details!.length > 3) ...[
                const SizedBox(height: 4),
                Text(
                  '+ ${order.details!.length - 3} productos más...',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ],
            ],

            // Notas del cliente
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
  final Color? iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.maxLines = 2,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
