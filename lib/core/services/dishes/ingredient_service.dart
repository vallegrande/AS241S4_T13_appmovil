import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/ingredient.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';
import 'package:flutter/foundation.dart';

class IngredientService {
  static final String _baseUrl = '${Environment.apiUrl}/v1/api/supplies';

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

  // CREATE - Crear ingrediente/insumo
  static Future<Ingredient> create(Ingredient ingredient) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getAuthHeaders(),
        body: jsonEncode(ingredient.toJson()),
      );

      if (kDebugMode) {
        print('🔵 CREATE Ingredient - Status: ${response.statusCode}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Ingredient.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para crear ingredientes');
      }
      
      throw Exception('Error al crear ingrediente: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en create: $e');
      rethrow;
    }
  }

  // READ - Obtener todos los ingredientes activos
  static Future<List<Ingredient>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('🔵 GET Active Ingredients - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Ingredient.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver los ingredientes');
      }
      
      throw Exception('Error al cargar ingredientes: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en getAll: $e');
      rethrow;
    }
  }

  // READ - Obtener TODOS los ingredientes (incluidos inactivos)
  static Future<List<Ingredient>> getAllWithInactive() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/all'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('🔵 GET All Ingredients - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Ingredient.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver todos los ingredientes');
      }
      
      throw Exception('Error al cargar todos los ingredientes: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en getAllWithInactive: $e');
      rethrow;
    }
  }

  // READ - Obtener ingrediente por ID
  static Future<Ingredient> getById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('🔵 GET Ingredient by ID - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return Ingredient.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        throw Exception('Ingrediente no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver este ingrediente');
      }
      
      throw Exception('Error al cargar ingrediente: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en getById: $e');
      rethrow;
    }
  }

  // UPDATE - Actualizar ingrediente
  static Future<Ingredient> update(int id, Ingredient ingredient) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: _getAuthHeaders(),
        body: jsonEncode(ingredient.toJson()),
      );

      if (kDebugMode) {
        print('🔵 UPDATE Ingredient - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return Ingredient.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        throw Exception('Ingrediente no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para actualizar ingredientes');
      }
      
      throw Exception('Error al actualizar ingrediente: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en update: $e');
      rethrow;
    }
  }

  // STATE - Desactivar ingrediente (Soft Delete)
  static Future<void> disable(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/disable/$id'),
        headers: _getAuthHeaders(isJson: false),
      );

      if (kDebugMode) {
        print('🔵 DISABLE Ingredient - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para desactivar ingredientes');
        }
        throw Exception('Error al desactivar ingrediente: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error en disable: $e');
      rethrow;
    }
  }

  // STATE - Restaurar ingrediente
  static Future<void> restore(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/restore/$id'),
        headers: _getAuthHeaders(isJson: false),
      );

      if (kDebugMode) {
        print('🔵 RESTORE Ingredient - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para restaurar ingredientes');
        }
        throw Exception('Error al restaurar ingrediente: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error en restore: $e');
      rethrow;
    }
  }

  // DELETE - Eliminar ingrediente físicamente
  static Future<void> delete(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: _getAuthHeaders(isJson: false),
      );

      if (kDebugMode) {
        print('🔵 DELETE Ingredient - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para eliminar ingredientes');
        }
        throw Exception('Error al eliminar ingrediente: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error en delete: $e');
      rethrow;
    }
  }

  // ALERTS - Ingredientes próximos a vencer
  static Future<List<Ingredient>> getExpiringSoon(int days) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/alerts/expiring-soon/$days'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('🔵 GET Expiring Soon - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Ingredient.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ Error en getExpiringSoon: $e');
      return [];
    }
  }

  // ALERTS - Ingredientes con stock bajo
  static Future<List<Ingredient>> getLowStock() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/alerts/low-stock'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('🔵 GET Low Stock - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Ingredient.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ Error en getLowStock: $e');
      return [];
    }
  }

  // ALERTS - Ingredientes vencidos
  static Future<List<Ingredient>> getExpired() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/alerts/expired'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('🔵 GET Expired - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Ingredient.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) print('❌ Error en getExpired: $e');
      return [];
    }
  }
}