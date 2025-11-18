import 'dart:convert';
import 'dart:io';
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

  static Future<String> uploadPhoto(int id, File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/$id/upload-photo'),
      );

      if (AuthService.token != null) {
        request.headers['Authorization'] = 'Bearer ${AuthService.token}';
      }

      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      request.files.add(multipartFile);

      if (kDebugMode) {
        print('UPLOAD Photo - Presentation ID: $id');
        print('File: ${imageFile.path}');
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('UPLOAD Photo - Status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
          if (jsonResponse is Map && jsonResponse.containsKey('dishPhotoUrl')) {
            return jsonResponse['dishPhotoUrl'];
          }
          return jsonResponse.toString();
        } catch (e) {
          return utf8.decode(response.bodyBytes);
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException('Presentación no encontrada');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para subir fotos');
      } else if (response.statusCode == 400) {
        throw Exception('Archivo inválido o formato no soportado');
      }

      throw Exception('Error al subir foto: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('Error en uploadPhoto: $e');
      rethrow;
    }
  }

  static Future<String> uploadPhotoBytes(
      int id, Uint8List bytes, String filename) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/$id/upload-photo'),
      );

      if (AuthService.token != null) {
        request.headers['Authorization'] = 'Bearer ${AuthService.token}';
      }

      // Usar fromBytes en lugar de fromPath
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      );
      request.files.add(multipartFile);

      if (kDebugMode) {
        print('UPLOAD Photo Bytes - Presentation ID: $id');
        print('Filename: $filename');
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('UPLOAD Photo - Status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
          if (jsonResponse is Map && jsonResponse.containsKey('dishPhotoUrl')) {
            return jsonResponse['dishPhotoUrl'];
          }
          return jsonResponse.toString();
        } catch (e) {
          return utf8.decode(response.bodyBytes);
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException('Presentación no encontrada');
      } else if (response.statusCode == 403) {
        throw Exception('No tiene permisos para subir fotos');
      } else if (response.statusCode == 400) {
        throw Exception('Archivo inválido o formato no soportado');
      }

      throw Exception('Error al subir foto: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('Error en uploadPhotoBytes: $e');
      rethrow;
    }
  }

  static String getPhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) {
      return '';
    }

    // Si ya viene con http, retornar tal cual
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return photoPath;
    }

    // Si solo viene el nombre del archivo "dish_1.png"
    if (!photoPath.contains('/')) {
      photoPath = '/uploads/dishes/$photoPath';
    }

    // Si viene "uploads/dishes/xxx.png"
    if (!photoPath.startsWith('/')) {
      photoPath = '/$photoPath';
    }

    return '${Environment.apiUrl}$photoPath';
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

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() => message;
}
