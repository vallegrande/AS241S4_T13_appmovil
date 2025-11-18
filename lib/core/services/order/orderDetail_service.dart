import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/order/orderDetail_model.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';

class OrderDetailService {
  final String baseUrl = "${Environment.apiUrl}/v1/api/order-details";

  Map<String, String> _getHeaders() {
    final token = AuthService.token;
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Crear detalle de pedido
  Future<OrderDetail> createOrderDetail(OrderDetail detail) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _getHeaders(),
        body: jsonEncode(detail.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OrderDetail.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 409) {
        throw Exception(
            'No se puede agregar detalle: Estado del pedido no permite modificaciones');
      } else if (response.statusCode == 400) {
        throw Exception('Datos inválidos: ${response.body}');
      } else {
        throw Exception(
            'Error al crear detalle (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Error en createOrderDetail: $e');
      throw Exception('Error de conexión al crear detalle: $e');
    }
  }

  // Obtener detalles por ID de pedido
  Future<List<OrderDetail>> getDetailsByOrder(int idOrder) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/order/$idOrder'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => OrderDetail.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener detalles (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getDetailsByOrder: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar detalle de pedido
  Future<OrderDetail?> updateOrderDetail(
      int idDetail, OrderDetail updatedDetail) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$idDetail'),
        headers: _getHeaders(),
        body: jsonEncode(updatedDetail.toJson()),
      );

      if (response.statusCode == 200) {
        return OrderDetail.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('No se encontró el detalle con ID $idDetail');
      } else if (response.statusCode == 403) {
        throw Exception('No se puede modificar: ${response.body}');
      } else {
        throw Exception(
            'Error al actualizar detalle (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Error en updateOrderDetail: $e');
      throw Exception('Error: $e');
    }
  }

  // Eliminar detalle de pedido
  Future<Map<String, dynamic>> deleteOrderDetail(int idDetail) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$idDetail'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error al eliminar detalle');
      } else {
        throw Exception('Error al eliminar detalle (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en deleteOrderDetail: $e');
      throw Exception('Error: $e');
    }
  }

  // Calcular subtotal de un detalle
  double calculateSubtotal(OrderDetail detail) {
    return detail.amount * detail.unitPrice;
  }

  // Validar cantidad
  bool validateAmount(int amount) {
    return amount > 0;
  }

  // Validar precio unitario
  bool validateUnitPrice(double unitPrice) {
    return unitPrice > 0;
  }

  // Validar detalle completo antes de enviar
  // ✅ CORREGIDO: Ahora verifica si idPresentation no es null antes de comparar
  bool validateDetail(OrderDetail detail) {
    return validateAmount(detail.amount) &&
        validateUnitPrice(detail.unitPrice) &&
        detail.idPresentation != null &&
        detail.idPresentation! > 0;
  }

  // Crear múltiples detalles de una vez
  Future<List<OrderDetail>> createMultipleDetails(
      List<OrderDetail> details) async {
    List<OrderDetail> createdDetails = [];

    for (var detail in details) {
      try {
        final created = await createOrderDetail(detail);
        createdDetails.add(created);
      } catch (e) {
        if (kDebugMode) print('Error al crear detalle: $e');
        // Si falla uno, podrías decidir si continuar o lanzar excepción
        throw Exception('Error al crear detalle: $e');
      }
    }

    return createdDetails;
  }

  // Actualizar cantidad de un detalle
  Future<OrderDetail?> updateDetailAmount(int idDetail, int newAmount) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$idDetail'),
        headers: _getHeaders(),
        body: jsonEncode({'amount': newAmount}),
      );

      if (response.statusCode == 200) {
        return OrderDetail.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Detalle no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('No se puede modificar este detalle');
      } else {
        throw Exception(
            'Error al actualizar cantidad (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en updateDetailAmount: $e');
      throw Exception('Error: $e');
    }
  }

  // Calcular total de todos los detalles de un pedido
  Future<double> calculateOrderTotal(int idOrder) async {
    try {
      final details = await getDetailsByOrder(idOrder);
      double total = 0.0;

      for (var detail in details) {
        total += detail.subtotal ?? calculateSubtotal(detail);
      }

      return total;
    } catch (e) {
      if (kDebugMode) print('Error en calculateOrderTotal: $e');
      throw Exception('Error al calcular total: $e');
    }
  }

  // Contar items en un pedido
  Future<int> countOrderItems(int idOrder) async {
    try {
      final details = await getDetailsByOrder(idOrder);
      int count = 0;

      for (var detail in details) {
        count += detail.amount;
      }

      return count;
    } catch (e) {
      if (kDebugMode) print('Error en countOrderItems: $e');
      throw Exception('Error al contar items: $e');
    }
  }

  // Verificar si un pedido tiene detalles
  Future<bool> orderHasDetails(int idOrder) async {
    try {
      final details = await getDetailsByOrder(idOrder);
      return details.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('Error en orderHasDetails: $e');
      return false;
    }
  }

  // Obtener resumen de un pedido
  Future<Map<String, dynamic>> getOrderSummary(int idOrder) async {
    try {
      final details = await getDetailsByOrder(idOrder);

      double total = 0.0;
      int totalItems = 0;

      for (var detail in details) {
        total += detail.subtotal ?? calculateSubtotal(detail);
        totalItems += detail.amount;
      }

      return {
        'totalDetails': details.length,
        'totalItems': totalItems,
        'total': total,
        'details': details,
      };
    } catch (e) {
      if (kDebugMode) print('Error en getOrderSummary: $e');
      throw Exception('Error al obtener resumen: $e');
    }
  }
}
