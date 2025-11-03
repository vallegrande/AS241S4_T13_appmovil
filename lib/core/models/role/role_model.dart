class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? json['id_role'],
      name: json['name'] ?? json['name_role'],
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
