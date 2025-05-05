import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'auth_screen.dart';
import 'ModulesScreen.dart';
import '../theme/App_Colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Color?> _gradientAnimation;
  double _progress = 0.0;
  bool _isInitializing = false;
  String? _initializationError;
  final int totalModules = 4;

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
    _loadUserProgress();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('No user logged in');
      return;
    }

    try {
      final moduleDetails = await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .get();

      if (moduleDetails.docs.isEmpty) {
        setState(() {
          _progress = 0.0;
        });
        debugPrint('No progress data found for userId: ${user.uid}');
        return;
      }

      int completedModules = 0;

      for (var module in moduleDetails.docs) {
        final data = module.data();
        debugPrint('Module ${module.id} data: $data');

        final porcentaje = (data.containsKey('porcentaje') && data['porcentaje'] != null)
            ? (data['porcentaje'] as num).toDouble()
            : 0.0;
        final quizCompleted = (data.containsKey('quiz_completed') && data['quiz_completed'] != null)
            ? data['quiz_completed'] as bool
            : false;

        if (porcentaje == 100 && quizCompleted) {
          completedModules++;
        }
      }

      setState(() {
        _progress = completedModules / totalModules;
        debugPrint('Progress updated: completedModules=$completedModules, totalModules=$totalModules, progress=$_progress');
      });
    } catch (e) {
      debugPrint('Error cargando progreso: $e');
      setState(() {
        _initializationError = 'Error al cargar progreso: $e';
      });
    }
  }

  Future<void> _initializeUserData() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
      _initializationError = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Usuario no autenticado");
      }

      // Verificar o crear progreso
      final progressRef = FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc('initial');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final progressDoc = await transaction.get(progressRef);
        
        if (!progressDoc.exists) {
          transaction.set(progressRef, {
            'mcompleto': [],
            'ultimo_acceso': FieldValue.serverTimestamp(),
          });
          debugPrint('Progress initialized for userId: ${user.uid}');
        }
      });

      setState(() {
        _isInitializing = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error inicializando datos: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _isInitializing = false;
        _initializationError = 'Error al inicializar datos. Por favor, reinicia la aplicación.';
      });
    }
  }

  Future<void> _navigateToModules() async {
    try {
      await _initializeUserData();
      if (!mounted) return;
      
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ModulesScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_initializationError ?? 'Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Widget _buildLogoutButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppColors.glassmorphicBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.glassmorphicBorder,
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const AuthScreen(),
                      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                    ),
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Error al cerrar sesión'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              splashColor: AppColors.glassmorphicBorder,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.logout,
                  color: AppColors.buttonText,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
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
                  ? Border.all(color: AppColors.textPrimary, width: 2)
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

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundDynamic,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25, right: 10),
                      child: _buildLogoutButton(),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                width: 250,
                                height: 250,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.glassmorphicBackground,
                                  border: Border.all(
                                    color: AppColors.glassmorphicBorder,
                                    width: 5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowColor,
                                      blurRadius: 15,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/siaap.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              '¡Bienvenido ${user?.email ?? 'Estudiante'}!',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Text(
                              'Prepárate para tu viaje en programación',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 40),
                          if (_isInitializing)
                            const CircularProgressIndicator(color: AppColors.progressActive)
                          else
                            _buildActionButton(
                              title: 'Explorar Módulos',
                              icon: Icons.school,
                              backgroundColor: AppColors.primaryButton,
                              textColor: AppColors.buttonText,
                              onPressed: _navigateToModules,
                              animationDelay: 0.4,
                            ),
                          if (_initializationError != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                _initializationError!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 20),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                const Text(
                                  'Tu progreso',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: _progress,
                                      backgroundColor: AppColors.progressInactive,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.progressActive),
                                      minHeight: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${(_progress * 100).toStringAsFixed(0)}% completado',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}