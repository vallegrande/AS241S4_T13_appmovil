// lib/core/models/sales/sale_model.dart
// REEMPLAZA TODO EL ARCHIVO CON ESTE CÓDIGO:

import 'package:intl/intl.dart';

class Sale {
  final int idSale;
  final int idUser;
  final int idCustomer;
  final String? customerName;
  final SaleCustomer? customer; // Cambiado a SaleCustomer
  final int? idOrder;
  final DateTime saleDate;
  final double total;
  final String paymentType;
  final int state; // 0=Anulada, 2=Cerrada

  // Campos específicos por método de pago
  final double? cashReceived;
  final double? cashChange;
  final String? cardType;
  final String? cardLast4;
  final String? cardOperation;
  final String? posReference;
  final String? phonePayment;
  final String? transactionCode;
  final String? bankName;
  final String? bankAccount;
  final String? bankOperation;
  final String? paymentProofUrl;

  // Relaciones
  final List<SaleDetail>? details;

  Sale({
    required this.idSale,
    required this.idUser,
    required this.idCustomer,
    this.customerName,
    this.customer,
    this.idOrder,
    required this.saleDate,
    required this.total,
    required this.paymentType,
    required this.state,
    this.cashReceived,
    this.cashChange,
    this.cardType,
    this.cardLast4,
    this.cardOperation,
    this.posReference,
    this.phonePayment,
    this.transactionCode,
    this.bankName,
    this.bankAccount,
    this.bankOperation,
    this.paymentProofUrl,
    this.details,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    print('🔄 Parseando venta #${json['idSale']}');
    
    // Extraer objeto Customer si existe
    SaleCustomer? customerObj;
    if (json['customer'] != null && json['customer'] != "") {
      try {
        customerObj = SaleCustomer.fromJson(json['customer']);
        print('✅ Venta tiene objeto Customer: ${customerObj.fullName}');
      } catch (e) {
        print('⚠️ Error parseando Customer: $e');
      }
    }

    // Extraer nombre del cliente
    String? extractedCustomerName;
    
    // Prioridad 1: Customer object completo
    if (customerObj != null && customerObj.fullName.isNotEmpty) {
      extractedCustomerName = customerObj.fullName;
    }
    // Prioridad 2: customerName directo
    else if (json['customerName'] != null && json['customerName'].toString().trim().isNotEmpty) {
      extractedCustomerName = json['customerName'].toString().trim();
    }
    // Prioridad 3: customer.fullName en el objeto customer
    else if (json['customer'] != null && json['customer']['fullName'] != null) {
      extractedCustomerName = json['customer']['fullName'].toString().trim();
    }
    // Prioridad 4: customer_name (con guión bajo)
    else if (json['customer_name'] != null) {
      extractedCustomerName = json['customer_name'].toString().trim();
    }
    // Último recurso: ID temporal
    else {
      final customerId = json['idCustomer'] ?? '?';
      extractedCustomerName = 'Cliente #$customerId';
    }

    // Validar que no sea un nombre inválido
    if (extractedCustomerName == 'Cliente Mostrador' || 
        extractedCustomerName == 'null' || 
        extractedCustomerName == '') {
      final customerId = json['idCustomer'] ?? '?';
      extractedCustomerName = 'Cliente #$customerId';
    }

    // Parsear details con nombres reales
    List<SaleDetail>? details;
  if (json['details'] != null && json['details'] is List) {
    details = (json['details'] as List).map((detailJson) {
      // LÓGICA MEJORADA PARA ENCONTRAR EL NOMBRE
      String presentationName = 'Producto #${detailJson['idPresentation'] ?? '?'}';
      
      // Buscar en TODAS las posibles ubicaciones
      if (detailJson['presentationName'] != null && 
          detailJson['presentationName'].toString().trim().isNotEmpty) {
        presentationName = detailJson['presentationName'].toString().trim();
        print('✅ Nombre desde presentationName: $presentationName');
      } 
      else if (detailJson['presentation'] != null && detailJson['presentation'] is Map) {
        final presentation = detailJson['presentation'] as Map;
        if (presentation['name'] != null && presentation['name'].toString().trim().isNotEmpty) {
          presentationName = presentation['name'].toString().trim();
          print('✅ Nombre desde presentation.name: $presentationName');
        }
        else if (presentation['presentationName'] != null) {
          presentationName = presentation['presentationName'].toString().trim();
          print('✅ Nombre desde presentation.presentationName: $presentationName');
        }
      }
      else if (detailJson['productName'] != null) {
        presentationName = detailJson['productName'].toString().trim();
        print('✅ Nombre desde productName: $presentationName');
      }
      else if (detailJson['name'] != null) {
        presentationName = detailJson['name'].toString().trim();
        print('✅ Nombre desde name: $presentationName');
      }
      
      return SaleDetail(
        idDetailSale: detailJson['idDetailSale'] ?? 0,
        idSale: detailJson['idSale'] ?? 0,
        idPresentation: detailJson['idPresentation'] ?? 0,
        presentationName: presentationName,
        amount: detailJson['amount'] ?? 0,
        unitPrice: (detailJson['unitPrice'] ?? 0).toDouble(),
        subtotal: (detailJson['subtotal'] ?? 0).toDouble(),
      );
    }).toList();
  }

    return Sale(
      idSale: json['idSale'] ?? 0,
      idUser: json['idUser'] ?? 0,
      idCustomer: json['idCustomer'] ?? 0,
      customerName: extractedCustomerName,
      customer: customerObj,
      idOrder: json['idOrder'],
      saleDate: DateTime.parse(json['saleDate']),
      total: (json['total'] ?? 0).toDouble(),
      paymentType: json['paymentType'] ?? 'EFECTIVO',
      state: json['state'] ?? 2,
      cashReceived: json['cashReceived'] != null ? (json['cashReceived'] as num).toDouble() : null,
      cashChange: json['cashChange'] != null ? (json['cashChange'] as num).toDouble() : null,
      cardType: json['cardType'],
      cardLast4: json['cardLast4'],
      cardOperation: json['cardOperation'],
      posReference: json['posReference'],
      phonePayment: json['phonePayment'],
      transactionCode: json['transactionCode'],
      bankName: json['bankName'],
      bankAccount: json['bankAccount'],
      bankOperation: json['bankOperation'],
      paymentProofUrl: json['paymentProofUrl'],
      details: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSale': idSale,
      'idUser': idUser,
      'idCustomer': idCustomer,
      'customerName': customerName,
      'idOrder': idOrder,
      'saleDate': saleDate.toIso8601String(),
      'total': total,
      'paymentType': paymentType,
      'state': state,
      'cashReceived': cashReceived,
      'cashChange': cashChange,
      'cardType': cardType,
      'cardLast4': cardLast4,
      'cardOperation': cardOperation,
      'posReference': posReference,
      'phonePayment': phonePayment,
      'transactionCode': transactionCode,
      'bankName': bankName,
      'bankAccount': bankAccount,
      'bankOperation': bankOperation,
      'paymentProofUrl': paymentProofUrl,
    };
  }

  String get safeCustomerName {
    // Prioridad 1: Customer object completo
    if (customer != null && customer!.fullName.isNotEmpty) {
      return customer!.fullName;
    }
    
    // Prioridad 2: customerName del modelo
    if (customerName != null && 
        customerName!.trim().isNotEmpty && 
        customerName != 'Cliente Mostrador' && 
        customerName != 'null' &&
        !customerName!.startsWith('Cliente #')) {
      return customerName!;
    }
    
    // Último recurso
    return 'Cliente #$idCustomer';
  }

  String get displayCustomerName => safeCustomerName;

  String get formattedDate {
    return '${saleDate.day}/${saleDate.month}/${saleDate.year} ${saleDate.hour}:${saleDate.minute.toString().padLeft(2, '0')}';
  }

  String get formattedTotal {
    return 'S/ ${total.toStringAsFixed(2)}';
  }

  bool get isActive => state == 2;
  bool get isAnnulled => state == 0;
}

// ==========================================
// MODELO SaleCustomer (solo lo necesario para ventas)
// ==========================================
class SaleCustomer {
  final int? idCustomer;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? address;

  SaleCustomer({
    this.idCustomer,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.address,
  });

  factory SaleCustomer.fromJson(Map<String, dynamic> json) {
    return SaleCustomer(
      idCustomer: json['idCustomer'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}

// ==========================================f
// MODELO SaleDetail
// ==========================================
class SaleDetail {
  final int idDetailSale;
  final int idSale;
  final int idPresentation;
  final String presentationName;
  final int amount;
  final double unitPrice;
  final double subtotal;

  SaleDetail({
    required this.idDetailSale,
    required this.idSale,
    required this.idPresentation,
    required this.presentationName,
    required this.amount,
    required this.unitPrice,
    required this.subtotal,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    // Intentar obtener el nombre real del producto
    String presentationName;
    
    if (json['presentationName'] != null) {
      presentationName = json['presentationName'].toString();
    } else if (json['presentation'] != null && json['presentation']['name'] != null) {
      presentationName = json['presentation']['name'].toString();
    } else {
      presentationName = 'Producto #${json['idPresentation'] ?? '?'}';
    }

    return SaleDetail(
      idDetailSale: json['idDetailSale'] ?? 0,
      idSale: json['idSale'] ?? 0,
      idPresentation: json['idPresentation'] ?? 0,
      presentationName: presentationName,
      amount: json['amount'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDetailSale': idDetailSale,
      'idSale': idSale,
      'idPresentation': idPresentation,
      'presentationName': presentationName,
      'amount': amount,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }
}

// ==========================================
// MODELO CreateSaleRequest
// ==========================================
class CreateSaleRequest {
  final int? idOrder;
  final int? idCustomer;
  final int idUser;
  final String paymentType;

  // Campos específicos por método de pago
  final double? cashReceived;
  final double? cashChange;
  final String? cardType;
  final String? cardLast4;
  final String? cardOperation;
  final String? posReference;
  final String? phonePayment;
  final String? transactionCode;
  final String? bankName;
  final String? bankAccount;
  final String? bankOperation;

  CreateSaleRequest({
    this.idOrder,
    this.idCustomer,
    required this.idUser,
    required this.paymentType,
    this.cashReceived,
    this.cashChange,
    this.cardType,
    this.cardLast4,
    this.cardOperation,
    this.posReference,
    this.phonePayment,
    this.transactionCode,
    this.bankName,
    this.bankAccount,
    this.bankOperation,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'idUser': idUser,
      'paymentType': paymentType,
    };

    if (idOrder != null) map['idOrder'] = idOrder;
    if (idCustomer != null) map['idCustomer'] = idCustomer;
    if (cashReceived != null) map['cashReceived'] = cashReceived;
    if (cashChange != null) map['cashChange'] = cashChange;
    if (cardLast4 != null) map['cardLast4'] = cardLast4;
    if (cardOperation != null) map['cardOperation'] = cardOperation;
    if (cardType != null) map['cardType'] = cardType;
    if (posReference != null) map['posReference'] = posReference;
    if (phonePayment != null) map['phonePayment'] = phonePayment;
    if (transactionCode != null) map['transactionCode'] = transactionCode;
    if (bankName != null) map['bankName'] = bankName;
    if (bankAccount != null) map['bankAccount'] = bankAccount;
    if (bankOperation != null) map['bankOperation'] = bankOperation;

    return map;
  }
}