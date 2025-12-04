// lib/features/sales/widgets/payment_modal.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:as241s4_t13_appmovil/core/services/sales/sale_service.dart';
import 'package:as241s4_t13_appmovil/core/services/order/order_service.dart';
import 'package:as241s4_t13_appmovil/core/models/sales/sale_model.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';

class PaymentModal extends StatefulWidget {
  final dynamic order;
  final VoidCallback? onPaymentSuccess;

  const PaymentModal({
    super.key,
    required this.order,
    this.onPaymentSuccess,
  });

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color darkText = const Color(0xFF1A1A2E);
  
  String _selectedPaymentType = 'EFECTIVO';
  double _cashReceived = 0.0;
  double _cashChange = 0.0;
  bool _isLoading = false;

  final TextEditingController _cardLast4Controller = TextEditingController();
  final TextEditingController _cardOperationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _transactionController = TextEditingController();
  final TextEditingController _bankOperationController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();

  dynamic get order => widget.order;

  @override
  void initState() {
    super.initState();
    // Asumimos que order.total es double
    _cashReceived = order.total;
    _calculateChange();
  }

  // MÉTODO HELPER MEJORADO PARA EXTRAER NOMBRE DEL CLIENTE
  String _extractCustomerName(dynamic order) {
  try {
    // Prioridad 1: fullName directo del customer
    if (order.customer != null && order.customer.fullName != null) {
      final name = order.customer.fullName.toString().trim();
      if (name.isNotEmpty && name != 'null') return name;
    }
    
    // Prioridad 2: Construir nombre desde firstName y lastName
    if (order.customer != null && order.customer.firstName != null) {
      final firstName = order.customer.firstName.toString().trim();
      final lastName = order.customer.lastName?.toString().trim() ?? '';
      if (firstName.isNotEmpty && firstName != 'null') {
        return '$firstName $lastName'.trim();
      }
    }
    
    // Prioridad 3: Usar customerName si existe en el modelo Order
    if (order.customerName != null) {
      final name = order.customerName.toString().trim();
      if (name.isNotEmpty && name != 'null') return name;
    }
    
    // Último recurso: ID del cliente (NUNCA "Cliente Mostrador")
    final customerId = order.idCustomer ?? order.customer?.idCustomer ?? 'N/A';
    return 'Cliente #$customerId';
    
  } catch (e) {
    final customerId = order.idCustomer?.toString() ?? 'N/A';
    return 'Cliente #$customerId';
  }
}

  @override
  Widget build(BuildContext context) {
    final customerName = _extractCustomerName(order);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Resumen del pedido con nombre REAL del cliente
                  _buildOrderSummary(customerName),
                  const SizedBox(height: 20),
                  // Métodos de pago
                  _buildPaymentMethods(),
                  const SizedBox(height: 20),
                  // Campos de pago dinámicos
                  _buildPaymentFields(),
                ],
              ),
            ),
          ),
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.payment_rounded, color: primaryOrange, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Procesar Pago',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  Text(
                    'Pedido #${order.idOrder}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(String customerName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryOrange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total a Pagar',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'S/ ${order.total.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: primaryOrange,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'ENTREGADO',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Información del pedido con nombre REAL del cliente
          Row(
            children: [
              Icon(Icons.person_rounded, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  customerName, // Usar nombre extraído
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Items del pedido
          if (order.details != null && order.details!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...order.details!.map<Widget>((item) => _buildOrderItem(item)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    String productName = 'Producto #${item.idPresentation}';
    double subtotal = 0.0;

    try {
      // Intentamos obtener el nombre si existe la propiedad presentationName
      // Usamos dynamic para evitar el error NoSuchMethod si no existe
      try {
        if ((item as dynamic).presentationName != null) {
          productName = (item as dynamic).presentationName;
        }
      } catch (_) {}

      // Cálculo seguro del subtotal
      if (item.subtotal != null) {
        subtotal = item.subtotal;
      } else {
        subtotal = (item.amount ?? 0) * (item.unitPrice ?? 0.0);
      }
    } catch (e) {
      // Si todo falla, mantenemos los valores por defecto
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${item.amount}x',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primaryOrange,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              productName,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            'S/ ${subtotal.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final paymentMethods = [
      {'type': 'EFECTIVO', 'icon': Icons.attach_money_rounded},
      {'type': 'TARJETA', 'icon': Icons.credit_card_rounded},
      {'type': 'YAPE', 'icon': Icons.phone_iphone_rounded},
      {'type': 'PLIN', 'icon': Icons.phone_android_rounded},
      {'type': 'TRANSFERENCIA', 'icon': Icons.account_balance_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de Pago',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: paymentMethods.length,
          itemBuilder: (context, index) {
            final method = paymentMethods[index];
            final isSelected = _selectedPaymentType == method['type'];
            final icon = method['icon'] as IconData;
            final type = method['type'] as String;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPaymentType = type;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? primaryOrange.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primaryOrange : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: primaryOrange.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? primaryOrange : Colors.grey.shade600,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? primaryOrange : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentFields() {
    switch (_selectedPaymentType) {
      case 'EFECTIVO':
        return _buildCashFields();
      case 'TARJETA':
        return _buildCardFields();
      case 'YAPE':
      case 'PLIN':
        return _buildDigitalFields();
      case 'TRANSFERENCIA':
        return _buildTransferFields();
      default:
        return const SizedBox();
    }
  }

  Widget _buildCashFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pago en Efectivo',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Monto Recibido *',
            prefixText: 'S/ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          initialValue: _cashReceived.toStringAsFixed(2),
          onChanged: (value) {
            final received = double.tryParse(value) ?? 0.0;
            setState(() {
              _cashReceived = received;
              _calculateChange();
            });
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Vuelto',
            prefixText: 'S/ ',
            filled: true,
            fillColor: Colors.green.shade50,
          ),
          readOnly: true,
          controller: TextEditingController(text: _cashChange.toStringAsFixed(2)),
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildCardFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pago con Tarjeta',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _cardLast4Controller,
          decoration: const InputDecoration(
            labelText: 'Últimos 4 dígitos *',
            hintText: '1234',
          ),
          keyboardType: TextInputType.number,
          maxLength: 4,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _cardOperationController,
          decoration: const InputDecoration(
            labelText: 'Número de Operación *',
            hintText: 'Ej: 123456789',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField(
          items: ['VISA', 'MASTERCARD', 'AMEX']
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          decoration: const InputDecoration(labelText: 'Tipo de Tarjeta'),
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildDigitalFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pago con $_selectedPaymentType',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Número de Teléfono *',
            hintText: '987654321',
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _transactionController,
          decoration: const InputDecoration(
            labelText: 'Código de Transacción *',
            hintText: 'Ej: YAPE123456',
          ),
        ),
      ],
    );
  }

  Widget _buildTransferFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Transferencia Bancaria',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField(
          items: ['BCP', 'BBVA', 'Interbank', 'Scotiabank', 'BanBif']
              .map((bank) => DropdownMenuItem(value: bank, child: Text(bank)))
              .toList(),
          decoration: const InputDecoration(labelText: 'Banco *'),
          onChanged: (value) {
            _bankNameController.text = value ?? '';
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bankOperationController,
          decoration: const InputDecoration(
            labelText: 'Número de Operación *',
            hintText: 'Ej: 123456789',
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _isLoading ? null : _processPayment,
              style: FilledButton.styleFrom(backgroundColor: primaryOrange),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Confirmar Pago'),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateChange() {
    setState(() {
      _cashChange = _cashReceived - order.total;
      if (_cashChange < 0) _cashChange = 0;
    });
  }

  Future<void> _processPayment() async {
    // Validaciones básicas
    if (_selectedPaymentType == 'EFECTIVO' && _cashReceived < order.total) {
      _showError('El monto recibido debe ser mayor o igual al total');
      return;
    }

    if (_selectedPaymentType == 'TARJETA' && 
        (_cardLast4Controller.text.isEmpty || _cardOperationController.text.isEmpty)) {
      _showError('Complete los campos requeridos para tarjeta');
      return;
    }

    if ((_selectedPaymentType == 'YAPE' || _selectedPaymentType == 'PLIN') &&
        (_phoneController.text.isEmpty || _transactionController.text.isEmpty)) {
      _showError('Complete los campos requeridos para pago digital');
      return;
    }

    if (_selectedPaymentType == 'TRANSFERENCIA' && 
        (_bankNameController.text.isEmpty || _bankOperationController.text.isEmpty)) {
      _showError('Complete los campos requeridos para transferencia');
      return;
    }

    setState(() => _isLoading = true);

  try {
    // Crear request para la venta
    final saleRequest = CreateSaleRequest(
      idOrder: order.idOrder,
      idCustomer: order.idCustomer ?? order.customer?.idCustomer,
      idUser: AuthService.userId ?? 1, // Usar el usuario autenticado
      paymentType: _selectedPaymentType,
      cashReceived: _selectedPaymentType == 'EFECTIVO' ? _cashReceived : null,
      cashChange: _selectedPaymentType == 'EFECTIVO' ? _cashChange : null,
      cardLast4: _selectedPaymentType == 'TARJETA' ? _cardLast4Controller.text : null,
      cardOperation: _selectedPaymentType == 'TARJETA' ? _cardOperationController.text : null,
      phonePayment: (_selectedPaymentType == 'YAPE' || _selectedPaymentType == 'PLIN') 
          ? _phoneController.text : null,
      transactionCode: (_selectedPaymentType == 'YAPE' || _selectedPaymentType == 'PLIN') 
          ? _transactionController.text : null,
      bankName: _selectedPaymentType == 'TRANSFERENCIA' ? _bankNameController.text : null,
      bankOperation: _selectedPaymentType == 'TRANSFERENCIA' ? _bankOperationController.text : null,
    );

    print('🔄 Creando venta para pedido #${order.idOrder}');
    print('📋 Datos de la venta:');
    print('   - ID Order: ${order.idOrder}');
    print('   - ID Customer: ${order.idCustomer}');
    print('   - ID User: ${AuthService.userId}');
    print('   - Método de pago: $_selectedPaymentType');
    print('   - Total: ${order.total}');
    
    // Crear la venta
    final sale = await SaleService.createSale(saleRequest);
    
    print('✅ VENTA CREADA EXITOSAMENTE:');
    print('   - ID Venta: #${sale.idSale}');
    print('   - Cliente: ${sale.displayCustomerName}');
    print('   - Total: ${sale.formattedTotal}');
    print('   - Fecha: ${sale.formattedDate}');
    print('   - Estado: ${sale.isActive ? "CERRADA" : "ANULADA"}');
    print('   - ID Order asociado: ${sale.idOrder}');

    // Cerrar el pedido cambiando su estado a "CERRADO"
    try {
      await OrderService().updateOrderStatus(order.idOrder, 'CERRADO');
      print('✅ Pedido #${order.idOrder} cerrado exitosamente');
    } catch (e) {
      print('⚠️ Venta creada pero error al cerrar pedido: $e');
      // Continuamos aunque falle el cierre del pedido para no bloquear al usuario
    }

    if (mounted) {
  setState(() => _isLoading = false);
  
  // Mostrar mensaje de éxito
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('✅ Venta #${sale.idSale} creada exitosamente'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );
  
  // Cerrar el modal inmediatamente
  Navigator.pop(context);
  
  // Llamar al callback para refrescar las ventas
  widget.onPaymentSuccess?.call();
}

  } catch (e) {
    print('❌ ERROR DETALLADO al crear venta:');
    print('   Tipo de error: ${e.runtimeType}');
    print('   Mensaje: $e');
    print('   Stack trace: ${e.toString()}');
    
    if (mounted) {
      setState(() => _isLoading = false);
      _showError('Error al procesar pago: ${e.toString()}');
    }
  }
}

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _cardLast4Controller.dispose();
    _cardOperationController.dispose();
    _phoneController.dispose();
    _transactionController.dispose();
    _bankOperationController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }
}