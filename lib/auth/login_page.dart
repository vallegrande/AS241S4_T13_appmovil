import 'package:flutter/material.dart';
import '../services/user_service.dart';
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
  String? _errorMessage;
  bool _isLoading = false;

  void _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, complete todos los campos.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Usuario o contraseña incorrectos.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error de conexión: No se pudo contactar al servidor.';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background/Fondo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/header/Logo.png",
                  height: 200,
                  width: 400,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),

                const Text(
                  "INGRESA TUS DATOS",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF1100),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 30),

                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextField(
                    controller: _usernameController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Usuario",
                      labelStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color(0xFFFF1100),
                        size: 24,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFFF1100),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      labelStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color(0xFFFF1100),
                        size: 24,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFFF1100),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                    ),
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 15),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 35),

                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF1100),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 3,
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Ingresar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}