import 'package:flutter/material.dart';
import 'widgets/header.dart';
import 'widgets/sidebar.dart';
import 'users/panel_user.dart';
import 'users/panel_rolAndDepartament.dart';
import 'Dishes/panel_dishes.dart';
import 'auth/login_page.dart';
import 'services/user_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isSidebarOpen = false;
  String currentPage = 'Home';

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
        currentPage = item;
        isSidebarOpen = false;
      });
    }
  }

  Widget _buildContent() {
    Widget content;

    switch (currentPage) {
      case 'Home':
        content = Container(
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
        break;
      case 'Usuarios':
        content = const PanelUserScreen();
        break;
      case 'Platos':
        content = const PanelDishes();
        break;
      case 'Roles/Departamentos':
        content = const PanelRolAndDepartament();
        break;
      case 'Ventas':
        content = Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(child: Text('Ventas Content', style: TextStyle(fontSize: 18))),
        );
        break;
      case 'Pedidos':
        content = Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(child: Text('Pedidos Content', style: TextStyle(fontSize: 18))),
        );
        break;
      case 'Mesas':
        content = Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(child: Text('Mesas Content', style: TextStyle(fontSize: 18))),
        );
        break;
      case 'Config':
        content = Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(child: Text('Configuración', style: TextStyle(fontSize: 18))),
        );
        break;
      default:
        content = Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(child: Text('Default Content', style: TextStyle(fontSize: 18))),
        );
        break;
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
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
            selectedItem: currentPage,
          ),
        ],
      ),
    );
  }
}