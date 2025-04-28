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

class Module3ActividadesScreen extends StatefulWidget {
  final Map<String, dynamic> moduleData;

  const Module3ActividadesScreen({Key? key, required this.moduleData}) : super(key: key);

  @override
  _Module3ActividadesScreenState createState() => _Module3ActividadesScreenState();
}

class _Module3ActividadesScreenState extends State<Module3ActividadesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  Map<String, int> _remainingAttemptsPerActivity = {
    'search_algorithms': 5,
    'count_vowels_recursive': 3,
    'sum_digits': 3,
    'bubble_sort_grades': 3,
    'queue_simulation': 3,
    'study_hours_tracker': 3,
    'inventory_system': 3,
  };
  bool _isAttemptsLoading = true;
  String? _errorMessage;
  Map<String, bool> _completedActivities = {
    'search_algorithms': false,
    'count_vowels_recursive': false,
    'sum_digits': false,
    'bubble_sort_grades': false,
    'queue_simulation': false,
    'study_hours_tracker': false,
    'inventory_system': false,
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
          .doc(widget.moduleData['id'] ?? 'module3')
          .get();

      if (progressDoc.exists) {
        final data = progressDoc.data();
        final attempts = data?['attempts_per_activity'] as Map<String, dynamic>? ?? {};
        final completed = data?['completed_activities'] as Map<String, dynamic>? ?? {};
        setState(() {
          _remainingAttemptsPerActivity = {
            'search_algorithms': (attempts['search_algorithms'] as num?)?.toInt() ?? 5,
            'count_vowels_recursive': (attempts['count_vowels_recursive'] as num?)?.toInt() ?? 3,
            'sum_digits': (attempts['sum_digits'] as num?)?.toInt() ?? 3,
            'bubble_sort_grades': (attempts['bubble_sort_grades'] as num?)?.toInt() ?? 3,
            'queue_simulation': (attempts['queue_simulation'] as num?)?.toInt() ?? 3,
            'study_hours_tracker': (attempts['study_hours_tracker'] as num?)?.toInt() ?? 3,
            'inventory_system': (attempts['inventory_system'] as num?)?.toInt() ?? 3,
          };
          _completedActivities = {
            'search_algorithms': completed['search_algorithms'] ?? false,
            'count_vowels_recursive': completed['count_vowels_recursive'] ?? false,
            'sum_digits': completed['sum_digits'] ?? false,
            'bubble_sort_grades': completed['bubble_sort_grades'] ?? false,
            'queue_simulation': completed['queue_simulation'] ?? false,
            'study_hours_tracker': completed['study_hours_tracker'] ?? false,
            'inventory_system': completed['inventory_system'] ?? false,
          };
          _isAttemptsLoading = false;
        });
      } else {
        await FirebaseFirestore.instance
            .collection('progress')
            .doc(user.uid)
            .collection('modules')
            .doc(widget.moduleData['id'] ?? 'module3')
            .set({
          'attempts_per_activity': {
            'search_algorithms': 5,
            'count_vowels_recursive': 3,
            'sum_digits': 3,
            'bubble_sort_grades': 3,
            'queue_simulation': 3,
            'study_hours_tracker': 3,
            'inventory_system': 3,
          },
          'completed_activities': {
            'search_algorithms': false,
            'count_vowels_recursive': false,
            'sum_digits': false,
            'bubble_sort_grades': false,
            'queue_simulation': false,
            'study_hours_tracker': false,
            'inventory_system': false,
          },
          'last_updated': FieldValue.serverTimestamp(),
          'module_id': widget.moduleData['id'] ?? 'module3',
          'module_title': widget.moduleData['module_title'] ?? 'Módulo 3: Algoritmos',
        }, SetOptions(merge: true));

        setState(() {
          _remainingAttemptsPerActivity = {
            'search_algorithms': 5,
            'count_vowels_recursive': 3,
            'sum_digits': 3,
            'bubble_sort_grades': 3,
            'queue_simulation': 3,
            'study_hours_tracker': 3,
            'inventory_system': 3,
          };
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

  Future<void> _decrementAttempts(String activityId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final newAttempts = _remainingAttemptsPerActivity[activityId]! - 1;

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.moduleData['id'] ?? 'module3')
          .set({
        'attempts_per_activity': {activityId: newAttempts},
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _remainingAttemptsPerActivity[activityId] = newAttempts;
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
          .doc(widget.moduleData['id'] ?? 'module3')
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
    if (_remainingAttemptsPerActivity[activityId]! <= 0 && !_completedActivities[activityId]!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Has agotado los intentos para "$activityId". Contacta al soporte.'),
          backgroundColor: const Color(0xFFEF4444),
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
          _decrementAttempts(activityId);
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
    final totalAttemptsRemaining = _remainingAttemptsPerActivity.values.reduce((a, b) => a + b);

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
                    'Actividades - ${widget.moduleData['module_title'] ?? 'Módulo 3'}',
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
                        'Intentos totales restantes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFFFFFFFF).withOpacity(0.9),
                        ),
                      ),
                      Text(
                        '$totalAttemptsRemaining',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: totalAttemptsRemaining > 0 ? const Color(0xFFFFFFFF) : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Text(
                    'Progreso: $completedCount/7 actividades completadas',
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
                  text: 'Búsqueda Lineal o Binaria',
                  activityId: 'search_algorithms',
                  attempts: _remainingAttemptsPerActivity['search_algorithms']!,
                  isCompleted: _completedActivities['search_algorithms']!,
                  onPressed: () => _navigateToActivity(
                    const SearchAlgorithmsActivityScreen(),
                    'search_algorithms',
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                _buildActivityButton(
                  text: 'Contar Vocales Recursivamente',
                  activityId: 'count_vowels_recursive',
                  attempts: _remainingAttemptsPerActivity['count_vowels_recursive']!,
                  isCompleted: _completedActivities['count_vowels_recursive']!,
                  onPressed: () => _navigateToActivity(
                    const CountVowelsRecursiveActivityScreen(),
                    'count_vowels_recursive',
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                _buildActivityButton(
                  text: 'Suma de Dígitos',
                  activityId: 'sum_digits',
                  attempts: _remainingAttemptsPerActivity['sum_digits']!,
                  isCompleted: _completedActivities['sum_digits']!,
                  onPressed: () => _navigateToActivity(
                    const SumDigitsActivityScreen(),
                    'sum_digits',
                  ),
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                  _buildActivityButton(
                  text: 'Ordenar Calificaciones (Burbuja)',
                  activityId: 'bubble_sort_grades',
                  attempts: _remainingAttemptsPerActivity['bubble_sort_grades']!,
                  isCompleted: _completedActivities['bubble_sort_grades']!,
                  onPressed: () => _navigateToActivity(
                    const BubbleSortGradesActivityScreen(),
                    'bubble_sort_grades',
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                _buildActivityButton(
                  text: 'Simular Cola de Atención',
                  activityId: 'queue_simulation',
                  attempts: _remainingAttemptsPerActivity['queue_simulation']!,
                  isCompleted: _completedActivities['queue_simulation']!,
                  onPressed: () => _navigateToActivity(
                    const QueueSimulationActivityScreen(),
                    'queue_simulation',
                  ),
                ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                _buildActivityButton(
                  text: 'Registrar Horas de Estudio',
                  activityId: 'study_hours_tracker',
                  attempts: _remainingAttemptsPerActivity['study_hours_tracker']!,
                  isCompleted: _completedActivities['study_hours_tracker']!,
                  onPressed: () => _navigateToActivity(
                    const StudyHoursTrackerActivityScreen(),
                    'study_hours_tracker',
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                _buildActivityButton(
                  text: 'Sistema de Inventario',
                  activityId: 'inventory_system',
                  attempts: _remainingAttemptsPerActivity['inventory_system']!,
                  isCompleted: _completedActivities['inventory_system']!,
                  onPressed: () => _navigateToActivity(
                    const InventorySystemActivityScreen(),
                    'inventory_system',
                  ),
                ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityButton({
    required String text,
    required String activityId,
    required int attempts,
    required bool isCompleted,
    required VoidCallback onPressed,
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
                : attempts <= 0
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
            Flexible(
              child: Text(
                '$text ($attempts intentos)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
                overflow: TextOverflow.ellipsis,
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