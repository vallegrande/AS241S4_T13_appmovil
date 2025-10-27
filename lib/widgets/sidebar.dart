import 'package:flutter/material.dart';
import 'dart:ui';

class AppSidebar extends StatelessWidget {
  final bool isOpen;
  final Function(String)? onItemTap;
  final VoidCallback? onClose;
  final VoidCallback? onLogout;
  final String selectedItem;
  final List<String> menuItems;

  // Definición de colores principales
  static const Color primaryColor = Color(0xFFFF1100);
  static const Color backgroundColor = Color(0xFFF7F8FA);
  static const Color accentColor = Color(0xFFEFEFEF);
  static const Color textColor = Colors.black87;

  const AppSidebar({
    super.key,
    required this.isOpen,
    this.onItemTap,
    this.onClose,
    this.onLogout,
    this.selectedItem = 'Home',
    this.menuItems = const [
      'Home',
      'Usuarios',
      'Roles/Departamentos',
      'Catálogo',
      'Ventas',
      'Pedidos',
      'Mesas',
      'Config'
    ],
  });

  static const Map<String, IconData> _iconData = {
    'Home': Icons.dashboard,
    'Usuarios': Icons.people_alt_rounded,
    'Roles/Departamentos': Icons.workspaces_outline,
    'Catálogo': Icons.storefront_rounded,
    'Ventas': Icons.point_of_sale_rounded,
    'Pedidos': Icons.receipt_long_rounded,
    'Mesas': Icons.table_bar_rounded,
    'Config': Icons.settings_rounded,
    'Cerrar Sesión': Icons.logout_rounded,
  };

  // 🗑️ ELIMINADA: Se quitó la función _maybeBadge (con sus referencias)

  // Widget para cada ítem del menú (Diseño limpio y moderno)
  Widget _sidebarItem({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    final icon = _iconData[title] ?? Icons.circle_outlined;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4), 
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            // Fondo sutil: 10% de opacidad del color primario
            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            // Borde ligero para resaltar la selección
            border: isSelected ? Border.all(color: primaryColor.withOpacity(0.2), width: 1.5) : null,
          ),
          child: Row(
            children: [
              // Indicador vertical de selección (la "barrita" roja)
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: 4, 
                height: 24, 
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
              ),
              const SizedBox(width: 12),
              // Icono
              Icon(
                icon,
                size: 24,
                color: isSelected ? primaryColor : Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              // Título del ítem
              Expanded(
                child: Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? primaryColor : textColor,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Flecha de indicador de selección
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.chevron_right_rounded, size: 20, color: primaryColor.withOpacity(0.8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget de Avatar de Perfil
  Widget _profileAvatar({
    required String name,
    String role = 'Usuario',
    VoidCallback? onTap,
  }) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
        : 'U';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10, top: 10), 
        child: Row(
          children: [
            CircleAvatar(
              radius: 24, 
              backgroundColor: primaryColor.withOpacity(0.9), 
              child: Text(
                initials,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close_rounded, color: Colors.grey.shade600),
              tooltip: 'Cerrar menú',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double sidebarWidth = 300.0;
    final bool smallScreen = screenWidth < 720;

    // Se ajustó el cálculo del desplazamiento para cuando está cerrado
    final closedOffset = -(smallScreen ? (screenWidth * 0.70) : sidebarWidth) - 24;

    return Stack(
      children: [
        if (isOpen)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 260),
            opacity: isOpen ? 1.0 : 0.0,
            child: GestureDetector(
              onTap: onClose,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  width: screenWidth,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
          ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOut,
          left: isOpen ? 0 : closedOffset,
          top: 0,
          bottom: 0,
          width: smallScreen ? screenWidth * 0.70 : sidebarWidth,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              // Estilo de contenedor principal
              decoration: const BoxDecoration(
                color: backgroundColor, 
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12, 
                    blurRadius: 15,
                    offset: Offset(4, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileAvatar(name: 'Carlo', role: 'Administrador', onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abrir perfil (demo)')),
                    );
                  }),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: accentColor), 
                  const SizedBox(height: 16),
                  // Barra de Búsqueda
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12), 
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, size: 20, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onSubmitted: (q) {},
                            decoration: const InputDecoration(
                              hintText: 'Buscar...',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                              isCollapsed: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Lista de Ítems
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: menuItems.map((item) {
                          // Se usa "Roles y Departamentos" solo para la visualización del título
                          final displayTitle = item == 'Roles/Departamentos' ? 'Roles y Departamentos' : item;
                          final isSelected = item == selectedItem;
                          return _sidebarItem(
                            context: context,
                            title: displayTitle,
                            isSelected: isSelected,
                            onTap: () {
                              onItemTap?.call(item);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // --- Sección Inferior (Ajustes y Salir) ---
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Botón Ajustes
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            onItemTap?.call('Config');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04), 
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.tune_rounded, size: 18, color: primaryColor),
                                const SizedBox(width: 8),
                                Text('Ajustes', style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón Salir
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: onLogout,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: primaryColor,
                            elevation: 8, 
                            shadowColor: primaryColor.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                              SizedBox(width: 6),
                              Text('Salir', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}