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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {"name": name};

    if (id > 0) {
      data["id"] = id;
    }

    return data;
  }
}
