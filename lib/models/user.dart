// Archivo: lib/models/user.dart
import 'package:flutter/foundation.dart';
import 'role.dart';
import 'department.dart';

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
  final String? adress; // Campo corregido para coincidir con la API.
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
        adress: json['adress'] as String?, // Lee de 'adress'
        phone: json['phone'] as String?,
        gender: json['gender'] as String?,
        profilePhoto: json['profilePhoto'] as String?,
        state: json['state'] as bool? ?? true,
        registrationDate: json['registrationDate'] as String?,
        horaInicio: json['horaInicio'] as String?,
        horaFin: json['horaFin'] as String?,
        plannedHours: json['plannedHours'] as int?,
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
        'adress': adress, // Envía como 'adress'
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