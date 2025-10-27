import 'package:flutter/material.dart';
import 'widgets/header.dart';
import 'widgets/sidebar.dart';

import 'package:as241s4_t13_appmovil/features/users/panel_user.dart';
import 'package:as241s4_t13_appmovil/features/rol_department/panel_rolAndDepartament.dart';
import 'package:as241s4_t13_appmovil/features/catalog/panel_catalog.dart';
import 'package:as241s4_t13_appmovil/login/login_page.dart';
import 'package:as241s4_t13_appmovil/core/services/users/user_service.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';

enum AppPage {
  Home,
  Usuarios,
  RolesDepartamentos,
  Catalogo,
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
  AppPage currentPage = AppPage.Home;

  static const Map<String, AppPage> pageMap = {
    'Home': AppPage.Home,
    'Usuarios': AppPage.Usuarios,
    'Roles y Departamentos': AppPage.RolesDepartamentos,
    'Catálogo': AppPage.Catalogo,
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

  void _handleMenuTap(String page) {
    setState(() {
      currentPage = pageMap[page] ?? AppPage.Home;
      isSidebarOpen = false;
    });
  }

  void _logout() {
    AuthService.clearContext();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget _buildPlaceholderContent(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Próximamente...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: _getPageContent(),
    );
  }

  Widget _getPageContent() {
    switch (currentPage) {
      case AppPage.Home:
        return _buildPlaceholderContent('Dashboard Principal');
      case AppPage.Usuarios:
        return const PanelUserScreen();
      case AppPage.RolesDepartamentos:
        return const PanelRolAndDepartament();
      case AppPage.Catalogo:
        return const PanelCatalogScreen();
      case AppPage.Ventas:
        return _buildPlaceholderContent('Módulo de Ventas');
      case AppPage.Pedidos:
        return _buildPlaceholderContent('Módulo de Pedidos');
      case AppPage.Mesas:
        return _buildPlaceholderContent('Módulo de Mesas');
      case AppPage.Config:
        return _buildPlaceholderContent('Configuración del Sistema');
      default:
        return _buildPlaceholderContent('Contenido no encontrado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedItemString = pageMap.entries
        .firstWhere(
          (entry) => entry.value == currentPage,
          orElse: () => pageMap.entries.first,
        )
        .key;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
            onLogout: _logout,
            selectedItem: selectedItemString,
            menuItems: pageMap.keys.toList(),
          ),
        ],
      ),
    );
  }
}