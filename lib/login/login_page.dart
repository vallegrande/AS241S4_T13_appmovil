import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';
import '../main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = const FlutterSecureStorage();

  String? _errorMessage;
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _usernameFocused = false;
  bool _passwordFocused = false;
  bool _rememberMe = false;

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(() {
      setState(() => _usernameFocused = _usernameFocus.hasFocus);
    });
    _passwordFocus.addListener(() {
      setState(() => _passwordFocused = _passwordFocus.hasFocus);
    });
    _loadSavedCredentials();
  }

  // Cargar credenciales guardadas
  Future<void> _loadSavedCredentials() async {
    try {
      final username = await _secureStorage.read(key: 'username');
      final password = await _secureStorage.read(key: 'password');
      final rememberMe = await _secureStorage.read(key: 'rememberMe');

      if (mounted && username != null && password != null) {
        setState(() {
          _usernameController.text = username;
          _passwordController.text = password;
          _rememberMe = rememberMe == 'true';
        });
      }
    } catch (e) {
      debugPrint('Error loading credentials: $e');
    }
  }

  // Guardar credenciales
  Future<void> _saveCredentials() async {
    try {
      await _secureStorage.write(
          key: 'username', value: _usernameController.text);
      await _secureStorage.write(
          key: 'password', value: _passwordController.text);
      await _secureStorage.write(key: 'rememberMe', value: 'true');
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  // Eliminar credenciales guardadas
  Future<void> _clearCredentials() async {
    try {
      await _secureStorage.delete(key: 'username');
      await _secureStorage.delete(key: 'password');
      await _secureStorage.delete(key: 'rememberMe');
    } catch (e) {
      debugPrint('Error clearing credentials: $e');
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    AuthService.clearContext();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (response.success) {
        // Si login es exitoso y rememberMe está activo, guardar credenciales
        if (_rememberMe) {
          await _saveCredentials();
        } else {
          await _clearCredentials();
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        setState(() {
          _errorMessage =
              response.message ?? 'Error desconocido al iniciar sesión.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error de conexión o credenciales inválidas.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeader(isSmallScreen),
                        const SizedBox(height: 48),
                        _buildLoginCard(isSmallScreen),
                        const SizedBox(height: 24),
                        _buildFooter(isSmallScreen),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B35),
            Color(0xFFFF8C42),
            Color(0xFFFFA556),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -50,
            top: 100,
            child: Opacity(
              opacity: 0.1,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: 300,
            child: Opacity(
              opacity: 0.1,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 50,
            bottom: 100,
            child: Opacity(
              opacity: 0.1,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 100 : 150,
          height: isSmallScreen ? 100 : 150,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.3),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Image.asset(
            'assets/header/Logo.png',
            fit: BoxFit.contain,
          ),
        )
            .animate()
            .scale(
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
            .fade(duration: 400.ms),
        const SizedBox(height: 58),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFFFF4E6), Colors.white],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            '¡Bienvenido al sistema!',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 26 : 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        )
            .animate()
            .fadeIn(
              delay: 200.ms,
              duration: 800.ms,
            )
            .slideY(
              begin: -0.3,
              end: 0,
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: Colors.white,
                size: isSmallScreen ? 16 : 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Inicia sesión de forma segura',
                style: GoogleFonts.inter(
                  fontSize: isSmallScreen ? 13 : 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(
              delay: 500.ms,
              duration: 800.ms,
            )
            .slideX(
              begin: -0.3,
              end: 0,
              curve: Curves.easeOut,
            )
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
            ),
      ],
    );
  }

  Widget _buildLoginCard(bool isSmallScreen) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFF6B35).withOpacity(0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildUsernameField(isSmallScreen),
                  const SizedBox(height: 20),
                  _buildPasswordField(isSmallScreen),
                  const SizedBox(height: 16),
                  _buildRememberMeCheckbox(isSmallScreen),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    _buildErrorMessage(isSmallScreen),
                  ],
                  const SizedBox(height: 32),
                  _buildLoginButton(isSmallScreen),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child:
                              Divider(color: Colors.grey[300], thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Acceso Seguro',
                          style: GoogleFonts.inter(
                            color: Colors.grey[500],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                          child:
                              Divider(color: Colors.grey[300], thickness: 1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: 700.ms,
          duration: 800.ms,
        )
        .slideY(
          begin: 0.4,
          end: 0,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
        );
  }

  Widget _buildRememberMeCheckbox(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: _rememberMe
            ? const Color(0xFFFF6B35).withOpacity(0.08)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _rememberMe
              ? const Color(0xFFFF6B35).withOpacity(0.3)
              : Colors.grey[200]!,
          width: 1.5,
        ),
      ),
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        value: _rememberMe,
        onChanged: (value) {
          setState(() => _rememberMe = value ?? false);
        },
        title: Text(
          'Recuerda mis credenciales',
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 13 : 14,
            color: const Color(0xFF1A202C),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Guardado seguro en tu dispositivo',
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 11 : 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        activeColor: const Color(0xFFFF6B35),
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.leading,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildUsernameField(bool isSmallScreen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()..scale(_usernameFocused ? 1.02 : 1.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _usernameFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: _usernameController,
        focusNode: _usernameFocus,
        style: GoogleFonts.inter(
          fontSize: isSmallScreen ? 14 : 16,
          color: const Color(0xFF1A202C),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: 'Usuario',
          labelStyle: GoogleFonts.inter(
            color:
                _usernameFocused ? const Color(0xFFFF6B35) : Colors.grey[600],
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
          hintText: 'usuario@ejemplo.com',
          hintStyle: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: isSmallScreen ? 13 : 14,
          ),
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.person_outline_rounded,
              color:
                  _usernameFocused ? const Color(0xFFFF6B35) : Colors.grey[500],
              size: isSmallScreen ? 22 : 26,
            ),
          ),
          filled: true,
          fillColor: _usernameFocused
              ? const Color(0xFFFF6B35).withOpacity(0.06)
              : Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor, ingrese su usuario';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(bool isSmallScreen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()..scale(_passwordFocused ? 1.02 : 1.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _passwordFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: _passwordController,
        focusNode: _passwordFocus,
        obscureText: !_passwordVisible,
        style: GoogleFonts.inter(
          fontSize: isSmallScreen ? 14 : 16,
          color: const Color(0xFF1A202C),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: 'Contraseña',
          labelStyle: GoogleFonts.inter(
            color:
                _passwordFocused ? const Color(0xFFFF6B35) : Colors.grey[600],
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
          hintText: '••••••••',
          hintStyle: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: isSmallScreen ? 13 : 14,
          ),
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.lock_outline_rounded,
              color:
                  _passwordFocused ? const Color(0xFFFF6B35) : Colors.grey[500],
              size: isSmallScreen ? 22 : 26,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: Colors.grey[500],
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: () {
              setState(() => _passwordVisible = !_passwordVisible);
            },
          ),
          filled: true,
          fillColor: _passwordFocused
              ? const Color(0xFFFF6B35).withOpacity(0.06)
              : Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingrese su contraseña';
          }
          if (value.length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildErrorMessage(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 14 : 18,
        vertical: isSmallScreen ? 12 : 14,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade50,
            Colors.red.shade100.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade700,
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                color: Colors.red.shade800,
                fontSize: isSmallScreen ? 12 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .shake(
          hz: 4,
          curve: Curves.easeInOut,
          duration: 500.ms,
        )
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
        );
  }

  Widget _buildLoginButton(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 54 : 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42), Color(0xFFFFA556)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoading ? null : _login,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Ingresando...',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 15 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login_rounded,
                        color: Colors.white,
                        size: isSmallScreen ? 22 : 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Iniciar Sesión',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: isSmallScreen ? 20 : 22,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isSmallScreen) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
          ),
          child: TextButton.icon(
            onPressed: () {
              // Implementar recuperación de contraseña
            },
            icon: Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
              size: isSmallScreen ? 18 : 20,
            ),
            label: Text(
              '¿Olvidaste tu contraseña?',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: isSmallScreen ? 13 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        )
            .animate()
            .fadeIn(
              delay: 1300.ms,
              duration: 800.ms,
            )
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Conexión segura',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(
              delay: 1500.ms,
              duration: 800.ms,
            )
            .scale(begin: const Offset(0.8, 0.8)),
      ],
    );
  }
}
