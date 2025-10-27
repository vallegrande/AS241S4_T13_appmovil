class Category {
  final int? idCategory;
  final String name;
  final String? description;
  final String? section;
  final bool? delivery;
  final int? displayOrder;
  final bool state;
  final String? createdAt;
  final List<dynamic>? products;

  Category({
    this.idCategory,
    required this.name,
    this.description,
    this.section,
    this.delivery,
    this.displayOrder,
    required this.state,
    this.createdAt,
    this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      idCategory: json['idCategory'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      section: json['section'] as String?,
      delivery: json['delivery'] as bool?,
      displayOrder: json['displayOrder'] as int?,
      state: json['state'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
      products: json['products'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idCategory != null) 'idCategory': idCategory,
      'name': name,
      if (description != null) 'description': description,
      if (section != null) 'section': section,
      if (delivery != null) 'delivery': delivery,
      if (displayOrder != null) 'displayOrder': displayOrder,
      'state': state,
      if (createdAt != null) 'createdAt': createdAt,
      if (products != null) 'products': products,
    };
  }

  Category copyWith({
    int? idCategory,
    String? name,
    String? description,
    String? section,
    bool? delivery,
    int? displayOrder,
    bool? state,
    String? createdAt,
    List<dynamic>? products,
  }) {
    return Category(
      idCategory: idCategory ?? this.idCategory,
      name: name ?? this.name,
      description: description ?? this.description,
      section: section ?? this.section,
      delivery: delivery ?? this.delivery,
      displayOrder: displayOrder ?? this.displayOrder,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      products: products ?? this.products,
    );
  }
}