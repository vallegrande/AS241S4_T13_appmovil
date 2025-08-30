import 'package:flutter/material.dart';
import 'package:myapp/users/form_user.dart';

class PanelUserScreen extends StatefulWidget {
  const PanelUserScreen({super.key});

  @override
  State<PanelUserScreen> createState() => _PanelUserScreenState();
}

class _PanelUserScreenState extends State<PanelUserScreen> {
  bool _isSidebarOpen = false;

  // Botón cuadrado con bordes redondeados (HEADER)
  Widget _buildIconButton(String assetPath, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12), // esquinas redondeadas
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEBE0E0), // Fondo EBE0E0
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(assetPath, height: 22),
      ),
    );
  }

  // Iconos del sidebar (cuadrados con esquinas redondeadas)
  Widget _sidebarIcon(
    String assetPath, {
    VoidCallback? onTap,
    double size = 28,
    Color? backgroundColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFEBE0E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(assetPath, height: size),
      ),
    );
  }

  // Ícono especial del Perfil (más grande y sin fondo)
  Widget _profileIcon(
    String assetPath, {
    VoidCallback? onTap,
    double size = 40,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.transparent, // sin fondo
        ),
        child: Image.asset(assetPath, height: size),
      ),
    );
  }

  // Tarjeta de usuario con diseño de 3 columnas
  Widget _userCard({
    required String name,
    required String email,
    required String phone,
    required String carnet,
    required String role,
    required String imagePath,
    required Color roleColor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COLUMNA 1: FOTO PERFIL
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // COLUMNA 2: DATOS
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // reducido
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Correo
                  Row(
                    children: [
                      Image.asset("assets/card_user/gmail.png", height: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Teléfono
                  Row(
                    children: [
                      Image.asset("assets/card_user/telefono.png", height: 14),
                      const SizedBox(width: 6),
                      Text(phone, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Carnet
                  Row(
                    children: [
                      Image.asset("assets/card_user/carnet.png", height: 14),
                      const SizedBox(width: 6),
                      Text(carnet, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // COLUMNA 3: ROLE ARRIBA + BOTONES ABAJO
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // distribuye arriba y abajo
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Cargo (Role) arriba
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 40), // espacio intermedio
                // Botones Editar + Eliminar abajo
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {}, // acción editar
                      child: Image.asset(
                        "assets/card_user/editar.png",
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {}, // acción eliminar
                      child: Image.asset(
                        "assets/card_user/eliminar.png",
                        height: 20,
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
      body: Column(
        children: [
          // HEADER
          Container(
            height: 60,
            color: const Color(0xFFFF1100), // rojo header
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo + Hamburguesa
                Row(
                  children: [
                    ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color.fromARGB(255, 230, 230, 230),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset("assets/header/Logo.png", height: 40),
                    ),
                    const SizedBox(width: 12),
                    _buildIconButton(
                      "assets/header/MenuHeader.png",
                      onTap: () {
                        setState(() => _isSidebarOpen = !_isSidebarOpen);
                      },
                    ),
                  ],
                ),

                // Botones derecha
                Row(
                  children: [
                    _buildIconButton("assets/header/MesaHeader.png"),
                    _buildIconButton("assets/header/PedidosHeader.png"),
                    _buildIconButton("assets/header/AtencionHeader.png"),
                  ],
                ),
              ],
            ),
          ),

          // SIDEBAR + CONTENIDO
          Expanded(
            child: Row(
              children: [
                // SIDEBAR
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isSidebarOpen ? 60 : 0,
                  decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
                  child: _isSidebarOpen
                      ? Column(
                          children: [
                            const SizedBox(height: 16),
                            _profileIcon("assets/sidebar/PerfilUser.png"),
                            _sidebarIcon("assets/sidebar/Home.png"),
                            _sidebarIcon("assets/sidebar/Ventas.png"),
                            _sidebarIcon("assets/sidebar/Pedidos.png"),
                            _sidebarIcon(
                              "assets/sidebar/Users.png",
                              backgroundColor: Color(0xFFFF1100),
                            ),
                            _sidebarIcon("assets/sidebar/Mesas.png"),
                            _sidebarIcon("assets/sidebar/Platos.png"),
                            _sidebarIcon("assets/sidebar/Config.png"),
                            _sidebarIcon("assets/sidebar/go_out.png"),
                            const Spacer(),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                // CONTENIDO PRINCIPAL
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER DEL PANEL
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  "Panel de usuarios",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.info_outline, color: Colors.red),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserForm(), // 👈 tu pantalla
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Color.fromARGB(255, 255, 255, 255),
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
                                  child: Text(role),
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
                                  child: Text(state),
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
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  6,
                                ), // 👈 radio pequeño
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Descargar reporte",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // LISTADO DE USUARIOS
                        Expanded(
                          child: ListView(
                            children: [
                              _userCard(
                                name: "Carlos Caycho",
                                email: "carlos.caycho@vallegrande.edu.pe",
                                phone: "903018604",
                                carnet: "12345678",
                                role: "Admin",
                                imagePath: "assets/card_user/perfil1.png",
                                roleColor: Colors.green,
                              ),
                              _userCard(
                                name: "Alejandro Casas",
                                email: "ale.cas@vallegrande.edu.pe",
                                phone: "903018604",
                                carnet: "87654321",
                                role: "Mozo",
                                imagePath: "assets/card_user/perfil2.png",
                                roleColor: Colors.purple,
                              ),
                              _userCard(
                                name: "Sebastian Conca",
                                email: "seb.conca@vallegrande.edu.pe",
                                phone: "903018604",
                                carnet: "45678912",
                                role: "Cajero",
                                imagePath: "assets/card_user/perfil3.png",
                                roleColor: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
