import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../theme/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _gradientAnimation = ColorTween(
      begin: AppColors.backgroundGradientTop,
      end: AppColors.backgroundGradientBottom,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundDynamic,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Contenedor circular para el logo (más grande)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 220,  // Tamaño aumentado
                          height: 220, // Tamaño aumentado
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.glassmorphicBackground,
                            border: Border.all(
                              color: AppColors.glassmorphicBorder,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowColor,
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(  // Usamos ClipOval para un círculo perfecto
                            child: Image.asset(
                              'assets/siaap.png',
                              fit: BoxFit.cover,  // Cambiado a 'cover' para llenar el círculo
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Título con animación
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Bienvenido a SIAAP',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Tu plataforma de aprendizaje de programación',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Botón de Iniciar Sesión con efecto de onda
                    _buildAuthButton(
                      title: 'Iniciar Sesión',
                      icon: Icons.login,
                      backgroundColor: AppColors.primaryButton,
                      textColor: AppColors.buttonText,
                      onPressed: () => _navigateTo(context, const LoginScreen()),
                      animationDelay: 0.4,
                    ),
                    const SizedBox(height: 20),

                    // Botón de Registro con borde animado
                    _buildAuthButton(
                      title: 'Registrarse',
                      icon: Icons.person_add,
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.textPrimary,
                      border: true,
                      onPressed: () => _navigateTo(context, const RegisterScreen()),
                      animationDelay: 0.6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthButton({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    bool border = false,
    required VoidCallback onPressed,
    required double animationDelay,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            animationDelay,
            1.0,
            curve: Curves.fastOutSlowIn,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(30),
              border: border
                  ? Border.all(color: AppColors.glassmorphicBorder, width: 2)
                  : null,
              boxShadow: [
                if (!border)
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: onPressed,
                splashColor: border ? AppColors.glassmorphicBorder : AppColors.progressActive,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: textColor, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}