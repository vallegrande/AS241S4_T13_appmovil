import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/product.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';
import 'package:flutter/foundation.dart';

class ProductService {
  static final String _baseUrl = '${Environment.apiUrl}/v1/api/products';

  // Headers con autenticación
  static Map<String, String> _getAuthHeaders({bool isJson = true}) {
    final headers = <String, String>{};
    
    if (AuthService.token != null) {
      headers['Authorization'] = 'Bearer ${AuthService.token}';
    }
    
    if (isJson) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    
    return headers;
  }

  // CREATE - Crear producto
  static Future<Product> create(Product product) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getAuthHeaders(),
        body: jsonEncode(product.toJson()),
      );

      if (kDebugMode) {
        print('🔵 CREATE Product - Status: ${response.statusCode}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para crear productos');
      }
      
      throw Exception('Error al crear producto: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en create: $e');
      rethrow;
    }
  }

  // READ - Obtener todos los productos activos
  static Future<List<Product>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('🔵 GET Active Products - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver los productos');
      }
      
      throw Exception('Error al cargar productos: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en getAll: $e');
      rethrow;
    }
  }

  // READ - Obtener TODOS los productos (incluidos inactivos)
  static Future<List<Product>> getAllWithInactive() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/all'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('🔵 GET All Products - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver todos los productos');
      }
      
      throw Exception('Error al cargar todos los productos: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en getAllWithInactive: $e');
      rethrow;
    }
  }

  // READ - Obtener producto por ID
  static Future<Product> getById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('🔵 GET Product by ID - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        throw NotFoundException('Producto no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver este producto');
      }
      
      throw Exception('Error al cargar producto: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en getById: $e');
      rethrow;
    }
  }

  // UPDATE - Actualizar producto
  static Future<Product> update(int id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: _getAuthHeaders(),
        body: jsonEncode(product.toJson()),
      );

      if (kDebugMode) {
        print('🔵 UPDATE Product - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        throw NotFoundException('Producto no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para actualizar productos');
      }
      
      throw Exception('Error al actualizar producto: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en update: $e');
      rethrow;
    }
  }

  // STATE - Desactivar producto (Soft Delete)
  static Future<void> disable(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/disable/$id'),
        headers: _getAuthHeaders(isJson: false),
      );

      if (kDebugMode) {
        print('🔵 DISABLE Product - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para desactivar productos');
        }
        throw Exception('Error al desactivar producto: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error en disable: $e');
      rethrow;
    }
  }

  // STATE - Restaurar producto
  static Future<void> restore(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/restore/$id'),
        headers: _getAuthHeaders(isJson: false),
      );

      if (kDebugMode) {
        print('🔵 RESTORE Product - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para restaurar productos');
        }
        throw Exception('Error al restaurar producto: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error en restore: $e');
      rethrow;
    }
  }

  // DELETE - Eliminar producto físicamente
  static Future<void> delete(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: _getAuthHeaders(isJson: false),
      );

      if (kDebugMode) {
        print('🔵 DELETE Product - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para eliminar productos');
        }
        throw Exception('Error al eliminar producto: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error en delete: $e');
      rethrow;
    }
  }
}