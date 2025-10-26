// lib/models/product_ingredient.dart

import 'ingredient.dart';

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
  final Ingredient? ingredient;
  final double quantity;
  final String? unit;

  ProductIngredient({
    required this.id,
    this.ingredient,
    required this.quantity,
    this.unit,
  });

  factory ProductIngredient.fromJson(Map<String, dynamic> json) {
    return ProductIngredient(
      id: ProductIngredientId.fromJson(json['id'] as Map<String, dynamic>? ?? {}),
      ingredient: json['ingredient'] != null
          ? Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>)
          : null,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    // Nota: El backend de Spring Boot a menudo espera solo los IDs en las relaciones ManyToOne anidadas.
    'quantity': quantity,
    if (unit != null) 'unit': unit,
    // Si necesitas enviar el ingrediente completo para actualizar, habilita:
    // if (ingredient != null) 'ingredient': ingredient!.toJson(),
  };
}