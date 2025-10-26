// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'token_manager.dart';

const String _BASE_URL = 'http://localhost:8080';

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);

  @override
  String toString() => 'ConflictException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  
  @override
  String toString() => 'NotFoundException: $message';
}

class LoginResponse {
  final bool success;
  final String? token;
  final String? role;
  final List<String>? authorities;
  final String? message;

  LoginResponse({
    required this.success,
    this.token,
    this.role,
    this.authorities,
    this.message,
  });
}

Map<String, dynamic> _decodeJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('Token JWT inválido.');
  }
  final payload = parts[1];

  String normalizedPayload = payload.replaceAll('-', '+').replaceAll('_', '/');
  switch (normalizedPayload.length % 4) {
    case 2:
      normalizedPayload += '==';
      break;
    case 3:
      normalizedPayload += '=';
      break;
  }

  try {
    return jsonDecode(utf8.decode(base64.decode(normalizedPayload)));
  } catch (e) {
    throw Exception('Fallo al decodificar el payload del JWT.');
  }
}

class AuthService {
  final String _authUrl = '$_BASE_URL/api/auth/login'; 

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_authUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final jsonBody = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : null;

      if (response.statusCode == 200) {
        final token = jsonBody['token'] as String?;

        if (token == null) {
          return LoginResponse(
              success: false, message: 'Respuesta de login incompleta: falta token.');
        }

        final payload = _decodeJwt(token);
        final role = payload['role'] as String? ?? 'USER';
        
        // FIX: Manejar authorities faltantes
        List<String> authorities = [];
        if (payload['authorities'] != null) {
          if (payload['authorities'] is List) {
            authorities = List<String>.from(payload['authorities']);
          }
        } else {
          authorities = [role];
          if (kDebugMode) {
            print('⚠️  Token sin authorities, usando role como authority: $role');
          }
        }

        // ✅ Usar el TokenManager centralizado
        TokenManager.setToken(token, role, authorities: authorities);

        return LoginResponse(
          success: true,
          token: token,
          role: role,
          authorities: authorities,
        );
      } else {
        final errorMessage = jsonBody?['message'] ?? jsonBody?['error'] ?? 'Credenciales inválidas.';
        return LoginResponse(success: false, message: errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error de Login: $e');
      }
      return LoginResponse(
          success: false, message: 'Error de conexión o fallo en el servidor.');
    }
  }
}