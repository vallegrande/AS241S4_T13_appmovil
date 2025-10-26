// Archivo: lib/services/product_ingredient_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/product_ingredient.dart';
import 'auth_service.dart'; // Importa TokenManager y excepciones

const String _BASE_URL = 'http://localhost:8080';

class ProductIngredientService {
  final String _baseUrl = '$_BASE_URL/v1/api/product-ingredients';

  Future<ProductIngredient> create(ProductIngredient productIngredient) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: TokenManager.getAuthHeaders(),
      body: jsonEncode(productIngredient.toJson()),
    );

    if (response.statusCode == 201) {
      return ProductIngredient.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Failed to create product ingredient: ${response.statusCode}');
  }

  Future<List<ProductIngredient>> getIngredientsByProductId(int idProduct) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/product/$idProduct'),
        headers: TokenManager.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => ProductIngredient.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      }
      throw Exception('Failed to load product ingredients: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  Future<List<ProductIngredient>> getProductsByIngredientId(int idIngredient) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ingredient/$idIngredient'),
        headers: TokenManager.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => ProductIngredient.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      }
      throw Exception('Failed to load ingredient products: ${response.statusCode}');
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteAssociation(ProductIngredientId productIngredientId) async {
    final response = await http.delete(
      Uri.parse(_baseUrl),
      headers: TokenManager.getAuthHeaders(),
      body: jsonEncode(productIngredientId.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete association: ${response.statusCode}');
    }
  }

  Future<void> deleteProductIngredient(int idProduct, int idIngredient) async {
    final body = {
      'idProduct': idProduct,
      'idIngredient': idIngredient,
    };

    final response = await http.delete(
      Uri.parse(_baseUrl),
      headers: TokenManager.getAuthHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product ingredient: ${response.statusCode}');
    }
  }
}