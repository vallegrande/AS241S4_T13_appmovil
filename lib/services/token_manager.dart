// lib/services/token_manager.dart
import 'package:flutter/foundation.dart';

class TokenManager {
  static String? _jwtToken;
  static String? _userRole;
  static List<String>? _userAuthorities;

  static void setToken(String token, String role, {List<String>? authorities}) {
    _jwtToken = token;
    _userRole = role;
    _userAuthorities = authorities ?? [role];
    
    if (kDebugMode) {
      print('✅ TokenManager - Token almacenado: ${_jwtToken?.length} caracteres');
      print('✅ TokenManager - Rol del usuario: $_userRole');
      print('✅ TokenManager - Authorities del usuario: $_userAuthorities');
    }
  }

  static void clear() {
    _jwtToken = null;
    _userRole = null;
    _userAuthorities = null;
    if (kDebugMode) {
      print('✅ TokenManager - Token limpiado');
    }
  }

  static String? getToken() {
    if (kDebugMode) {
      print('🔍 TokenManager - getToken(): ${_jwtToken != null ? "EXISTE" : "NULL"}');
    }
    return _jwtToken;
  }

  static String? getUserRole() => _userRole;
  static List<String>? getUserAuthorities() => _userAuthorities;

  static Map<String, String> getAuthHeaders({bool isJson = true}) {
    final headers = <String, String>{};
    
    final token = getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      if (kDebugMode) {
        print('🔐 TokenManager - Authorization Header agregado: Bearer ${token.substring(0, 50)}...');
      }
    } else {
      if (kDebugMode) {
        print('❌ TokenManager - ERROR: No hay token disponible para Authorization header');
        print('❌ TokenManager - _jwtToken es null');
      }
    }
    
    if (isJson) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    
    if (kDebugMode) {
      print('📤 TokenManager - Headers que se enviarán:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          print('   $key: Bearer ${value.length > 50 ? value.substring(0, 50) + '...' : value}');
        } else {
          print('   $key: $value');
        }
      });
    }
    
    return headers;
  }
}