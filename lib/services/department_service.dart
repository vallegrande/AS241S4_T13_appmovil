// Archivo: lib/services/department_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
// Importamos clases auxiliares (TokenManager, Department, Exceptions)
import 'user_service.dart'; 
import 'auth_service.dart'; // Solo para TokenManager.getAuthHeaders

const String _BASE_URL = 'http://localhost:8080';

class DepartmentService {
  final UserService _userService = UserService();
  
  Future<List<Department>> getDepartments() async => _userService.getDepartments();
  Future<Department> saveDepartment(Department department) async => _userService.saveDepartment(department);
  Future<void> deleteDepartment(int id) async => _userService.deleteDepartment(id);
}