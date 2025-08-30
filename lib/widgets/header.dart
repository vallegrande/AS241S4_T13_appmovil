import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const AppHeader({super.key, this.onMenuTap});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      color: const Color(0xFFFF1100),
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
                onTap: onMenuTap,
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
    );
  }
}
