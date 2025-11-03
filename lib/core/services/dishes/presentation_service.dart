import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/presentation.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';
import 'package:flutter/foundation.dart';

class PresentationService {
  static final String _baseUrl = '${Environment.apiUrl}/v1/api/presentations';

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

  static Future<Presentation> create(Presentation presentation) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getAuthHeaders(),
        body: jsonEncode(presentation.toJson()),
      );

      if (kDebugMode) {
        print('CREATE Presentation - Status: ${response.statusCode}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Presentation.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para crear presentaciones');
      }

      throw Exception('Error al crear presentación: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('Error en create: $e');
      rethrow;
    }
  }

  static Future<List<Presentation>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('GET Active Presentations - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Presentation.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver las presentaciones');
      }

      throw Exception('Error al cargar presentaciones: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('Error en getAll: $e');
      rethrow;
    }
  }

  static Future<List<Presentation>> getAllWithInactive() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/all'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('GET All Presentations - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Presentation.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver todas las presentaciones');
      }

      throw Exception(
          'Error al cargar todas las presentaciones: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('Error en getAllWithInactive: $e');
      rethrow;
    }
  }

  static Future<Presentation> getById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('GET Presentation by ID - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return Presentation.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        throw NotFoundException('Presentación no encontrada');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para ver esta presentación');
      }

      throw Exception('Error al cargar presentación: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('Error en getById: $e');
      rethrow;
    }
  }

  static Future<Presentation> update(int id, Presentation presentation) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: _getAuthHeaders(),
        body: jsonEncode(presentation.toJson()),
      );

      if (kDebugMode) {
        print('UPDATE Presentation - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return Presentation.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        throw NotFoundException('Presentación no encontrada');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para actualizar presentaciones');
      }

      throw Exception(
          'Error al actualizar presentación: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('Error en update: $e');
      rethrow;
    }
  }

  static Future<void> disable(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/disable/$id'),
        headers: _getAuthHeaders(isJson: false),
      );

      if (kDebugMode) {
        print('DISABLE Presentation - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para desactivar presentaciones');
        }
        throw Exception(
            'Error al desactivar presentación: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error en disable: $e');
      rethrow;
    }
  }

  static Future<void> restore(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/restore/$id'),
        headers: _getAuthHeaders(isJson: false),
      );

      if (kDebugMode) {
        print('RESTORE Presentation - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para restaurar presentaciones');
        }
        throw Exception(
            'Error al restaurar presentación: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error en restore: $e');
      rethrow;
    }
  }

  static Future<void> delete(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: _getAuthHeaders(isJson: false),
      );

      if (kDebugMode) {
        print('DELETE Presentation - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para eliminar presentaciones');
        }
        throw Exception(
            'Error al eliminar presentación: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error en delete: $e');
      rethrow;
    }
  }
}
