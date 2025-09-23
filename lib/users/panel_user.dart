import 'package:flutter/material.dart';
import 'package:myapp/users/form_user.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';

class User {
  String name;
  String email;
  String phone;
  String carnet;
  String role;
  String imagePath;
  bool isDeleted;
  String originalRole;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.carnet,
    required this.role,
    required this.imagePath,
    this.isDeleted = false,
  }) : originalRole = role; 
}

class PanelUserScreen extends StatefulWidget {
  const PanelUserScreen({super.key});

  @override
  State<PanelUserScreen> createState() => _PanelUserScreenState();
}

class _PanelUserScreenState extends State<PanelUserScreen> {
  bool _isSidebarOpen = false;

  List<User> users = [
    User(
      name: "Carlos Caycho",
      email: "carlos.caycho@vallegrande.edu.pe",
      phone: "903018604",
      carnet: "12345678",
      role: "Admin",
      imagePath: "assets/card_user/perfil1.png",
    ),
    User(
      name: "Alejandro Casas",
      email: "ale.cas@vallegrande.edu.pe",
      phone: "903018604",
      carnet: "87654321",
      role: "Mozo",
      imagePath: "assets/card_user/perfil2.png",
    ),
    User(
      name: "Sebastian Conca",
      email: "seb.conca@vallegrande.edu.pe",
      phone: "903018604",
      carnet: "45678912",
      role: "Cajero",
      imagePath: "assets/card_user/perfil3.png",
    ),
  ];

  // Abrir UserForm para agregar o editar
  Future<void> _openUserForm({User? user, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserForm(
          nombres: user?.name,
          gmail: user?.email,
          telefono: user?.phone,
          numeroDocumento: user?.carnet,
          rol: user?.role,
          imagePath: user?.imagePath,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        User newUser = User(
          name: result["nombres"] ?? "",
          email: result["gmail"] ?? "",
          phone: result["telefono"] ?? "",
          carnet: result["numeroDocumento"] ?? "",
          role: result["rol"] ?? "Admin",
          imagePath: result["imagePath"] ?? "assets/formUser/defaultUser.png",
        );

        if (index != null) {
          users[index] = newUser;
        } else {
          users.add(newUser);
        }
      });
    }
  }

  Widget _userCard(User user, int index) {
    Color roleColor = Colors.grey;
    if (user.role == "Admin") roleColor = Colors.green;
    if (user.role == "Mozo") roleColor = Colors.purple;
    if (user.role == "Cajero") roleColor = Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.asset(
                user.imagePath,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Image.asset("assets/card_user/gmail.png", height: 14),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          user.email,
                          style: const TextStyle(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Image.asset("assets/card_user/telefono.png", height: 14),
                      const SizedBox(width: 5),
                      Text(user.phone, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Image.asset("assets/card_user/carnet.png", height: 14),
                      const SizedBox(width: 5),
                      Text(user.carnet, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    user.role,
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón Editar
                    InkWell(
                      onTap: () => _openUserForm(user: user, index: index),
                      child: Image.asset(
                        "assets/card_user/editar.png",
                        height: 21,
                      ),
                    ),
                    const SizedBox(width: 9),
                    // Toggle Eliminar/Restaurar
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (!user.isDeleted) {
                            user.isDeleted = true;
                            user.role = "Inactivo";
                          } else {
                            user.isDeleted = false;
                            user.role = user.originalRole;
                          }
                        });
                      },
                      child: Image.asset(
                        user.isDeleted
                            ? "assets/card_user/restaurar.png"
                            : "assets/card_user/eliminar.png",
                        height: 21,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenido principal
          Column(
            children: [
              AppHeader(
                onMenuTap: () => setState(() => _isSidebarOpen = true),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER PANEL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Text(
                                "Panel de usuarios",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.info_outline,
                                color: Colors.red,
                                size: 22,
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => _openUserForm(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(13),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // FILTROS
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Buscar usuarios",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        hint: const Text("Todos los roles"),
                        items: ["Admin", "Mozo", "Cajero", "Cocinero"]
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(
                                  role,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        hint: const Text("Todos los estados"),
                        items: ["Activo", "Inactivo"]
                            .map(
                              (state) => DropdownMenuItem(
                                value: state,
                                child: Text(
                                  state,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 16),

                      // BOTÓN DESCARGAR REPORTE
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Descargar reporte",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // LISTADO DE USUARIOS
                      Expanded(
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) =>
                              _userCard(users[index], index),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Sidebar (se superpone al contenido)
          AppSidebar(
            isOpen: _isSidebarOpen,
            onItemTap: (item) {
              setState(() => _isSidebarOpen = false);
              debugPrint("Clicked: $item");
            },
            onClose: () => setState(() => _isSidebarOpen = false),
          ),
        ],
      ),
    );
  }
}