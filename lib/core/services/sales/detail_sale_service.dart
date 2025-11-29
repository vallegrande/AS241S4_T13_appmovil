// lib/core/services/sales/detail_sale_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/sales/sale_model.dart';

class DetailSaleService {
  static final String _baseUrl = Environment.apiUrl;
  static const String _apiPath = '/v1/api/detail-sale';

  // Headers comunes
  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Obtener detalles de venta por ID de venta
  static Future<List<SaleDetail>> getDetailsBySale(int idSale) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_apiPath/sale/$idSale'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => SaleDetail.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar detalles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener detalle específico por ID
  static Future<SaleDetail> getDetailById(int idDetailSale) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_apiPath/$idDetailSale'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return SaleDetail.fromJson(jsonData);
      } else {
        throw Exception('Error al cargar detalle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}