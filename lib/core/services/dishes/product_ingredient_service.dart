import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/dishes/product_ingredient.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';
import 'package:flutter/foundation.dart';

class ProductIngredientService {
  static final String _baseUrl =
      '${Environment.apiUrl}/v1/api/product-ingredients';

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

  static Future<ProductIngredient> create(
      ProductIngredient productIngredient) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getAuthHeaders(),
        body: jsonEncode(productIngredient.toJson()),
      );

      if (kDebugMode) {
        print('CREATE Product-Ingredient - Status: ${response.statusCode}');
        print('Body enviado: ${jsonEncode(productIngredient.toJson())}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ProductIngredient.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 403) {
        throw Exception(
            'No tiene permisos para crear relaciones producto-ingrediente');
      }

      throw Exception('Error al crear relación: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) print('Error en create: $e');
      rethrow;
    }
  }

  static Future<List<ProductIngredient>> getIngredientsByProduct(
      int idProduct) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/product/$idProduct'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('GET Ingredients by Product - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList
            .map((json) => ProductIngredient.fromJson(json))
            .toList();
      } else if (response.statusCode == 404) {
        return []; // No hay ingredientes asociados
      } else if (response.statusCode == 403) {
        throw Exception(
            'No tiene permisos para ver los ingredientes del producto');
      }

      return [];
    } catch (e) {
      if (kDebugMode) print('Error en getIngredientsByProduct: $e');
      return [];
    }
  }

  static Future<List<ProductIngredient>> getProductsByIngredient(
      int idIngredient) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ingredient/$idIngredient'),
        headers: _getAuthHeaders(),
      );

      if (kDebugMode) {
        print('GET Products by Ingredient - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList
            .map((json) => ProductIngredient.fromJson(json))
            .toList();
      } else if (response.statusCode == 404) {
        return []; // No hay productos asociados
      } else if (response.statusCode == 403) {
        throw Exception(
            'No tiene permisos para ver los productos del ingrediente');
      }

      return [];
    } catch (e) {
      if (kDebugMode) print('Error en getProductsByIngredient: $e');
      return [];
    }
  }

  static Future<void> delete(int idProduct, int idIngredient) async {
    try {
      final body = {
        'idProduct': idProduct,
        'idIngredient': idIngredient,
      };

      final response = await http.delete(
        Uri.parse(_baseUrl),
        headers: _getAuthHeaders(),
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print('DELETE Product-Ingredient - Status: ${response.statusCode}');
        print('Body enviado: ${jsonEncode(body)}');
      }

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para eliminar relaciones');
        }
        throw Exception('Error al eliminar relación: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error en delete: $e');
      rethrow;
    }
  }

  static Future<void> deleteByIds(ProductIngredientId ids) async {
    try {
      final response = await http.delete(
        Uri.parse(_baseUrl),
        headers: _getAuthHeaders(),
        body: jsonEncode(ids.toJson()),
      );

      if (kDebugMode) {
        print(
            'DELETE Product-Ingredient (ByIds) - Status: ${response.statusCode}');
      }

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 403) {
          throw Exception('No tiene permisos para eliminar relaciones');
        }
        throw Exception('Error al eliminar relación: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error en deleteByIds: $e');
      rethrow;
    }
  }
}
