// Archivo: lib/services/role_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
// Importamos clases auxiliares (TokenManager, Role, Exceptions)
import 'user_service.dart'; 
import 'auth_service.dart'; // Solo para TokenManager.getAuthHeaders

const String _BASE_URL = 'http://localhost:8080';

class RoleService {
  final UserService _userService = UserService();
  
  Future<List<Role>> getRoles() async => _userService.getRoles();
  Future<Role> saveRole(Role role) async => _userService.saveRole(role);
  Future<void> deleteRole(int id) async => _userService.deleteRole(id);
}