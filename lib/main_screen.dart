import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/header.dart';
import 'widgets/sidebar.dart';

import 'package:as241s4_t13_appmovil/features/users/panel_user.dart';
import 'package:as241s4_t13_appmovil/features/customers/panel_customer.dart';
import 'package:as241s4_t13_appmovil/features/rol_department/panel_rolAndDepartament.dart';
import 'package:as241s4_t13_appmovil/features/catalog/panel_catalog.dart';
import 'package:as241s4_t13_appmovil/features/dashboard/dashboard_panel.dart';
import 'package:as241s4_t13_appmovil/login/login_page.dart';
import 'package:as241s4_t13_appmovil/features/table/panel_table.dart';
import 'package:as241s4_t13_appmovil/features/orders/panel_order.dart';
import 'package:as241s4_t13_appmovil/core/services/users/user_service.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';
import 'package:as241s4_t13_appmovil/features/sales/panel_sales.dart';


enum AppPage {
  home,
  rolesDepartamentos,
  usuarios,
  clientes,
  catalogo,
  mesas,
  pedidos,
  ventas,
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = false;
  AppPage _currentPage = AppPage.home;
  late AnimationController _pageTransitionController;

  late final List<SidebarMenuItem> _menuItems;

  @override
  void initState() {
    super.initState();
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pageTransitionController.forward();

    // Orden correcto del menú
    _menuItems = [
      const SidebarMenuItem(
        key: 'Home',
        title: 'Dashboard',
        icon: Icons.dashboard_rounded,
      ),
      const SidebarMenuItem(
        key: 'Roles/Departamentos',
        title: 'Roles y Departamentos',
        icon: Icons.workspaces_outline,
      ),
      const SidebarMenuItem(
        key: 'Usuarios',
        title: 'Usuarios',
        icon: Icons.people_alt_rounded,
        badge: 5,
      ),
      const SidebarMenuItem(
        key: 'Clientes',
        title: 'Clientes',
        icon: Icons.business_center_rounded,
        badge: 12,
      ),
      const SidebarMenuItem(
        key: 'Catálogo',
        title: 'Catálogo',
        icon: Icons.storefront_rounded,
        badge: 12,
      ),
      const SidebarMenuItem(
        key: 'Mesas',
        title: 'Mesas',
        icon: Icons.table_bar_rounded,
      ),
      const SidebarMenuItem(
        key: 'Pedidos',
        title: 'Pedidos',
        icon: Icons.receipt_long_rounded,
        badge: 3,
      ),
      const SidebarMenuItem(
        key: 'Ventas',
        title: 'Ventas',
        icon: Icons.point_of_sale_rounded,
      ),
    ];
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    super.dispose();
  }

  // Mapeo de keys a páginas
  static const Map<String, AppPage> _pageMap = {
    'Home': AppPage.home,
    'Roles/Departamentos': AppPage.rolesDepartamentos,
    'Usuarios': AppPage.usuarios,
    'Clientes': AppPage.clientes,
    'Catálogo': AppPage.catalogo,
    'Mesas': AppPage.mesas,
    'Pedidos': AppPage.pedidos,
    'Ventas': AppPage.ventas,
  };

  // Mapeo inverso para obtener el key desde la página
  static const Map<AppPage, String> _pageToKeyMap = {
    AppPage.home: 'Home',
    AppPage.rolesDepartamentos: 'Roles/Departamentos',
    AppPage.usuarios: 'Usuarios',
    AppPage.clientes: 'Clientes',
    AppPage.catalogo: 'Catálogo',
    AppPage.mesas: 'Mesas',
    AppPage.pedidos: 'Pedidos',
    AppPage.ventas: 'Ventas',
  };

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _handleMenuTap(String itemKey) {
    final page = _pageMap[itemKey];
    if (page != null && page != _currentPage) {
      _pageTransitionController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentPage = page;
          _isSidebarOpen = false;
        });
        _pageTransitionController.forward();
      });
    } else if (page == _currentPage) {
      setState(() {
        _isSidebarOpen = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: Color(0xFFFF6B35)),
            SizedBox(width: 12),
            Text('Cerrar Sesión'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Salir',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      AuthService.clearContext();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  Widget _buildPlaceholderContent(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: const Color(0xFFFF6B35).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'Próximamente...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
        begin: const Offset(0.8, 0.8),
        duration: 400.ms,
        curve: Curves.easeOutBack);
  }

  String _getPageTitle() {
    switch (_currentPage) {
      case AppPage.home:
        return 'Dashboard';
      case AppPage.rolesDepartamentos:
        return 'Roles y Departamentos';
      case AppPage.usuarios:
        return 'Usuarios';
      case AppPage.clientes:
        return 'Clientes';
      case AppPage.catalogo:
        return 'Catálogo';
      case AppPage.mesas:
        return 'Mesas';
      case AppPage.pedidos:
        return 'Pedidos';
      case AppPage.ventas:
        return 'Ventas';
    }
  }

  Widget _getPageContent() {
    switch (_currentPage) {
      case AppPage.home:
        return const DashboardPanel();
      case AppPage.rolesDepartamentos:
        return const PanelRolAndDepartament();
      case AppPage.usuarios:
        return const PanelUserScreen();
      case AppPage.clientes:
        return const PanelCustomerScreen();
      case AppPage.catalogo:
        return const PanelCatalogScreen();
      case AppPage.mesas:
        return const PanelTableScreen();
      case AppPage.pedidos:
        return const OrderPanel();
      case AppPage.ventas:
        return const PanelSales();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedItemKey = _pageToKeyMap[_currentPage] ?? 'Home';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _pageTransitionController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _pageTransitionController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.02, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _pageTransitionController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  left: false,
                  right: false,
                  child: AppHeader(
                    onMenuTap: _toggleSidebar,
                    title: _getPageTitle(),
                    enableGlassEffect: true,
                  ),
                ),
                Expanded(
                  child: _getPageContent(),
                ),
              ],
            ),
          ),
          AppSidebar(
            isOpen: _isSidebarOpen,
            selectedItem: selectedItemKey,
            menuItems: _menuItems,
            userProfile: UserProfile(
              name: _getUserName(),
              role: _getUserRole(),
              avatarUrl: null,
            ),
            enableGlassEffect: true,
            onItemTap: _handleMenuTap,
            onClose: () => setState(() => _isSidebarOpen = false),
            onLogout: _handleLogout,
          ),
        ],
      ),
    );
  }

  String _getUserName() {
    return 'Carlo';
  }

  String _getUserRole() {
    return 'Administrador';
  }
}
