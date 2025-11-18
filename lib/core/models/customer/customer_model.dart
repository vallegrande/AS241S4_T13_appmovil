// lib/core/models/customers/customer_model.dart
import 'dart:convert';

class Customer {
  final int? idCustomer;
  final String firstName;
  final String lastName;
  final String? email;
  final String phone;
  final String documentType;
  final String documentNumber;
  final String? address;
  final String customerType;
  final int? state;
  final DateTime? createdAt;

  Customer({
    this.idCustomer,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.phone,
    required this.documentType,
    required this.documentNumber,
    this.address,
    required this.customerType,
    this.state,
    this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      idCustomer: json['idCustomer'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      documentType: json['documentType'] ?? '',
      documentNumber: json['documentNumber'] ?? '',
      address: json['address'],
      customerType: json['customerType'] ?? 'NATURAL',
      state: json['state'] ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'customerType': customerType,
    };

    if (idCustomer != null) {
      data['idCustomer'] = idCustomer;
    }

    if (email != null && email!.isNotEmpty) data['email'] = email;
    if (address != null && address!.isNotEmpty) data['address'] = address;
    if (state != null) data['state'] = state;

    return data;
  }

  static List<Customer> listFromJson(String body) {
    final parsed = json.decode(body);
    return parsed.map<Customer>((json) => Customer.fromJson(json)).toList();
  }

  // Helper para obtener el nombre completo
  String get fullName => '$firstName $lastName';

  // Helper para verificar si está activo
  bool get isActive => state == 1;

  // Helper para obtener el tipo legible
  String get customerTypeLabel =>
      customerType == 'NATURAL' ? 'Natural' : 'Jurídico';
}
