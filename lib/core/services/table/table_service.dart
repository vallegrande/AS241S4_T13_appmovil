// lib/core/services/tables/table_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/table/table_model.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';

class TableService {
  final String baseUrl = "${Environment.apiUrl}/v1/api/mesas";

  Map<String, String> _getHeaders() {
    final token = AuthService.token;
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Obtener todas las mesas
  Future<List<TableModel>> getAllTables() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => TableModel.fromJson(item)).toList();
    } else {
      throw Exception("Error al obtener las mesas (${response.statusCode})");
    }
  }

  // Obtener mesa por ID
  Future<TableModel> getTableById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return TableModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al obtener la mesa con ID $id");
    }
  }

  // Obtener mesas por estado (activas/inactivas)
  Future<List<TableModel>> getTablesByState(bool state) async {
    final response = await http.get(
      Uri.parse('$baseUrl/estado/$state'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => TableModel.fromJson(item)).toList();
    } else {
      throw Exception(
          "Error al obtener mesas por estado (${response.statusCode})");
    }
  }

  // Crear mesa
  Future<TableModel> createTable(TableModel table) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _getHeaders(),
      body: json.encode(table.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return TableModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al crear la mesa (${response.statusCode})");
    }
  }

  // Actualizar mesa
  Future<TableModel> updateTable(int id, TableModel table) async {
    if (kDebugMode) {
      print('📄 Actualizando mesa ID: $id');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: _getHeaders(),
      body: json.encode(table.toJson()),
    );

    if (response.statusCode == 200) {
      return TableModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al actualizar la mesa (${response.statusCode})");
    }
  }

  // Eliminar mesa (soft delete)
  Future<void> deleteTable(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Error al eliminar la mesa (${response.statusCode})");
    }
  }

  // Restaurar mesa
  Future<void> restoreTable(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/restaurar/$id'),
      headers: _getHeaders(),
      body: json.encode({}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al restaurar la mesa (${response.statusCode})");
    }
  }

  // Obtener porcentaje de ocupación
  Future<Map<String, dynamic>> getOccupancyPercentage() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ocupacion'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          "Error al obtener el porcentaje de ocupación (${response.statusCode})");
    }
  }

  // Obtener reporte completo de ocupación
  Future<OccupancyReport> getOccupancyReport() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ocupacion'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return OccupancyReport.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          "Error al obtener el reporte de ocupación (${response.statusCode})");
    }
  }

  // Actualizar ocupación de una mesa
  Future<TableModel> updateOccupation(int id, bool isOccupied) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/ocupacion?isOccupied=$isOccupied'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return TableModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          "Error al actualizar ocupación de la mesa (${response.statusCode})");
    }
  }

  // Obtener último ID de mesa (útil después de crear)
  Future<int?> getLatestTableId() async {
    try {
      final tables = await getAllTables();
      if (tables.isEmpty) return null;
      return tables
          .map((t) => t.idTable)
          .reduce((a, b) => (a ?? 0) > (b ?? 0) ? a : b);
    } catch (e) {
      if (kDebugMode) print('Error obteniendo última mesa: $e');
      return null;
    }
  }
}
