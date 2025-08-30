import 'package:flutter/material.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  bool _isSidebarOpen = false; // Sidebar (si lo necesitas)

  // Botón cuadrado con bordes redondeados (HEADER)
  Widget _buildIconButton(String assetPath, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEBE0E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(assetPath, height: 22),
      ),
    );
  }

  // Widget para input con label + placeholder
Widget _buildTextField(String label, {bool obscure = false, String? hint}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      const SizedBox(height: 3),
      TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint ?? "Ingrese $label", // 👈 placeholder dinámico
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          isDense: true, // <- reduce altura
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}

// Widget para dropdown con label + placeholder
Widget _buildDropdown(String label, List<String> items) {
  String? selected;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      const SizedBox(height: 3),
      StatefulBuilder(
        builder: (context, setState) {
          return DropdownButtonFormField<String>(
            value: selected,
            items: items
                .map(
                  (item) => DropdownMenuItem(value: item, child: Text(item)),
                )
                .toList(),
            onChanged: (value) => setState(() => selected = value),
            decoration: InputDecoration(
              hintText: "Seleccione $label", // 👈 placeholder dinámico
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
    ],
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
            color: const Color(0xFFFF1100),
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
                        setState(() {
                          _isSidebarOpen = !_isSidebarOpen;
                        });
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

          // CONTENIDO
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Crear perfil de usuario",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Foto de perfil centrada con texto "Editar foto de perfil"
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/formUser/defaultUser.png",
                          width: 80, // ajusta a tu tamaño
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Editar foto de perfil",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Formulario
                  _buildDropdown("Tipo de documento", ["DNI", "CNE"]),
                  _buildTextField("Numero de documento"),
                  _buildTextField("Nombres"),
                  _buildTextField("Apellidos"),
                  _buildDropdown("Género", ["Masculino", "Femenino", "Otros"]),
                  _buildTextField("Gmail"),
                  _buildTextField("Contraseña", obscure: true),
                  _buildDropdown("Rol asignado", ["Admin", "Cocinero", "Mozo"]),
                  _buildTextField("Teléfono"),
                  _buildTextField("Dirección"),

                  const SizedBox(height: 20),

                  // BOTONES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Guardar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
