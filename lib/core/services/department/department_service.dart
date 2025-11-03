import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/department/department_model.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';

class DepartmentService {
  final String baseUrl = "${Environment.apiUrl}/v1/api/departments";

  Map<String, String> _getHeaders() {
    final token = AuthService.token;
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<List<Department>> getAllDepartments() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _getHeaders(),
      );

      if (kDebugMode) {
        print('📥 GET Departments - Status: ${response.statusCode}');
        print('📥 Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Department.fromJson(json)).toList();
      } else {
        throw Exception("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) print('Error en getAllDepartments: $e');
      rethrow;
    }
  }

  Future<Department> getDepartmentById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(),
      );

      if (kDebugMode) {
        print('GET Department $id - Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return Department.fromJson(json.decode(response.body));
      } else {
        throw Exception("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) print('Error en getDepartmentById: $e');
      rethrow;
    }
  }

  Future<void> createDepartment(Department department) async {
    try {
      final body = json.encode(department.toJson());

      if (kDebugMode) {
        print('POST Department');
        print('URL: $baseUrl');
        print('Headers: ${_getHeaders()}');
        print('Body: $body');
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _getHeaders(),
        body: body,
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody =
            response.body.isNotEmpty ? response.body : 'Sin mensaje de error';
        throw Exception("Error ${response.statusCode}: $errorBody");
      }
    } catch (e) {
      if (kDebugMode) print('Error en createDepartment: $e');
      rethrow;
    }
  }

  Future<void> updateDepartment(Department department) async {
    try {
      final body = json.encode(department.toJson());

      if (kDebugMode) {
        print('PUT Department ${department.id}');
        print('URL: $baseUrl/${department.id}');
        print('Body: $body');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/${department.id}'),
        headers: _getHeaders(),
        body: body,
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorBody =
            response.body.isNotEmpty ? response.body : 'Sin mensaje de error';
        throw Exception("Error ${response.statusCode}: $errorBody");
      }
    } catch (e) {
      if (kDebugMode) print('Error en updateDepartment: $e');
      rethrow;
    }
  }

  Future<void> deleteDepartment(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(),
      );

      if (kDebugMode) {
        print('DELETE Department $id - Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorBody =
            response.body.isNotEmpty ? response.body : 'Sin mensaje de error';
        throw Exception("Error ${response.statusCode}: $errorBody");
      }
    } catch (e) {
      if (kDebugMode) print('Error en deleteDepartment: $e');
      rethrow;
    }
  }
}
