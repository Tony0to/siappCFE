import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math'; // Para usar Random
import 'dart:async'; // Para usar Timer

class SumDigitsActivityScreen extends StatefulWidget {
  const SumDigitsActivityScreen({Key? key}) : super(key: key);

  @override
  _SumDigitsActivityScreenState createState() => _SumDigitsActivityScreenState();
}

class _SumDigitsActivityScreenState extends State<SumDigitsActivityScreen> {
  String _selectedType = 'iterative'; // 'iterative' o 'recursive'
  String? _iterativeStatusMessage;
  String? _recursiveStatusMessage;
  bool _isCorrect = false;
  bool _iterativeCompleted = false;
  bool _recursiveCompleted = false;
  bool _iterativeLocked = false;
  bool _recursiveLocked = false;
  List<String> _simulationSteps = [];

  // ScrollController para controlar el desplazamiento
  final ScrollController _scrollController = ScrollController();

  // Timer para el desplazamiento automático
  Timer? _scrollTimer;

  // Líneas de código desordenadas para la versión iterativa
  List<String> _iterativeCodeLines = [
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

  // Líneas de código desordenadas para la versión recursiva
  List<String> _recursiveCodeLines = [
    'FUNCIÓN sumaDigitos(n)',
    'SI n = 0 ENTONCES',
    'RETORNAR 0',
    'SINO',
    'RETORNAR (n MOD 10) + sumaDigitos(n DIV 10)',
    'FIN FUNCIÓN',
  ];

  // Líneas ordenadas correctamente para la versión iterativa
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

  // Líneas ordenadas correctamente para la versión recursiva
  final List<String> _correctRecursiveOrder = [
    'FUNCIÓN sumaDigitos(n)',
    'SI n = 0 ENTONCES',
    'RETORNAR 0',
    'SINO',
    'RETORNAR (n MOD 10) + sumaDigitos(n DIV 10)',
    'FIN FUNCIÓN',
  ];

  // Líneas que el usuario ordenará (50% prellenado de forma no continua)
  List<String> _userIterativeOrder = List.filled(10, '');
  List<String> _userRecursiveOrder = List.filled(6, '');

  // Listas para rastrear líneas disponibles
  List<String> _availableIterativeLines = [];
  List<String> _availableRecursiveLines = [];

  @override
  void initState() {
    super.initState();

    // Prellenar el 50% del código de forma no continua
    final random = Random();

    // Para la versión iterativa: Seleccionar 5 índices aleatorios de 0 a 9 (10 líneas, 50% = 5)
    List<int> iterativeIndices = List.generate(10, (index) => index);
    iterativeIndices.shuffle(random);
    List<int> prefilledIterativeIndices = iterativeIndices.sublist(0, 5);

    for (int i = 0; i < prefilledIterativeIndices.length; i++) {
      int position = prefilledIterativeIndices[i];
      _userIterativeOrder[position] = _correctIterativeOrder[position];
    }

    List<int> remainingIterativeIndices = iterativeIndices.sublist(5);
    _availableIterativeLines = remainingIterativeIndices.map((index) => _correctIterativeOrder[index]).toList()
      ..shuffle(random);

    // Para la versión recursiva: Seleccionar 3 índices aleatorios de 0 a 5 (6 líneas, 50% = 3)
    List<int> recursiveIndices = List.generate(6, (index) => index);
    recursiveIndices.shuffle(random);
    List<int> prefilledRecursiveIndices = recursiveIndices.sublist(0, 3);

    for (int i = 0; i < prefilledRecursiveIndices.length; i++) {
      int position = prefilledRecursiveIndices[i];
      _userRecursiveOrder[position] = _correctRecursiveOrder[position];
    }

    List<int> remainingRecursiveIndices = recursiveIndices.sublist(3);
    _availableRecursiveLines = remainingRecursiveIndices.map((index) => _correctRecursiveOrder[index]).toList()
      ..shuffle(random);
  }

  // Función para manejar el desplazamiento automático mientras se arrastra
  void _handleDragScroll(PointerEvent event) {
    const double edgeThreshold = 50.0; // Distancia desde el borde para activar el scroll
    const double scrollSpeed = 10.0; // Velocidad del desplazamiento
    final screenHeight = MediaQuery.of(context).size.height;
    final pointerY = event.position.dy;

    if (pointerY < edgeThreshold) {
      if (_scrollTimer == null || !_scrollTimer!.isActive) {
        _scrollTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
          if (_scrollController.hasClients) {
            final newOffset = _scrollController.offset - scrollSpeed;
            _scrollController.jumpTo(newOffset.clamp(
              _scrollController.position.minScrollExtent,
              _scrollController.position.maxScrollExtent,
            ));
          }
        });
      }
    } else if (pointerY > screenHeight - edgeThreshold) {
      if (_scrollTimer == null || !_scrollTimer!.isActive) {
        _scrollTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
          if (_scrollController.hasClients) {
            final newOffset = _scrollController.offset + scrollSpeed;
            _scrollController.jumpTo(newOffset.clamp(
              _scrollController.position.minScrollExtent,
              _scrollController.position.maxScrollExtent,
            ));
          }
        });
      }
    } else {
      _scrollTimer?.cancel();
    }
  }

  // Detener el desplazamiento cuando termina el arrastre
  void _stopDragScroll() {
    _scrollTimer?.cancel();
  }

  void _verifyIterativeOrder() {
    bool isCorrect = _userIterativeOrder.toString() == _correctIterativeOrder.toString();

    setState(() {
      _iterativeCompleted = isCorrect;
      _iterativeStatusMessage = isCorrect ? '¡Correcto!' : 'Incorrecto';
      _iterativeLocked = true;
    });

    if (!_recursiveCompleted) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _selectedType = 'recursive';
            _iterativeStatusMessage = null;
          });
        }
      });
    }
  }

  void _verifyRecursiveOrder() {
    bool isCorrect = _userRecursiveOrder.toString() == _correctRecursiveOrder.toString();

    setState(() {
      _recursiveCompleted = isCorrect;
      _recursiveStatusMessage = isCorrect ? '¡Correcto!' : 'Incorrecto';
      _recursiveLocked = true;
    });

    if (!_iterativeCompleted) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _selectedType = 'iterative';
            _recursiveStatusMessage = null;
          });
        }
      });
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
        steps.add('${indent}  n =  Leland0, RETORNAR 0');
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
    _isCorrect = _iterativeCompleted && _recursiveCompleted;
    Navigator.pop(context, _isCorrect);
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003459), Color(0xFF00A8E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
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
                  Text(
                    'Ejercicio: Suma de Dígitos',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = 'iterative';
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _selectedType == 'iterative'
                                ? const Color(0xFF003459).withOpacity(0.8)
                                : const Color(0xFF003459).withOpacity(0.5),
                            _selectedType == 'iterative'
                                ? const Color(0xFF00A8E8).withOpacity(0.8)
                                : const Color(0xFF00A8E8).withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Versión Iterativa',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = 'recursive';
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _selectedType == 'recursive'
                                ? const Color(0xFF003459).withOpacity(0.8)
                                : const Color(0xFF003459).withOpacity(0.5),
                            _selectedType == 'recursive'
                                ? const Color(0xFF00A8E8).withOpacity(0.8)
                                : const Color(0xFF00A8E8).withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Versión Recursiva',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ordena las líneas de código para completar ambos algoritmos:',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedType == 'iterative') ...[
                    Text(
                      'Versión Iterativa:',
                      style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(_userIterativeOrder.length, (index) {
                        return DragTarget<String>(
                          onAccept: !_iterativeLocked
                              ? (data) {
                                  setState(() {
                                    if (_userIterativeOrder[index].isNotEmpty) {
                                      _availableIterativeLines.add(_userIterativeOrder[index]);
                                    }
                                    _userIterativeOrder[index] = data;
                                    _availableIterativeLines.remove(data);
                                  });
                                }
                              : null,
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Text(
                                _userIterativeOrder[index].isEmpty ? 'Arrastra una línea aquí' : _userIterativeOrder[index],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: _userIterativeOrder[index].isEmpty ? Colors.white30 : Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Líneas disponibles para la versión iterativa:',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: _availableIterativeLines.asMap().entries.map((entry) {
                        String line = entry.value;
                        return Draggable<String>(
                          data: line,
                          feedback: Material(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                line,
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                          childWhenDragging: Container(),
                          child: _iterativeLocked
                              ? Container()
                              : Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    line,
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                                  ),
                                ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (_iterativeStatusMessage != null)
                      Text(
                        _iterativeStatusMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _iterativeCompleted ? Colors.green : Colors.red,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _iterativeLocked ? null : _verifyIterativeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF003459),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: Text(
                          'Verificar',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Versión Recursiva:',
                      style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(_userRecursiveOrder.length, (index) {
                        return DragTarget<String>(
                          onAccept: !_recursiveLocked
                              ? (data) {
                                  setState(() {
                                    if (_userRecursiveOrder[index].isNotEmpty) {
                                      _availableRecursiveLines.add(_userRecursiveOrder[index]);
                                    }
                                    _userRecursiveOrder[index] = data;
                                    _availableRecursiveLines.remove(data);
                                  });
                                }
                              : null,
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Text(
                                _userRecursiveOrder[index].isEmpty ? 'Arrastra una línea aquí' : _userRecursiveOrder[index],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: _userRecursiveOrder[index].isEmpty ? Colors.white30 : Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Líneas disponibles para la versión recursiva:',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: _availableRecursiveLines.asMap().entries.map((entry) {
                        String line = entry.value;
                        return Draggable<String>(
                          data: line,
                          feedback: Material(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                line,
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                          childWhenDragging: Container(),
                          child: _recursiveLocked
                              ? Container()
                              : Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    line,
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                                  ),
                                ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (_recursiveStatusMessage != null)
                      Text(
                        _recursiveStatusMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _recursiveCompleted ? Colors.green : Colors.red,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _recursiveLocked ? null : _verifyRecursiveOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF003459),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: Text(
                          'Verificar',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_iterativeCompleted && _recursiveCompleted) ...[
                    Text(
                      'Simulación con el número 123:',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                              color: Colors.white70,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _runSimulation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF003459),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: Text(
                          'Ejecutar Simulación',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Center(
                    child: ElevatedButton(
                      onPressed: _completeActivity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF003459),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text(
                        'Completar Actividad',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}