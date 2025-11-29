// lib/features/sales/widgets/sales_stats_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:as241s4_t13_appmovil/core/models/sales/sale_model.dart';

class SalesStatsCard extends StatelessWidget {
  final List<Sale> sales;

  const SalesStatsCard({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    final darkText = const Color(0xFF1A1A2E);
    
    // Calcular métricas reales
    final totalVentas = sales.length;
    final totalIngresos = sales.where((s) => s.isActive).fold<double>(0, (sum, sale) => sum + sale.total);
    final ticketPromedio = totalVentas > 0 ? totalIngresos / totalVentas : 0;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Total Ventas', totalVentas.toString(), Icons.shopping_bag_rounded, Colors.blue, darkText),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Ingresos', 'S/ ${totalIngresos.toStringAsFixed(2)}', Icons.trending_up_rounded, const Color(0xFFFF6B35), darkText),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Ticket Prom.', 'S/ ${ticketPromedio.toStringAsFixed(2)}', Icons.attach_money_rounded, Colors.green, darkText),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color darkText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}