import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/users/user_model.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';

class UserService {
  final String baseUrl = "${Environment.apiUrl}/v1/api/users";

  Map<String, String> _getHeaders() {
    final token = AuthService.token;
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<List<User>> getAllUsers() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => User.fromJson(item)).toList();
    } else {
      throw Exception("Error al obtener los usuarios (${response.statusCode})");
    }
  }

  Future<User> getUserById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al obtener el usuario con ID $id");
    }
  }

  Future<List<User>> getUsersByState(bool state) async {
    final response = await http.get(
      Uri.parse('$baseUrl/state/$state'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => User.fromJson(item)).toList();
    } else {
      throw Exception(
          "Error al obtener usuarios por estado (${response.statusCode})");
    }
  }

  Future<void> createUser(User user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _getHeaders(),
      body: json.encode(user.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Error al crear el usuario (${response.statusCode})");
    }
  }

  Future<void> updateUser(User user) async {
    if (user.idUser == null) {
      throw Exception("El ID del usuario no puede ser nulo para actualizarlo");
    }

    final token = AuthService.token;
    if (kDebugMode) {
      print(
          'Token usado para PUT: ${token == null ? "NULO/AUSENTE" : "Token presente"}');
    }
    final response = await http.put(
      Uri.parse('$baseUrl/${user.idUser}'),
      headers: _getHeaders(),
      body: json.encode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Error al actualizar el usuario (${response.statusCode})");
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/delete/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Error al desactivar el usuario (${response.statusCode})");
    }
  }

  Future<void> restoreUser(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/restore/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al restaurar el usuario (${response.statusCode})");
    }
  }

  Future<String?> uploadUserPhoto(int userId, File imageFile) async {
    final uri = Uri.parse('$baseUrl/$userId/upload-photo');
    final request = http.MultipartRequest('POST', uri);

    final token = AuthService.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final fileStream = http.ByteStream(imageFile.openRead());
    final fileLength = await imageFile.length();

    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      fileLength,
      filename: imageFile.path.split(Platform.pathSeparator).last,
    );

    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception(
          "Error al subir la foto (status: ${response.statusCode}): ${response.body}");
    }
  }

  Future<String?> uploadUserPhotoWeb(int userId, Uint8List imageBytes) async {
    final uri = Uri.parse('$baseUrl/$userId/upload-photo');
    final request = http.MultipartRequest('POST', uri);

    final token = AuthService.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: 'profile_$userId.jpg',
    );

    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception(
          "Error al subir la foto (status: ${response.statusCode}): ${response.body}");
    }
  }

  Future<int?> getLatestUserId() async {
    try {
      final users = await getAllUsers();
      if (users.isEmpty) return null;
      return users
          .map((u) => u.idUser)
          .reduce((a, b) => (a ?? 0) > (b ?? 0) ? a : b);
    } catch (e) {
      if (kDebugMode) print('Error obteniendo último usuario: $e');
      return null;
    }
  }

  Future<double> getActivePercentage() async {
    final response = await http.get(
      Uri.parse('$baseUrl/active-percentage'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['percentage'] ?? 0.0).toDouble();
    } else {
      throw Exception("Error al obtener porcentaje de activos");
    }
  }
}
