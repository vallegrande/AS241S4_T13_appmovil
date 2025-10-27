class Department {
  final int? id;
  final String? name;

  Department({this.id, this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (name != null) 'name': name,
  };
}

class Product {
  final int? idProduct;
  final String name;
  final String? description;
  final bool state;
  final String? createdAt;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? department;
  final List<dynamic>? presentations;
  final List<dynamic>? productIngredients;

  Product({
    this.idProduct,
    required this.name,
    this.description,
    required this.state,
    this.createdAt,
    this.category,
    this.department,
    this.presentations,
    this.productIngredients,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      idProduct: json['idProduct'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      state: json['state'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
      category: json['category'] as Map<String, dynamic>?,
      department: json['department'] as Map<String, dynamic>?,
      presentations: json['presentations'] as List<dynamic>?,
      productIngredients: json['productIngredients'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idProduct != null) 'idProduct': idProduct,
      'name': name,
      if (description != null) 'description': description,
      'state': state,
      if (createdAt != null) 'createdAt': createdAt,
      if (category != null) 'category': category,
      if (department != null) 'department': department,
      if (presentations != null) 'presentations': presentations,
      if (productIngredients != null) 'productIngredients': productIngredients,
    };
  }

  Product copyWith({
    int? idProduct,
    String? name,
    String? description,
    bool? state,
    String? createdAt,
    Map<String, dynamic>? category,
    Map<String, dynamic>? department,
    List<dynamic>? presentations,
    List<dynamic>? productIngredients,
  }) {
    return Product(
      idProduct: idProduct ?? this.idProduct,
      name: name ?? this.name,
      description: description ?? this.description,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      department: department ?? this.department,
      presentations: presentations ?? this.presentations,
      productIngredients: productIngredients ?? this.productIngredients,
    );
  }
}