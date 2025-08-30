import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final bool isOpen;
  final Function(String)? onItemTap;

  const AppSidebar({super.key, required this.isOpen, this.onItemTap});

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
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Image.asset(assetPath, height: size),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isOpen ? 60 : 0,
      decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
      child: isOpen
          ? Column(
              children: [
                const SizedBox(height: 16),
                _profileIcon("assets/sidebar/PerfilUser.png"),
                _sidebarIcon(
                  "assets/sidebar/Home.png",
                  onTap: () => onItemTap?.call("Home"),
                ),
                _sidebarIcon(
                  "assets/sidebar/Ventas.png",
                  onTap: () => onItemTap?.call("Ventas"),
                ),
                _sidebarIcon(
                  "assets/sidebar/Pedidos.png",
                  onTap: () => onItemTap?.call("Pedidos"),
                ),
                _sidebarIcon(
                  "assets/sidebar/Users.png",
                  backgroundColor: const Color(0xFFFF1100),
                  onTap: () => onItemTap?.call("Users"),
                ),
                _sidebarIcon(
                  "assets/sidebar/Mesas.png",
                  onTap: () => onItemTap?.call("Mesas"),
                ),
                _sidebarIcon(
                  "assets/sidebar/Platos.png",
                  onTap: () => onItemTap?.call("Platos"),
                ),
                _sidebarIcon(
                  "assets/sidebar/Config.png",
                  onTap: () => onItemTap?.call("Config"),
                ),
                _sidebarIcon(
                  "assets/sidebar/go_out.png",
                  onTap: () => onItemTap?.call("Salir"),
                ),
                const Spacer(),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
