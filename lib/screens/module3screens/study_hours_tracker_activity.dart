import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:siapp/theme/app_colors.dart';

class StudyHoursTrackerActivityScreen extends StatefulWidget {
  const StudyHoursTrackerActivityScreen({super.key});

  @override
  _StudyHoursTrackerActivityScreenState createState() => _StudyHoursTrackerActivityScreenState();
}

class _StudyHoursTrackerActivityScreenState extends State<StudyHoursTrackerActivityScreen> {
  String? _statusMessage;
  bool _isCompleted = false;
  bool _isLocked = false;
  double _score = 0.0;
  List<int> _wrongIndices = []; // Tracks indices of incorrectly placed lines

  final ScrollController _scrollController = ScrollController();


  final List<String> _correctOrder = [
    'INICIO',
    'dias ← ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]',
    'horas ← lista vacía',
    'PARA cada dia en dias HACER',
    'IMPRIMIR "Ingresa horas estudiadas el", dia',
    'leer h',
    'agregar h a horas',
    'FIN PARA',
    'total ← suma de elementos en horas',
    'promedio ← total / 7',
    'IMPRIMIR "Total de horas:", total',
    'IMPRIMIR "Promedio diario:", promedio',
    'SI promedio ≥ 2 ENTONCES',
    'IMPRIMIR "¡Buen ritmo de estudio!"',
    'SINO',
    'IMPRIMIR "Puedes mejorar tu ritmo de estudio."',
    'FIN SI',
    'FIN',
  ];

  late List<String> _initialUserOrder;
  List<String> _userOrder = List.filled(18, '');
  List<String> _availableLines = [];

  @override
  void initState() {
    super.initState();
    _initializeActivity();
  }

  void _initializeActivity() {
    final random = Random();
    final indices = List<int>.generate(18, (i) => i)..shuffle(random);

    final prefilledIndices = indices.sublist(0, 11); // 50% pre-filled
    _userOrder = List.filled(18, '');

    for (final i in prefilledIndices) {
      _userOrder[i] = _correctOrder[i];
    }

    _availableLines = indices.sublist(9).map((i) => _correctOrder[i]).toList();
    _initialUserOrder = List.from(_userOrder);
    setState(() {});
  }

  int _getIndentationLevel(String line) {
    if (line.contains('IMPRIMIR "Ingresa horas estudiadas el", dia') ||
        line.contains('leer h') ||
        line.contains('agregar h a horas') ||
        line.contains('FIN PARA')) {
      return 1;
    } else if (line.contains('IMPRIMIR "¡Buen ritmo de estudio!"') ||
        line.contains('IMPRIMIR "Puedes mejorar tu ritmo de estudio."') ||
        line.contains('SINO') ||
        line.contains('FIN SI')) {
      return 1;
    }
    return 0;
  }

  void _resetActivity() {
    setState(() {
      _userOrder = List.from(_initialUserOrder);
      _availableLines = _correctOrder
          .asMap()
          .entries
          .where((entry) => _userOrder[entry.key].isEmpty)
          .map((entry) => entry.value)
          .toList();
      _statusMessage = null;
      _isCompleted = false;
      _isLocked = false;
      _score = 0.0;
      _wrongIndices.clear();
    });
  }

  static const double kEdgeActivation = 120.0; // alto de la zona activa
  static const double kMaxSpeed = 9.33; // px por evento, reducido a 1/3 de 28.0

  void _handleDragScroll(PointerMoveEvent event) {
    if (!_scrollController.hasClients) return;

    final screenH = MediaQuery.of(context).size.height;
    final y = event.position.dy;
    double delta = 0;

    // Zona superior
    if (y < kEdgeActivation) {
      final t = 1 - (y / kEdgeActivation); // 0 → kEdgeActivation  ⇒  0…1
      delta = -kMaxSpeed * t;
    }
    // Zona inferior
    if (y > screenH - kEdgeActivation) {
      final t = 1 - ((screenH - y) / kEdgeActivation);
      delta = kMaxSpeed * t;
    }

    if (delta != 0) {
      final newOffset = (_scrollController.offset + delta)
          .clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.jumpTo(newOffset); // instantáneo y muy fluido
    }
  }

  Future<void> _verifyOrder() async {
    _wrongIndices.clear();
    int correct = 0;

    for (int i = 0; i < _userOrder.length; i++) {
      if (_userOrder[i] == _correctOrder[i]) {
        correct++;
      } else {
        _wrongIndices.add(i);
      }
    }

    _score = (correct / _correctOrder.length) * 100;
    final passed = _score >= 70;

    setState(() {
      _isCompleted = passed;
      _isLocked = passed;
      _statusMessage = 'Calificación: ${_score.toStringAsFixed(1)}% '
          '${passed ? "✅" : "❌"} '
          'Incorrectas: ${_wrongIndices.length}';
    });

    await _showResultDialog(passed);
  }

  void _completeActivity() {
    Navigator.pop(context, {
      'score': _score,
      'passed': _isCompleted,
    });
  }

  void _showGradingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Criterios de Evaluación',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu calificación se basa en el porcentaje de líneas de código colocadas correctamente:',
                style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textPrimary),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 12),
              Text(
                '• Cada línea correcta aporta 5.56% a la calificación total.',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              Text(
                '• Se aprueba con 70% o más.',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
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

  Future<void> _showResultDialog(bool passed) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                passed ? Icons.check_circle : Icons.error,
                color: passed ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                passed ? '¡Buen trabajo!' : 'Revisión',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calificación: ${_score.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                if (!passed) ...[
                  Text(
                    'Líneas en posición incorrecta:',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  ..._wrongIndices.map(
                    (i) => Text(
                      '• ${_userOrder[i]}',
                      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (passed) _completeActivity();
              },
              child: Text(
                'Aceptar',
                style: GoogleFonts.poppins(color: AppColors.textPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'back_button',
            onPressed: () => Navigator.pop(context),
            backgroundColor: AppColors.glassmorphicBackground,
            child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'grade_button',
            onPressed: _showGradingInfo,
            backgroundColor: AppColors.backgroundDark,
            child: Icon(Icons.grade, color: AppColors.textPrimary),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SafeArea(
        child: Listener(
          onPointerMove: _handleDragScroll,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassmorphicCard(
                  child: Text(
                    'Ejercicio: Registro de Horas de Estudio',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Text(
                    'Ordena las líneas de código para completar el algoritmo de registro de horas de estudio. Arrastra las líneas disponibles a las posiciones correctas.',
                    style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Algoritmo de Registro de Horas:',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        color: Colors.black87,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(_userOrder.length, (index) {
                            final indentationLevel = _userOrder[index].isEmpty ? 0 : _getIndentationLevel(_userOrder[index]);
                            final isFixed = _initialUserOrder[index].isNotEmpty;
                            final isWrong = _wrongIndices.contains(index) && !_isCompleted;

                            return Padding(
                              padding: EdgeInsets.only(left: 16.0 * indentationLevel),
                              child: SizedBox(
                                width: double.infinity,
                                child: DragTarget<String>(
                                  hitTestBehavior: HitTestBehavior.translucent,
                                  onWillAccept: (data) => !_isLocked && !isFixed,
                                  onAccept: (data) {
                                    setState(() {
                                      final previous = _userOrder[index];
                                      if (previous.isNotEmpty) _availableLines.add(previous);
                                      _userOrder[index] = data;
                                      _availableLines.remove(data);
                                    });
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _userOrder[index].isEmpty ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: isWrong
                                            ? Border.all(color: Colors.redAccent, width: 2)
                                            : (_userOrder[index].isNotEmpty && !isFixed
                                                ? Border.all(color: AppColors.glassmorphicBorder, width: 1)
                                                : null),
                                      ),
                                      child: _userOrder[index].isEmpty
                                          ? Text(
                                              'Arrastra una línea aquí',
                                              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                                              textAlign: TextAlign.left,
                                            )
                                          : Text(
                                              _userOrder[index],
                                              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                                              textAlign: TextAlign.left,
                                            ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Líneas disponibles:',
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableLines.map((line) {
                            return Draggable<String>(
                              data: line,
                              feedback: Material(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.progressActive,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    line,
                                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                                  ),
                                ),
                              ),
                              childWhenDragging: Container(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.progressActive,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  line,
                                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                if (_statusMessage != null)
                  GlassmorphicCard(
                    child: Text(
                      _statusMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: _isCompleted ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedButton(
                      text: 'Verificar',
                      onPressed: _isLocked ? null : _verifyOrder,
                      gradient: LinearGradient(
                        colors: _isLocked
                            ? [Colors.grey.shade600, Colors.grey.shade400]
                            : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                      ),
                    ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    const SizedBox(width: 16),
                    _buildAnimatedButton(
                      text: 'Reiniciar',
                      onPressed: _isLocked ? null : _resetActivity,
                      gradient: LinearGradient(
                        colors: _isLocked
                            ? [Colors.grey.shade600, Colors.grey.shade400]
                            : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                      ),
                    ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  ],
                ),
              ],
            ),
          ),
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