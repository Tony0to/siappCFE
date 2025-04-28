import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hardware_software_activity.dart';
import 'order_steps_activity.dart';
import 'flowchart_activity.dart';

class ActividadesScreen extends StatefulWidget {
  final Map<String, dynamic> moduleData;

  const ActividadesScreen({Key? key, required this.moduleData}) : super(key: key);

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
      duration: const Duration(milliseconds: 800),
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
          .doc(widget.moduleData['id'] ?? 'module1')
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
            .doc(widget.moduleData['id'] ?? 'module1')
            .set({
          'intentos': 3,
          'completed_activities': {
            'hardware_software': false,
            'order_steps': false,
            'flowchart': false,
          },
          'last_updated': FieldValue.serverTimestamp(),
          'module_id': widget.moduleData['id'] ?? 'module1',
          'module_title': widget.moduleData['module_title'] ?? 'Módulo',
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
          .doc(widget.moduleData['id'] ?? 'module1')
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
          backgroundColor: const Color(0xFFEF4444),
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
          .doc(widget.moduleData['id'] ?? 'module1')
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
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  void _navigateToActivity(Widget screen, String activityId) {
    if (_isAttemptsExhausted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Has agotado todos tus intentos. Contacta al soporte o intenta de nuevo más tarde.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_completedActivities[activityId]!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta actividad ya está completada.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
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
            gradient: LinearGradient(
              colors: [Color(0xFF003459), Color(0xFF00A8E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFFFFFFFF)),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Cargando progreso...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 500.ms),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildAnimatedButton(
                    text: 'Reintentar',
                    onPressed: _loadProgressFromFirestore,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007EA7), Color(0xFF00A8E8)],
                    ),
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
          gradient: LinearGradient(
            colors: [Color(0xFF003459), Color(0xFF00A8E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassmorphicCard(
                  child: Text(
                    'Actividades - ${widget.moduleData['module_title'] ?? 'Módulo'}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFFFFF),
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
                          color: const Color(0xFFFFFFFF).withOpacity(0.9),
                        ),
                      ),
                      Text(
                        '$_remainingAttempts',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _remainingAttempts > 0 ? const Color(0xFFFFFFFF) : const Color(0xFFEF4444),
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
                      color: const Color(0xFFFFFFFF).withOpacity(0.9),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Text(
                    'Actividades Complementarias',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4FC3F7),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
                const SizedBox(height: 20),
                Text(
                  'Selecciona una actividad para comenzar:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    height: 1.6,
                    color: const Color(0xFFFFFFFF).withOpacity(0.9),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCompleted
                ? [Colors.green.shade600, Colors.green.shade400]
                : _isAttemptsExhausted
                    ? [Colors.grey.shade600, Colors.grey.shade400]
                    : [const Color(0xFF007EA7), const Color(0xFF00A8E8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
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
                color: const Color(0xFFFFFFFF),
              ),
            ),
            if (isCompleted)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFFFFFF),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFFFFF),
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
        color: const Color(0xFFFFFFFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}