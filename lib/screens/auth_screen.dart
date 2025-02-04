import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo de la aplicación
                Image.asset(
                  'assets/logo.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 50),

                // Botón de Iniciar Sesión
                _buildAuthButton(
                  title: 'Iniciar Sesión',
                  color: Colors.white,
                  textColor: Colors.blue,
                  onPressed: () => _navigateTo(context, const LoginScreen()),
                ),
                const SizedBox(height: 20),

                // Botón de Registrarse
                _buildAuthButton(
                  title: 'Registrarse',
                  color: Colors.transparent,
                  textColor: Colors.white,
                  border: true,
                  onPressed: () => _navigateTo(context, const RegisterScreen()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función para navegar a otra pantalla
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => screen),
    );
  }

  // Widget para construir botones personalizados
  Widget _buildAuthButton({
    required String title,
    required Color color,
    required Color textColor,
    bool border = false,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: border
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 0, // Elimina la sombra del botón
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}