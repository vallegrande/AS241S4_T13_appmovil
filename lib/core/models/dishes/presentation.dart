class Presentation {
  final int? idPresentation;
  final String name;
  final String? description;
  final double price;
  final double? deliveryPrice;
  final double? takeoutPrice;
  final double? promoPrice;
  final int? preparationTime;
  final String? dishPhotoUrl;
  final bool state;
  final String? createdAt;
  final Map<String, dynamic>? product;

  Presentation({
    this.idPresentation,
    required this.name,
    this.description,
    required this.price,
    this.deliveryPrice,
    this.takeoutPrice,
    this.promoPrice,
    this.preparationTime,
    this.dishPhotoUrl,
    required this.state,
    this.createdAt,
    this.product,
  });

  factory Presentation.fromJson(Map<String, dynamic> json) {
    return Presentation(
      idPresentation: json['idPresentation'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      deliveryPrice: (json['deliveryPrice'] as num?)?.toDouble(),
      takeoutPrice: (json['takeoutPrice'] as num?)?.toDouble(),
      promoPrice: (json['promoPrice'] as num?)?.toDouble(),
      preparationTime: json['preparationTime'] as int?,
      dishPhotoUrl: json['dishPhotoUrl'] as String?,
      state: json['state'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
      product: json['product'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idPresentation != null) 'idPresentation': idPresentation,
      'name': name,
      if (description != null) 'description': description,
      'price': price,
      if (deliveryPrice != null) 'deliveryPrice': deliveryPrice,
      if (takeoutPrice != null) 'takeoutPrice': takeoutPrice,
      if (promoPrice != null) 'promoPrice': promoPrice,
      if (preparationTime != null) 'preparationTime': preparationTime,
      if (dishPhotoUrl != null) 'dishPhotoUrl': dishPhotoUrl,
      'state': state,
      if (createdAt != null) 'createdAt': createdAt,
      if (product != null) 'product': product,
    };
  }

  Presentation copyWith({
    int? idPresentation,
    String? name,
    String? description,
    double? price,
    double? deliveryPrice,
    double? takeoutPrice,
    double? promoPrice,
    int? preparationTime,
    String? dishPhotoUrl,
    bool? state,
    String? createdAt,
    Map<String, dynamic>? product,
  }) {
    return Presentation(
      idPresentation: idPresentation ?? this.idPresentation,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      takeoutPrice: takeoutPrice ?? this.takeoutPrice,
      promoPrice: promoPrice ?? this.promoPrice,
      preparationTime: preparationTime ?? this.preparationTime,
      dishPhotoUrl: dishPhotoUrl ?? this.dishPhotoUrl,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      product: product ?? this.product,
    );
  }
}
