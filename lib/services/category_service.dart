// Archivo: lib/services/category_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/category.dart' as models;
import 'package:myapp/services/user_service.dart'; // TokenManager y excepciones
import 'package:flutter/foundation.dart' show debugPrint;

const String _BASE_URL = 'http://localhost:8080';

class CategoryService {
  final String _baseUrl = '$_BASE_URL/v1/api/categories';

  Future<List<models.Category>> getAll() async {
    final url = '$_baseUrl/all';
    final headers = TokenManager.getAuthHeaders();
    
    // ========== DEBUG COMPLETO ==========
    debugPrint('════════════════════════════════════════════════');
    debugPrint('🌐 PETICIÓN HTTP - CATEGORIES');
    debugPrint('════════════════════════════════════════════════');
    debugPrint('URL: $url');
    debugPrint('Método: GET');
    debugPrint('Headers enviados:');
    headers.forEach((key, value) {
      if (key == 'Authorization') {
        debugPrint('  $key: ${value.substring(0, 50)}...');
      } else {
        debugPrint('  $key: $value');
      }
    });
    debugPrint('════════════════════════════════════════════════');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      debugPrint('════════════════════════════════════════════════');
      debugPrint('📥 RESPUESTA HTTP - CATEGORIES');
      debugPrint('════════════════════════════════════════════════');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Reason Phrase: ${response.reasonPhrase}');
      debugPrint('Headers de respuesta:');
      response.headers.forEach((key, value) {
        debugPrint('  $key: $value');
      });
      debugPrint('Body (primeros 500 chars):');
      final bodyPreview = response.body.length > 500 
          ? '${response.body.substring(0, 500)}...' 
          : response.body;
      debugPrint(bodyPreview);
      debugPrint('════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('✅ Categorías parseadas correctamente: ${jsonList.length}');
        return jsonList.map((json) => models.Category.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        debugPrint('❌ ERROR 403 FORBIDDEN');
        debugPrint('El servidor rechazó la petición por falta de permisos');
        debugPrint('Posibles causas:');
        debugPrint('  1. Token expirado');
        debugPrint('  2. Token inválido');
        debugPrint('  3. Rol insuficiente');
        debugPrint('  4. Backend no configurado correctamente');
        
        // Intentar parsear el mensaje de error del backend
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          debugPrint('Mensaje del backend: $errorBody');
        } catch (e) {
          debugPrint('No se pudo parsear el mensaje de error');
        }
      }
      
      throw Exception('Failed to load categories: ${response.statusCode}');
      
    } catch (e) {
      debugPrint('════════════════════════════════════════════════');
      debugPrint('❌ EXCEPCIÓN EN PETICIÓN');
      debugPrint('════════════════════════════════════════════════');
      debugPrint('Error: $e');
      debugPrint('Tipo: ${e.runtimeType}');
      debugPrint('════════════════════════════════════════════════');
      rethrow;
    }
  }

  Future<models.Category> getById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$id'),
      headers: TokenManager.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return models.Category.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 404) {
      throw NotFoundException('Category not found');
    }
    throw Exception('Failed to load category: ${response.statusCode}');
  }

  Future<models.Category> create(models.Category category) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: TokenManager.getAuthHeaders(),
      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode == 201) {
      return models.Category.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 409) {
      throw ConflictException('Category already exists');
    }
    throw Exception('Failed to create category: ${response.statusCode}');
  }

  Future<models.Category> update(int id, models.Category category) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: TokenManager.getAuthHeaders(),
      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode == 200) {
      return models.Category.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 404) {
      throw NotFoundException('Category not found');
    } else if (response.statusCode == 409) {
      throw ConflictException('Category conflict');
    }
    throw Exception('Failed to update category: ${response.statusCode}');
  }

  Future<void> disable(int id) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/disable/$id'),
      headers: TokenManager.getAuthHeaders(isJson: false),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to disable category: ${response.statusCode}');
    }
  }

  Future<void> restore(int id) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/restore/$id'),
      headers: TokenManager.getAuthHeaders(isJson: false),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to restore category: ${response.statusCode}');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: TokenManager.getAuthHeaders(isJson: false),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete category: ${response.statusCode}');
    }
  }
}