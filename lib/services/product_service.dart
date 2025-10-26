// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/product.dart';
import 'token_manager.dart';
import 'package:flutter/foundation.dart' show debugPrint;

const String _BASE_URL = 'http://localhost:8080';

class ProductService {
  final String _baseUrl = '$_BASE_URL/v1/api/products';

  Future<List<Product>> getAllActive() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: TokenManager.getAuthHeaders(),
      );

      debugPrint('🌐 GET Active Products - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        debugPrint('❌ 403 Forbidden - No permission for active products');
        throw Exception('No tiene permisos para acceder a los productos activos');
      }
      throw Exception('Failed to load active products: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error en getAllActive: $e');
      rethrow;
    }
  }

  Future<List<Product>> getAll() async {
    final url = '$_baseUrl/all';
    final headers = TokenManager.getAuthHeaders();
    
    debugPrint('════════════════════════════════════════════════');
    debugPrint('🌐 PETICIÓN HTTP - ALL PRODUCTS');
    debugPrint('════════════════════════════════════════════════');
    debugPrint('URL: $url');
    debugPrint('Método: GET');
    debugPrint('Headers: $headers');
    debugPrint('════════════════════════════════════════════════');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      debugPrint('════════════════════════════════════════════════');
      debugPrint('📥 RESPUESTA HTTP - ALL PRODUCTS');
      debugPrint('════════════════════════════════════════════════');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Body: ${response.body.isNotEmpty ? response.body : "EMPTY BODY"}');
      debugPrint('════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('✅ Productos parseados: ${jsonList.length}');
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        debugPrint('❌ ERROR 403 FORBIDDEN - PRODUCTS');
        debugPrint('🔍 Diagnóstico del problema:');
        debugPrint('   - El backend espera: hasRole("ADMIN")');
        debugPrint('   - Pero el JWT tiene: "role": "ADMIN"');
        debugPrint('   - Spring Security busca: ROLE_ADMIN');
        debugPrint('🎯 Solución requerida en el backend:');
        debugPrint('   - Cambiar hasRole("ADMIN") por hasAuthority("ADMIN")');
        debugPrint('   - O modificar el JWT para incluir ROLE_ADMIN');
        
        throw Exception('''
Error de permisos: 403 Forbidden

Problema identificado:
• El backend Spring Boot está configurado con hasRole("ADMIN")
• Spring Security espera la autoridad "ROLE_ADMIN" 
• Pero el token JWT solo contiene "role": "ADMIN"

Solución:
Contacte al administrador para modificar el SecurityConfig.java
y cambiar hasRole("ADMIN") por hasAuthority("ADMIN")
''');
      }
      
      throw Exception('Failed to load all products: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error en getAll: $e');
      rethrow;
    }
  }

  // Método temporal con headers forzados
  Future<List<Product>> getAllWithForcedHeaders() async {
    final url = '$_baseUrl/all';
    
    final token = TokenManager.getToken();
    if (token == null) {
      throw Exception('Token no disponible incluso en método forzado');
    }
    
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    
    debugPrint('🔄 getAllWithForcedHeaders - URL: $url');
    debugPrint('🔐 Headers forzados: $headers');
    
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint('✅ Productos cargados con headers forzados: ${jsonList.length}');
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else if (response.statusCode == 403) {
      debugPrint('❌ 403 incluso con headers forzados - Problema en backend');
      throw Exception('Error de permisos en backend: 403 Forbidden');
    }
    
    throw Exception('Failed to load products: ${response.statusCode}');
  }

  Future<Product> getById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: TokenManager.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        throw NotFoundException('Product not found');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver este producto');
      }
      throw Exception('Failed to load product: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error en getById: $e');
      rethrow;
    }
  }

  Future<Product> create(Product product) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: TokenManager.getAuthHeaders(),
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 201) {
        return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 409) {
        throw ConflictException('Product already exists');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para crear productos');
      }
      throw Exception('Failed to create product: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error en create: $e');
      rethrow;
    }
  }

  Future<Product> update(int id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: TokenManager.getAuthHeaders(),
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        throw NotFoundException('Product not found');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para actualizar productos');
      }
      throw Exception('Failed to update product: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error en update: $e');
      rethrow;
    }
  }

  Future<void> disable(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/disable/$id'),
        headers: TokenManager.getAuthHeaders(isJson: false),
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para deshabilitar productos');
        }
        throw Exception('Failed to disable product: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error en disable: $e');
      rethrow;
    }
  }

  Future<void> restore(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/restore/$id'),
        headers: TokenManager.getAuthHeaders(isJson: false),
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para restaurar productos');
        }
        throw Exception('Failed to restore product: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error en restore: $e');
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: TokenManager.getAuthHeaders(isJson: false),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para eliminar productos');
        }
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error en delete: $e');
      rethrow;
    }
  }
}