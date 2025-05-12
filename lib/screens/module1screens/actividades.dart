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
  int _remainingAttemptsGlobal = 3;
  bool _isAttemptsLoading = true;
  String? _errorMessage;
  bool hardwareSoftwareCompleted = false;
  bool orderStepsCompleted = false;
  bool flowchartCompleted = false;
  bool allActivitiesCompleted = false;
  bool quizCompleted = false;
  double calf = 0.0;
  Map<String, double> _activityScores = {
    'hardware_software': 0.0,
    'order_steps': 0.0,
    'flowchart': 0.0,
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
      _errorMessage = null;
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
        final attempts = data?['global_attempts'] as num? ?? 3;
        final completed = data?['completed_activities'] as Map<String, dynamic>? ?? {};
        final scores = data?['activity_scores'] as Map<String, dynamic>? ?? {};
        final allCompleted = data?['all_activities_completed'] as bool? ?? false;
        final quizCompleted = data?['quiz_completed'] as bool? ?? false;
        final calf = (data?['calf'] as num?)?.toDouble() ?? 0.0;
        setState(() {
          _remainingAttemptsGlobal = attempts.toInt();
          hardwareSoftwareCompleted = completed['hardware_software'] ?? false;
          orderStepsCompleted = completed['order_steps'] ?? false;
          flowchartCompleted = completed['flowchart'] ?? false;
          _activityScores = {
            'hardware_software': (scores['hardware_software'] as num?)?.toDouble() ?? 0.0,
            'order_steps': (scores['order_steps'] as num?)?.toDouble() ?? 0.0,
            'flowchart': (scores['flowchart'] as num?)?.toDouble() ?? 0.0,
          };
          allActivitiesCompleted = allCompleted;
          this.quizCompleted = quizCompleted;
          this.calf = calf;
          _isAttemptsLoading = false;
        });
      } else {
        await FirebaseFirestore.instance
            .collection('progress')
            .doc(user.uid)
            .collection('modules')
            .doc(widget.actividadesData['id'] ?? 'module1')
            .set({
          'global_attempts': 3,
          'completed_activities': {
            'hardware_software': false,
            'order_steps': false,
            'flowchart': false,
          },
          'activity_scores': {
            'hardware_software': 0.0,
            'order_steps': 0.0,
            'flowchart': 0.0,
          },
          'all_activities_completed': false,
          'quiz_completed': false,
          'calf': 0.0,
          'last_updated': FieldValue.serverTimestamp(),
          'module_id': widget.actividadesData['id'] ?? 'module1',
          'module_title': widget.actividadesData['module_title'] ?? 'Módulo 1: Introducción',
        }, SetOptions(merge: true));

        setState(() {
          _remainingAttemptsGlobal = 3;
          hardwareSoftwareCompleted = false;
          orderStepsCompleted = false;
          flowchartCompleted = false;
          _activityScores = {
            'hardware_software': 0.0,
            'order_steps': 0.0,
            'flowchart': 0.0,
          };
          allActivitiesCompleted = false;
          quizCompleted = false;
          calf = 0.0;
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

  Future<void> _consumeAttempt() async {
    if (_remainingAttemptsGlobal <= 0) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final newAttempts = _remainingAttemptsGlobal - 1;
      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.actividadesData['id'] ?? 'module1')
          .set({
        'global_attempts': newAttempts,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() => _remainingAttemptsGlobal = newAttempts);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar los intentos: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _markActivityCompleted(String activityId, double score) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        switch (activityId) {
          case 'hardware_software':
            hardwareSoftwareCompleted = true;
            _activityScores['hardware_software'] = score;
            break;
          case 'order_steps':
            orderStepsCompleted = true;
            _activityScores['order_steps'] = score;
            break;
          case 'flowchart':
            flowchartCompleted = true;
            _activityScores['flowchart'] = score;
            break;
        }
        allActivitiesCompleted = hardwareSoftwareCompleted &&
            orderStepsCompleted &&
            flowchartCompleted;

        if (allActivitiesCompleted) {
          final completedCount = (hardwareSoftwareCompleted ? 1 : 0) +
              (orderStepsCompleted ? 1 : 0) +
              (flowchartCompleted ? 1 : 0);
          final totalScore = _activityScores.values.reduce((a, b) => a + b);
          final averageScore = (totalScore / completedCount).round();
          final calfScore = totalScore / completedCount;

          quizCompleted = true;
          calf = calfScore;

          FirebaseFirestore.instance
              .collection('progress')
              .doc(user.uid)
              .collection('modules')
              .doc(widget.actividadesData['id'] ?? 'module1')
              .set({
            'final_score': averageScore,
            'quiz_completed': quizCompleted,
            'calf': calf,
            'last_updated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          _showCompletionDialog(calfScore);
        }
      });

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.actividadesData['id'] ?? 'module1')
          .set({
        'completed_activities': {
          'hardware_software': hardwareSoftwareCompleted,
          'order_steps': orderStepsCompleted,
          'flowchart': flowchartCompleted,
        },
        'activity_scores': _activityScores,
        'all_activities_completed': allActivitiesCompleted,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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
    bool isCompleted;
    switch (activityId) {
      case 'hardware_software':
        isCompleted = hardwareSoftwareCompleted;
        break;
      case 'order_steps':
        isCompleted = orderStepsCompleted;
        break;
      case 'flowchart':
        isCompleted = flowchartCompleted;
        break;
      default:
        isCompleted = false;
    }

    if (_remainingAttemptsGlobal <= 0 && !isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Has agotado tus 3 intentos.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Esta actividad ya está completada.'),
          backgroundColor: AppColors.success,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((result) async {
      if (result != null && result is Map) {
        final double score = (result['score'] as num?)?.toDouble() ?? 0.0;
        final bool passed = result['passed'] as bool? ?? false;
        if (passed) {
          await _markActivityCompleted(activityId, score);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Actividad completada! Calificación: ${score.toStringAsFixed(1)}%'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          await _consumeAttempt();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Actividad no aprobada. Intentos restantes: $_remainingAttemptsGlobal'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAttemptsLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
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
                  gradient: LinearGradient(
                    colors: [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                  ),
                ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
              ],
            ],
          ),
        ),
      );
    }

    final completedCount = (hardwareSoftwareCompleted ? 1 : 0) +
        (orderStepsCompleted ? 1 : 0) +
        (flowchartCompleted ? 1 : 0);
    final progressValue = completedCount / 3;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassmorphicCard(
                child: Text(
                  'Actividades - ${widget.actividadesData['module_title'] ?? 'Módulo 1'}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
              const SizedBox(height: 20),
              GlassmorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progreso: $completedCount/3 actividades completadas',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.progressActive),
                        ).animate().fadeIn(duration: 600.ms),
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.progressActive.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              GlassmorphicCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Intentos restantes: $_remainingAttemptsGlobal/3',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              Text(
                'Selecciona una actividad para comenzar:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _buildActivityButton(
                    text: 'Clasificar Hardware o Software',
                    activityId: 'hardware_software',
                    isCompleted: hardwareSoftwareCompleted,
                    onPressed: () => _navigateToActivity(
                      const HardwareSoftwareActivityScreen(),
                      'hardware_software',
                    ),
                  ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  _buildActivityButton(
                    text: 'Ordenar Pasos de Actividades',
                    activityId: 'order_steps',
                    isCompleted: orderStepsCompleted,
                    onPressed: () => _navigateToActivity(
                      const OrderStepsActivityScreen(),
                      'order_steps',
                    ),
                  ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  _buildActivityButton(
                    text: 'Diseñar Diagrama de Flujo',
                    activityId: 'flowchart',
                    isCompleted: flowchartCompleted,
                    onPressed: () => _navigateToActivity(
                      const FlowchartActivityScreen(),
                      'flowchart',
                    ),
                  ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
                ],
              ),
              const SizedBox(height: 20),
              _buildAnimatedButton(
                text: 'Finalizar Módulo',
                onPressed: allActivitiesCompleted
                    ? () {
                        final completedCount = 3;
                        final totalScore = _activityScores.values.reduce((a, b) => a + b);
                        final calfScore = totalScore / completedCount;
                        _showCompletionDialog(calfScore);
                      }
                    : null,
                gradient: LinearGradient(
                  colors: allActivitiesCompleted
                      ? [AppColors.success, AppColors.success.withOpacity(0.8)]
                      : [Colors.grey.shade600, Colors.grey.shade400],
                ),
              ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityButton({
    required String text,
    required String activityId,
    required bool isCompleted,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassmorphicBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassmorphicBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (isCompleted)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 24,
                ),
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
              color: AppColors.shadowColor,
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
            color: AppColors.textPrimary,
          ),
        ),
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }

  void _showCompletionDialog(double calf) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassmorphicBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: AppColors.progressActive, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Módulo Completado',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Felicidades! Has completado todas las actividades del Módulo 1.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 12),
              Text(
                'Progreso: 3/3 actividades completadas',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 12),
              Text(
                'Calificación final: ${calf.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: GoogleFonts.poppins(color: AppColors.progressActive),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassmorphicBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassmorphicBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}