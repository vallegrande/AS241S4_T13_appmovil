// lib/core/models/sales/sale_model.dart
class Sale {
  final int idSale;
  final int idUser;
  final int idCustomer;
  final String customerName;
  final int? idOrder;
  final DateTime saleDate;
  final double total;
  final String paymentType; // 'EFECTIVO', 'TARJETA', 'YAPE', 'PLIN', 'TRANSFERENCIA'
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
    required this.customerName,
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
    return Sale(
      idSale: json['idSale'] ?? 0,
      idUser: json['idUser'] ?? 0,
      idCustomer: json['idCustomer'] ?? 0,
      customerName: json['customerName'] ?? 'Cliente Mostrador',
      idOrder: json['idOrder'],
      saleDate: DateTime.parse(json['saleDate']),
      total: (json['total'] ?? 0).toDouble(),
      paymentType: json['paymentType'] ?? 'EFECTIVO',
      state: json['state'] ?? 2,
      cashReceived: (json['cashReceived'] ?? 0).toDouble(),
      cashChange: (json['cashChange'] ?? 0).toDouble(),
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
      details: json['details'] != null 
          ? (json['details'] as List).map((e) => SaleDetail.fromJson(e)).toList()
          : null,
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

  String get formattedDate {
    return '${saleDate.day}/${saleDate.month}/${saleDate.year} ${saleDate.hour}:${saleDate.minute.toString().padLeft(2, '0')}';
  }

  String get formattedTotal {
    return 'S/ ${total.toStringAsFixed(2)}';
  }

  bool get isActive => state == 2;
  bool get isAnnulled => state == 0;
}

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
    return SaleDetail(
      idDetailSale: json['idDetailSale'] ?? 0,
      idSale: json['idSale'] ?? 0,
      idPresentation: json['idPresentation'] ?? 0,
      presentationName: json['presentationName'] ?? 'Producto #${json['idPresentation']}',
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