import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sidebar moderno con paleta naranja y diseño premium
class AppSidebar extends StatefulWidget {
  final bool isOpen;
  final Function(String)? onItemTap;
  final VoidCallback? onClose;
  final VoidCallback? onLogout;
  final String selectedItem;
  final List<SidebarMenuItem> menuItems;
  final UserProfile? userProfile;
  final bool enableGlassEffect;

  const AppSidebar({
    super.key,
    required this.isOpen,
    this.onItemTap,
    this.onClose,
    this.onLogout,
    this.selectedItem = 'Home',
    this.menuItems = const [],
    this.userProfile,
    this.enableGlassEffect = true,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _itemsController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';
  int _hoveredIndex = -1;

  // Paleta naranja premium
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color lightOrange = Color(0xFFFF8C42);
  static const Color accentOrange = Color(0xFFFFA556);
  static const Color backgroundColor = Color(0xFFFFFBF7);
  static const Color darkBackgroundColor = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _itemsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (widget.isOpen) {
      _slideController.forward();
      _itemsController.forward();
    }
  }

  @override
  void didUpdateWidget(AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _slideController.forward();
        _itemsController.forward();
      } else {
        _slideController.reverse();
        _itemsController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _itemsController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<SidebarMenuItem> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.menuItems;
    return widget.menuItems.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    const double sidebarWidth = 240.0; // Reducido de 260 a 240
    final bool isSmallScreen = screenWidth < 720;
    final effectiveWidth = isSmallScreen ? screenWidth * 0.65 : sidebarWidth;

    return Stack(
      children: [
        // Backdrop overlay
        if (widget.isOpen)
          GestureDetector(
            onTap: widget.onClose,
            child: AnimatedBuilder(
              animation: _slideController,
              builder: (context, child) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8 * _slideController.value,
                    sigmaY: 8 * _slideController.value,
                  ),
                  child: Container(
                    color:
                        Colors.black.withOpacity(0.4 * _slideController.value),
                    width: screenWidth,
                    height: screenSize.height,
                  ),
                );
              },
            ),
          ),

        // Sidebar container
        AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            final slideValue =
                Curves.easeOutCubic.transform(_slideController.value);
            return Positioned(
              left: -effectiveWidth + (effectiveWidth * slideValue),
              top: 0,
              bottom: 0,
              width: effectiveWidth,
              child: child!,
            );
          },
          child: _buildSidebarContent(context, isDark, effectiveWidth),
        ),
      ],
    );
  }

  Widget _buildSidebarContent(BuildContext context, bool isDark, double width) {
    final topPadding = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      darkBackgroundColor.withOpacity(0.95),
                      darkBackgroundColor.withOpacity(0.9),
                    ]
                  : [
                      Colors.white.withOpacity(0.98),
                      backgroundColor.withOpacity(0.95),
                    ],
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            border: Border.all(
              color: primaryOrange.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryOrange.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(8, 0),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(5, 0),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: topPadding + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(context, isDark),
                const SizedBox(height: 16),
                _buildDivider(isDark),
                const SizedBox(height: 16),
                _buildSearchBar(isDark),
                const SizedBox(height: 20),
                _buildMenuSection(context, isDark),
                const SizedBox(height: 16),
                _buildBottomActions(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, bool isDark) {
    final profile = widget.userProfile ??
        UserProfile(name: 'Carlo', role: 'Administrador', avatarUrl: null);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Abrir perfil'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryOrange.withOpacity(0.12),
                lightOrange.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryOrange.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Hero(
                tag: 'user_avatar',
                child: _buildAvatar(profile, isDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: GoogleFonts.poppins(
                        fontSize: 17, // Aumentado de 15 a 17
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.role,
                      style: GoogleFonts.inter(
                        fontSize: 14, // Aumentado de 12 a 14
                        fontWeight: FontWeight.w500,
                        color: primaryOrange,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Cerrar menú',
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: 100.ms,
        )
        .slideX(
          begin: -0.2,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildAvatar(UserProfile profile, bool isDark) {
    final initials = profile.name
        .trim()
        .split(' ')
        .map((s) => s.isNotEmpty ? s[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryOrange,
            lightOrange,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            primaryOrange.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _searchFocus.hasFocus
              ? primaryOrange.withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _searchFocus.hasFocus
                ? primaryOrange.withOpacity(0.15)
                : Colors.black.withOpacity(isDark ? 0.1 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: GoogleFonts.inter(
          fontSize: 15, // Aumentado de 13 a 15
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar menú...',
          hintStyle: GoogleFonts.inter(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            fontSize: 15, // Aumentado de 13 a 15
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _searchFocus.hasFocus
                ? primaryOrange
                : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: 200.ms,
        )
        .slideY(
          begin: -0.1,
          duration: 400.ms,
        );
  }

  Widget _buildMenuSection(BuildContext context, bool isDark) {
    final filteredItems = _filteredItems;

    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: List.generate(
            filteredItems.length,
            (index) {
              final item = filteredItems[index];
              final isSelected = item.key == widget.selectedItem;

              return _buildMenuItem(
                context: context,
                item: item,
                isSelected: isSelected,
                isDark: isDark,
                index: index,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required SidebarMenuItem item,
    required bool isSelected,
    required bool isDark,
    required int index,
  }) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      cursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onItemTap?.call(item.key),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          primaryOrange,
                          lightOrange,
                        ],
                      )
                    : isHovered
                        ? LinearGradient(
                            colors: [
                              primaryOrange.withOpacity(0.08),
                              lightOrange.withOpacity(0.05),
                            ],
                          )
                        : null,
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? null
                    : isHovered
                        ? Border.all(
                            color: primaryOrange.withOpacity(0.2),
                            width: 1.5,
                          )
                        : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryOrange.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    width: 3,
                    height: isSelected ? 22 : 0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: isSelected ? 10 : 0),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: isSelected
                          ? Colors.white
                          : (isHovered
                              ? primaryOrange
                              : (isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 16, // Aumentado de 14 a 16
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isHovered
                                ? primaryOrange
                                : (isDark
                                    ? Colors.white.withOpacity(0.87)
                                    : const Color(0xFF2D3748))),
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.badge != null) _buildBadge(item.badge!, isSelected),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: isSelected ? 1.0 : 0.0,
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: (100 + (index * 50)).ms,
        )
        .slideX(
          begin: -0.2,
          duration: 400.ms,
          delay: (100 + (index * 50)).ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildBadge(int count, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : accentOrange,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: (isSelected ? Colors.white : accentOrange).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isSelected ? primaryOrange : Colors.white,
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.settings_rounded,
            label: 'Ajustes',
            onTap: () => widget.onItemTap?.call('Config'),
            isPrimary: false,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            icon: Icons.logout_rounded,
            label: 'Salir',
            onTap: widget.onLogout,
            isPrimary: true,
            isDark: isDark,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: 400.ms,
        )
        .slideY(
          begin: 0.2,
          duration: 400.ms,
          delay: 400.ms,
        );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isPrimary,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [primaryOrange, lightOrange],
                  )
                : null,
            color: isPrimary
                ? null
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: !isPrimary
                ? Border.all(
                    color: primaryOrange.withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: primaryOrange.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isPrimary ? Colors.white : primaryOrange,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15, // Aumentado de 13 a 15
                  color: isPrimary ? Colors.white : primaryOrange,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modelo de datos para items del menú
class SidebarMenuItem {
  final String key;
  final String title;
  final IconData icon;
  final int? badge;

  const SidebarMenuItem({
    required this.key,
    required this.title,
    required this.icon,
    this.badge,
  });
}

/// Modelo de perfil de usuario
class UserProfile {
  final String name;
  final String role;
  final String? avatarUrl;

  const UserProfile({
    required this.name,
    required this.role,
    this.avatarUrl,
  });
}
