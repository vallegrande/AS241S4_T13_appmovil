// Archivo: lib/models/ingredient.dart

class Ingredient {
  final int? idIngredient;
  final String name;
  final String code;
  final String? category;
  final String? unit;
  final double quantity;
  final double? minStock;
  final double? maxStock;
  final String? location;
  final double? unitPrice;
  final double? totalCost;
  final String? supplier;
  final String? lastPurchaseDate;
  final String? expirationDate;
  final String? productionDate;
  final String? lotNumber;
  final bool requiresRefrigeration;
  final String? recommendedTemperature;
  final bool hasAllergens;
  final String? allergenType;
  final String? description;
  final String? imageUrl;
  final bool state;

  Ingredient({
    this.idIngredient,
    required this.name,
    required this.code,
    this.category,
    this.unit,
    required this.quantity,
    this.minStock,
    this.maxStock,
    this.location,
    this.unitPrice,
    this.totalCost,
    this.supplier,
    this.lastPurchaseDate,
    this.expirationDate,
    this.productionDate,
    this.lotNumber,
    required this.requiresRefrigeration,
    this.recommendedTemperature,
    required this.hasAllergens,
    this.allergenType,
    this.description,
    this.imageUrl,
    required this.state,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      idIngredient: json['idIngredient'] as int?,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      category: json['category'] as String?,
      unit: json['unit'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      minStock: (json['minStock'] as num?)?.toDouble(),
      maxStock: (json['maxStock'] as num?)?.toDouble(),
      location: json['location'] as String?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      totalCost: (json['totalCost'] as num?)?.toDouble(),
      supplier: json['supplier'] as String?,
      lastPurchaseDate: json['lastPurchaseDate'] as String?,
      expirationDate: json['expirationDate'] as String?,
      productionDate: json['productionDate'] as String?,
      lotNumber: json['lotNumber'] as String?,
      requiresRefrigeration: json['requiresRefrigeration'] as bool? ?? false,
      recommendedTemperature: json['recommendedTemperature'] as String?,
      hasAllergens: json['hasAllergens'] as bool? ?? false,
      allergenType: json['allergenType'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      state: json['state'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idIngredient != null) 'idIngredient': idIngredient,
      'name': name,
      'code': code,
      'category': category,
      'unit': unit,
      'quantity': quantity,
      'minStock': minStock,
      'maxStock': maxStock,
      'location': location,
      'unitPrice': unitPrice,
      'totalCost': totalCost,
      'supplier': supplier,
      'lastPurchaseDate': lastPurchaseDate,
      'expirationDate': expirationDate,
      'productionDate': productionDate,
      'lotNumber': lotNumber,
      'requiresRefrigeration': requiresRefrigeration,
      'recommendedTemperature': recommendedTemperature,
      'hasAllergens': hasAllergens,
      'allergenType': allergenType,
      'description': description,
      'imageUrl': imageUrl,
      'state': state,
    };
  }

  Ingredient copyWith({
    int? idIngredient,
    String? name,
    String? code,
    String? category,
    String? unit,
    double? quantity,
    double? minStock,
    double? maxStock,
    String? location,
    double? unitPrice,
    double? totalCost,
    String? supplier,
    String? lastPurchaseDate,
    String? expirationDate,
    String? productionDate,
    String? lotNumber,
    bool? requiresRefrigeration,
    String? recommendedTemperature,
    bool? hasAllergens,
    String? allergenType,
    String? description,
    String? imageUrl,
    bool? state,
  }) {
    return Ingredient(
      idIngredient: idIngredient ?? this.idIngredient,
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      location: location ?? this.location,
      unitPrice: unitPrice ?? this.unitPrice,
      totalCost: totalCost ?? this.totalCost,
      supplier: supplier ?? this.supplier,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      expirationDate: expirationDate ?? this.expirationDate,
      productionDate: productionDate ?? this.productionDate,
      lotNumber: lotNumber ?? this.lotNumber,
      requiresRefrigeration: requiresRefrigeration ?? this.requiresRefrigeration,
      recommendedTemperature: recommendedTemperature ?? this.recommendedTemperature,
      hasAllergens: hasAllergens ?? this.hasAllergens,
      allergenType: allergenType ?? this.allergenType,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      state: state ?? this.state,
    );
  }
}