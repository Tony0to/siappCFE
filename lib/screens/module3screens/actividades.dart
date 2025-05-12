import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_algorithms_activity.dart';
import 'count_vowels_recursive_activity.dart';
import 'sum_digits_activity.dart';
import 'bubble_sort_grades_activity.dart';
import 'queue_simulation_activity.dart';
import 'study_hours_tracker_activity.dart';
import 'inventory_system_activity.dart';
import 'package:siapp/theme/app_colors.dart';

class Module3ActividadesScreen extends StatefulWidget {
  final Map<String, dynamic> moduleData;

  const Module3ActividadesScreen({Key? key, required this.moduleData}) : super(key: key);

  @override
  _Module3ActividadesScreenState createState() => _Module3ActividadesScreenState();
}

class _Module3ActividadesScreenState extends State<Module3ActividadesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  int _remainingAttemptsGlobal = 3;
  bool _isAttemptsLoading = true;
  String? _errorMessage;
  bool searchAlgorithmsCompleted = false;
  bool countVowelsRecursiveCompleted = false;
  bool sumDigitsCompleted = false;
  bool bubbleSortGradesCompleted = false;
  bool queueSimulationCompleted = false;
  bool studyHoursTrackerCompleted = false;
  bool inventorySystemCompleted = false;
  bool allActivitiesCompleted = false;
  bool quizCompleted = false;
  double calf = 0.0;
  Map<String, double> _activityScores = {
    'search_algorithms': 0.0,
    'count_vowels_recursive': 0.0,
    'sum_digits': 0.0,
    'bubble_sort_grades': 0.0,
    'queue_simulation': 0.0,
    'study_hours_tracker': 0.0,
    'inventory_system': 0.0,
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
          .doc(widget.moduleData['id'] ?? 'module3')
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
          searchAlgorithmsCompleted = completed['search_algorithms'] ?? false;
          countVowelsRecursiveCompleted = completed['count_vowels_recursive'] ?? false;
          sumDigitsCompleted = completed['sum_digits'] ?? false;
          bubbleSortGradesCompleted = completed['bubble_sort_grades'] ?? false;
          queueSimulationCompleted = completed['queue_simulation'] ?? false;
          studyHoursTrackerCompleted = completed['study_hours_tracker'] ?? false;
          inventorySystemCompleted = completed['inventory_system'] ?? false;
          _activityScores = {
            'search_algorithms': (scores['search_algorithms'] as num?)?.toDouble() ?? 0.0,
            'count_vowels_recursive': (scores['count_vowels_recursive'] as num?)?.toDouble() ?? 0.0,
            'sum_digits': (scores['sum_digits'] as num?)?.toDouble() ?? 0.0,
            'bubble_sort_grades': (scores['bubble_sort_grades'] as num?)?.toDouble() ?? 0.0,
            'queue_simulation': (scores['queue_simulation'] as num?)?.toDouble() ?? 0.0,
            'study_hours_tracker': (scores['study_hours_tracker'] as num?)?.toDouble() ?? 0.0,
            'inventory_system': (scores['inventory_system'] as num?)?.toDouble() ?? 0.0,
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
            .doc(widget.moduleData['id'] ?? 'module3')
            .set({
          'global_attempts': 3,
          'completed_activities': {
            'search_algorithms': false,
            'count_vowels_recursive': false,
            'sum_digits': false,
            'bubble_sort_grades': false,
            'queue_simulation': false,
            'study_hours_tracker': false,
            'inventory_system': false,
          },
          'activity_scores': {
            'search_algorithms': 0.0,
            'count_vowels_recursive': 0.0,
            'sum_digits': 0.0,
            'bubble_sort_grades': 0.0,
            'queue_simulation': 0.0,
            'study_hours_tracker': 0.0,
            'inventory_system': 0.0,
          },
          'all_activities_completed': false,
          'quiz_completed': false,
          'calf': 0.0,
          'last_updated': FieldValue.serverTimestamp(),
          'module_id': widget.moduleData['id'] ?? 'module3',
          'module_title': widget.moduleData['module_title'] ?? 'Módulo 3: Algoritmos',
        }, SetOptions(merge: true));

        setState(() {
          _remainingAttemptsGlobal = 3;
          searchAlgorithmsCompleted = false;
          countVowelsRecursiveCompleted = false;
          sumDigitsCompleted = false;
          bubbleSortGradesCompleted = false;
          queueSimulationCompleted = false;
          studyHoursTrackerCompleted = false;
          inventorySystemCompleted = false;
          _activityScores = {
            'search_algorithms': 0.0,
            'count_vowels_recursive': 0.0,
            'sum_digits': 0.0,
            'bubble_sort_grades': 0.0,
            'queue_simulation': 0.0,
            'study_hours_tracker': 0.0,
            'inventory_system': 0.0,
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
          .doc(widget.moduleData['id'] ?? 'module3')
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
          case 'search_algorithms':
            searchAlgorithmsCompleted = true;
            _activityScores['search_algorithms'] = score;
            break;
          case 'count_vowels_recursive':
            countVowelsRecursiveCompleted = true;
            _activityScores['count_vowels_recursive'] = score;
            break;
          case 'sum_digits':
            sumDigitsCompleted = true;
            _activityScores['sum_digits'] = score;
            break;
          case 'bubble_sort_grades':
            bubbleSortGradesCompleted = true;
            _activityScores['bubble_sort_grades'] = score;
            break;
          case 'queue_simulation':
            queueSimulationCompleted = true;
            _activityScores['queue_simulation'] = score;
            break;
          case 'study_hours_tracker':
            studyHoursTrackerCompleted = true;
            _activityScores['study_hours_tracker'] = score;
            break;
          case 'inventory_system':
            inventorySystemCompleted = true;
            _activityScores['inventory_system'] = score;
            break;
        }
        allActivitiesCompleted = searchAlgorithmsCompleted &&
            countVowelsRecursiveCompleted &&
            sumDigitsCompleted &&
            bubbleSortGradesCompleted &&
            queueSimulationCompleted &&
            studyHoursTrackerCompleted &&
            inventorySystemCompleted;

        if (allActivitiesCompleted) {
          final completedCount = (searchAlgorithmsCompleted ? 1 : 0) +
              (countVowelsRecursiveCompleted ? 1 : 0) +
              (sumDigitsCompleted ? 1 : 0) +
              (bubbleSortGradesCompleted ? 1 : 0) +
              (queueSimulationCompleted ? 1 : 0) +
              (studyHoursTrackerCompleted ? 1 : 0) +
              (inventorySystemCompleted ? 1 : 0);
          final totalScore = _activityScores.values.reduce((a, b) => a + b);
          final averageScore = (totalScore / completedCount).round();
          final calfScore = totalScore / completedCount;

          quizCompleted = true;
          calf = calfScore;

          FirebaseFirestore.instance
              .collection('progress')
              .doc(user.uid)
              .collection('modules')
              .doc(widget.moduleData['id'] ?? 'module3')
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
          .doc(widget.moduleData['id'] ?? 'module3')
          .set({
        'completed_activities': {
          'search_algorithms': searchAlgorithmsCompleted,
          'count_vowels_recursive': countVowelsRecursiveCompleted,
          'sum_digits': sumDigitsCompleted,
          'bubble_sort_grades': bubbleSortGradesCompleted,
          'queue_simulation': queueSimulationCompleted,
          'study_hours_tracker': studyHoursTrackerCompleted,
          'inventory_system': inventorySystemCompleted,
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
      case 'search_algorithms':
        isCompleted = searchAlgorithmsCompleted;
        break;
      case 'count_vowels_recursive':
        isCompleted = countVowelsRecursiveCompleted;
        break;
      case 'sum_digits':
        isCompleted = sumDigitsCompleted;
        break;
      case 'bubble_sort_grades':
        isCompleted = bubbleSortGradesCompleted;
        break;
      case 'queue_simulation':
        isCompleted = queueSimulationCompleted;
        break;
      case 'study_hours_tracker':
        isCompleted = studyHoursTrackerCompleted;
        break;
      case 'inventory_system':
        isCompleted = inventorySystemCompleted;
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

    final completedCount = (searchAlgorithmsCompleted ? 1 : 0) +
        (countVowelsRecursiveCompleted ? 1 : 0) +
        (sumDigitsCompleted ? 1 : 0) +
        (bubbleSortGradesCompleted ? 1 : 0) +
        (queueSimulationCompleted ? 1 : 0) +
        (studyHoursTrackerCompleted ? 1 : 0) +
        (inventorySystemCompleted ? 1 : 0);
    final progressValue = completedCount / 7;

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
                  'Actividades - ${widget.moduleData['module_title'] ?? 'Módulo 3'}',
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
                      'Progreso: $completedCount/7 actividades completadas',
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
                childAspectRatio: 1.2,
                children: [
                  _buildActivityButton(
                    text: 'Búsqueda Lineal o Binaria',
                    activityId: 'search_algorithms',
                    isCompleted: searchAlgorithmsCompleted,
                    onPressed: () => _navigateToActivity(
                      const SearchAlgorithmsActivityScreen(),
                      'search_algorithms',
                    ),
                  ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  _buildActivityButton(
                    text: 'Contar Vocales Recursivamente',
                    activityId: 'count_vowels_recursive',
                    isCompleted: countVowelsRecursiveCompleted,
                    onPressed: () => _navigateToActivity(
                      const CountVowelsRecursiveActivityScreen(),
                      'count_vowels_recursive',
                    ),
                  ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  _buildActivityButton(
                    text: 'Suma de Dígitos',
                    activityId: 'sum_digits',
                    isCompleted: sumDigitsCompleted,
                    onPressed: () => _navigateToActivity(
                      const SumDigitsActivityScreen(),
                      'sum_digits',
                    ),
                  ).animate().scale(delay: 450.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  _buildActivityButton(
                    text: 'Ordenar Calificaciones',
                    activityId: 'bubble_sort_grades',
                    isCompleted: bubbleSortGradesCompleted,
                    onPressed: () => _navigateToActivity(
                      const BubbleSortActivityScreen(),
                      'bubble_sort_grades',
                    ),
                  ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  _buildActivityButton(
                    text: 'Simular Cola de Atención',
                    activityId: 'queue_simulation',
                    isCompleted: queueSimulationCompleted,
                    onPressed: () => _navigateToActivity(
                      const QueueSimulationActivityScreen(),
                      'queue_simulation',
                    ),
                  ).animate().scale(delay: 550.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  _buildActivityButton(
                    text: 'Registrar Horas de Estudio',
                    activityId: 'study_hours_tracker',
                    isCompleted: studyHoursTrackerCompleted,
                    onPressed: () => _navigateToActivity(
                      const StudyHoursTrackerActivityScreen(),
                      'study_hours_tracker',
                    ),
                  ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  _buildActivityButton(
                    text: 'Sistema de Inventario',
                    activityId: 'inventory_system',
                    isCompleted: inventorySystemCompleted,
                    onPressed: () => _navigateToActivity(
                      const InventorySystemActivityScreen(),
                      'inventory_system',
                    ),
                  ).animate().scale(delay: 650.ms, duration: 400.ms, curve: Curves.easeOutBack),
                ],
              ),
              const SizedBox(height: 20),
              _buildAnimatedButton(
                text: 'Finalizar Módulo',
                onPressed: allActivitiesCompleted ? () {
                  final completedCount = 7;
                  final totalScore = _activityScores.values.reduce((a, b) => a + b);
                  final calfScore = totalScore / completedCount;
                  _showCompletionDialog(calfScore);
                } : null,
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
                '¡Felicidades! Has completado todas las actividades del Módulo 3.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 12),
              Text(
                'Progreso: 7/7 actividades completadas',
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