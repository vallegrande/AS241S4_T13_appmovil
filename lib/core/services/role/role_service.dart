import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/role/role_model.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';

class RoleService {
  final String baseUrl = "${Environment.apiUrl}/v1/api/roles";

  Map<String, String> _getHeaders() {
    final token = AuthService.token;
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<List<Role>> getAllRoles() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _getHeaders(),
      );

      if (kDebugMode) {
        print(' GET Roles - Status: ${response.statusCode}');
        print(' Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Role.fromJson(json)).toList();
      } else {
        throw Exception("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) print(' Error en getAllRoles: $e');
      rethrow;
    }
  }

  Future<Role> getRoleById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(),
      );

      if (kDebugMode) {
        print(' GET Role $id - Status: ${response.statusCode}');
        print(' Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return Role.fromJson(json.decode(response.body));
      } else {
        throw Exception("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) print(' Error en getRoleById: $e');
      rethrow;
    }
  }

  Future<void> createRole(Role role) async {
    try {
      final body = json.encode(role.toJson());

      if (kDebugMode) {
        print(' POST Role');
        print(' URL: $baseUrl');
        print(' Headers: ${_getHeaders()}');
        print(' Body: $body');
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _getHeaders(),
        body: body,
      );

      if (kDebugMode) {
        print(' Response Status: ${response.statusCode}');
        print(' Response Body: ${response.body}');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody =
            response.body.isNotEmpty ? response.body : 'Sin mensaje de error';
        throw Exception("Error ${response.statusCode}: $errorBody");
      }
    } catch (e) {
      if (kDebugMode) print(' Error en createRole: $e');
      rethrow;
    }
  }

  Future<void> updateRole(Role role) async {
    try {
      final body = json.encode(role.toJson());

      if (kDebugMode) {
        print(' PUT Role ${role.id}');
        print(' URL: $baseUrl/${role.id}');
        print(' Body: $body');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/${role.id}'),
        headers: _getHeaders(),
        body: body,
      );

      if (kDebugMode) {
        print(' Response Status: ${response.statusCode}');
        print(' Response Body: ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorBody =
            response.body.isNotEmpty ? response.body : 'Sin mensaje de error';
        throw Exception("Error ${response.statusCode}: $errorBody");
      }
    } catch (e) {
      if (kDebugMode) print(' Error en updateRole: $e');
      rethrow;
    }
  }

  Future<void> deleteRole(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(),
      );

      if (kDebugMode) {
        print(' DELETE Role $id - Status: ${response.statusCode}');
        print(' Response: ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorBody =
            response.body.isNotEmpty ? response.body : 'Sin mensaje de error';
        throw Exception("Error ${response.statusCode}: $errorBody");
      }
    } catch (e) {
      if (kDebugMode) print(' Error en deleteRole: $e');
      rethrow;
    }
  }
}
