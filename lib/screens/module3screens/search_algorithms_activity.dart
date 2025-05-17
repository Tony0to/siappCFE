import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:siapp/theme/app_colors.dart';

class SearchAlgorithmsActivityScreen extends StatefulWidget {
  const SearchAlgorithmsActivityScreen({super.key});

  @override
  _SearchAlgorithmsActivityScreenState createState() => _SearchAlgorithmsActivityScreenState();
}

class _SearchAlgorithmsActivityScreenState extends State<SearchAlgorithmsActivityScreen> {
  String _selectedSearchType = 'lineal';
  String? _statusMessage;
  bool _linearCompleted = false;
  bool _binaryCompleted = false;
  bool _isCompleted = false;
  bool _linearLocked = false;
  bool _binaryLocked = false;
  double _linearScore = 0.0;
  double _binaryScore = 0.0;
  double _score = 0.0;
  List<int> _linearWrongIndices = [];
  List<int> _binaryWrongIndices = [];

  final ScrollController _scrollController = ScrollController();

  final List<int> _sortedList = [10, 15, 18, 20, 23, 27, 30, 35, 40, 45];

  final List<String> _correctLinearOrder = [
    'lista ← [10, 15, 18, 20, 23, 27, 30, 35, 40, 45]',
    'IMPRIMIR "Ingresa el número a buscar:"',
    'leer numero',
    'encontrado ← FALSO',
    'PARA i desde 0 hasta longitud(lista)-1 HACER',
    'SI lista[i] = numero ENTONCES',
    'IMPRIMIR "Número encontrado en la posición", i',
    'encontrado ← VERDADERO',
    'TERMINAR',
    'FIN SI',
    'FIN PARA',
    'SI NO encontrado ENTONCES',
    'IMPRIMIR "Número no encontrado (búsqueda lineal)"',
    'FIN SI',
  ];

  final List<String> _correctBinaryOrder = [
    'lista ← [10, 15, 18, 20, 23, 27, 30, 35, 40, 45]',
    'IMPRIMIR "Ingresa el número a buscar:"',
    'leer numero',
    'inicio ← 0',
    'fin ← longitud(lista) - 1',
    'encontrado ← FALSO',
    'MIENTRAS inicio ≤ fin Y NO encontrado HACER',
    'medio ← (inicio + fin) / 2',
    'SI lista[medio] = numero ENTONCES',
    'encontrado ← VERDADERO',
    'IMPRIMIR "Número encontrado en la posición", medio',
    'SINO SI lista[medio] < numero ENTONCES',
    'inicio ← medio + 1',
    'SINO',
    'fin ← medio - 1',
    'FIN SI',
    'FIN MIENTRAS',
    'SI NO encontrado ENTONCES',
    'IMPRIMIR "Número no encontrado (búsqueda binaria)"',
    'FIN SI',
  ];

  late List<String> _initialLinearOrder;
  late List<String> _initialBinaryOrder;
  List<String> _userLinearOrder = List.filled(14, '');
  List<String> _userBinaryOrder = List.filled(20, '');
  List<String> _availableLinearLines = [];
  List<String> _availableBinaryLines = [];

  @override
  void initState() {
    super.initState();
    _initializeActivity();
  }

  void _initializeActivity() {
    final random = Random();

    // Linear: 50% pre-filled (7 out of 14 lines)
    final linearIndices = List<int>.generate(14, (i) => i)..shuffle(random);
    final prefilledLinearIndices = linearIndices.sublist(0, 10);
    _userLinearOrder = List.filled(14, '');

    for (final i in prefilledLinearIndices) {
      _userLinearOrder[i] = _correctLinearOrder[i];
    }
    _availableLinearLines = linearIndices.sublist(7).map((i) => _correctLinearOrder[i]).toList();
    _initialLinearOrder = List.from(_userLinearOrder);

    // Binary: 50% pre-filled (10 out of 20 lines)
    final binaryIndices = List<int>.generate(20, (i) => i)..shuffle(random);
    final prefilledBinaryIndices = binaryIndices.sublist(0, 15);
    _userBinaryOrder = List.filled(20, '');

    for (final i in prefilledBinaryIndices) {
      _userBinaryOrder[i] = _correctBinaryOrder[i];
    }
    _availableBinaryLines = binaryIndices.sublist(10).map((i) => _correctBinaryOrder[i]).toList();
    _initialBinaryOrder = List.from(_userBinaryOrder);

    setState(() {});
  }

  int _getIndentationLevel(String line) {
    if (_selectedSearchType == 'lineal') {
      if (line.contains('SI lista[i] = numero ENTONCES') ||
          line.contains('IMPRIMIR "Número encontrado en la posición", i') ||
          line.contains('encontrado ← VERDADERO') ||
          line.contains('TERMINAR') ||
          line.contains('FIN SI') ||
          line.contains('SI NO encontrado ENTONCES') ||
          line.contains('IMPRIMIR "Número no encontrado (búsqueda lineal)"')) {
        return 1;
      }
    } else {
      if (line.contains('medio ← (inicio + fin) / 2') ||
          line.contains('SI lista[medio] = numero ENTONCES') ||
          line.contains('encontrado ← VERDADERO') ||
          line.contains('IMPRIMIR "Número encontrado en la posición", medio') ||
          line.contains('SINO SI lista[medio] < numero ENTONCES') ||
          line.contains('inicio ← medio + 1') ||
          line.contains('SINO') ||
          line.contains('fin ← medio - 1') ||
          line.contains('FIN SI') ||
          line.contains('SI NO encontrado ENTONCES') ||
          line.contains('IMPRIMIR "Número no encontrado (búsqueda binaria)"')) {
        return 1;
      }
    }
    return 0;
  }

  void _resetActivity() {
    setState(() {
      if (_selectedSearchType == 'lineal') {
        _userLinearOrder = List.from(_initialLinearOrder);
        _availableLinearLines = _correctLinearOrder
            .asMap()
            .entries
            .where((entry) => _userLinearOrder[entry.key].isEmpty)
            .map((entry) => entry.value)
            .toList();
        _linearCompleted = false;
        _linearLocked = false;
        _linearScore = 0.0;
        _linearWrongIndices.clear();
      } else {
        _userBinaryOrder = List.from(_initialBinaryOrder);
        _availableBinaryLines = _correctBinaryOrder
            .asMap()
            .entries
            .where((entry) => _userBinaryOrder[entry.key].isEmpty)
            .map((entry) => entry.value)
            .toList();
        _binaryCompleted = false;
        _binaryLocked = false;
        _binaryScore = 0.0;
        _binaryWrongIndices.clear();
      }
      _statusMessage = null;
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
    if (_selectedSearchType == 'lineal') {
      _linearWrongIndices.clear();
      int correct = 0;

      for (int i = 0; i < _userLinearOrder.length; i++) {
        if (_userLinearOrder[i] == _correctLinearOrder[i]) {
          correct++;
        } else {
          _linearWrongIndices.add(i);
        }
      }

      _linearScore = (correct / _correctLinearOrder.length) * 100;
      final passed = _linearScore >= 70;

      setState(() {
        _linearCompleted = passed;
        _linearLocked = passed;
        _statusMessage = 'Calificación: ${_linearScore.toStringAsFixed(1)}% '
            '${passed ? "✅" : "❌"} '
            'Incorrectas: ${_linearWrongIndices.length}';
      });

      await _showResultDialog(passed, 'Lineal');
    } else {
      _binaryWrongIndices.clear();
      int correct = 0;

      for (int i = 0; i < _userBinaryOrder.length; i++) {
        if (_userBinaryOrder[i] == _correctBinaryOrder[i]) {
          correct++;
        } else {
          _binaryWrongIndices.add(i);
        }
      }

      _binaryScore = (correct / _correctBinaryOrder.length) * 100;
      final passed = _binaryScore >= 70;

      setState(() {
        _binaryCompleted = passed;
        _binaryLocked = passed;
        _statusMessage = 'Calificación: ${_binaryScore.toStringAsFixed(1)}% '
            '${passed ? "✅" : "❌"} '
            'Incorrectas: ${_binaryWrongIndices.length}';
      });

      await _showResultDialog(passed, 'Binaria');
    }
  }

  void _completeActivity() {
    _isCompleted = _linearCompleted && _binaryCompleted;
    _score = (_linearScore + _binaryScore) / 2;
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
                'Tu calificación se basa en el porcentaje de líneas de código colocadas correctamente para cada algoritmo:',
                style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textPrimary),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 12),
              Text(
                '• Lineal: Cada línea aporta 7.14% (14 líneas).',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              Text(
                '• Binaria: Cada línea aporta 5% (20 líneas).',
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
    final score = _selectedSearchType == 'lineal' ? _linearScore : _binaryScore;
    final wrongIndices = _selectedSearchType == 'lineal' ? _linearWrongIndices : _binaryWrongIndices;
    final userOrder = _selectedSearchType == 'lineal' ? _userLinearOrder : _userBinaryOrder;

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
                if (passed && _linearCompleted && _binaryCompleted) {
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
                    'Ejercicio: Búsqueda Lineal y Binaria',
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
                    'Lista ordenada: ${_sortedList.join(', ')}',
                    style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Text(
                    'Ordena las líneas de código para completar los algoritmos de búsqueda lineal y binaria.',
                    style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSearchType = 'lineal';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Búsqueda Lineal',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _selectedSearchType == 'lineal' ? AppColors.progressActive : AppColors.textSecondary,
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
                        _selectedSearchType = 'binaria';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Búsqueda Binaria',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _selectedSearchType == 'binaria' ? AppColors.progressActive : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                if (_selectedSearchType == 'lineal') ...[
                  GlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Algoritmo Lineal:',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          color: Colors.black87,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(_userLinearOrder.length, (index) {
                              final indentationLevel = _userLinearOrder[index].isEmpty ? 0 : _getIndentationLevel(_userLinearOrder[index]);
                              final isFixed = _initialLinearOrder[index].isNotEmpty;
                              final isWrong = _linearWrongIndices.contains(index) && !_linearCompleted;

                              return Padding(
                                padding: EdgeInsets.only(left: 16.0 * indentationLevel),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: DragTarget<String>(
                                    hitTestBehavior: HitTestBehavior.translucent,
                                    onWillAccept: (data) => !_linearLocked && !isFixed,
                                    onAccept: (data) {
                                      setState(() {
                                        final previous = _userLinearOrder[index];
                                        if (previous.isNotEmpty) _availableLinearLines.add(previous);
                                        _userLinearOrder[index] = data;
                                        _availableLinearLines.remove(data);
                                      });
                                    },
                                    builder: (context, candidateData, rejectedData) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _userLinearOrder[index].isEmpty ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          border: isWrong
                                              ? Border.all(color: Colors.redAccent, width: 2)
                                              : (_userLinearOrder[index].isNotEmpty && !isFixed
                                                  ? Border.all(color: AppColors.glassmorphicBorder, width: 1)
                                                  : null),
                                        ),
                                        child: _userLinearOrder[index].isEmpty
                                            ? Text(
                                                'Arrastra una línea aquí',
                                                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                                                textAlign: TextAlign.left,
                                              )
                                            : Text(
                                                _userLinearOrder[index],
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
                            children: _availableLinearLines.map((line) {
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
                  if (_statusMessage != null && _selectedSearchType == 'lineal')
                    GlassmorphicCard(
                      child: Text(
                        _statusMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _linearCompleted ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedButton(
                        text: 'Verificar',
                        onPressed: _linearLocked ? null : _verifyOrder,
                        gradient: LinearGradient(
                          colors: _linearLocked
                              ? [Colors.grey.shade600, Colors.grey.shade400]
                              : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                        ),
                      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(width: 16),
                      _buildAnimatedButton(
                        text: 'Reiniciar',
                        onPressed: _linearLocked ? null : _resetActivity,
                        gradient: LinearGradient(
                          colors: _linearLocked
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
                          'Algoritmo Binario:',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          color: Colors.black87,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(_userBinaryOrder.length, (index) {
                              final indentationLevel = _userBinaryOrder[index].isEmpty ? 0 : _getIndentationLevel(_userBinaryOrder[index]);
                              final isFixed = _initialBinaryOrder[index].isNotEmpty;
                              final isWrong = _binaryWrongIndices.contains(index) && !_binaryCompleted;

                              return Padding(
                                padding: EdgeInsets.only(left: 16.0 * indentationLevel),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: DragTarget<String>(
                                    hitTestBehavior: HitTestBehavior.translucent,
                                    onWillAccept: (data) => !_binaryLocked && !isFixed,
                                    onAccept: (data) {
                                      setState(() {
                                        final previous = _userBinaryOrder[index];
                                        if (previous.isNotEmpty) _availableBinaryLines.add(previous);
                                        _userBinaryOrder[index] = data;
                                        _availableBinaryLines.remove(data);
                                      });
                                    },
                                    builder: (context, candidateData, rejectedData) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _userBinaryOrder[index].isEmpty ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          border: isWrong
                                              ? Border.all(color: Colors.redAccent, width: 2)
                                              : (_userBinaryOrder[index].isNotEmpty && !isFixed
                                                  ? Border.all(color: AppColors.glassmorphicBorder, width: 1)
                                                  : null),
                                        ),
                                        child: _userBinaryOrder[index].isEmpty
                                            ? Text(
                                                'Arrastra una línea aquí',
                                                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                                                textAlign: TextAlign.left,
                                              )
                                            : Text(
                                                _userBinaryOrder[index],
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
                            children: _availableBinaryLines.map((line) {
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
                  if (_statusMessage != null && _selectedSearchType == 'binaria')
                    GlassmorphicCard(
                      child: Text(
                        _statusMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _binaryCompleted ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedButton(
                        text: 'Verificar',
                        onPressed: _binaryLocked ? null : _verifyOrder,
                        gradient: LinearGradient(
                          colors: _binaryLocked
                              ? [Colors.grey.shade600, Colors.grey.shade400]
                              : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                        ),
                      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(width: 16),
                      _buildAnimatedButton(
                        text: 'Reiniciar',
                        onPressed: _binaryLocked ? null : _resetActivity,
                        gradient: LinearGradient(
                          colors: _binaryLocked
                              ? [Colors.grey.shade600, Colors.grey.shade400]
                              : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                        ),
                      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    ],
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