import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:as241s4_t13_appmovil/core/models/order/order_model.dart';
import 'package:as241s4_t13_appmovil/core/models/order/orderDetail_model.dart';
import 'package:as241s4_t13_appmovil/core/models/customer/customer_model.dart'
    as customer_model;
import 'package:as241s4_t13_appmovil/core/models/dishes/presentation.dart';
import 'package:as241s4_t13_appmovil/core/models/table/table_model.dart';
import 'package:as241s4_t13_appmovil/core/services/order/order_service.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';
import 'package:as241s4_t13_appmovil/core/services/order/orderDetail_service.dart';
import 'package:intl/intl.dart';
import 'modal_customer.dart';
import 'modal_presentations.dart';
import 'modal_tables.dart';
import 'view-order-cook.dart';
import 'view-order-waiter.dart';
import 'view-order.dart';

class OrderPanel extends StatefulWidget {
  const OrderPanel({super.key});

  @override
  State<OrderPanel> createState() => _OrderPanelState();
}

class _OrderPanelState extends State<OrderPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();
  final OrderDetailService _orderDetailService = OrderDetailService();
  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);
  final Color accentOrange = const Color(0xFFFFA556);
  final Color surfaceBg = const Color(0xFFFAFAFC);

  String _orderType = 'LOCAL';
  customer_model.Customer? _selectedCustomer;
  TableModel? _selectedTable;
  int _numberOfPeople = 1;
  String _deliveryAddress = '';
  String _customerNotes = '';
  final List<OrderDetailItem> _orderDetails = [];
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final userId = AuthService.userId;
    setState(() => _isAuthenticated = userId != null && userId > 0);

    if (!_isAuthenticated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚠️ No se pudo obtener el ID de usuario'),
          backgroundColor: primaryOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  double get _totalAmount =>
      _orderDetails.fold(0.0, (sum, item) => sum + item.subtotal);

  int get _totalItems =>
      _orderDetails.fold(0, (sum, item) => sum + item.quantity);

  bool _canSubmitOrder() {
    if (!_isAuthenticated || _orderDetails.isEmpty) return false;

    switch (_orderType) {
      case 'DELIVERY':
        return _selectedCustomer != null &&
            _selectedCustomer!.idCustomer != null &&
            _selectedCustomer!.idCustomer != 1 &&
            _deliveryAddress.trim().isNotEmpty &&
            _selectedCustomer!.phone.trim().isNotEmpty;
      case 'LOCAL':
        return _selectedTable != null;
      case 'TAKEOUT':
        return true;
      default:
        return false;
    }
  }

  String? _getValidationMessage() {
    if (!_isAuthenticated) return 'Usuario no autenticado';
    if (_orderDetails.isEmpty) return 'Agrega al menos un producto';

    switch (_orderType) {
      case 'DELIVERY':
        if (_selectedCustomer == null || _selectedCustomer!.idCustomer == 1)
          return 'Selecciona un cliente registrado';
        if (_deliveryAddress.trim().isEmpty) return 'Ingresa dirección';
        if (_selectedCustomer!.phone.trim().isEmpty)
          return 'Cliente sin teléfono';
        break;
      case 'LOCAL':
        if (_selectedTable == null) return 'Selecciona una mesa';
        final available =
            _selectedTable!.capacity - _selectedTable!.currentOccupancy;
        if (available < _numberOfPeople)
          return 'Capacidad insuficiente en mesa';
        break;
    }
    return null;
  }

  Future<void> _addPresentation() async {
    final presentation = await showPresentationSelectionModal(
      context,
      orderType: _orderType,
    );

    if (presentation != null) {
      double price = presentation.price;
      switch (_orderType.toUpperCase()) {
        case 'DELIVERY':
          price = presentation.deliveryPrice ?? presentation.price;
          break;
        case 'TAKEOUT':
          price = presentation.takeoutPrice ?? presentation.price;
          break;
      }

      final existingIndex = _orderDetails.indexWhere(
        (item) =>
            item.presentation.idPresentation == presentation.idPresentation,
      );

      setState(() {
        if (existingIndex != -1) {
          _orderDetails[existingIndex].quantity++;
        } else {
          _orderDetails.add(OrderDetailItem(
            presentation: presentation,
            quantity: 1,
            unitPrice: price,
          ));
        }
      });
    }
  }

  Future<void> _selectCustomer() async {
    final customer = await showCustomerSelectionModal(
      context,
      orderType: _orderType,
    );

    if (customer != null) {
      setState(() {
        _selectedCustomer = customer;
        if (_orderType == 'DELIVERY' &&
            customer.address != null &&
            customer.address!.trim().isNotEmpty) {
          _deliveryAddress = customer.address!;
          _addressController.text = customer.address!;
        }
      });
    }
  }

  Future<void> _selectTable() async {
    if (_numberOfPeople <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ingresa el número de personas primero'),
          backgroundColor: primaryOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final table = await showTableSelectionModal(
      context,
      numberOfPeople: _numberOfPeople,
    );

    if (table != null) setState(() => _selectedTable = table);
  }

  Future<void> _submitOrder() async {
    final validationMsg = _getValidationMessage();
    if (validationMsg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationMsg),
          backgroundColor: primaryOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = AuthService.userId;
      if (userId == null || userId <= 0) {
        throw Exception('Usuario no autenticado');
      }

      final details = _orderDetails.map((item) {
        return OrderDetail(
          idPresentation: item.presentation.idPresentation!,
          amount: item.quantity,
          unitPrice: item.unitPrice,
          presentationName: item.presentation.name,
        );
      }).toList();

      int customerId;
      if (_orderType == 'DELIVERY') {
        customerId = _selectedCustomer!.idCustomer!;
      } else {
        customerId = _selectedCustomer?.idCustomer ?? 1;
      }

      bool confirmed = false;
      if (_orderType == 'LOCAL' && _selectedTable != null) {
        confirmed = _selectedTable!.currentOccupancy > 0;
      }

      final order = Order(
        idUser: userId,
        idCustomer: customerId,
        orderDate: DateTime.now(),
        orderStatus: 'PENDIENTE',
        typeOfConsumption: _orderType,
        idTable: _orderType == 'LOCAL' ? _selectedTable?.idTable : null,
        total: _totalAmount,
        amount: _totalItems,
        deliveryAddress:
            _orderType == 'DELIVERY' && _deliveryAddress.trim().isNotEmpty
                ? _deliveryAddress.trim()
                : null,
        customerNotes:
            _customerNotes.trim().isNotEmpty ? _customerNotes.trim() : null,
        numberOfPeople: _orderType == 'LOCAL' ? _numberOfPeople : 1,
        confirmed: confirmed,
        details: details,
      );

      final createdOrder = await _orderService.createOrder(order);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pedido #${createdOrder.idOrder} creado exitosamente',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: primaryOrange,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMsg)),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    setState(() {
      _selectedCustomer = null;
      _selectedTable = null;
      _numberOfPeople = 1;
      _deliveryAddress = '';
      _customerNotes = '';
      _orderDetails.clear();
      _addressController.clear();
      _notesController.clear();
    });
  }

  void _recalculatePrices() {
    for (var item in _orderDetails) {
      double newPrice = item.presentation.price;
      switch (_orderType.toUpperCase()) {
        case 'DELIVERY':
          newPrice = item.presentation.deliveryPrice ?? item.presentation.price;
          break;
        case 'TAKEOUT':
          newPrice = item.presentation.takeoutPrice ?? item.presentation.price;
          break;
      }
      item.unitPrice = newPrice;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: surfaceBg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.warning_amber_rounded,
                      size: 80, color: primaryOrange),
                ),
                const SizedBox(height: 24),
                Text('Usuario no autenticado',
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                    'Por favor, vuelve a iniciar sesión para gestionar pedidos.',
                    style: GoogleFonts.inter(
                        fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text('Reintentar',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _loadCurrentUser,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: surfaceBg,
      body: Column(
        children: [
          // Header personalizado con tabs
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryOrange, lightOrange, accentOrange],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryOrange.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Título
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Gestión de Pedidos',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tabs
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(
                          icon: Icon(Icons.add_circle, size: 22),
                          text: 'Crear'),
                      Tab(
                          icon: Icon(Icons.restaurant, size: 22),
                          text: 'Cocina'),
                      Tab(
                          icon: Icon(Icons.room_service, size: 22),
                          text: 'Mesero'),
                      Tab(icon: Icon(Icons.list_alt, size: 22), text: 'Todos'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Contenido de tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCreateOrderTab(),
                CookOrdersView(orderService: _orderService),
                WaiterOrdersView(
                  orderService: _orderService,
                  orderDetailService: _orderDetailService,
                ),
                AllOrdersView(orderService: _orderService),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateOrderTab() {
    return _isSubmitting
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(strokeWidth: 3, color: primaryOrange),
                const SizedBox(height: 16),
                Text('Creando pedido...',
                    style: GoogleFonts.poppins(fontSize: 16)),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildOrderTypeSection(),
                      const SizedBox(height: 16),
                      if (_orderType == 'LOCAL') ...[
                        _buildTableSection(),
                        const SizedBox(height: 16),
                      ],
                      _buildCustomerSection(),
                      const SizedBox(height: 16),
                      if (_orderType == 'DELIVERY') ...[
                        _buildAddressSection(),
                        const SizedBox(height: 16),
                      ],
                      _buildNotesSection(),
                      const SizedBox(height: 16),
                      _buildCartSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          );
  }

  Widget _buildOrderTypeSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: primaryOrange.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.fastfood_rounded,
                    color: primaryOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Text('Tipo de Consumo',
                  style: GoogleFonts.poppins(
                      fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildOrderTypeChip(
                      'LOCAL', Icons.restaurant, primaryOrange)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildOrderTypeChip(
                      'DELIVERY', Icons.delivery_dining, lightOrange)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildOrderTypeChip(
                      'TAKEOUT', Icons.shopping_bag, accentOrange)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildOrderTypeChip(String type, IconData icon, Color color) {
    final isSelected = _orderType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _orderType = type;
          if (type != 'LOCAL') _selectedTable = null;
          if (type != 'DELIVERY') {
            _deliveryAddress = '';
            _addressController.clear();
          }
          _recalculatePrices();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? color : Colors.grey.shade300, width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: isSelected ? Colors.white : color),
            const SizedBox(height: 6),
            Text(type,
                style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    final isDelivery = _orderType == 'DELIVERY';
    final isInvalid = isDelivery &&
        (_selectedCustomer == null || _selectedCustomer!.idCustomer == 1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isInvalid ? primaryOrange : primaryOrange.withOpacity(0.15),
            width: isInvalid ? 2 : 1),
        boxShadow: [
          BoxShadow(
              color: primaryOrange.withOpacity(isInvalid ? 0.15 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _selectCustomer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryOrange.withOpacity(0.1),
                            lightOrange.withOpacity(0.1)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person_rounded,
                          color: primaryOrange, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cliente',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(
                              _selectedCustomer?.fullName ??
                                  'Cliente Mostrador',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedCustomer != null
                                      ? Colors.black87
                                      : Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 18, color: primaryOrange),
                  ],
                ),
                if (isInvalid) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primaryOrange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: primaryOrange, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('DELIVERY requiere cliente registrado',
                              style: GoogleFonts.inter(
                                  color: primaryOrange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildTableSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryOrange.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: primaryOrange.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.table_restaurant_rounded,
                    color: primaryOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Text('Mesa',
                  style: GoogleFonts.poppins(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Text('*',
                  style: TextStyle(
                      color: primaryOrange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Personas:',
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_rounded,
                          color: _numberOfPeople > 1
                              ? primaryOrange
                              : Colors.grey),
                      onPressed: _numberOfPeople > 1
                          ? () => setState(() => _numberOfPeople--)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryOrange.withOpacity(0.15),
                            lightOrange.withOpacity(0.15)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$_numberOfPeople',
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: primaryOrange)),
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.add_circle_rounded, color: primaryOrange),
                      onPressed: () => setState(() => _numberOfPeople++),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_selectedTable != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryOrange.withOpacity(0.1),
                    lightOrange.withOpacity(0.1)
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: primaryOrange.withOpacity(0.3), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.table_restaurant_rounded,
                            color: primaryOrange, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedTable!.name,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(
                                'Capacidad: ${_selectedTable!.capacity} | Disponible: ${_selectedTable!.capacity - _selectedTable!.currentOccupancy}',
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: Colors.grey.shade700)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            size: 22, color: Colors.grey.shade600),
                        onPressed: () => setState(() => _selectedTable = null),
                      ),
                    ],
                  ),
                  if (_selectedTable!.currentOccupancy > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: lightOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: lightOrange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: lightOrange, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                                'Mesa ocupada (${_selectedTable!.currentOccupancy}/${_selectedTable!.capacity}) - Se compartirá',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: lightOrange,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.table_restaurant_rounded, size: 20),
                label: Text('Seleccionar Mesa',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _selectTable,
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildAddressSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryOrange.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: primaryOrange.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.location_on_rounded,
                    color: primaryOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Text('Dirección de Entrega',
                  style: GoogleFonts.poppins(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Text('*',
                  style: TextStyle(
                      color: primaryOrange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _addressController,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Ingresa la dirección completa...',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.edit_location_alt_rounded,
                    color: primaryOrange, size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 2,
              onChanged: (value) => setState(() => _deliveryAddress = value),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildNotesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.note_rounded,
                    color: Colors.grey.shade600, size: 22),
              ),
              const SizedBox(width: 12),
              Text('Notas Adicionales',
                  style: GoogleFonts.poppins(
                      fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _notesController,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Observaciones, alergias, preferencias...',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.edit_note_rounded,
                    color: Colors.grey.shade600, size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
              onChanged: (value) => setState(() => _customerNotes = value),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 250.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildCartSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryOrange.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: primaryOrange.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.shopping_cart_rounded,
                        color: primaryOrange, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text('Productos',
                      style: GoogleFonts.poppins(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  if (_orderDetails.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryOrange.withOpacity(0.15),
                            lightOrange.withOpacity(0.15)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${_orderDetails.length}',
                          style: GoogleFonts.poppins(
                              color: primaryOrange,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Agregar',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                onPressed: _addPresentation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_orderDetails.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: surfaceBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 56, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Carrito vacío',
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('Toca "Agregar" para añadir productos',
                        style: GoogleFonts.inter(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            ..._orderDetails.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildCartItem(item, index);
            }),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildCartItem(OrderDetailItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Controles de cantidad
            Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => item.quantity++),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.add_circle_rounded,
                          color: primaryOrange, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryOrange.withOpacity(0.15),
                        lightOrange.withOpacity(0.15)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryOrange.withOpacity(0.3)),
                  ),
                  child: Text('${item.quantity}',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryOrange)),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      if (item.quantity > 1) {
                        setState(() => item.quantity--);
                      } else {
                        _confirmRemoveItem(index, item.presentation.name);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                          item.quantity > 1
                              ? Icons.remove_circle_rounded
                              : Icons.delete_rounded,
                          color: item.quantity > 1
                              ? primaryOrange
                              : Colors.red.shade400,
                          size: 28),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.presentation.name,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('S/ ${item.unitPrice.toStringAsFixed(2)} c/u',
                        style: GoogleFonts.inter(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Subtotal
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Subtotal',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('S/ ${item.subtotal.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: primaryOrange)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveItem(int index, String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_rounded, color: Colors.red.shade400, size: 24),
            const SizedBox(width: 12),
            Text('Eliminar producto',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text('¿Deseas eliminar "$itemName" del carrito?',
            style: GoogleFonts.inter(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _orderDetails.removeAt(index));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text('Eliminar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canSubmit = _canSubmitOrder();
    final validationMsg = _getValidationMessage();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: primaryOrange.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Resumen
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryOrange.withOpacity(0.1),
                          lightOrange.withOpacity(0.1)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: primaryOrange.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Text('Total Items',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('$_totalItems',
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: primaryOrange)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryOrange, lightOrange],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: primaryOrange.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text('TOTAL A PAGAR',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text('S/ ${_totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!canSubmit && validationMsg != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: lightOrange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: lightOrange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(validationMsg,
                          style: GoogleFonts.inter(
                              color: lightOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: canSubmit ? _submitOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canSubmit ? primaryOrange : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: canSubmit ? 6 : 0,
                  shadowColor:
                      canSubmit ? primaryOrange.withOpacity(0.5) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 26),
                    const SizedBox(width: 12),
                    Text('CREAR PEDIDO',
                        style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailItem {
  final Presentation presentation;
  int quantity;
  double unitPrice;

  OrderDetailItem({
    required this.presentation,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;
}
