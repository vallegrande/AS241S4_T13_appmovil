// lib/features/customers/panel_customer.dart
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:as241s4_t13_appmovil/core/models/customer/customer_model.dart';
import 'package:as241s4_t13_appmovil/core/services/customer/customer_service.dart';
import 'package:as241s4_t13_appmovil/features/customers/customer_form.dart';

class PanelCustomerScreen extends StatefulWidget {
  const PanelCustomerScreen({super.key});

  @override
  State<PanelCustomerScreen> createState() => _PanelCustomerScreenState();
}

class _PanelCustomerScreenState extends State<PanelCustomerScreen>
    with TickerProviderStateMixin {
  final CustomerService _customerService = CustomerService();

  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  bool _isLoading = true;
  String? _error;

  String? _filterState;
  String? _filterType;
  final _searchController = TextEditingController();

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color lightOrange = const Color(0xFFFF8C42);
  final Color surfaceBg = const Color(0xFFFAFAFC);
  final Color cardBg = Colors.white;

  late AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fetchCustomers();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final fetchedCustomers = await _customerService.getAllCustomers();
      if (mounted) {
        customers = fetchedCustomers;
        _applyFilters();
        _fabAnimController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al obtener clientes: $e';
          filteredCustomers = [];
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      filteredCustomers = customers.where((customer) {
        if (_filterState != null && _filterState != 'Todos') {
          final wantsActive = _filterState == 'Activos';
          if (customer.isActive != wantsActive) return false;
        }

        if (_filterType != null && _filterType != 'Todos') {
          if (customer.customerType != _filterType) return false;
        }

        if (query.isNotEmpty) {
          return customer.firstName.toLowerCase().contains(query) ||
              customer.lastName.toLowerCase().contains(query) ||
              customer.documentNumber.toLowerCase().contains(query) ||
              (customer.email?.toLowerCase().contains(query) ?? false);
        }
        return true;
      }).toList();
    });
  }

  void _goToForm({Customer? customer}) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CustomerForm(customer: customer),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
    if (result == true) _fetchCustomers();
  }

  Future<void> _deleteCustomer(int customerId) async {
    final confirm = await _showConfirmDialog(
      'Desactivar cliente',
      '¿Seguro que deseas desactivar este cliente?',
      Icons.person_off_rounded,
      Colors.orange.shade700,
    );
    if (confirm == true) {
      try {
        await _customerService.deleteCustomer(customerId);
        _fetchCustomers();
        _showSnackBar('Cliente desactivado exitosamente', primaryOrange,
            Icons.check_circle_rounded);
      } catch (e) {
        _showSnackBar('Error al desactivar: $e', Colors.red.shade600,
            Icons.error_rounded);
      }
    }
  }

  Future<void> _restoreCustomer(int customerId) async {
    final confirm = await _showConfirmDialog(
      'Reactivar cliente',
      '¿Deseas reactivar este cliente?',
      Icons.check_circle_rounded,
      Colors.green.shade600,
    );
    if (confirm == true) {
      try {
        await _customerService.restoreCustomer(customerId);
        _fetchCustomers();
        _showSnackBar('Cliente reactivado exitosamente', Colors.green.shade600,
            Icons.check_circle_rounded);
      } catch (e) {
        _showSnackBar(
            'Error al reactivar: $e', Colors.red.shade600, Icons.error_rounded);
      }
    }
  }

  Future<bool?> _showConfirmDialog(
      String title, String content, IconData icon, Color color) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: cardBg,
        elevation: 8,
        contentPadding: const EdgeInsets.all(12),
        title: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 40)),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: const Color(0xFF1A1A2E))),
          ],
        ),
        content: Text(content,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 15, color: Colors.grey.shade700, height: 1.5)),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
        actions: [
          Flexible(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Cancelar',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Confirmar',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fade(),
    );
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [primaryOrange, lightOrange, const Color(0xFFFFA556)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: primaryOrange.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 2)),
                child: const Icon(Icons.business_center_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gestión de Clientes',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Administra la cartera de clientes',
                        style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard('Total', customers.length.toString(),
                  Icons.people_rounded, Colors.white),
              const SizedBox(width: 12),
              _buildStatCard(
                  'Activos',
                  customers.where((c) => c.isActive).length.toString(),
                  Icons.check_circle_rounded,
                  Colors.green.shade400),
              const SizedBox(width: 12),
              _buildStatCard(
                  'Inactivos',
                  customers.where((c) => !c.isActive).length.toString(),
                  Icons.cancel_rounded,
                  Colors.red.shade400),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  Text(label,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.filter_list_rounded,
                    color: primaryOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Filtros de Búsqueda',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: TextField(
              controller: _searchController,
              style:
                  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, documento o email...',
                hintStyle: GoogleFonts.inter(
                    fontSize: 13, color: Colors.grey.shade400),
                prefixIcon:
                    Icon(Icons.search_rounded, color: primaryOrange, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded,
                            color: Colors.grey.shade400, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                filled: false,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClipRect(
            child: Row(
              children: [
                Expanded(
                  child: _buildCustomDropdown<String?>(
                    value: _filterType,
                    hint: 'Tipos',
                    icon: Icons.business_center_rounded,
                    items: const [
                      DropdownMenuItem<String?>(
                          value: 'Todos', child: Text('Todos')),
                      DropdownMenuItem<String?>(
                          value: 'NATURAL', child: Text('Natural')),
                      DropdownMenuItem<String?>(
                          value: 'JURIDICO', child: Text('Jurídico')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterType = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCustomDropdown<String?>(
                    value: _filterState,
                    hint: 'Estados',
                    icon: Icons.toggle_on_rounded,
                    items: const [
                      DropdownMenuItem<String?>(
                          value: 'Todos', child: Text('Todos')),
                      DropdownMenuItem<String?>(
                          value: 'Activos', child: Text('Activos')),
                      DropdownMenuItem<String?>(
                          value: 'Inactivos', child: Text('Inactivos')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _filterState = v;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _filterType = null;
                      _filterState = null;
                      _searchController.clear();
                      _applyFilters();
                    });
                  },
                  icon: const Icon(Icons.clear_all_rounded, size: 18),
                  label: Text('Limpiar',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.2, duration: 600.ms);
  }

  Widget _buildCustomDropdown<T>({
    required T value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    Widget displayed;
    if (value == null) {
      displayed = Text(hint,
          style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500));
    } else {
      Widget? found;
      for (var item in items) {
        if (item.value == value) {
          found = item.child;
          break;
        }
      }
      displayed = found ??
          Text(hint,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500));
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<T>(
          isExpanded: true,
          value: value,
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Flexible(child: displayed),
            ],
          ),
          items: items,
          onChanged: onChanged,
          buttonStyleData: ButtonStyleData(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          ),
          dropdownStyleData: DropdownStyleData(
            width: 250,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            offset: const Offset(0, 8),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.expand_more_rounded),
            iconSize: 22,
            iconEnabledColor: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _customerCard(Customer customer, int index) {
    final isActive = customer.isActive;
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        verticalOffset: 30,
        curve: Curves.easeOutCubic,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _goToForm(customer: customer),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  colors: [
                                    primaryOrange.withOpacity(0.2),
                                    const Color(0xFFFFA556).withOpacity(0.1)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                              boxShadow: [
                                BoxShadow(
                                    color: primaryOrange.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      colors: [primaryOrange, lightOrange],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight)),
                              child: Center(
                                child: Text(
                                  customer.firstName.isNotEmpty
                                      ? customer.firstName[0].toUpperCase()
                                      : 'C',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.shade500
                                    : Colors.red.shade500,
                                shape: BoxShape.circle,
                                border: Border.all(color: cardBg, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          (isActive ? Colors.green : Colors.red)
                                              .withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.fullName,
                              style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A2E),
                                  letterSpacing: -0.3),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildInfoChip(
                                    icon: Icons.credit_card_rounded,
                                    label:
                                        '${customer.documentType}: ${customer.documentNumber}',
                                    color: primaryOrange),
                                _buildInfoChip(
                                    icon: Icons.business_center_rounded,
                                    label: customer.customerTypeLabel,
                                    color: customer.customerType == 'NATURAL'
                                        ? Colors.blue.shade600
                                        : Colors.purple.shade600),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (customer.email != null &&
                                customer.email!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.email_rounded,
                                      size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 6),
                                  Expanded(
                                      child: Text(customer.email!,
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            if (customer.email != null &&
                                customer.email!.isNotEmpty)
                              const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.phone_rounded,
                                    size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 6),
                                Text(customer.phone,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                            color: primaryOrange.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12)),
                        child: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert_rounded,
                              color: primaryOrange, size: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 8,
                          offset: const Offset(-10, 40),
                          onSelected: (value) {
                            if (value == 'edit') _goToForm(customer: customer);
                            if (value == 'toggle_state') {
                              isActive
                                  ? _deleteCustomer(customer.idCustomer!)
                                  : _restoreCustomer(customer.idCustomer!);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: primaryOrange.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Icon(Icons.edit_rounded,
                                          color: primaryOrange, size: 18)),
                                  const SizedBox(width: 12),
                                  Text('Editar cliente',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(height: 18),
                            PopupMenuItem(
                              value: 'toggle_state',
                              child: Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: (isActive
                                                  ? Colors.red
                                                  : Colors.green)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Icon(
                                          isActive
                                              ? Icons.person_off_rounded
                                              : Icons.check_circle_rounded,
                                          color: isActive
                                              ? Colors.red.shade600
                                              : Colors.green.shade600,
                                          size: 18)),
                                  const SizedBox(width: 12),
                                  Text(isActive ? 'Desactivar' : 'Reactivar',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: isActive
                                              ? Colors.red.shade700
                                              : Colors.green.shade700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [Colors.red.shade50, Colors.red.shade100]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.red.shade600, shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded,
                  color: Colors.white, size: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error al cargar datos',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade900,
                        fontSize: 16)),
                const SizedBox(height: 2),
                Text(_error!,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade800,
                        fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _error = null),
            icon: Icon(Icons.close_rounded, color: Colors.red.shade700),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    ).animate().shake(hz: 4, duration: 500.ms).fadeIn();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.grey.shade50, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                shape: BoxShape.circle),
            child: Icon(Icons.person_search_rounded,
                size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text('No se encontraron clientes',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text('Intenta ajustar los filtros o crear uno nuevo',
              style:
                  GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _filterType = null;
                _filterState = null;
                _searchController.clear();
                _applyFilters();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Limpiar filtros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: primaryOrange.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            child:
                CircularProgressIndicator(color: primaryOrange, strokeWidth: 3),
          )
              .animate()
              .scale(duration: 800.ms, curve: Curves.easeInOut)
              .then()
              .shake(hz: 2),
          const SizedBox(height: 24),
          Text('Cargando clientes...',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : surfaceBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 12),
                  _buildFilters(context),
                  const SizedBox(height: 12),
                  if (_error != null) _buildErrorBanner(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            SliverFillRemaining(
              child: _buildLoadingState(),
            ),
          if (!_isLoading && filteredCustomers.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            ),
          if (!_isLoading && filteredCustomers.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _customerCard(filteredCustomers[index], index),
                  childCount: filteredCustomers.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimController,
        child: FloatingActionButton.extended(
          onPressed: () => _goToForm(),
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(Icons.person_add_rounded, size: 24),
          label: Text(
            'Nuevo Cliente',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
