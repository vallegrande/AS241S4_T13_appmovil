class ProductIngredientId {
  final int idProduct;
  final int idIngredient;

  ProductIngredientId({
    required this.idProduct,
    required this.idIngredient,
  });

  factory ProductIngredientId.fromJson(Map<String, dynamic> json) {
    return ProductIngredientId(
      idProduct: json['idProduct'] as int? ?? 0,
      idIngredient: json['idIngredient'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'idProduct': idProduct,
    'idIngredient': idIngredient,
  };
}

class ProductIngredient {
  final ProductIngredientId id;
  final Map<String, dynamic>? ingredient;
  final Map<String, dynamic>? product;
  final double quantity;
  final String? unit;

  ProductIngredient({
    required this.id,
    this.ingredient,
    this.product,
    required this.quantity,
    this.unit,
  });

  factory ProductIngredient.fromJson(Map<String, dynamic> json) {
    return ProductIngredient(
      id: ProductIngredientId.fromJson(json['id'] as Map<String, dynamic>? ?? {}),
      ingredient: json['ingredient'] as Map<String, dynamic>?,
      product: json['product'] as Map<String, dynamic>?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'quantity': quantity,
    if (unit != null) 'unit': unit,
    if (ingredient != null) 'ingredient': ingredient,
    if (product != null) 'product': product,
  };

  ProductIngredient copyWith({
    ProductIngredientId? id,
    Map<String, dynamic>? ingredient,
    Map<String, dynamic>? product,
    double? quantity,
    String? unit,
  }) {
    return ProductIngredient(
      id: id ?? this.id,
      ingredient: ingredient ?? this.ingredient,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}