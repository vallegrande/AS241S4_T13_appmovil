import 'package:intl/intl.dart';
import 'orderDetail_model.dart';

class Order {
  final int? idOrder;
  final int idUser;
  final int? idCustomer;
  final Customer? customer;
  final DateTime orderDate;
  final String orderStatus;
  final String typeOfConsumption;
  final int? idTable;
  final double total;
  final int amount;
  final String? deliveryAddress;
  final String? customerNotes;
  final int numberOfPeople;
  final bool confirmed;
  final List<OrderDetail>? details;

  Order({
    this.idOrder,
    required this.idUser,
    this.idCustomer,
    this.customer,
    required this.orderDate,
    required this.orderStatus,
    required this.typeOfConsumption,
    this.idTable,
    required this.total,
    required this.amount,
    this.deliveryAddress,
    this.customerNotes,
    this.numberOfPeople = 1,
    this.confirmed = false,
    this.details,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      idOrder: json['idOrder'],
      idUser: json['idUser'],
      idCustomer: json['idCustomer'],
      customer: json['customer'] != null && json['customer'] != ""
          ? Customer.fromJson(json['customer'])
          : null,
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'])
          : DateTime.now(),
      orderStatus: json['orderStatus'] ?? 'PENDIENTE',
      typeOfConsumption: json['typeOfConsumption'] ?? 'SALON',
      idTable: json['idTable'],
      total: (json['total'] ?? 0).toDouble(),
      amount: json['amount'] ?? 0,
      deliveryAddress: json['deliveryAddress'],
      customerNotes: json['customerNotes'],
      numberOfPeople: json['numberOfPeople'] ?? 1,
      confirmed: json['confirmed'] ?? false,
      details: json['details'] != null
          ? (json['details'] as List)
              .map((detail) => OrderDetail.fromJson(detail))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'idUser': idUser,
      'orderDate': DateFormat('yyyy-MM-dd HH:mm:ss').format(orderDate),
      'orderStatus': orderStatus,
      'typeOfConsumption': typeOfConsumption,
      'total': total,
      'amount': amount,
      'numberOfPeople': numberOfPeople,
      'confirmed': confirmed,
    };

    if (idOrder != null) data['idOrder'] = idOrder;
    if (idCustomer != null) data['idCustomer'] = idCustomer;
    if (idTable != null) data['idTable'] = idTable;
    if (deliveryAddress != null) data['deliveryAddress'] = deliveryAddress;
    if (customerNotes != null) data['customerNotes'] = customerNotes;
    if (details != null) {
      data['details'] = details!.map((detail) => detail.toJson()).toList();
    }

    return data;
  }

  Order copyWith({
    int? idOrder,
    int? idUser,
    int? idCustomer,
    Customer? customer,
    DateTime? orderDate,
    String? orderStatus,
    String? typeOfConsumption,
    int? idTable,
    double? total,
    int? amount,
    String? deliveryAddress,
    String? customerNotes,
    int? numberOfPeople,
    bool? confirmed,
    List<OrderDetail>? details,
  }) {
    return Order(
      idOrder: idOrder ?? this.idOrder,
      idUser: idUser ?? this.idUser,
      idCustomer: idCustomer ?? this.idCustomer,
      customer: customer ?? this.customer,
      orderDate: orderDate ?? this.orderDate,
      orderStatus: orderStatus ?? this.orderStatus,
      typeOfConsumption: typeOfConsumption ?? this.typeOfConsumption,
      idTable: idTable ?? this.idTable,
      total: total ?? this.total,
      amount: amount ?? this.amount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerNotes: customerNotes ?? this.customerNotes,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      confirmed: confirmed ?? this.confirmed,
      details: details ?? this.details,
    );
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy HH:mm').format(orderDate);
  }

  String get formattedTotal {
    return 'S/ ${total.toStringAsFixed(2)}';
  }
}

// ✅ MODELO CUSTOMER CORREGIDO - Ahora usa firstName en lugar de name
class Customer {
  final int? idCustomer;
  final String? firstName; // ✅ CAMBIO: era "name", ahora "firstName"
  final String? lastName;
  final String? phone;
  final String? email;
  final String? address;
  final String? documentType; // ✅ AGREGADO: viene en el JSON
  final String? documentNumber; // ✅ AGREGADO: viene en el JSON
  final String? customerType; // ✅ AGREGADO: viene en el JSON
  final int? state; // ✅ AGREGADO: viene en el JSON
  final String? createdAt; // ✅ AGREGADO: viene en el JSON

  Customer({
    this.idCustomer,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.address,
    this.documentType,
    this.documentNumber,
    this.customerType,
    this.state,
    this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      idCustomer: json['idCustomer'],
      firstName: json['firstName'], // ✅ Ahora lee el campo correcto
      lastName: json['lastName'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      documentType: json['documentType'],
      documentNumber: json['documentNumber'],
      customerType: json['customerType'],
      state: json['state'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idCustomer != null) 'idCustomer': idCustomer,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (documentType != null) 'documentType': documentType,
      if (documentNumber != null) 'documentNumber': documentNumber,
      if (customerType != null) 'customerType': customerType,
      if (state != null) 'state': state,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
