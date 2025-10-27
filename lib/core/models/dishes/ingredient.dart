class Ingredient {
  final int? idIngredient;
  final String name;
  final String code;
  final String? category;
  final String? unit;
  final double? quantity;
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
  final bool? requiresRefrigeration;
  final String? recommendedTemperature;
  final bool? hasAllergens;
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
    this.quantity,
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
    this.requiresRefrigeration,
    this.recommendedTemperature,
    this.hasAllergens,
    this.allergenType,
    this.description,
    this.imageUrl,
    required this.state,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      idIngredient: json['idIngredient'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      category: json['category'],
      unit: json['unit'],
      quantity: json['quantity']?.toDouble(),
      minStock: json['minStock']?.toDouble(),
      maxStock: json['maxStock']?.toDouble(),
      location: json['location'],
      unitPrice: json['unitPrice']?.toDouble(),
      totalCost: json['totalCost']?.toDouble(),
      supplier: json['supplier'],
      lastPurchaseDate: json['lastPurchaseDate'],
      expirationDate: json['expirationDate'],
      productionDate: json['productionDate'],
      lotNumber: json['lotNumber'],
      requiresRefrigeration: json['requiresRefrigeration'],
      recommendedTemperature: json['recommendedTemperature'],
      hasAllergens: json['hasAllergens'],
      allergenType: json['allergenType'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      state: json['state'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idIngredient != null) 'idIngredient': idIngredient,
      'name': name,
      'code': code,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      if (quantity != null) 'quantity': quantity,
      if (minStock != null) 'minStock': minStock,
      if (maxStock != null) 'maxStock': maxStock,
      if (location != null) 'location': location,
      if (unitPrice != null) 'unitPrice': unitPrice,
      if (totalCost != null) 'totalCost': totalCost,
      if (supplier != null) 'supplier': supplier,
      if (lastPurchaseDate != null) 'lastPurchaseDate': lastPurchaseDate,
      if (expirationDate != null) 'expirationDate': expirationDate,
      if (productionDate != null) 'productionDate': productionDate,
      if (lotNumber != null) 'lotNumber': lotNumber,
      if (requiresRefrigeration != null) 'requiresRefrigeration': requiresRefrigeration,
      if (recommendedTemperature != null) 'recommendedTemperature': recommendedTemperature,
      if (hasAllergens != null) 'hasAllergens': hasAllergens,
      if (allergenType != null) 'allergenType': allergenType,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'state': state,
    };
  }
}