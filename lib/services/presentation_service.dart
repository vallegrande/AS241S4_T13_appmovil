// Archivo: lib/services/presentation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/presentation.dart';
import 'auth_service.dart'; // Importa TokenManager y excepciones

const String _BASE_URL = 'http://localhost:8080';

class PresentationService {
  final String _baseUrl = '$_BASE_URL/v1/api/presentations';

  Future<List<Presentation>> getAll() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/all'),
      headers: TokenManager.getAuthHeaders(), // <-- Usa el token
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Presentation.fromJson(json)).toList();
    }
    throw Exception('Failed to load presentations: ${response.statusCode}');
  }

  Future<Presentation> getById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$id'),
      headers: TokenManager.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return Presentation.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 404) {
      throw NotFoundException('Presentation not found');
    }
    throw Exception('Failed to load presentation: ${response.statusCode}');
  }

  Future<Presentation> create(Presentation presentation) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: TokenManager.getAuthHeaders(),
      body: jsonEncode(presentation.toJson()),
    );

    if (response.statusCode == 201) {
      return Presentation.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Failed to create presentation: ${response.statusCode}');
  }

  Future<Presentation> update(int id, Presentation presentation) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: TokenManager.getAuthHeaders(),
      body: jsonEncode(presentation.toJson()),
    );

    if (response.statusCode == 200) {
      return Presentation.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 404) {
      throw NotFoundException('Presentation not found');
    }
    throw Exception('Failed to update presentation: ${response.statusCode}');
  }

  Future<void> disable(int id) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/disable/$id'),
      headers: TokenManager.getAuthHeaders(isJson: false),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to disable presentation: ${response.statusCode}');
    }
  }

  Future<void> restore(int id) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/restore/$id'),
      headers: TokenManager.getAuthHeaders(isJson: false),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to restore presentation: ${response.statusCode}');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: TokenManager.getAuthHeaders(isJson: false),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete presentation: ${response.statusCode}');
    }
  }

  Future<List<Presentation>> getByProductId(int idProduct) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/product/$idProduct'),
      headers: TokenManager.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Presentation.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return [];
    }
    throw Exception('Failed to load presentations by product: ${response.statusCode}');
  }
}