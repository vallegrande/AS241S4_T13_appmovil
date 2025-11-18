// ==========================================
// modal_customer.dart - ACTUALIZADO
// ==========================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:as241s4_t13_appmovil/core/models/customer/customer_model.dart';
import 'package:as241s4_t13_appmovil/core/services/customer/customer_service.dart';

class CustomerSelectionModal extends StatefulWidget {
  final String orderType;

  const CustomerSelectionModal({
    Key? key,
    required this.orderType,
  }) : super(key: key);

  @override
  State<CustomerSelectionModal> createState() => _CustomerSelectionModalState();
}

class _CustomerSelectionModalState extends State<CustomerSelectionModal> {
  final CustomerService _customerService = CustomerService();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color surfaceBg = const Color(0xFFFAFAFC);

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      setState(() => _isLoading = true);
      final customers = await _customerService.getCustomersByState(1);
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredCustomers = query.isEmpty
          ? _customers
          : _customers.where((c) {
              return c.fullName.toLowerCase().contains(_searchQuery) ||
                  c.documentNumber.toLowerCase().contains(_searchQuery) ||
                  c.phone.toLowerCase().contains(_searchQuery);
            }).toList();
    });
  }

  bool _canSelectCustomer(Customer customer) {
    if (widget.orderType == 'DELIVERY') {
      if (customer.idCustomer == 1) return false;
      if (customer.phone.trim().isEmpty) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryOrange, const Color(0xFFFF8C42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_search,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seleccionar Cliente',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.orderType == 'DELIVERY')
                          Text(
                            'Requiere teléfono registrado',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, documento...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: primaryOrange),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterCustomers('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: _filterCustomers,
                ),
              ),
            ),

            // Lista
            Flexible(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryOrange),
                    )
                  : _filteredCustomers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shrinkWrap: true,
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];
                            final canSelect = _canSelectCustomer(customer);
                            return _buildCustomerCard(customer, canSelect);
                          },
                        ),
            ),

            // Footer info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Toca un cliente para seleccionarlo',
                        style: GoogleFonts.inter(
                          color: Colors.blue.shade900,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildCustomerCard(Customer customer, bool canSelect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: canSelect ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              canSelect ? primaryOrange.withOpacity(0.3) : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: canSelect
            ? [
                BoxShadow(
                  color: primaryOrange.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: canSelect ? () => Navigator.pop(context, customer) : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: canSelect
                      ? primaryOrange.withOpacity(0.15)
                      : Colors.grey.shade300,
                  child: Icon(
                    Icons.person,
                    color: canSelect ? primaryOrange : Colors.grey.shade600,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: canSelect ? Colors.black87 : Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.badge,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              customer.documentNumber,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (customer.phone.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              customer.phone,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      if (!canSelect)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '❌ No válido para DELIVERY',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (canSelect)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: primaryOrange,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No se encontraron clientes',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Intenta con otra búsqueda'
                  : 'No hay clientes registrados',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

Future<Customer?> showCustomerSelectionModal(
  BuildContext context, {
  required String orderType,
}) {
  return showDialog<Customer>(
    context: context,
    barrierDismissible: false,
    builder: (context) => CustomerSelectionModal(orderType: orderType),
  );
}
