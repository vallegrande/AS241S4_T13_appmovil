import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:as241s4_t13_appmovil/core/models/order/order_model.dart';
import 'package:as241s4_t13_appmovil/core/services/order/order_service.dart';
import 'package:intl/intl.dart';

class WaiterOrdersView extends StatefulWidget {
  final OrderService orderService;

  const WaiterOrdersView({super.key, required this.orderService});

  @override
  State<WaiterOrdersView> createState() => _WaiterOrdersViewState();
}

class _WaiterOrdersViewState extends State<WaiterOrdersView>
    with AutomaticKeepAliveClientMixin {
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
      final ready = await widget.orderService.getOrdersByStatus('LISTO');
      final delivered =
          await widget.orderService.getOrdersByStatus('ENTREGADO');

      if (mounted) {
        setState(() {
          _readyOrders = ready;
          _deliveredOrders = delivered;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: primaryOrange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Funciones auxiliares para tipos de pedido
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

            // Información del pedido
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

            // Lista de productos en el diálogo
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
                            color: primaryOrange,
                            shape: BoxShape.circle,
                          ),
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
                            color: primaryOrange,
                          ),
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
                    fontStyle: FontStyle.normal,
                  ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Text('Pedido #${order.idOrder} entregado exitosamente',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ],
              ),
              backgroundColor: primaryOrange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }

        await _loadOrders();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: $e'), backgroundColor: primaryOrange),
          );
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
      length: 2,
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
                    label: Text('${_readyOrders.length}'),
                    isLabelVisible: _readyOrders.isNotEmpty,
                    backgroundColor: Colors.white,
                    textColor: primaryOrange,
                    child: const Icon(Icons.restaurant_menu_rounded),
                  ),
                  text: 'Listos',
                ),
                Tab(
                  icon: Badge(
                    label: Text('${_deliveredOrders.length}'),
                    isLabelVisible: _deliveredOrders.isNotEmpty,
                    backgroundColor: Colors.white,
                    textColor: primaryOrange,
                    child: const Icon(Icons.check_circle_rounded),
                  ),
                  text: 'Entregados',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrdersList(_readyOrders, true),
                _buildOrdersList(_deliveredOrders, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, bool showDeliverButton) {
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
              child: Icon(
                  showDeliverButton
                      ? Icons.restaurant_menu_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 64,
                  color: primaryOrange),
            ),
            const SizedBox(height: 20),
            Text(
                showDeliverButton
                    ? 'No hay pedidos listos'
                    : 'No hay pedidos entregados',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
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
            onDeliver: showDeliverButton ? () => _deliverOrder(order) : null,
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

class _WaiterOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onDeliver;
  final Color primaryOrange;
  final Color lightOrange;
  final String Function(String) getTypeLabel;
  final IconData Function(String) getTypeIcon;
  final Color Function(String) getTypeColor;

  const _WaiterOrderCard({
    required this.order,
    this.onDeliver,
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

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.orderStatus == 'ENTREGADO';
    final typeColor = getTypeColor(order.typeOfConsumption);

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
                          // Badge de tipo
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
                    color: primaryOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          isDelivered
                              ? Icons.check_circle_rounded
                              : Icons.restaurant_menu_rounded,
                          size: 14,
                          color: primaryOrange),
                      const SizedBox(width: 4),
                      Text(isDelivered ? 'Entregado' : 'Listo',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryOrange)),
                    ],
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
                        const SizedBox(height: 6),
                      ],
                      if (order.numberOfPeople > 1) ...[
                        _InfoRow(
                          icon: Icons.people_rounded,
                          label: '${order.numberOfPeople} personas',
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (order.deliveryAddress != null) ...[
                        _InfoRow(
                          icon: Icons.location_on_rounded,
                          label: order.deliveryAddress!,
                          maxLines: 1,
                        ),
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
                            detail.presentationName ?? 'Producto',
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

            // Botón de entregar
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
          child: Text(label,
              style:
                  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis),
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
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
