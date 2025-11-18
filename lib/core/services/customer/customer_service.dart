// lib/core/services/customers/customer_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/customer/customer_model.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';

class CustomerService {
  final String baseUrl = "${Environment.apiUrl}/v1/api/customers";

  Map<String, String> _getHeaders() {
    final token = AuthService.token;
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Obtener todos los clientes
  Future<List<Customer>> getAllCustomers() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Customer.fromJson(item)).toList();
    } else {
      throw Exception("Error al obtener los clientes (${response.statusCode})");
    }
  }

  // Obtener cliente por ID
  Future<Customer> getCustomerById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Customer.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al obtener el cliente con ID $id");
    }
  }

  // Obtener clientes por estado
  Future<List<Customer>> getCustomersByState(int state) async {
    final response = await http.get(
      Uri.parse('$baseUrl/state/$state'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Customer.fromJson(item)).toList();
    } else {
      throw Exception(
          "Error al obtener clientes por estado (${response.statusCode})");
    }
  }

  // Obtener cliente por documento
  Future<Customer> getCustomerByDocument(String documentNumber) async {
    final response = await http.get(
      Uri.parse('$baseUrl/document/$documentNumber'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Customer.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al obtener cliente por documento");
    }
  }

  // Buscar clientes
  Future<List<Customer>> searchCustomers(String query, {int? state}) async {
    var uri = Uri.parse('$baseUrl/search');

    final queryParams = {'query': query};
    if (state != null) {
      queryParams['state'] = state.toString();
    }

    uri = uri.replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Customer.fromJson(item)).toList();
    } else {
      throw Exception("Error al buscar clientes (${response.statusCode})");
    }
  }

  // Obtener clientes por tipo
  Future<List<Customer>> getCustomersByType(String type, {int? state}) async {
    var uri = Uri.parse('$baseUrl/type/$type');

    if (state != null) {
      uri = uri.replace(queryParameters: {'state': state.toString()});
    }

    final response = await http.get(
      uri,
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Customer.fromJson(item)).toList();
    } else {
      throw Exception(
          "Error al obtener clientes por tipo (${response.statusCode})");
    }
  }

  // Crear cliente
  Future<Customer> createCustomer(Customer customer) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _getHeaders(),
      body: json.encode(customer.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Customer.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al crear el cliente (${response.statusCode})");
    }
  }

  // Actualizar cliente
  Future<Customer> updateCustomer(int id, Customer customer) async {
    if (kDebugMode) {
      print('🔄 Actualizando cliente ID: $id');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: _getHeaders(),
      body: json.encode(customer.toJson()),
    );

    if (response.statusCode == 200) {
      return Customer.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          "Error al actualizar el cliente (${response.statusCode})");
    }
  }

  // Desactivar cliente (soft delete)
  Future<void> deleteCustomer(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/delete'),
      headers: _getHeaders(),
      body: json.encode({}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Error al desactivar el cliente (${response.statusCode})");
    }
  }

  // Restaurar cliente
  Future<void> restoreCustomer(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/restore'),
      headers: _getHeaders(),
      body: json.encode({}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al restaurar el cliente (${response.statusCode})");
    }
  }

  // Obtener último ID de cliente (útil después de crear)
  Future<int?> getLatestCustomerId() async {
    try {
      final customers = await getAllCustomers();
      if (customers.isEmpty) return null;
      return customers
          .map((c) => c.idCustomer)
          .reduce((a, b) => (a ?? 0) > (b ?? 0) ? a : b);
    } catch (e) {
      if (kDebugMode) print('Error obteniendo último cliente: $e');
      return null;
    }
  }
}
