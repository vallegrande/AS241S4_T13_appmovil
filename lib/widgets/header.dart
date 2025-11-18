import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header principal con diseño naranja premium
class AppHeader extends StatefulWidget {
  final VoidCallback? onMenuTap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final String? title;
  final List<Widget>? actions;
  final bool enableGlassEffect;
  final Color? backgroundColor;

  const AppHeader({
    super.key,
    this.onMenuTap,
    this.showBackButton = false,
    this.onBackPressed,
    this.title,
    this.actions,
    this.enableGlassEffect = false,
    this.backgroundColor,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  bool _isPressed = false;

  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color lightOrange = Color(0xFFFF8C42);
  static const Color accentOrange = Color(0xFFFFA556);

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleMenuPress() {
    setState(() => _isPressed = true);
    _rippleController.forward().then((_) {
      _rippleController.reverse();
      setState(() => _isPressed = false);
    });
    widget.onMenuTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 12, // ← SIN topPadding porque SafeArea ya lo maneja
        left: 18,
        right: 18,
        bottom: 12, // ← REDUCIDO: era 16, ahora 8 para no cortar contenido
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryOrange,
            lightOrange,
            accentOrange,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!widget.showBackButton)
            _buildMenuButton()
          else
            _buildBackButton(context),
          if (widget.title != null) _buildTitle(),
          if (widget.title != null) const Spacer(),
          _buildLogo(),
          if (widget.actions != null) ...[
            const SizedBox(width: 8),
            Row(children: widget.actions!),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _isPressed ? 1 : 0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 - (value * 0.08),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => _handleMenuPress(),
            onTapCancel: () => setState(() => _isPressed = false),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(_isPressed ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  if (_isPressed)
                    AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        return Container(
                          width: 45 * _rippleController.value,
                          height: 45 * _rippleController.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                0.6 * (1 - _rippleController.value),
                              ),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.3, duration: 500.ms);
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onBackPressed ?? () => Navigator.maybePop(context),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    )
        .animate()
        .slideX(
          begin: -0.5,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: 300.ms);
  }

  Widget _buildTitle() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          widget.title!,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        )
            .animate()
            .fadeIn(
              duration: 500.ms,
              delay: 200.ms,
            )
            .slideX(
              begin: -0.2,
              duration: 500.ms,
              delay: 200.ms,
            ),
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo',
      child: Image.asset(
        "assets/header/Logo.png",
        height: 70,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 28,
            ),
          );
        },
      ),
    )
        .animate()
        .fadeIn(
          duration: 500.ms,
          delay: 300.ms,
        )
        .slideX(
          begin: 0.3,
          duration: 500.ms,
          delay: 300.ms,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 500.ms,
          delay: 300.ms,
        );
  }
}
