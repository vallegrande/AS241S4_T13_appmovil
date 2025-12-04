// lib/features/sales/widgets/sale_detail_modal.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:as241s4_t13_appmovil/core/models/sales/sale_model.dart';
import 'package:as241s4_t13_appmovil/core/services/sales/sale_service.dart';

class SaleDetailModal extends StatefulWidget {
  final Sale sale;

  const SaleDetailModal({super.key, required this.sale});

  @override
  State<SaleDetailModal> createState() => _SaleDetailModalState();
}

class _SaleDetailModalState extends State<SaleDetailModal> {
  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color darkText = const Color(0xFF1A1A2E);
  bool _isLoading = false;

  // Usar los datos reales de la venta
  Sale get sale => widget.sale;

  // MÉTODO HELPER PARA EXTRAER NOMBRE DEL CLIENTE EN VENTA
  String _extractCustomerName(Sale sale) {
    try {
      // Prioridad 1: customerName de Sale
      if (sale.customerName != null) {
        final name = sale.customerName.toString().trim();
        if (name.isNotEmpty && name != 'null') return name;
      }
      
      // Último recurso: ID del cliente
      final customerId = sale.idCustomer ?? '?';
      return 'Cliente #$customerId';
      
    } catch (e) {
      final customerId = sale.idCustomer?.toString() ?? '?';
      return 'Cliente #$customerId';
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerName = _extractCustomerName(sale);
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(),
          // Body con scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Información de la venta con nombre REAL del cliente
                  _buildSaleInfo(),
                  const SizedBox(height: 20),
                  // Detalles del pago
                  _buildPaymentDetails(),
                  const SizedBox(height: 20),
                  // Items
                  _buildItemsList(),
                  const SizedBox(height: 20),
                  // Comprobante
                  _buildProofSection(),
                ],
              ),
            ),
          ),
          // Footer con acciones
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
              Icon(Icons.receipt_long_rounded, color: primaryOrange, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Venta #${sale.idSale}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(sale.isActive ? 'CERRADA' : 'ANULADA'),
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

  Widget _buildSaleInfo() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                Icons.calendar_today_rounded,
                'Fecha',
                sale.formattedDate,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                Icons.person_rounded,
                'Cliente',
                sale.customerName ?? 'Cliente #${sale.idCustomer}', // ← NOMBRE REAL
              ),
            ),
          ],
        ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  _getPaymentIcon(sale.paymentType),
                  'Método de Pago',
                  sale.paymentType,
                  isPayment: true,
                ),
              ),
              if (sale.idOrder != null) ...[
                Expanded(
                  child: _buildInfoItem(
                    Icons.shopping_bag_rounded,
                    'Pedido',
                    '#${sale.idOrder}',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment_rounded, color: primaryOrange, size: 18),
              const SizedBox(width: 8),
              Text(
                'Detalles del Pago',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sale.paymentType == 'EFECTIVO') ...[
            _buildPaymentDetailItem('Recibido', 'S/ ${sale.cashReceived?.toStringAsFixed(2) ?? "0.00"}'),
            _buildPaymentDetailItem('Vuelto', 'S/ ${sale.cashChange?.toStringAsFixed(2) ?? "0.00"}', isChange: true),
          ],
          if (sale.paymentType == 'TARJETA') ...[
            if (sale.cardLast4 != null) _buildPaymentDetailItem('Últimos 4 dígitos', '**** ${sale.cardLast4}'),
            if (sale.cardOperation != null) _buildPaymentDetailItem('Nº Operación', sale.cardOperation!),
            if (sale.cardType != null) _buildPaymentDetailItem('Tipo de Tarjeta', sale.cardType!),
            if (sale.posReference != null) _buildPaymentDetailItem('Ref. POS', sale.posReference!),
          ],
          if (sale.paymentType == 'YAPE' || sale.paymentType == 'PLIN') ...[
            if (sale.phonePayment != null) _buildPaymentDetailItem('Teléfono', sale.phonePayment!),
            if (sale.transactionCode != null) _buildPaymentDetailItem('Código Transacción', sale.transactionCode!),
          ],
          if (sale.paymentType == 'TRANSFERENCIA') ...[
            if (sale.bankName != null) _buildPaymentDetailItem('Banco', sale.bankName!),
            if (sale.bankOperation != null) _buildPaymentDetailItem('Nº Operación', sale.bankOperation!),
            if (sale.bankAccount != null) _buildPaymentDetailItem('Cuenta', sale.bankAccount!),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    final items = sale.details ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt_rounded, color: primaryOrange, size: 18),
              const SizedBox(width: 8),
              Text(
                'Productos (${items.length})',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(_buildItemRow).toList(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryOrange, const Color(0xFFFF8C42)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  sale.formattedTotal,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_rounded, color: primaryOrange, size: 18),
              const SizedBox(width: 8),
              Text(
                'Comprobante de Pago',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Estado del comprobante
          sale.isActive
              ? _buildProofUpload()
              : _buildNoProofMessage(),
        ],
      ),
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
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cerrar'),
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (sale.isActive) ...[
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.cancel_rounded),
                label: Text(_isLoading ? 'Procesando...' : 'Anular'),
                onPressed: _isLoading ? null : _annulSale,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Métodos auxiliares
  Widget _buildStatusBadge(String status) {
    final bool isActive = status == 'CERRADA';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {bool isPayment = false}) {
    return Row(
      children: [
        Icon(icon, color: primaryOrange, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isPayment ? primaryOrange : darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetailItem(String label, String value, {bool isChange = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isChange ? Colors.green : darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(SaleDetail item) {
  // Verificar si el nombre es genérico
  final isGenericName = item.presentationName.startsWith('Producto #');
  
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryOrange, const Color(0xFFFF8C42)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${item.amount}x',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.presentationName,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isGenericName ? Colors.orange.shade700 : darkText,
                  fontStyle: isGenericName ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              if (isGenericName)
                Text(
                  'ID de presentación: ${item.idPresentation}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'S/ ${item.unitPrice.toStringAsFixed(2)} c/u',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'S/ ${item.subtotal.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
  Widget _buildProofUpload() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Column(
            children: [
              Icon(Icons.add_photo_alternate_rounded, size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'Subir comprobante',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Formatos: JPG, PNG (Máx. 5MB)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoProofMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'No se puede subir comprobante en ventas anuladas',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  IconData _getPaymentIcon(String paymentType) {
    switch (paymentType) {
      case 'EFECTIVO': return Icons.attach_money_rounded;
      case 'TARJETA': return Icons.credit_card_rounded;
      case 'YAPE': return Icons.phone_iphone_rounded;
      case 'PLIN': return Icons.phone_android_rounded;
      case 'TRANSFERENCIA': return Icons.account_balance_rounded;
      default: return Icons.payment_rounded;
    }
  }

  void _annulSale() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Anular Venta?'),
        content: const Text(
          'Esta acción revertirá la venta y cambiará su estado a ANULADA. ¿Estás seguro de continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              _processAnular(); // Ejecutar anulación
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Anular'),
          ),
        ],
      ),
    );
  }

  Future<void> _processAnular() async {
    // Si la pantalla ya no está activa, no hacemos nada
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Llamamos al servicio para anular (0 = Anulado, estado inactivo)
      await SaleService.updateSaleState(sale.idSale, 0);

      // Verificamos si seguimos montados antes de usar el contexto
      if (mounted) {
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Venta anulada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Cerramos el modal y devolvemos true para indicar que la tabla debe recargarse
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al anular: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}