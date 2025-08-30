import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'users/panel_user.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

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

                // Campo usuario
                const TextField(
                  decoration: InputDecoration(
                    labelText: "Usuario",
                    prefixIcon: Icon(Icons.person, color: Colors.red),
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo contraseña
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock, color: Colors.red),
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                // Botón ingresar (a panel de admin o usuario según quieras)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PanelUserScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Ingresar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Botón mozo (vuelve al login)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Mozo",
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
