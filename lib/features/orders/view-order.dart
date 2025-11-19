import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:as241s4_t13_appmovil/core/models/order/order_model.dart';
import 'package:as241s4_t13_appmovil/core/services/order/order_service.dart';
import 'package:intl/intl.dart';

class AllOrdersView extends StatefulWidget {
  final OrderService orderService;

  const AllOrdersView({super.key, required this.orderService});

  @override
  State<AllOrdersView> createState() => _AllOrdersViewState();
}

class _AllOrdersViewState extends State<AllOrdersView>
    with AutomaticKeepAliveClientMixin {
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String _selectedStatus = 'TODOS';
  String _selectedType = 'TODOS';
  String _searchQuery = '';

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);
  final Color surfaceBg = const Color(0xFFFAFAFC);

  final List<String> _statusList = [
    'TODOS',
    'PENDIENTE',
    'EN_PREPARACION',
    'LISTO',
    'ENTREGADO',
    'CERRADO',
    'CANCELADO'
  ];

  final List<String> _typeList = ['TODOS', 'LOCAL', 'TAKEOUT', 'DELIVERY'];

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
      final orders = await widget.orderService.getAllOrders();
      if (mounted) {
        setState(() {
          _allOrders = orders;
          _filterOrders();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: primaryOrange),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _allOrders.where((order) {
        final matchesStatus =
            _selectedStatus == 'TODOS' || order.orderStatus == _selectedStatus;
        final matchesType = _selectedType == 'TODOS' ||
            order.typeOfConsumption == _selectedType;
        final matchesSearch = _searchQuery.isEmpty ||
            order.idOrder.toString().contains(_searchQuery) ||
            (order.customer?.fullName ?? '')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            _getTypeLabel(order.typeOfConsumption)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            _containsProductName(order, _searchQuery.toLowerCase());
        return matchesStatus && matchesType && matchesSearch;
      }).toList();
      _filteredOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    });
  }

  bool _containsProductName(Order order, String query) {
    if (query.isEmpty) return true;
    if (order.details == null) return false;

    for (final detail in order.details!) {
      if (detail.presentationName?.toLowerCase().contains(query) == true) {
        return true;
      }
    }
    return false;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDIENTE':
        return Colors.orange;
      case 'EN_PREPARACION':
        return Colors.blue;
      case 'LISTO':
        return Colors.green;
      case 'ENTREGADO':
        return Colors.purple;
      case 'CERRADO':
        return Colors.grey;
      case 'CANCELADO':
        return Colors.red;
      default:
        return primaryOrange;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDIENTE':
        return 'Pendiente';
      case 'EN_PREPARACION':
        return 'En Preparación';
      case 'LISTO':
        return 'Listo';
      case 'ENTREGADO':
        return 'Entregado';
      case 'CERRADO':
        return 'Cerrado';
      case 'CANCELADO':
        return 'Cancelado';
      case 'TODOS':
        return 'Todos los estados';
      default:
        return status;
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
      case 'TODOS':
        return 'Todos los tipos';
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
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        // Filtros y búsqueda
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
            boxShadow: [
              BoxShadow(
                color: primaryOrange.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            children: [
              // Barra de búsqueda
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por ID, cliente, producto...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search_rounded, color: primaryOrange),
                  filled: true,
                  fillColor: surfaceBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: GoogleFonts.inter(fontSize: 14),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filterOrders();
                  });
                },
              ),
              const SizedBox(height: 12),

              // Filtros con Dropdown
              Row(
                children: [
                  // Dropdown para Estado
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: surfaceBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down_rounded,
                              color: primaryOrange),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                          items: _statusList.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Row(
                                children: [
                                  if (status != 'TODOS') ...[
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(_getStatusLabel(status)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedStatus = newValue;
                                _filterOrders();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Dropdown para Tipo
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: surfaceBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down_rounded,
                              color: primaryOrange),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                          items: _typeList.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Row(
                                children: [
                                  if (type != 'TODOS') ...[
                                    Icon(
                                      _getTypeIcon(type),
                                      size: 16,
                                      color: _getTypeColor(type),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(_getTypeLabel(type)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedType = newValue;
                                _filterOrders();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de pedidos
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryOrange))
              : _filteredOrders.isEmpty
                  ? Center(
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
                          Text(
                              _searchQuery.isEmpty
                                  ? 'No hay pedidos'
                                  : 'No se encontraron pedidos',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600)),
                          const SizedBox(height: 8),
                          Text('Intenta con otros filtros de búsqueda',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      color: primaryOrange,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];
                          return _OrderCard(
                            order: order,
                            getStatusColor: _getStatusColor,
                            getStatusLabel: _getStatusLabel,
                            getTypeLabel: _getTypeLabel,
                            getTypeColor: _getTypeColor,
                            primaryOrange: primaryOrange,
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final Color Function(String) getStatusColor;
  final String Function(String) getStatusLabel;
  final String Function(String) getTypeLabel;
  final Color Function(String) getTypeColor;
  final Color primaryOrange;

  const _OrderCard({
    required this.order,
    required this.getStatusColor,
    required this.getStatusLabel,
    required this.getTypeLabel,
    required this.getTypeColor,
    required this.primaryOrange,
  });

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
    final statusColor = getStatusColor(order.orderStatus);
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
                  child: Icon(_getTypeIcon(order.typeOfConsumption),
                      color: typeColor, size: 24),
                ),
                const SizedBox(width: 12),

                // Info principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Pedido #${order.idOrder}',
                              style: GoogleFonts.poppins(
                                  fontSize: 17, fontWeight: FontWeight.w700)),
                          if (order.confirmed) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryOrange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Confirmado',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(order.orderDate),
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),

                // Estado
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(getStatusLabel(order.orderStatus),
                      style: GoogleFonts.poppins(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
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
                      // Tipo de pedido
                      _InfoRow(
                        icon: _getTypeIcon(order.typeOfConsumption),
                        label: '${getTypeLabel(order.typeOfConsumption)}',
                        iconColor: typeColor,
                      ),
                      const SizedBox(height: 6),

                      if (order.customer != null) ...[
                        _InfoRow(
                          icon: Icons.person_rounded,
                          label: order.customer!.fullName,
                        ),
                        const SizedBox(height: 4),
                      ],

                      if (order.idTable != null)
                        _InfoRow(
                          icon: Icons.table_restaurant_rounded,
                          label: 'Mesa ${order.idTable}',
                        ),

                      if (order.deliveryAddress != null)
                        _InfoRow(
                          icon: Icons.location_on_rounded,
                          label: order.deliveryAddress!,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),

                // Total y items
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
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${order.amount} items',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),

            // Lista de productos
            if (order.details != null && order.details!.isNotEmpty) ...[
              const Divider(height: 20),
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
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
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
