import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:siapp/theme/app_colors.dart';
import 'dart:math';

class FlowchartActivityScreen extends StatefulWidget {
  final Map<String, dynamic>? moduleData;

  const FlowchartActivityScreen({Key? key, this.moduleData}) : super(key: key);

  @override
  _FlowchartActivityScreenState createState() => _FlowchartActivityScreenState();
}

class _FlowchartActivityScreenState extends State<FlowchartActivityScreen> with TickerProviderStateMixin {
  List<String> _steps = [
    'ingresar x',
    'ingresar y',
    'z=x+y',
    'z>10',
    'El resultado es mayor',
    'el resultado es menor',
  ];

  final Map<String, Offset> _stepPositions = {};
  final Map<String, bool> _isPlaced = {};
  final Map<String, String?> _dragTargetOccupancy = {};
  final Map<String, Offset> _correctPositions = {
    'ingresar x': const Offset(110, 90),
    'ingresar y': const Offset(110, 160),
    'z=x+y': const Offset(110, 230),
    'z>10': const Offset(110, 300),
    'El resultado es mayor': const Offset(210, 360),
    'el resultado es menor': const Offset(10, 360),
  };

  String? _statusMessage;
  bool _isCompleted = false;
  bool _isLocked = false;
  double _score = 0.0;
  List<String> _wrongSteps = [];

  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _steps.shuffle(Random());
    for (var step in _steps) {
      _stepPositions[step] = Offset.zero;
      _isPlaced[step] = false;
    }
    for (var step in _correctPositions.keys) {
      _dragTargetOccupancy[step] = null;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetPositions() {
    setState(() {
      for (var step in _steps) {
        _stepPositions[step] = Offset.zero;
        _isPlaced[step] = false;
      }
      for (var step in _correctPositions.keys) {
        _dragTargetOccupancy[step] = null;
      }
      _statusMessage = null;
      _isCompleted = false;
      _isLocked = false;
      _score = 0.0;
      _wrongSteps.clear();
      _steps.shuffle(Random());
    });
  }

  Future<void> _verifyDiagram() async {
    _wrongSteps.clear();
    int correct = 0;

    for (final step in _steps) {
      final correctPos = _correctPositions[step]!;
      final currentPos = _stepPositions[step]!;
      final placed = _isPlaced[step]!;
      const tol = 20.0;

      final ok = placed &&
          (currentPos.dx - correctPos.dx).abs() <= tol &&
          (currentPos.dy - correctPos.dy).abs() <= tol;

      if (ok) {
        correct++;
      } else {
        _wrongSteps.add(step);
      }
    }

    _score = (correct / _steps.length) * 100;
    final passed = _score >= 70;

    setState(() {
      _isCompleted = passed;
      _isLocked = passed;
      _statusMessage =
          'Calificación: ${_score.toStringAsFixed(1)}% ${passed ? "✅" : "❌"} Incorrectos: ${_wrongSteps.length}';
    });

    await _showResultDialog(passed);
  }

  void _completeActivity() {
    Navigator.pop(context, {'score': _score, 'passed': _isCompleted});
  }

  Future<void> _showResultDialog(bool passed) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassmorphicBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              passed ? Icons.check_circle : Icons.error,
              color: passed ? AppColors.success : AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              passed ? '¡Actividad Completada!' : 'Actividad No Aprobada',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
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
                'Calificación: ${_score.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (_wrongSteps.isNotEmpty && !passed) ...[
                Text(
                  'Pasos incorrectos:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                ..._wrongSteps.map((step) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Text(
                        '• $step',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )),
              ],
              if (passed)
                Text(
                  '¡Felicidades! Has completado la actividad.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (passed) _completeActivity();
            },
            child: Text(
              'Aceptar',
              style: GoogleFonts.poppins(color: AppColors.progressActive),
            ),
          ),
        ],
      ),
    );
  }

  void _showGradingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassmorphicBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'Criterios de Evaluación',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
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
                'Para aprobar esta actividad, debes colocar correctamente al menos el 70% de los pasos en el diagrama de flujo.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• Cada paso debe estar en su posición correcta dentro de una tolerancia de 20 píxeles.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• La calificación se calcula como el porcentaje de pasos colocados correctamente.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Se aprueba con una calificación de 70% o más.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            heroTag: null,
            backgroundColor: AppColors.glassmorphicBackground,
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _showGradingInfo,
            heroTag: null,
            backgroundColor: AppColors.glassmorphicBackground,
            child: const Icon(Icons.info, color: Colors.white),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassmorphicCard(
                child: Text(
                  'Diseñar Diagrama de Flujo',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
              const SizedBox(height: 20),
              if (_statusMessage != null)
                GlassmorphicCard(
                  child: Text(
                    _statusMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: _isCompleted ? AppColors.success : AppColors.textPrimary,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              GlassmorphicCard(
                child: Text(
                  'Instrucciones: Arrastra los pasos y colócalos en el lugar correcto sobre el diagrama de flujo.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              GlassmorphicCard(
                child: Stack(
                  children: [
                    Container(
                      height: 500,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.glassmorphicBorder, width: 2),
                        image: const DecorationImage(
                          image: AssetImage('assets/flowchart.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 500,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          ..._correctPositions.entries.map((entry) {
                            final step = entry.key;
                            return Positioned(
                              left: entry.value.dx,
                              top: entry.value.dy,
                              child: DragTarget<String>(
                                builder: (context, candidateData, rejectedData) {
                                  return Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _dragTargetOccupancy[step] == null
                                          ? AppColors.glassmorphicBackground.withOpacity(0.3)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  );
                                },
                                onAcceptWithDetails: (details) {
                                  if (_isLocked) return;
                                  setState(() {
                                    final droppedStep = details.data;
                                    final targetPos = _correctPositions[step]!;
                                    final adjustedOffset = Offset(targetPos.dx, targetPos.dy);

                                    final currentOccupant = _dragTargetOccupancy[step];
                                    if (currentOccupant != null) {
                                      _stepPositions[currentOccupant] = Offset.zero;
                                      _isPlaced[currentOccupant] = false;
                                    }

                                    _stepPositions[droppedStep] = adjustedOffset;
                                    _isPlaced[droppedStep] = true;
                                    _dragTargetOccupancy[step] = droppedStep;

                                    for (var target in _dragTargetOccupancy.keys) {
                                      if (target != step && _dragTargetOccupancy[target] == droppedStep) {
                                        _dragTargetOccupancy[target] = null;
                                      }
                                    }
                                  });
                                },
                              ),
                            );
                          }),
                          ..._steps.map((step) {
                            return Positioned(
                              left: _stepPositions[step]!.dx,
                              top: _stepPositions[step]!.dy,
                              child: Draggable<String>(
                                data: step,
                                feedback: Material(
                                  elevation: 4.0,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassmorphicBackground,
                                      borderRadius: BorderRadius.circular(8),
                                      border: _wrongSteps.contains(step) && !_isCompleted
                                          ? Border.all(color: AppColors.error, width: 2)
                                          : null,
                                    ),
                                    child: Text(
                                      step,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                childWhenDragging: Container(),
                                child: _isPlaced[step]!
                                    ? Container(
                                        width: 100,
                                        padding: const EdgeInsets.all(6.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.glassmorphicBackground,
                                          borderRadius: BorderRadius.circular(8),
                                          border: _wrongSteps.contains(step) && !_isCompleted
                                              ? Border.all(color: AppColors.error, width: 2)
                                              : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          step,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      )
                                    : Container(),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 20),
              GlassmorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pasos disponibles:',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.progressActive,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.glassmorphicBorder, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _steps.map((step) {
                              return !_isPlaced[step]!
                                  ? Draggable<String>(
                                      data: step,
                                      feedback: Material(
                                        elevation: 4.0,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 100,
                                          padding: const EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            color: AppColors.glassmorphicBackground,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            step,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Container(),
                                      child: Container(
                                        width: 100,
                                        padding: const EdgeInsets.all(6.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.glassmorphicBackground.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          step,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    _buildAnimatedButton(
                      text: 'Verificar',
                      onPressed: _isLocked ? null : _verifyDiagram,
                      gradient: LinearGradient(
                        colors: _isLocked
                            ? [Colors.grey.shade600, Colors.grey.shade400]
                            : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                      ),
                    ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 16),
                    _buildAnimatedButton(
                      text: 'Reiniciar',
                      onPressed: _isLocked ? null : _resetPositions,
                      gradient: LinearGradient(
                        colors: _isLocked
                            ? [Colors.grey.shade600, Colors.grey.shade400]
                            : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                      ),
                    ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
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
            color: AppColors.textPrimary,
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