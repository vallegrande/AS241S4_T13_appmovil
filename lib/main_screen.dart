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
import 'package:as241s4_t13_appmovil/core/services/users/user_service.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';

enum AppPage {
  home,
  usuarios,
  clientes,
  rolesDepartamentos,
  catalogo,
  ventas,
  pedidos,
  mesas,
  config,
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

  // Configuración de items del menú con el nuevo modelo
  late final List<SidebarMenuItem> _menuItems;

  @override
  void initState() {
    super.initState();
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // CORRECCIÓN PARA LA OPACIDAD: Iniciar la animación al cargar la pantalla.
    _pageTransitionController.forward();

    // Inicializar items del menú con badges de ejemplo
    _menuItems = [
      const SidebarMenuItem(
        key: 'Home',
        title: 'Dashboard',
        icon: Icons.dashboard_rounded,
      ),
      const SidebarMenuItem(
        key: 'Usuarios',
        title: 'Usuarios',
        icon: Icons.people_alt_rounded,
        badge: 5, // Ejemplo: 5 usuarios nuevos
      ),
      const SidebarMenuItem(
        key: 'Clientes',
        title: 'Clientes',
        icon: Icons.business_center_rounded,
        badge: 12, // Ejemplo: 12 clientes nuevos
      ),
      const SidebarMenuItem(
        key: 'Roles/Departamentos',
        title: 'Roles y Departamentos',
        icon: Icons.workspaces_outline,
      ),
      const SidebarMenuItem(
        key: 'Catálogo',
        title: 'Catálogo',
        icon: Icons.storefront_rounded,
        badge: 12, // Ejemplo: 12 productos nuevos
      ),
      const SidebarMenuItem(
        key: 'Ventas',
        title: 'Ventas',
        icon: Icons.point_of_sale_rounded,
      ),
      const SidebarMenuItem(
        key: 'Pedidos',
        title: 'Pedidos',
        icon: Icons.receipt_long_rounded,
        badge: 3, // Ejemplo: 3 pedidos pendientes
      ),
      const SidebarMenuItem(
        key: 'Mesas',
        title: 'Mesas',
        icon: Icons.table_bar_rounded,
      ),
      const SidebarMenuItem(
        key: 'Config',
        title: 'Configuración',
        icon: Icons.settings_rounded,
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
    'Usuarios': AppPage.usuarios,
    'Clientes': AppPage.clientes,
    'Roles/Departamentos': AppPage.rolesDepartamentos,
    'Catálogo': AppPage.catalogo,
    'Ventas': AppPage.ventas,
    'Pedidos': AppPage.pedidos,
    'Mesas': AppPage.mesas,
    'Config': AppPage.config,
  };

  // Mapeo inverso para obtener el key desde la página
  static const Map<AppPage, String> _pageToKeyMap = {
    AppPage.home: 'Home',
    AppPage.usuarios: 'Usuarios',
    AppPage.clientes: 'Clientes',
    AppPage.rolesDepartamentos: 'Roles/Departamentos',
    AppPage.catalogo: 'Catálogo',
    AppPage.ventas: 'Ventas',
    AppPage.pedidos: 'Pedidos',
    AppPage.mesas: 'Mesas',
    AppPage.config: 'Config',
  };

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _handleMenuTap(String itemKey) {
    final page = _pageMap[itemKey];
    if (page != null && page != _currentPage) {
      // Usar reverse y forward para la transición de página
      // Esto asegura la animación de fade out y luego fade in.
      _pageTransitionController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentPage = page;
          _isSidebarOpen = false;
        });
        _pageTransitionController.forward();
      });
    } else if (page == _currentPage) {
      // Solo cerrar sidebar si selecciona la misma página
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
            Icon(Icons.logout_rounded, color: Color(0xFFFF1100)),
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
              backgroundColor: const Color(0xFFFF1100),
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
      // Limpiar contexto de autenticación
      AuthService.clearContext();

      if (!mounted) return;

      // Navegar al login con animación
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
              color: const Color(0xFFFF1100).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: const Color(0xFFFF1100).withOpacity(0.6),
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
      case AppPage.usuarios:
        return 'Usuarios';
      case AppPage.clientes:
        return 'Clientes';
      case AppPage.rolesDepartamentos:
        return 'Roles y Departamentos';
      case AppPage.catalogo:
        return 'Catálogo';
      case AppPage.ventas:
        return 'Ventas';
      case AppPage.pedidos:
        return 'Pedidos';
      case AppPage.mesas:
        return 'Mesas';
      case AppPage.config:
        return 'Configuración';
    }
  }

  Widget _getPageContent() {
    switch (_currentPage) {
      case AppPage.home:
        return const DashboardPanel();
      case AppPage.usuarios:
        return const PanelUserScreen();
      case AppPage.clientes:
        return const PanelCustomerScreen();
      case AppPage.rolesDepartamentos:
        return const PanelRolAndDepartament();
      case AppPage.catalogo:
        return const PanelCatalogScreen();
      case AppPage.ventas:
        return _buildPlaceholderContent(
          'Módulo de Ventas',
          Icons.point_of_sale_rounded,
        );
      case AppPage.pedidos:
        return _buildPlaceholderContent(
          'Módulo de Pedidos',
          Icons.receipt_long_rounded,
        );
      case AppPage.mesas:
        return _buildPlaceholderContent(
          'Módulo de Mesas',
          Icons.table_bar_rounded,
        );
      case AppPage.config:
        return _buildPlaceholderContent(
          'Configuración del Sistema',
          Icons.settings_rounded,
        );
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
          // Contenido principal con transición
          AnimatedBuilder(
            animation: _pageTransitionController,
            builder: (context, child) {
              return FadeTransition(
                // Usa el valor del controlador para la opacidad
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
                // Header - aplica SafeArea aquí para que respete status bar
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

                // Contenido de la página
                Expanded(
                  child: _getPageContent(),
                ),
              ],
            ),
          ),

          // Sidebar con glassmorphism
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

  // Métodos para obtener información del usuario
  String _getUserName() {
    return 'Carlo';
  }

  String _getUserRole() {
    return 'Administrador';
  }
}
