import 'package:flutter/material.dart';
import 'widgets/header.dart';
import 'widgets/sidebar.dart';
import 'users/panel_user.dart';
import 'users/panel_rolAndDepartament.dart';
import 'Dishes/catalog_page.dart';
import 'auth/login_page.dart';
import 'services/user_service.dart';

// Enum para gestionar las páginas de forma segura
enum AppPage {
  Home,
  Usuarios,
  Platos,
  RolesDepartamentos,
  Ventas,
  Pedidos,
  Mesas,
  Config,
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isSidebarOpen = false;
  AppPage currentPage = AppPage.Home; // Usar el enum

  // Mapa para convertir los strings del menú a enums
  static const Map<String, AppPage> pageMap = {
    'Home': AppPage.Home,
    'Usuarios': AppPage.Usuarios,
    'Platos': AppPage.Platos,
    'Roles/Departamentos': AppPage.RolesDepartamentos,
    'Ventas': AppPage.Ventas,
    'Pedidos': AppPage.Pedidos,
    'Mesas': AppPage.Mesas,
    'Config': AppPage.Config,
  };

  void _toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  void _handleMenuTap(String item) {
    if (item == 'Salir') {
      TokenManager.clear();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      setState(() {
        // Convertir el string a enum usando el mapa
        currentPage = pageMap[item] ?? AppPage.Home;
        isSidebarOpen = false;
      });
    }
  }

  // Widget reutilizable para contenido de marcador de posición
  Widget _buildPlaceholderContent(String title) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(child: Text(title, style: const TextStyle(fontSize: 18))),
    );
  }

  Widget _buildContent() {
    switch (currentPage) {
      case AppPage.Home:
        return Container(
          color: const Color(0xFFF5F5F5),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 20),
                Text(
                  'Bienvenido al Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
                Text(
                  'Selecciona una opción del menú',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      case AppPage.Usuarios:
        return const PanelUserScreen();
      case AppPage.Platos:
        return const CatalogPage();
      case AppPage.RolesDepartamentos:
        return const PanelRolAndDepartament();
      case AppPage.Ventas:
        return _buildPlaceholderContent('Ventas Content');
      case AppPage.Pedidos:
        return _buildPlaceholderContent('Pedidos Content');
      case AppPage.Mesas:
        return _buildPlaceholderContent('Mesas Content');
      case AppPage.Config:
        return _buildPlaceholderContent('Configuración');
      default:
        return _buildPlaceholderContent('Default Content');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Convierte el enum a string para el `selectedItem` del sidebar
    final selectedItemString = pageMap.entries
        .firstWhere((entry) => entry.value == currentPage, orElse: () => pageMap.entries.first)
        .key;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          _buildContent(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppHeader(onMenuTap: _toggleSidebar),
          ),
          AppSidebar(
            isOpen: isSidebarOpen,
            onClose: _toggleSidebar,
            onItemTap: _handleMenuTap,
            selectedItem: selectedItemString,
          ),
        ],
      ),
    );
  }
}
