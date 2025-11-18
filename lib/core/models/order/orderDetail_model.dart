class OrderDetail {
  final int? idDetail;
  final int? idOrder;
  final String? presentationName;
  final int? idPresentation; // ✅ CAMBIO CRÍTICO: Ahora es nullable
  final int amount;
  final double unitPrice;
  final double? subtotal;

  OrderDetail({
    this.idDetail,
    this.idOrder,
    this.presentationName,
    this.idPresentation, // ✅ Ya no es required
    required this.amount,
    required this.unitPrice,
    this.subtotal,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      idDetail: json['idDetail'],
      idOrder: json['idOrder'],
      presentationName: json['presentationName'],
      idPresentation: json['idPresentation'], // ✅ Puede ser null sin problema
      amount: json['amount'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      subtotal: json['subtotal'] != null ? (json['subtotal']).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'amount': amount,
      'unitPrice': unitPrice,
    };

    if (idDetail != null) data['idDetail'] = idDetail;
    if (idOrder != null) data['idOrder'] = idOrder;
    if (presentationName != null) data['presentationName'] = presentationName;
    if (idPresentation != null)
      data['idPresentation'] = idPresentation; // ✅ Solo envía si no es null
    if (subtotal != null) data['subtotal'] = subtotal;

    return data;
  }

  OrderDetail copyWith({
    int? idDetail,
    int? idOrder,
    String? presentationName,
    int? idPresentation,
    int? amount,
    double? unitPrice,
    double? subtotal,
  }) {
    return OrderDetail(
      idDetail: idDetail ?? this.idDetail,
      idOrder: idOrder ?? this.idOrder,
      presentationName: presentationName ?? this.presentationName,
      idPresentation: idPresentation ?? this.idPresentation,
      amount: amount ?? this.amount,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  double get calculatedSubtotal {
    return amount * unitPrice;
  }

  String get formattedSubtotal {
    final total = subtotal ?? calculatedSubtotal;
    return 'S/ ${total.toStringAsFixed(2)}';
  }

  String get formattedUnitPrice {
    return 'S/ ${unitPrice.toStringAsFixed(2)}';
  }
}
