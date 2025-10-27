class Department {
  final int id;
  final String name;

  Department({required this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? json['id_department'],
      name: json['name'] ?? json['name_department'],
    );
  }

  // ⭐ MODIFICADO: No incluir 'id' si es 0 (para crear nuevos)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {"name": name};
    
    // Solo incluir ID si es mayor a 0 (para editar)
    if (id > 0) {
      data["id"] = id;
    }
    
    return data;
  }
}