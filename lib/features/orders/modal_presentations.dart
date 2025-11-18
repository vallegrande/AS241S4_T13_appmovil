import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/presentation.dart';
import 'package:as241s4_t13_appmovil/core/services/dishes/presentation_service.dart';

class PresentationSelectionModal extends StatefulWidget {
  final String orderType;

  const PresentationSelectionModal({
    Key? key,
    required this.orderType,
  }) : super(key: key);

  @override
  State<PresentationSelectionModal> createState() =>
      _PresentationSelectionModalState();
}

class _PresentationSelectionModalState
    extends State<PresentationSelectionModal> {
  List<Presentation> _presentations = [];
  List<Presentation> _filteredPresentations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final Color primaryOrange = const Color(0xFFFF6B35);
  final Color surfaceBg = const Color(0xFFFAFAFC);

  @override
  void initState() {
    super.initState();
    _loadPresentations();
  }

  Future<void> _loadPresentations() async {
    try {
      setState(() => _isLoading = true);
      final presentations = await PresentationService.getAll();
      setState(() {
        _presentations = presentations;
        _filteredPresentations = presentations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _filterPresentations(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredPresentations = query.isEmpty
          ? _presentations
          : _presentations.where((p) {
              return p.name.toLowerCase().contains(_searchQuery) ||
                  (p.description?.toLowerCase().contains(_searchQuery) ??
                      false);
            }).toList();
    });
  }

  double _getPriceByOrderType(Presentation p) {
    switch (widget.orderType.toUpperCase()) {
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

  String _getPriceLabel() {
    switch (widget.orderType.toUpperCase()) {
      case 'DELIVERY':
        return 'Precio Delivery';
      case 'TAKEOUT':
        return 'Precio Para Llevar';
      case 'PROMO':
        return 'Precio Promoción';
      default:
        return 'Precio Local';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                    child: const Icon(Icons.restaurant_menu,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seleccionar Plato',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _getPriceLabel(),
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
                    hintText: 'Buscar plato...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: primaryOrange),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterPresentations('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: _filterPresentations,
                ),
              ),
            ),

            // Grid
            Flexible(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryOrange))
                  : _filteredPresentations.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredPresentations.length,
                          itemBuilder: (context, index) {
                            final p = _filteredPresentations[index];
                            return _buildPresentationCard(p);
                          },
                        ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildPresentationCard(Presentation p) {
    final price = _getPriceByOrderType(p);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryOrange.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pop(context, p),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: p.dishPhotoUrl != null
                      ? CachedNetworkImage(
                          imageUrl:
                              PresentationService.getPhotoUrl(p.dishPhotoUrl),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: primaryOrange,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),

              // Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'S/ ${price.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart,
                              size: 18,
                              color: primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(Icons.restaurant, size: 48, color: Colors.grey.shade400),
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
            Icon(Icons.restaurant_menu_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No se encontraron platos',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
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

Future<Presentation?> showPresentationSelectionModal(
  BuildContext context, {
  required String orderType,
}) {
  return showDialog<Presentation>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PresentationSelectionModal(orderType: orderType),
  );
}
