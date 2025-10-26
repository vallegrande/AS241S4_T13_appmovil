// Archivo: lib/services/ingredient_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/ingredient.dart';
import 'auth_service.dart'; // Importa TokenManager y excepciones

const String _BASE_URL = 'http://localhost:8080';

class IngredientService {
  final String _baseUrl = '$_BASE_URL/v1/api/supplies';

  Future<Ingredient> create(Ingredient ingredient) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: TokenManager.getAuthHeaders(),
      body: jsonEncode(ingredient.toJson()),
    );

    if (response.statusCode == 201) {
      return Ingredient.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Failed to create ingredient: ${response.statusCode}');
  }

  Future<List<Ingredient>> getAllActive() async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: TokenManager.getAuthHeaders(), // <-- Usa el token
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Ingredient.fromJson(json)).toList();
    }
    throw Exception('Failed to load active ingredients: ${response.statusCode}');
  }

  Future<List<Ingredient>> getExpiringSoonAlerts(int days) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/alerts/expiring-soon/$days'),
      headers: TokenManager.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Ingredient.fromJson(json)).toList();
    }
    throw Exception('Failed to load expiring ingredients: ${response.statusCode}');
  }

  Future<List<Ingredient>> getLowStockAlerts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/alerts/low-stock'),
      headers: TokenManager.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Ingredient.fromJson(json)).toList();
    }
    throw Exception('Failed to load low stock alerts: ${response.statusCode}');
  }

  Future<List<Ingredient>> getExpiredAlerts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/alerts/expired'),
      headers: TokenManager.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Ingredient.fromJson(json)).toList();
    }
    throw Exception('Failed to load expired alerts: ${response.statusCode}');
  }

  Future<List<Ingredient>> getAll() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/all'),
      headers: TokenManager.getAuthHeaders(), // <-- Usa el token
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Ingredient.fromJson(json)).toList();
    }
    throw Exception('Failed to load all ingredients: ${response.statusCode}');
  }

  Future<Ingredient> getById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$id'),
      headers: TokenManager.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return Ingredient.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 404) {
      throw NotFoundException('Ingredient not found');
    }
    throw Exception('Failed to load ingredient: ${response.statusCode}');
  }

  Future<Ingredient> update(int id, Ingredient ingredient) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: TokenManager.getAuthHeaders(),
      body: jsonEncode(ingredient.toJson()),
    );

    if (response.statusCode == 200) {
      return Ingredient.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 404) {
      throw NotFoundException('Ingredient not found');
    }
    throw Exception('Failed to update ingredient: ${response.statusCode}');
  }

  Future<void> disable(int id) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/disable/$id'),
      headers: TokenManager.getAuthHeaders(isJson: false),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to disable ingredient: ${response.statusCode}');
    }
  }

  Future<void> restore(int id) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/restore/$id'),
      headers: TokenManager.getAuthHeaders(isJson: false),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to restore ingredient: ${response.statusCode}');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: TokenManager.getAuthHeaders(isJson: false),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete ingredient: ${response.statusCode}');
    }
  }
}