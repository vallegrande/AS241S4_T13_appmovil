import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppHeader({
    super.key,
    this.onMenuTap,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 18,
        right: 18,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFF1100),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + Hamburguesa o Botón de Retroceso
          Row(
            children: [
              // Botón de menú con animación
              if (!showBackButton)
                AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: onMenuTap != null ? 1.0 : 0.85,
                  curve: Curves.bounceOut,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: onMenuTap,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 14),
              // Logo con animación de pulso (original colors)
              AnimatedScale(
                duration: const Duration(milliseconds: 600),
                scale: 1.0,
                curve: Curves.easeOutBack,
                // Asumiendo que tienes un logo en assets/header/Logo.png
                child: Image.asset("assets/header/Logo.png", height: 40), 
              ),
            ],
          ),
          // Botón de retroceso
          if (showBackButton)
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: showBackButton ? 1.0 : 0.85,
              curve: Curves.bounceOut,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onBackPressed ?? () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                ),
              ),
            ),
        ],
      ),
    );
  }
}