// lib/main_screen.dart
import 'package:flutter/material.dart';
import 'widgets/header.dart';
import 'widgets/sidebar.dart';
import 'Dishes/panel_dishes.dart';
import 'users/panel_user.dart'; // Use the provided PanelUserScreen
import 'auth/login_page.dart'; // For logout navigation

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isSidebarOpen = false;
  String currentPage = 'Home'; // Track current content to display

  void _toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  void _handleMenuTap(String item) {
    print('Selected item: $item'); // Debug log
    setState(() {
      currentPage = item;
      isSidebarOpen = false; // Close sidebar after selection
    });
  }

  Widget _buildContent() {
    switch (currentPage) {
      case 'Home':
        return const Center(child: Text('Home Content'));
      case 'Platos':
        return const PanelDishes(); // Improved dishes panel
      case 'Usuarios': // Changed from 'Users' to 'Usuarios'
        return const PanelUserScreen(); // Use the provided users panel
      case 'Ventas':
        return const Center(child: Text('Ventas Content'));
      case 'Pedidos':
        return const Center(child: Text('Pedidos Content'));
      case 'Mesas':
        return const Center(child: Text('Mesas Content'));
      case 'Config':
        return const Center(child: Text('Config Content'));
      case 'Salir':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return Container(); // Placeholder while navigating
      default:
        return const Center(child: Text('Default Content'));
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {}); // Force initial rebuild to sync state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content area
          _buildContent(),
          // Header (fixed at top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppHeader(onMenuTap: _toggleSidebar),
          ),
          // Sidebar (overlay)
          AppSidebar(
            isOpen: isSidebarOpen,
            onItemTap: _handleMenuTap,
            onClose: _toggleSidebar,
            selectedItem: currentPage, // Pass current page for highlighting
          ),
        ],
      ),
    );
  }
}