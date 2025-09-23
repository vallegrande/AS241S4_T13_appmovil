// lib/widgets/sidebar.dart
import 'package:flutter/material.dart';
import 'dart:ui';

class AppSidebar extends StatelessWidget {
  final bool isOpen;
  final Function(String)? onItemTap;
  final VoidCallback? onClose;
  final String selectedItem; // Tracks the currently selected item

  const AppSidebar({
    super.key,
    required this.isOpen,
    this.onItemTap,
    this.onClose,
    this.selectedItem = 'Home', // Default to Home
  });

  Widget _profileIcon(
    String assetPath, {
    VoidCallback? onTap,
    double size = 52,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.9),
          border: Border.all(color: const Color(0xFFFF1100), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(assetPath, height: size, fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo semitransparente con blur
        if (isOpen)
          GestureDetector(
            onTap: onClose,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: isOpen ? 1.0 : 0.0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(),
                ),
              ),
            ),
          ),
        // Sidebar con animación
        AnimatedPositioned(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutBack,
          left: isOpen ? 0 : -300,
          top: 0,
          child: Material(
            elevation: 14,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            child: Container(
              width: 300,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, const Color(0xFFF8F8F8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado del sidebar con altura fija
                  Container(
                    height: 80, // Fixed height to avoid scroll
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 600),
                          opacity: isOpen ? 1.0 : 0.0,
                          child: const Text(
                            'Menú',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF1100),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          scale: isOpen ? 1.0 : 0.85,
                          curve: Curves.bounceOut,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFFFF1100), size: 30),
                            onPressed: onClose,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  // Perfil de usuario con altura fija
                  Container(
                    height: 100, // Fixed height to avoid scroll
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        _profileIcon("assets/sidebar/PerfilUser.png"),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 600),
                              opacity: isOpen ? 1.0 : 0.0,
                              child: const Text(
                                "Carlos Mendoza",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const Text(
                              "Gerente General",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  // Opciones del menú
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildMenuItem("Home", "assets/sidebar/Home.png", selectedItem: selectedItem),
                            _buildMenuItem("Ventas", "assets/sidebar/Ventas.png", selectedItem: selectedItem),
                            _buildMenuItem("Pedidos", "assets/sidebar/Pedidos.png", selectedItem: selectedItem),
                            _buildMenuItem(
                              "Usuarios", 
                              "assets/sidebar/Users.png",
                              backgroundColor: selectedItem == 'Usuarios' ? const Color(0xFFFF1100) : null,
                              textColor: selectedItem == 'Usuarios' ? Colors.white : Colors.black87,
                              selectedItem: selectedItem,
                            ),
                            _buildMenuItem("Mesas", "assets/sidebar/Mesas.png", selectedItem: selectedItem),
                            _buildMenuItem(
                              "Platos",
                              "assets/sidebar/Platos.png",
                              backgroundColor: selectedItem == 'Platos' ? const Color(0xFFFF1100) : null,
                              textColor: selectedItem == 'Platos' ? Colors.white : Colors.black87,
                              selectedItem: selectedItem,
                            ),
                            _buildMenuItem("Config", "assets/sidebar/Config.png", selectedItem: selectedItem),
                            _buildMenuItem("Salir", "assets/sidebar/go_out.png", selectedItem: selectedItem),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    String title,
    String iconPath, {
    Color? backgroundColor,
    Color textColor = Colors.black87,
    required String selectedItem,
  }) {
    final isSelected = title == selectedItem;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => onItemTap?.call(title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF1100) : (backgroundColor ?? const Color(0xFFF0F0F0)),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: 1.0,
                curve: Curves.bounceOut,
                child: Image.asset(
                  iconPath,
                  height: 28,
                  color: isSelected ? Colors.white : const Color(0xFFFF1100), // Red by default, white when selected
                ),
              ),
              const SizedBox(width: 16),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : textColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}