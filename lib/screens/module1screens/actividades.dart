import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siapp/theme/app_colors.dart';
import 'hardware_software_activity.dart';
import 'order_steps_activity.dart';
import 'flowchart_activity.dart';

class ActividadesScreen extends StatefulWidget {
  final Map<String, dynamic> actividadesData;

  const ActividadesScreen({Key? key, required this.actividadesData}) : super(key: key);

  @override
  _ActividadesScreenState createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  int _remainingAttempts = 3;
  bool _isAttemptsLoading = true;
  bool _isAttemptsExhausted = false;
  String? _errorMessage;
  Map<String, bool> _completedActivities = {
    'hardware_software': false,
    'order_steps': false,
    'flowchart': false,
  };

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _loadProgressFromFirestore();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressFromFirestore() async {
    setState(() {
      _isAttemptsLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Usuario no autenticado.';
          _isAttemptsLoading = false;
        });
        return;
      }

      final progressDoc = await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.actividadesData['id'] ?? 'module1')
          .get();

      if (progressDoc.exists) {
        final data = progressDoc.data();
        final attempts = (data?['intentos'] as num?)?.toInt() ?? 3;
        final completed = data?['completed_activities'] as Map<String, dynamic>? ?? {};
        setState(() {
          _remainingAttempts = attempts;
          _isAttemptsExhausted = attempts <= 0;
          _completedActivities = {
            'hardware_software': completed['hardware_software'] ?? false,
            'order_steps': completed['order_steps'] ?? false,
            'flowchart': completed['flowchart'] ?? false,
          };
          _isAttemptsLoading = false;
        });
      } else {
        await FirebaseFirestore.instance
            .collection('progress')
            .doc(user.uid)
            .collection('modules')
            .doc(widget.actividadesData['id'] ?? 'module1')
            .set({
          'intentos': 3,
          'completed_activities': {
            'hardware_software': false,
            'order_steps': false,
            'flowchart': false,
          },
          'last_updated': FieldValue.serverTimestamp(),
          'module_id': widget.actividadesData['id'] ?? 'module1',
          'module_title': widget.actividadesData['module_title'] ?? 'Módulo',
        }, SetOptions(merge: true));

        setState(() {
          _remainingAttempts = 3;
          _isAttemptsExhausted = false;
          _isAttemptsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el progreso: $e';
        _isAttemptsLoading = false;
      });
    }
  }

  Future<void> _decrementAttempts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final newAttempts = _remainingAttempts - 1;

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.actividadesData['id'] ?? 'module1')
          .set({
        'intentos': newAttempts,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _remainingAttempts = newAttempts;
        _isAttemptsExhausted = newAttempts <= 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar los intentos: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _markActivityCompleted(String activityId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.actividadesData['id'] ?? 'module1')
          .set({
        'completed_activities': {activityId: true},
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _completedActivities[activityId] = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar la actividad: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateToActivity(Widget screen, String activityId) {
    if (_isAttemptsExhausted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Has agotado todos tus intentos. Contacta al soporte o intenta de nuevo más tarde.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_completedActivities[activityId]!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Esta actividad ya está completada.'),
          backgroundColor: AppColors.progressBrightBlue,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((result) {
      if (result is bool) {
        if (result) {
          _markActivityCompleted(activityId);
        } else {
          _decrementAttempts();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAttemptsLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundDynamic,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.progressActive),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Cargando progreso...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 500.ms),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildAnimatedButton(
                    text: 'Reintentar',
                    onPressed: _loadProgressFromFirestore,
                    gradient: AppColors.primaryGradient,
                  ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                ],
              ],
            ),
          ),
        ),
      );
    }

    final completedCount = _completedActivities.values.where((completed) => completed).length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundDynamic,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassmorphicCard(
                  child: Text(
                    'Actividades - ${widget.actividadesData['module_title'] ?? 'Módulo'}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Intentos restantes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$_remainingAttempts',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _remainingAttempts > 0 ? AppColors.textPrimary : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Text(
                    'Progreso: $completedCount/3 actividades completadas',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Text(
                    'Actividades Complementarias',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.progressBrightBlue,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
                const SizedBox(height: 20),
                Text(
                  'Selecciona una actividad para comenzar:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                const SizedBox(height: 30),
                _buildActivityButton(
                  text: 'Clasificar Hardware o Software',
                  onPressed: () => _navigateToActivity(
                    const HardwareSoftwareActivityScreen(),
                    'hardware_software',
                  ),
                  isCompleted: _completedActivities['hardware_software']!,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                _buildActivityButton(
                  text: 'Ordenar Pasos de Actividades',
                  onPressed: () => _navigateToActivity(
                    const OrderStepsActivityScreen(),
                    'order_steps',
                  ),
                  isCompleted: _completedActivities['order_steps']!,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                _buildActivityButton(
                  text: 'Diseñar Diagrama de Flujo',
                  onPressed: () => _navigateToActivity(
                    const FlowchartActivityScreen(),
                    'flowchart',
                  ),
                  isCompleted: _completedActivities['flowchart']!,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityButton({
    required String text,
    required VoidCallback onPressed,
    required bool isCompleted,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                )
              : _isAttemptsExhausted
                  ? LinearGradient(
                      colors: [Colors.grey.shade600, Colors.grey.shade400],
                    )
                  : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.buttonText,
              ),
            ),
            if (isCompleted)
              Icon(
                Icons.check_circle,
                color: AppColors.buttonText,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required VoidCallback? onPressed,
    required LinearGradient gradient,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.buttonText,
          ),
        ),
      ),
    );
  }
}

class GlassmorphicCard extends StatelessWidget {
  final Widget child;

  const GlassmorphicCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassmorphicBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}