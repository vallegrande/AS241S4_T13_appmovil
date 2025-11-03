import 'dart:convert';
import 'package:as241s4_t13_appmovil/core/models/role/role_model.dart';
import 'package:as241s4_t13_appmovil/core/models/department/department_model.dart';

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
  final bool? state;
  final DateTime? registrationDate;
  final String? horaInicio;
  final String? horaFin;
  final double? plannedHours;
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
    this.state,
    this.registrationDate,
    this.horaInicio,
    this.horaFin,
    this.plannedHours,
    this.turno,
    this.hourlyRate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['idUser'] ?? json['id_user'],
      documentType: json['documentType'] ?? '',
      documentNumber: json['documentNumber'] ?? '',
      name: json['name'] ?? '',
      surnames: json['surnames'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      role: json['role'] != null
          ? Role.fromJson(json['role'])
          : Role(id: 0, name: ''),
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : Department(id: 0, name: ''),
      phone: json['phone'],
      adress: json['adress'],
      gender: json['gender'],
      profilePhoto: json['profilePhoto'],
      state: json['state'],
      registrationDate: json['registrationDate'] != null
          ? DateTime.tryParse(json['registrationDate'])
          : null,
      horaInicio: json['horaInicio'],
      horaFin: json['horaFin'],
      plannedHours: (json['plannedHours'] != null)
          ? double.tryParse(json['plannedHours'].toString())
          : null,
      turno: json['turno'],
      hourlyRate: (json['hourlyRate'] != null)
          ? double.tryParse(json['hourlyRate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'documentType': documentType,
      'documentNumber': documentNumber,
      'name': name,
      'surnames': surnames,
      'email': email,
      'role': {'id': role.id},
      'department': {'id': department.id},
    };

    if (idUser != null) {
      data['idUser'] = idUser;
    }

    if (password != null) {
      data['password'] = password;
    }

    if (phone != null && phone!.isNotEmpty) data['phone'] = phone;
    if (adress != null && adress!.isNotEmpty) data['adress'] = adress;
    if (gender != null && gender!.isNotEmpty) data['gender'] = gender;
    if (profilePhoto != null) data['profilePhoto'] = profilePhoto;
    if (state != null) data['state'] = state;

    if (horaInicio != null && horaInicio!.isNotEmpty)
      data['horaInicio'] = horaInicio;
    if (horaFin != null && horaFin!.isNotEmpty) data['horaFin'] = horaFin;
    if (plannedHours != null) data['plannedHours'] = plannedHours;
    if (turno != null && turno!.isNotEmpty) data['turno'] = turno;
    if (hourlyRate != null) data['hourlyRate'] = hourlyRate;

    return data;
  }

  static List<User> listFromJson(String body) {
    final parsed = json.decode(body);
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }
}
