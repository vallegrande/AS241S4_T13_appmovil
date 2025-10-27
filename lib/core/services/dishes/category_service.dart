import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/category.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';
import 'package:flutter/foundation.dart' hide Category;

class CategoryService {
  static final String _baseUrl = '${Environment.apiUrl}/v1/api/categories';

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

  // CREATE - Crear categoría
  static Future<Category> create(Category category) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getAuthHeaders(),
        body: jsonEncode(category.toJson()),
      );

      if (kDebugMode) {
        print('🔵 CREATE Category - Status: ${response.statusCode}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Category.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 409) {
        throw ConflictException('La categoría ya existe');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para crear categorías');
      }
      
      throw Exception('Error al crear categoría: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en create: $e');
      rethrow;
    }
  }

  // READ - Obtener todas las categorías activas
  static Future<List<Category>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('🔵 GET Active Categories - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Category.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver las categorías');
      }
      
      throw Exception('Error al cargar categorías: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en getAll: $e');
      rethrow;
    }
  }

  // READ - Obtener TODAS las categorías (incluidas inactivas)
  static Future<List<Category>> getAllWithInactive() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/all'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('🔵 GET All Categories - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Category.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver todas las categorías');
      }
      
      throw Exception('Error al cargar todas las categorías: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en getAllWithInactive: $e');
      rethrow;
    }
  }

  // READ - Obtener categoría por ID
  static Future<Category> getById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('🔵 GET Category by ID - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return Category.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        throw NotFoundException('Categoría no encontrada');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver esta categoría');
      }
      
      throw Exception('Error al cargar categoría: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en getById: $e');
      rethrow;
    }
  }

  // UPDATE - Actualizar categoría
  static Future<Category> update(int id, Category category) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: _getAuthHeaders(),
        body: jsonEncode(category.toJson()),
      );

      if (kDebugMode) {
        print('🔵 UPDATE Category - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return Category.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        throw NotFoundException('Categoría no encontrada');
      } else if (response.statusCode == 409) {
        throw ConflictException('Conflicto al actualizar categoría');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para actualizar categorías');
      }
      
      throw Exception('Error al actualizar categoría: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('❌ Error en update: $e');
      rethrow;
    }
  }

  // STATE - Desactivar categoría (Soft Delete)
  static Future<void> disable(int id) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/disable/$id'),
        headers: _getAuthHeaders(isJson: false),
      );

      if (kDebugMode) {
        print('🔵 DISABLE Category - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para desactivar categorías');
        }
        throw Exception('Error al desactivar categoría: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error en disable: $e');
      rethrow;
    }
  }

  // STATE - Restaurar categoría
  static Future<void> restore(int id) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/restore/$id'),
        headers: _getAuthHeaders(isJson: false),
      );

      if (kDebugMode) {
        print('🔵 RESTORE Category - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para restaurar categorías');
        }
        throw Exception('Error al restaurar categoría: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error en restore: $e');
      rethrow;
    }
  }

  // DELETE - Eliminar categoría físicamente
  static Future<void> delete(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: _getAuthHeaders(isJson: false),
      );

      if (kDebugMode) {
        print('🔵 DELETE Category - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para eliminar categorías');
        }
        throw Exception('Error al eliminar categoría: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error en delete: $e');
      rethrow;
    }
  }
}