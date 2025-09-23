// lib/auth/login_page.dart
import 'package:flutter/material.dart';
import 'admin_page.dart';
import '../users/panel_user.dart';
import '../main_screen.dart'; // Import MainScreen

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _login() {
    // Simple validation
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, complete todos los campos.';
      });
      return;
    }

    // Simulate successful login (replace with your auth logic)
    if (_usernameController.text == 'dario' && _passwordController.text == 'dario123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'Usuario o contraseña incorrectos.';
      });
    }
  }

  void _adminLogin() {
    // Admin logic (keep original navigation)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminPage()),
    );
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
                // Logo
                Image.asset(
                  "assets/header/Logo.png",
                  height: 200,
                  width: 400,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                const Text(
                  "INGRESA TUS DATOS",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 0, 0),
                  ),
                ),
                const SizedBox(height: 30),

                // Usuario
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Usuario",
                    prefixIcon: Icon(Icons.person, color: Colors.red),
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock, color: Colors.red),
                    border: UnderlineInputBorder(),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 30),

                // Botón ingresar (va al panel_user)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _login,
                    child: const Text(
                      "Ingresar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Botón administrador
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _adminLogin,
                    child: const Text(
                      "Administrador",
                      style: TextStyle(color: Colors.white),
                    ),
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