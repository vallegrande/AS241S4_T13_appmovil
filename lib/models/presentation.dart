import 'product.dart';

class Presentation {
  final int? idPresentation;
  final String name;
  final String description;
  final double price;
  final double? deliveryPrice;
  final double? takeoutPrice;
  final double? promoPrice;
  final int? preparationTime;
  final bool? state;
  final Product product;

  Presentation({
    this.idPresentation,
    required this.name,
    required this.description,
    required this.price,
    this.deliveryPrice,
    this.takeoutPrice,
    this.promoPrice,
    this.preparationTime,
    this.state,
    required this.product,
  });

  factory Presentation.fromJson(Map<String, dynamic> json) {
    return Presentation(
      idPresentation: json['idPresentation'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      deliveryPrice: (json['deliveryPrice'] as num?)?.toDouble(),
      takeoutPrice: (json['takeoutPrice'] as num?)?.toDouble(),
      promoPrice: (json['promoPrice'] as num?)?.toDouble(),
      preparationTime: json['preparationTime'] as int?,
      state: json['state'] as bool? ?? true,
      product: Product.fromJson(json['product'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    if (idPresentation != null) 'idPresentation': idPresentation,
    'name': name,
    'description': description,
    'price': price,
    if (deliveryPrice != null) 'deliveryPrice': deliveryPrice,
    if (takeoutPrice != null) 'takeoutPrice': takeoutPrice,
    if (promoPrice != null) 'promoPrice': promoPrice,
    if (preparationTime != null) 'preparationTime': preparationTime,
    if (state != null) 'state': state,
    'product': {'idProduct': product.idProduct},
  };
}
