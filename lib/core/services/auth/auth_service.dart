import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:as241s4_t13_appmovil/config/environment.dart';

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

class AuthService {
  static String? _token;
  static String? _role;
  static List<String> _authorities = [];

  static String? get token => _token;
  static String? get role => _role;
  static List<String> get authorities => _authorities;

  static void _setContext(String token, String role,
      {List<String> authorities = const []}) {
    _token = token;
    _role = role;
    _authorities = authorities;
    if (kDebugMode) {
      print('Token almacenado');
      print('Role: $_role');
      print('Authorities: $_authorities');
    }
  }

  static void clearContext() {
    _token = null;
    _role = null;
    _authorities = [];
    if (kDebugMode) print('Autenticación limpiada (Logout).');
  }

  final String _loginUrl = "${Environment.apiUrl}/api/auth/login";

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(_loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final Map<String, dynamic>? jsonBody = _tryDecodeJson(response.body);

    try {
      if (response.statusCode == 200) {
        final token = jsonBody?['token'] as String?;

        if (token == null) {
          return LoginResponse(
              success: false,
              message: 'Respuesta de login incompleta: falta token.');
        }

        final payload = _decodeJwt(token);
        final role = (payload['role'] as String?)?.toUpperCase() ?? 'USER';

        List<String> authorities = [];

        if (payload.containsKey('authorities') &&
            payload['authorities'] is List) {
          authorities = List<String>.from(payload['authorities']);
          if (kDebugMode)
            print('Authorities obtenidas del token: $authorities');
        } else {
          authorities = ['ROLE_$role'];
          if (kDebugMode) {
            print('Token sin authorities, creando authority: ROLE_$role');
          }
        }

        AuthService._setContext(token, role, authorities: authorities);

        return LoginResponse(
          success: true,
          token: token,
          role: role,
          authorities: authorities,
        );
      } else {
        final errorMessage = jsonBody?['message'] ??
            jsonBody?['error'] ??
            'Credenciales inválidas.';
        return LoginResponse(success: false, message: errorMessage);
      }
    } catch (e) {
      if (kDebugMode) print('Error de Login: $e');
      return LoginResponse(
          success: false, message: 'Error de conexión o token inválido.');
    }
  }

  Map<String, dynamic>? _tryDecodeJson(String body) {
    try {
      return json.decode(body) as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Error decodificando JSON: $e');
      return null;
    }
  }
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

  final decodedPayload =
      json.decode(utf8.decode(base64Url.decode(normalizedPayload)));

  if (kDebugMode) {
    print('JWT Payload decodificado:');
    print(const JsonEncoder.withIndent('  ').convert(decodedPayload));
  }

  return decodedPayload;
}
