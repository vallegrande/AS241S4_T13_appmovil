import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/order/order_model.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';

class OrderService {
  final String baseUrl = "${Environment.apiUrl}/v1/api/orders";

  Map<String, String> _getHeaders() {
    final token = AuthService.token;
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Crear pedido - CON DEBUG MEJORADO
  Future<Order> createOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _getHeaders(),
        body: jsonEncode(order.toJson()),
      );

      if (kDebugMode) {
        print('📡 Respuesta del backend:');
        print('   Status Code: ${response.statusCode}');
        print('   Body Length: ${response.body.length}');
        print('   Raw JSON: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonData = jsonDecode(response.body);

          if (kDebugMode) {
            print('🔍 JSON Decodificado:');
            print('   Type: ${jsonData.runtimeType}');
            print('   Keys: ${jsonData.keys}');
            print(
                '   idOrder: ${jsonData['idOrder']} (${jsonData['idOrder'].runtimeType})');
            print(
                '   idUser: ${jsonData['idUser']} (${jsonData['idUser'].runtimeType})');
            print(
                '   idCustomer: ${jsonData['idCustomer']} (${jsonData['idCustomer'].runtimeType})');
            print(
                '   idTable: ${jsonData['idTable']} (${jsonData['idTable'].runtimeType})');
            print('   customer: ${jsonData['customer']}');

            if (jsonData['customer'] != null) {
              print(
                  '   customer.idCustomer: ${jsonData['customer']['idCustomer']}');
              print(
                  '   customer.firstName: ${jsonData['customer']['firstName']}');
              print(
                  '   customer.lastName: ${jsonData['customer']['lastName']}');
            }

            if (jsonData['details'] != null) {
              print(
                  '   details count: ${(jsonData['details'] as List).length}');
              for (var i = 0; i < (jsonData['details'] as List).length; i++) {
                var detail = jsonData['details'][i];
                print('   detail[$i]:');
                print(
                    '      idDetail: ${detail['idDetail']} (${detail['idDetail'].runtimeType})');
                print(
                    '      idPresentation: ${detail['idPresentation']} (${detail['idPresentation']?.runtimeType})');
                print(
                    '      amount: ${detail['amount']} (${detail['amount']?.runtimeType})');
              }
            }
          }

          return Order.fromJson(jsonData);
        } catch (parseError) {
          if (kDebugMode) {
            print('❌ Error al parsear JSON:');
            print('   Error: $parseError');
            print('   StackTrace: ${StackTrace.current}');
          }
          rethrow;
        }
      } else {
        throw Exception(
            'Error al crear pedido (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Error en createOrder: $e');
      throw Exception('Error de conexión al crear pedido: $e');
    }
  }

  // Obtener todos los pedidos
  Future<List<Order>> getAllOrders() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener pedidos (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getAllOrders: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener pedido por ID
  Future<Order?> getOrderById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Order.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener pedido (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrderById: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener preview del pedido
  Future<Map<String, dynamic>> getOrderPreview(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id/preview'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 409) {
        throw Exception('No se puede generar precuenta en este estado');
      } else {
        throw Exception('Error al obtener preview (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrderPreview: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar estado del pedido
  Future<Map<String, dynamic>> updateOrderStatus(int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/status?status=$status'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Transición no permitida');
      } else if (response.statusCode == 404) {
        throw Exception('Pedido no encontrado');
      } else {
        throw Exception('Error al actualizar estado (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en updateOrderStatus: $e');
      throw Exception('Error: $e');
    }
  }

  // Los demás métodos permanecen igual...
  Future<List<Order>> getOrdersByUser(int idUser) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$idUser'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Error al obtener pedidos del usuario (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrdersByUser: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status/$status'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Error al obtener pedidos por estado (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrdersByStatus: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getOrdersByDate(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$baseUrl/date/$dateStr'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Error al obtener pedidos por fecha (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrdersByDate: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getOrdersByDateRange(DateTime start, DateTime end) async {
    try {
      final startStr = start.toIso8601String().split('T')[0];
      final endStr = end.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$baseUrl/date-range?start=$startStr&end=$endStr'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Error al obtener pedidos por rango (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrdersByDateRange: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar pedido (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en deleteOrder: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<int> getPendingOrdersCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pending/count'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        throw Exception('Error al obtener conteo (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getPendingOrdersCount: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<int> getReadyOrdersCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ready/count'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        throw Exception('Error al obtener conteo (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getReadyOrdersCount: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<int> getDeliveredOrdersCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delivered/count'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        throw Exception('Error al obtener conteo (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getDeliveredOrdersCount: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<int> getClosedOrdersCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/closed/count'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        throw Exception('Error al obtener conteo (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getClosedOrdersCount: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getOrdersByCustomer(int idCustomer) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customer/$idCustomer'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Error al obtener pedidos del cliente (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrdersByCustomer: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getOrdersByCustomerAndStatus(
      int idCustomer, String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customer/$idCustomer/status/$status'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener pedidos (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrdersByCustomerAndStatus: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getOrdersByType(String type) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/type/$type'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener pedidos (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrdersByType: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getOrdersByTypeAndStatus(
      String type, String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/type/$type/status/$status'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener pedidos (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrdersByTypeAndStatus: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getPendingDeliveries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delivery/pending'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener deliveries (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getPendingDeliveries: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getOrdersByTable(int idTable) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/table/$idTable'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Error al obtener pedidos de la mesa (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrdersByTable: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getOrdersByTableAndStatus(
      int idTable, String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/table/$idTable/status/$status'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener pedidos (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrdersByTableAndStatus: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<int> countOrdersByCustomer(int idCustomer) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customer/$idCustomer/count'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['totalOrders'];
      } else {
        throw Exception('Error al contar pedidos (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en countOrdersByCustomer: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getLastOrdersByCustomer(int idCustomer) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customer/$idCustomer/last'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener pedidos (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getLastOrdersByCustomer: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getOrdersByCustomerAndDateRange(
      int idCustomer, DateTime start, DateTime end) async {
    try {
      final startStr = start.toIso8601String().split('T')[0];
      final endStr = end.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse(
            '$baseUrl/customer/$idCustomer/date-range?start=$startStr&end=$endStr'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener pedidos (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getOrdersByCustomerAndDateRange: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<int>> generateOrderReport(int idOrder) async {
    try {
      final token = AuthService.token;
      final response = await http.get(
        Uri.parse('$baseUrl/reportOrders/$idOrder'),
        headers: {
          'Accept': 'application/pdf',
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Error al generar reporte (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('Error en generateOrderReport: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
