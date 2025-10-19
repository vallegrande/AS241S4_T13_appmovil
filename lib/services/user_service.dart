import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'package:http/http.dart' show MultipartFile;

const String _BASE_URL = 'http://localhost:8080';
const String _CONTENT_TYPE_JSON = 'application/json; charset=UTF-8';

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

class TokenManager {
  static String? _jwtToken;
  static String? _userRole;

  static void setToken(String token, String role) {
    _jwtToken = token;
    _userRole = role;
    if (kDebugMode) {
      print('Token almacenado: $_jwtToken');
      print('Rol del usuario: $_userRole');
    }
  }

  static void clear() {
    _jwtToken = null;
    _userRole = null;
  }

  static String? getToken() => _jwtToken;
  static String? getUserRole() => _userRole;

  static Map<String, String> getAuthHeaders({bool isJson = true}) {
    final headers = <String, String>{};
    if (_jwtToken != null) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    if (isJson) {
      headers['Content-Type'] = _CONTENT_TYPE_JSON;
    }
    return headers;
  }
}

class Role {
  final int? id;
  final String name;

  Role({this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
      };
}

class Department {
  final int? id;
  final String name;

  Department({this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
      };
}

class LoginResponse {
  final bool success;
  final String? token;
  final String? role;
  final String? message;

  LoginResponse({
    required this.success,
    this.token,
    this.role,
    this.message,
  });
}

class User {
  final int? idUser;
  final String documentType;
  final String documentNumber;
  final String name;
  final String surnames;
  final String email;
  final String? password;
  final Role role;
  final Department department;
  final String? phone;
  final String? adress;
  final String? gender;
  final String? profilePhoto;
  final bool state;
  final String? registrationDate;
  final String? horaInicio;
  final String? horaFin;
  final int? plannedHours;
  final String? turno;
  final double? hourlyRate;

  User({
    this.idUser,
    required this.documentType,
    required this.documentNumber,
    required this.name,
    required this.surnames,
    required this.email,
    this.password,
    required this.role,
    required this.department,
    this.phone,
    this.adress,
    this.gender,
    this.profilePhoto,
    required this.state,
    this.registrationDate,
    this.horaInicio,
    this.horaFin,
    this.plannedHours,
    this.turno,
    this.hourlyRate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        idUser: json['idUser'] as int?,
        documentType: json['documentType'] as String? ?? '',
        documentNumber: json['documentNumber'] as String? ?? '',
        name: json['name'] as String? ?? '',
        surnames: json['surnames'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] != null
            ? Role.fromJson(json['role'] as Map<String, dynamic>)
            : Role(id: null, name: ''),
        department: json['department'] != null
            ? Department.fromJson(json['department'] as Map<String, dynamic>)
            : Department(id: null, name: ''),
        phone: json['phone'] as String?,
        adress: json['adress'] as String?,
        gender: json['gender'] as String?,
        profilePhoto: json['profilePhoto'] as String?,
        state: json['state'] as bool? ?? true,
        registrationDate: json['registrationDate'] as String?,
        horaInicio: json['horaInicio'] as String?,
        horaFin: json['horaFin'] as String?,
        plannedHours: json['plannedHours'] as int?,
        turno: json['turno'] as String?,
        hourlyRate: json['hourlyRate'] != null
            ? (json['hourlyRate'] as num).toDouble()
            : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al parsear User.fromJson: $e');
        print('JSON recibido: $json');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        if (idUser != null) 'idUser': idUser,
        'documentType': documentType,
        'documentNumber': documentNumber,
        'name': name,
        'surnames': surnames,
        'email': email,
        if (password != null) 'password': password, 
        'role': {'id': role.id}, 
        'department': {'id': department.id},
        'phone': phone,
        'adress': adress,
        'gender': gender,
        'profilePhoto': profilePhoto, 
        'state': state,
        'registrationDate': registrationDate,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'plannedHours': plannedHours,
        'turno': turno,
        'hourlyRate': hourlyRate,
      };
}

class DniData {
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  
  DniData({
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
  });
  
  factory DniData.fromJson(Map<String, dynamic> json) {
    return DniData(
      nombres: json['nombres'] as String,
      apellidoPaterno: json['apellidoPaterno'] as String,
      apellidoMaterno: json['apellidoMaterno'] as String,
    );
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
        headers: {'Content-Type': _CONTENT_TYPE_JSON},
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

        TokenManager.setToken(token, role);

        return LoginResponse(
          success: true,
          token: token,
          role: role,
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

class UserService {
  final String _userUrl = '$_BASE_URL/v1/api/users';
  final String _roleUrl = '$_BASE_URL/v1/api/roles';
  final String _departmentUrl = '$_BASE_URL/v1/api/departments';
  final String _dniUrl = '$_BASE_URL/api/dni';

  Future<List<Role>> getRoles() async {
    final response = await http.get(
      Uri.parse(_roleUrl), 
      headers: TokenManager.getAuthHeaders(isJson: false)
    );
    if (response.statusCode == 200) {
      return (jsonDecode(utf8.decode(response.bodyBytes)) as List)
          .map((e) => Role.fromJson(e))
          .toList();
    }
    throw Exception('Fallo al obtener roles.');
  }

  Future<Role> saveRole(Role role) async {
    final bool isEditing = role.id != null;
    final uri = isEditing ? Uri.parse('$_roleUrl/${role.id}') : Uri.parse(_roleUrl);
    final response = isEditing
        ? await http.put(uri, headers: TokenManager.getAuthHeaders(), body: jsonEncode(role.toJson()))
        : await http.post(uri, headers: TokenManager.getAuthHeaders(), body: jsonEncode(role.toJson()));

    final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Role.fromJson(jsonBody);
    } else if (response.statusCode == 409) {
      throw ConflictException(jsonBody['error'] ?? 'Ya existe un Rol con ese nombre.');
    }
    throw Exception('Fallo al guardar el rol: ${jsonBody['message'] ?? response.statusCode}');
  }

  Future<void> deleteRole(int id) async {
    final response = await http.delete(
      Uri.parse('$_roleUrl/$id'), 
      headers: TokenManager.getAuthHeaders(isJson: false)
    );
    if (response.statusCode == 204 || response.statusCode == 200) return;

    final jsonBody = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes))
        : null;

    if (response.statusCode == 409) {
      throw ConflictException(jsonBody?['error'] ?? 'No se puede eliminar, el rol está asociado a usuarios.');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Rol no encontrado.');
    }
    throw Exception('Fallo al eliminar el rol: ${jsonBody?['message'] ?? response.statusCode}');
  }

  Future<List<Department>> getDepartments() async {
    final response = await http.get(
      Uri.parse(_departmentUrl), 
      headers: TokenManager.getAuthHeaders(isJson: false)
    );
    if (response.statusCode == 200) {
      return (jsonDecode(utf8.decode(response.bodyBytes)) as List)
          .map((e) => Department.fromJson(e))
          .toList();
    }
    throw Exception('Fallo al obtener departamentos.');
  }

  Future<Department> saveDepartment(Department department) async {
    final bool isEditing = department.id != null;
    final uri = isEditing 
        ? Uri.parse('$_departmentUrl/${department.id}') 
        : Uri.parse(_departmentUrl);
    final response = isEditing
        ? await http.put(uri, headers: TokenManager.getAuthHeaders(), body: jsonEncode(department.toJson()))
        : await http.post(uri, headers: TokenManager.getAuthHeaders(), body: jsonEncode(department.toJson()));

    final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Department.fromJson(jsonBody);
    } else if (response.statusCode == 409) {
      throw ConflictException(jsonBody['error'] ?? 'Ya existe un Departamento con ese nombre.');
    }
    throw Exception('Fallo al guardar el departamento: ${jsonBody['message'] ?? response.statusCode}');
  }

  Future<void> deleteDepartment(int id) async {
    final response = await http.delete(
      Uri.parse('$_departmentUrl/$id'),
      headers: TokenManager.getAuthHeaders(isJson: false)
    );

    if (response.statusCode == 204 || response.statusCode == 200) return;

    final jsonBody = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes))
        : null;

    if (response.statusCode == 409) {
      throw ConflictException(jsonBody?['error'] ?? 'No se puede eliminar, el departamento está asociado a usuarios.');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Departamento no encontrado.');
    }
    throw Exception('Fallo al eliminar el departamento: ${jsonBody?['message'] ?? response.statusCode}');
  }

  Future<List<User>> getUsers({int? id, bool? state}) async {
    Uri uri;
    if (id != null) {
      uri = Uri.parse('$_userUrl/$id');
    } else if (state != null) {
      uri = Uri.parse('$_userUrl/state/$state');
    } else {
      uri = Uri.parse(_userUrl);
    }

    final response = await http.get(
      uri, 
      headers: TokenManager.getAuthHeaders(isJson: false)
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
      if (id != null) {
        return [User.fromJson(jsonBody)];
      }
      return (jsonBody as List).map((e) => User.fromJson(e)).toList();
    } else if (response.statusCode == 404) {
      return [];
    }
    throw Exception('Fallo al obtener usuarios: ${response.statusCode}');
  }

  Future<User> saveUser(User user) async {
    try {
      final bool isEditing = user.idUser != null;
      final uri = isEditing 
          ? Uri.parse('$_userUrl/${user.idUser}')
          : Uri.parse(_userUrl);
      final body = jsonEncode(user.toJson());

      if (kDebugMode) {
        print('=== ENVIANDO REQUEST ===');
        print('URL: $uri');
        print('Método: ${isEditing ? "PUT" : "POST"}');
        print('Body: $body');
      }

      final response = isEditing
          ? await http.put(uri, headers: TokenManager.getAuthHeaders(), body: body)
          : await http.post(uri, headers: TokenManager.getAuthHeaders(), body: body);

      if (kDebugMode) {
        print('=== RESPUESTA RECIBIDA ===');
        print('Status Code: ${response.statusCode}');
        print('Headers: ${response.headers}');
        print('Body: ${response.body}');
      }

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw FormatException('La respuesta no es JSON. Content-Type: $contentType. Body: ${response.body}');
      }

      if (response.body.isEmpty) {
        throw FormatException('La respuesta está vacía');
      }

      final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return User.fromJson(jsonBody);
      } else if (response.statusCode == 409) {
        throw ConflictException(jsonBody['message'] ?? 'Conflicto: El email o número de documento ya existe.');
      }
      throw Exception('Fallo al guardar usuario: ${jsonBody['message'] ?? response.statusCode}');
    } catch (e) {
      if (kDebugMode) {
        print('=== ERROR EN SAVEUSER ===');
        print('Error: $e');
        print('Stack trace: ${StackTrace.current}');
      }
      rethrow;
    }
  }

  Future<void> softDeleteUser(int id) async {
    final response = await http.patch(
      Uri.parse('$_userUrl/delete/$id'), 
      headers: TokenManager.getAuthHeaders(isJson: false)
    );
    if (response.statusCode == 204 || response.statusCode == 200) return; 

    final jsonBody = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes))
        : null;
    throw Exception('Fallo al desactivar el usuario: ${jsonBody?['message'] ?? response.statusCode}');
  }


  Future<void> restoreUser(int id) async {
    final response = await http.patch(
      Uri.parse('$_userUrl/restore/$id'),
      headers: TokenManager.getAuthHeaders(isJson: false)
    );
    if (response.statusCode == 200) return;

    final jsonBody = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes))
        : null;
    throw Exception('Fallo al restaurar el usuario: ${jsonBody?['message'] ?? response.statusCode}');
  }

  Future<String> uploadProfilePhoto(int userId, File imageFile) async {
    final uri = Uri.parse('$_userUrl/$userId/upload-photo');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(TokenManager.getAuthHeaders(isJson: false));
    request.files.add(
      await MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonBody['profilePhotoUrl'] ?? 'Foto subida con éxito';
    } else {
      final jsonBody = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : null;
      throw Exception('Fallo al cargar la foto: ${jsonBody?['message'] ?? response.statusCode}');
    }
  }

  Future<String> uploadProfilePhotoWeb(int userId, Uint8List imageBytes, String fileName) async {
    final uri = Uri.parse('$_userUrl/$userId/upload-photo');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(TokenManager.getAuthHeaders(isJson: false));
    String contentType = 'image/jpeg';
    if (fileName.toLowerCase().endsWith('.png')) {
      contentType = 'image/png';
    } else if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
      contentType = 'image/jpeg';
    } else if (fileName.toLowerCase().endsWith('.gif')) {
      contentType = 'image/gif';
    } else if (fileName.toLowerCase().endsWith('.webp')) {
      contentType = 'image/webp';
    }
    request.files.add(
      MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
        contentType: MediaType.parse(contentType),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonBody['profilePhotoUrl'] ?? 'Foto subida con éxito';
    } else {
      final jsonBody = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : null;
      throw Exception('Fallo al cargar la foto: ${jsonBody?['message'] ?? response.statusCode}');
    }
  }

  Future<DniData> getDniData(String dniNumber) async {
    final uri = Uri.parse('$_dniUrl/$dniNumber');
    final response = await http.get(
      uri,
      headers: TokenManager.getAuthHeaders(isJson: false),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
      return DniData.fromJson(jsonBody);
    } else if (response.statusCode == 204) {
      throw NotFoundException('No se encontraron datos para el DNI proporcionado.');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Datos de DNI no encontrados.');
    }
    final jsonBody = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes))
        : null;
    throw Exception('Fallo al obtener datos de DNI: ${jsonBody?['message'] ?? response.statusCode}');
  }
}