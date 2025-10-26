import 'category.dart';
import 'department.dart';
import 'presentation.dart';

class Product {
  final int? idProduct;
  final String name;
  final String? description;
  final bool state;
  final String? createdAt;
  final Category category;
  final Department department;
  final List<Presentation>? presentations;

  Product({
    this.idProduct,
    required this.name,
    this.description,
    required this.state,
    this.createdAt,
    required this.category,
    required this.department,
    this.presentations,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      idProduct: json['idProduct'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      state: json['state'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
      category: Category.fromJson(json['category'] ?? {}),
      department: Department.fromJson(json['department'] ?? {}),
      presentations: json['presentations'] != null
          ? (json['presentations'] as List).map((p) => Presentation.fromJson(p)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (idProduct != null) 'idProduct': idProduct,
    'name': name,
    if (description != null) 'description': description,
    'state': state,
    if (createdAt != null) 'createdAt': createdAt,
    'category': {'idCategory': category.idCategory},
    'department': {'id': department.id},
  };
}