import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'dart:async';
import 'package:siapp/theme/app_colors.dart';

class SumDigitsActivityScreen extends StatefulWidget {
  const SumDigitsActivityScreen({super.key});

  @override
  _SumDigitsActivityScreenState createState() => _SumDigitsActivityScreenState();
}

class _SumDigitsActivityScreenState extends State<SumDigitsActivityScreen> {
  String _selectedType = 'iterative';
  String? _statusMessage;
  bool _iterativeCompleted = false;
  bool _recursiveCompleted = false;
  bool _isCompleted = false;
  bool _iterativeLocked = false;
  bool _recursiveLocked = false;
  double _iterativeScore = 0.0;
  double _recursiveScore = 0.0;
  double _score = 0.0;
  List<int> _iterativeWrongIndices = [];
  List<int> _recursiveWrongIndices = [];
  List<String> _simulationSteps = [];

  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  final List<String> _iterativeCodeLines = [
    'INICIO',
    'IMPRIMIR "Ingresa un número:"',
    'leer numero',
    'suma ← 0',
    'MIENTRAS numero > 0 HACER',
    'suma ← suma + (numero MOD 10)',
    'numero ← numero DIV 10',
    'FIN MIENTRAS',
    'IMPRIMIR "Suma de los dígitos:", suma',
    'FIN',
  ];

  final List<String> _recursiveCodeLines = [
    'FUNCIÓN sumaDigitos(n)',
    'SI n = 0 ENTONCES',
    'RETORNAR 0',
    'SINO',
    'RETORNAR (n MOD 10) + sumaDigitos(n DIV 10)',
    'FIN FUNCIÓN',
  ];

  final List<String> _correctIterativeOrder = [
    'INICIO',
    'IMPRIMIR "Ingresa un número:"',
    'leer numero',
    'suma ← 0',
    'MIENTRAS numero > 0 HACER',
    'suma ← suma + (numero MOD 10)',
    'numero ← numero DIV 10',
    'FIN MIENTRAS',
    'IMPRIMIR "Suma de los dígitos:", suma',
    'FIN',
  ];

  final List<String> _correctRecursiveOrder = [
    'FUNCIÓN sumaDigitos(n)',
    'SI n = 0 ENTONCES',
    'RETORNAR 0',
    'SINO',
    'RETORNAR (n MOD 10) + sumaDigitos(n DIV 10)',
    'FIN FUNCIÓN',
  ];

  late List<String> _initialIterativeOrder;
  late List<String> _initialRecursiveOrder;
  List<String> _userIterativeOrder = List.filled(10, '');
  List<String> _userRecursiveOrder = List.filled(6, '');
  List<String> _availableIterativeLines = [];
  List<String> _availableRecursiveLines = [];

  @override
  void initState() {
    super.initState();
    _initializeActivity();
  }

  void _initializeActivity() {
    final random = Random();

    // Iterative: 50% pre-filled (5 out of 10 lines)
    final iterativeIndices = List<int>.generate(10, (i) => i)..shuffle(random);
    final prefilledIterativeIndices = iterativeIndices.sublist(0, 6);
    _userIterativeOrder = List.filled(10, '');

    for (final i in prefilledIterativeIndices) {
      _userIterativeOrder[i] = _correctIterativeOrder[i];
    }
    _availableIterativeLines = iterativeIndices.sublist(5).map((i) => _correctIterativeOrder[i]).toList();
    _initialIterativeOrder = List.from(_userIterativeOrder);

    // Recursive: 50% pre-filled (3 out of 6 lines)
    final recursiveIndices = List<int>.generate(6, (i) => i)..shuffle(random);
    final prefilledRecursiveIndices = recursiveIndices.sublist(0, 3);
    _userRecursiveOrder = List.filled(6, '');

    for (final i in prefilledRecursiveIndices) {
      _userRecursiveOrder[i] = _correctRecursiveOrder[i];
    }
    _availableRecursiveLines = recursiveIndices.sublist(3).map((i) => _correctRecursiveOrder[i]).toList();
    _initialRecursiveOrder = List.from(_userRecursiveOrder);

    setState(() {});
  }

  int _getIndentationLevel(String line) {
    if (_selectedType == 'iterative') {
      if (line.contains('suma ← suma + (numero MOD 10)') ||
          line.contains('numero ← numero DIV 10)') ||
          line.contains('FIN MIENTRAS')) {
        return 1;
      }
    } else {
      if (line.contains('RETORNAR 0') ||
          line.contains('RETORNAR (n MOD 10) + sumaDigitos(n DIV 10)') ||
          line.contains('SINO')) {
        return 1;
      }
    }
    return 0;
  }

  void _resetActivity() {
    setState(() {
      if (_selectedType == 'iterative') {
        _userIterativeOrder = List.from(_initialIterativeOrder);
        _availableIterativeLines = _correctIterativeOrder
            .asMap()
            .entries
            .where((entry) => _userIterativeOrder[entry.key].isEmpty)
            .map((entry) => entry.value)
            .toList();
        _iterativeCompleted = false;
        _iterativeLocked = false;
        _iterativeScore = 0.0;
        _iterativeWrongIndices.clear();
      } else {
        _userRecursiveOrder = List.from(_initialRecursiveOrder);
        _availableRecursiveLines = _correctRecursiveOrder
            .asMap()
            .entries
            .where((entry) => _userRecursiveOrder[entry.key].isEmpty)
            .map((entry) => entry.value)
            .toList();
        _recursiveCompleted = false;
        _recursiveLocked = false;
        _recursiveScore = 0.0;
        _recursiveWrongIndices.clear();
      }
      _statusMessage = null;
      _simulationSteps = [];
    });
  }

  void _handleDragScroll(PointerEvent event) {
    const double edgeThreshold = 50.0;
    const double scrollSpeed = 10.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final pointerY = event.position.dy;

    if (pointerY < edgeThreshold && _scrollController.hasClients) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (_scrollController.hasClients) {
          final newOffset = _scrollController.offset - scrollSpeed;
          _scrollController.animateTo(
            newOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      });
    } else if (pointerY > screenHeight - edgeThreshold && _scrollController.hasClients) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (_scrollController.hasClients) {
          final newOffset = _scrollController.offset + scrollSpeed;
          _scrollController.animateTo(
            newOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      });
    } else {
      _scrollTimer?.cancel();
      _scrollTimer = null;
    }
  }

  void _stopDragScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  Future<void> _verifyOrder() async {
    if (_selectedType == 'iterative') {
      _iterativeWrongIndices.clear();
      int correct = 0;

      for (int i = 0; i < _userIterativeOrder.length; i++) {
        if (_userIterativeOrder[i] == _correctIterativeOrder[i]) {
          correct++;
        } else {
          _iterativeWrongIndices.add(i);
        }
      }

      _iterativeScore = (correct / _correctIterativeOrder.length) * 100;
      final passed = _iterativeScore >= 70;

      setState(() {
        _iterativeCompleted = passed;
        _iterativeLocked = passed;
        _statusMessage = 'Calificación: ${_iterativeScore.toStringAsFixed(1)}% '
            '${passed ? "✅" : "❌"} '
            'Incorrectas: ${_iterativeWrongIndices.length}';
      });

      await _showResultDialog(passed, 'Iterativa');
    } else {
      _recursiveWrongIndices.clear();
      int correct = 0;

      for (int i = 0; i < _userRecursiveOrder.length; i++) {
        if (_userRecursiveOrder[i] == _correctRecursiveOrder[i]) {
          correct++;
        } else {
          _recursiveWrongIndices.add(i);
        }
      }

      _recursiveScore = (correct / _correctRecursiveOrder.length) * 100;
      final passed = _recursiveScore >= 70;

      setState(() {
        _recursiveCompleted = passed;
        _recursiveLocked = passed;
        _statusMessage = 'Calificación: ${_recursiveScore.toStringAsFixed(1)}% '
            '${passed ? "✅" : "❌"} '
            'Incorrectas: ${_recursiveWrongIndices.length}';
      });

      await _showResultDialog(passed, 'Recursiva');
    }
  }

  void _simulateIterative(int number) {
    List<String> steps = [];
    int suma = 0;
    int num = number;

    steps.add('Número inicial: $num');
    steps.add('suma ← 0');

    while (num > 0) {
      int digit = num % 10;
      suma += digit;
      steps.add('suma ← $suma + ($num MOD 10) = ${suma - digit} + $digit = $suma');
      num = num ~/ 10;
      steps.add('numero ← $num DIV 10 = $num');
    }

    steps.add('Suma de los dígitos: $suma');
    setState(() {
      _simulationSteps = steps;
    });
  }

  void _simulateRecursive(int number, [int depth = 0]) {
    List<String> steps = [];
    void recursiveSteps(int n, int d) {
      String indent = '  ' * d;
      steps.add('${indent}sumaDigitos($n):');
      if (n == 0) {
        steps.add('${indent}  n = 0, RETORNAR 0');
        return;
      }
      int digit = n % 10;
      int nextN = n ~/ 10;
      steps.add('${indent}  (n MOD 10) = $digit');
      steps.add('${indent}  (n DIV 10) = $nextN');
      recursiveSteps(nextN, d + 1);
      steps.add('${indent}RETORNAR $digit + sumaDigitos($nextN) = $digit + ${d == 0 ? '' : '...'}');
    }

    recursiveSteps(number, depth);
    int result = _calculateRecursiveSum(number);
    steps.add('Suma de los dígitos: $result');
    setState(() {
      _simulationSteps = steps;
    });
  }

  int _calculateRecursiveSum(int n) {
    if (n == 0) return 0;
    return (n % 10) + _calculateRecursiveSum(n ~/ 10);
  }

  void _runSimulation() {
    const exampleNumber = 123;
    if (_selectedType == 'iterative') {
      _simulateIterative(exampleNumber);
    } else {
      _simulateRecursive(exampleNumber);
    }
  }

  void _completeActivity() {
    _isCompleted = _iterativeCompleted && _recursiveCompleted;
    _score = (_iterativeScore + _recursiveScore) / 2;
    Navigator.pop(context, {
      'score': _score,
      'passed': _isCompleted,
    });
  }

  void _showGradingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassmorphicBackground,
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
                'Tu calificación se basa en el porcentaje de líneas de código colocadas correctamente para cada algoritmo:',
                style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textPrimary),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 12),
              Text(
                '• Iterativo: Cada línea aporta 10% (10 líneas).',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              Text(
                '• Recursivo: Cada línea aporta 16.67% (6 líneas).',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              Text(
                '• Se aprueba cada algoritmo con 70% o más.',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
              Text(
                '• La calificación final es el promedio de ambos.',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
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

  Future<void> _showResultDialog(bool passed, String algorithmType) async {
    final score = _selectedType == 'iterative' ? _iterativeScore : _recursiveScore;
    final wrongIndices = _selectedType == 'iterative' ? _iterativeWrongIndices : _recursiveWrongIndices;
    final userOrder = _selectedType == 'iterative' ? _userIterativeOrder : _userRecursiveOrder;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.progressActive,
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
                  'Calificación ($algorithmType): ${score.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                if (!passed) ...[
                  Text(
                    'Líneas en posición incorrecta:',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  ...wrongIndices.map(
                    (i) => Text(
                      '• ${userOrder[i]}',
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
                if (passed && _iterativeCompleted && _recursiveCompleted) {
                  _completeActivity();
                }
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
    _scrollTimer?.cancel();
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
            backgroundColor: AppColors.glassmorphicBackground,
            child: Icon(Icons.grade, color: AppColors.textPrimary),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SafeArea(
        child: Listener(
          onPointerMove: _handleDragScroll,
          onPointerUp: (_) => _stopDragScroll(),
          onPointerCancel: (_) => _stopDragScroll(),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassmorphicCard(
                  child: Text(
                    'Ejercicio: Suma de Dígitos',
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
                    'Ordena las líneas de código para completar los algoritmos iterativo y recursivo para sumar los dígitos de un número.',
                    style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = 'iterative';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Versión Iterativa',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _selectedType == 'iterative' ? AppColors.progressActive : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 12),
                GlassmorphicCard(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = 'recursive';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Versión Recursiva',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _selectedType == 'recursive' ? AppColors.progressActive : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                if (_selectedType == 'iterative') ...[
                  GlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Algoritmo Iterativo:',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          color: Colors.black87,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(_userIterativeOrder.length, (index) {
                              final indentationLevel = _userIterativeOrder[index].isEmpty ? 0 : _getIndentationLevel(_userIterativeOrder[index]);
                              final isFixed = _initialIterativeOrder[index].isNotEmpty;
                              final isWrong = _iterativeWrongIndices.contains(index) && !_iterativeCompleted;

                              return Padding(
                                padding: EdgeInsets.only(left: 16.0 * indentationLevel),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: DragTarget<String>(
                                    hitTestBehavior: HitTestBehavior.translucent,
                                    onWillAccept: (data) => !_iterativeLocked && !isFixed,
                                    onAccept: (data) {
                                      setState(() {
                                        final previous = _userIterativeOrder[index];
                                        if (previous.isNotEmpty) _availableIterativeLines.add(previous);
                                        _userIterativeOrder[index] = data;
                                        _availableIterativeLines.remove(data);
                                      });
                                    },
                                    builder: (context, candidateData, rejectedData) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _userIterativeOrder[index].isEmpty ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          border: isWrong
                                              ? Border.all(color: Colors.redAccent, width: 2)
                                              : (_userIterativeOrder[index].isNotEmpty && !isFixed
                                                  ? Border.all(color: AppColors.glassmorphicBorder, width: 1)
                                                  : null),
                                        ),
                                        child: _userIterativeOrder[index].isEmpty
                                            ? Text(
                                                'Arrastra una línea aquí',
                                                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                                                textAlign: TextAlign.left,
                                              )
                                            : Text(
                                                _userIterativeOrder[index],
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
                            children: _availableIterativeLines.map((line) {
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
                  if (_statusMessage != null && _selectedType == 'iterative')
                    GlassmorphicCard(
                      child: Text(
                        _statusMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _iterativeCompleted ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedButton(
                        text: 'Verificar',
                        onPressed: _iterativeLocked ? null : _verifyOrder,
                        gradient: LinearGradient(
                          colors: _iterativeLocked
                              ? [Colors.grey.shade600, Colors.grey.shade400]
                              : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                        ),
                      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(width: 16),
                      _buildAnimatedButton(
                        text: 'Reiniciar',
                        onPressed: _iterativeLocked ? null : _resetActivity,
                        gradient: LinearGradient(
                          colors: _iterativeLocked
                              ? [Colors.grey.shade600, Colors.grey.shade400]
                              : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                        ),
                      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    ],
                  ),
                ] else ...[
                  GlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Algoritmo Recursivo:',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          color: Colors.black87,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(_userRecursiveOrder.length, (index) {
                              final indentationLevel = _userRecursiveOrder[index].isEmpty ? 0 : _getIndentationLevel(_userRecursiveOrder[index]);
                              final isFixed = _initialRecursiveOrder[index].isNotEmpty;
                              final isWrong = _recursiveWrongIndices.contains(index) && !_recursiveCompleted;

                              return Padding(
                                padding: EdgeInsets.only(left: 16.0 * indentationLevel),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: DragTarget<String>(
                                    hitTestBehavior: HitTestBehavior.translucent,
                                    onWillAccept: (data) => !_recursiveLocked && !isFixed,
                                    onAccept: (data) {
                                      setState(() {
                                        final previous = _userRecursiveOrder[index];
                                        if (previous.isNotEmpty) _availableRecursiveLines.add(previous);
                                        _userRecursiveOrder[index] = data;
                                        _availableRecursiveLines.remove(data);
                                      });
                                    },
                                    builder: (context, candidateData, rejectedData) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _userRecursiveOrder[index].isEmpty ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          border: isWrong
                                              ? Border.all(color: Colors.redAccent, width: 2)
                                              : (_userRecursiveOrder[index].isNotEmpty && !isFixed
                                                  ? Border.all(color: AppColors.glassmorphicBorder, width: 1)
                                                  : null),
                                        ),
                                        child: _userRecursiveOrder[index].isEmpty
                                            ? Text(
                                                'Arrastra una línea aquí',
                                                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                                                textAlign: TextAlign.left,
                                              )
                                            : Text(
                                                _userRecursiveOrder[index],
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
                            children: _availableRecursiveLines.map((line) {
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
                  if (_statusMessage != null && _selectedType == 'recursive')
                    GlassmorphicCard(
                      child: Text(
                        _statusMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _recursiveCompleted ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedButton(
                        text: 'Verificar',
                        onPressed: _recursiveLocked ? null : _verifyOrder,
                        gradient: LinearGradient(
                          colors: _recursiveLocked
                              ? [Colors.grey.shade600, Colors.grey.shade400]
                              : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                        ),
                      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(width: 16),
                      _buildAnimatedButton(
                        text: 'Reiniciar',
                        onPressed: _recursiveLocked ? null : _resetActivity,
                        gradient: LinearGradient(
                          colors: _recursiveLocked
                              ? [Colors.grey.shade600, Colors.grey.shade400]
                              : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                        ),
                      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    ],
                  ),
                ],
                if (_iterativeCompleted && _recursiveCompleted) ...[
                  const SizedBox(height: 20),
                  GlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Simulación con el número 123:',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _simulationSteps.map((step) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                step,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 20),
                  Center(
                    child: _buildAnimatedButton(
                      text: 'Ejecutar Simulación',
                      onPressed: _runSimulation,
                      gradient: LinearGradient(
                        colors: [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                      ),
                    ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  ),
                ],
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