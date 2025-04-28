import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math'; // Para usar Random
import 'dart:async'; // Para usar Timer

class SearchAlgorithmsActivityScreen extends StatefulWidget {
  const SearchAlgorithmsActivityScreen({Key? key}) : super(key: key);

  @override
  _SearchAlgorithmsActivityScreenState createState() => _SearchAlgorithmsActivityScreenState();
}

class _SearchAlgorithmsActivityScreenState extends State<SearchAlgorithmsActivityScreen> {
  String _selectedSearchType = 'lineal'; // 'lineal' o 'binaria'
  String? _linearStatusMessage;
  String? _binaryStatusMessage;
  bool _isCorrect = false;
  bool _linearCompleted = false;
  bool _binaryCompleted = false;
  bool _linearLocked = false;
  bool _binaryLocked = false;

  // ScrollController para controlar el desplazamiento
  final ScrollController _scrollController = ScrollController();

  // Timer para el desplazamiento automático
  Timer? _scrollTimer;

  // Lista predefinida ordenada (solo para mostrar)
  final List<int> _sortedList = [10, 15, 18, 20, 23, 27, 30, 35, 40, 45];

  // Líneas de código desordenadas para búsqueda lineal
  List<String> _linearCodeLines = [
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

  // Líneas de código desordenadas para búsqueda binaria
  List<String> _binaryCodeLines = [
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

  // Líneas ordenadas correctamente para búsqueda lineal
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

  // Líneas ordenadas correctamente para búsqueda binaria
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

  // Líneas que el usuario ordenará (75% prellenado de forma no continua)
  List<String> _userLinearOrder = List.filled(14, '');
  List<String> _userBinaryOrder = List.filled(20, '');

  // Listas para rastrear líneas disponibles
  List<String> _availableLinearLines = [];
  List<String> _availableBinaryLines = [];

  @override
  void initState() {
    super.initState();

    // Prellenar el 75% del código de forma no continua
    final random = Random();

    // Para búsqueda lineal: Seleccionar 10 índices aleatorios de 0 a 13
    List<int> linearIndices = List.generate(14, (index) => index);
    linearIndices.shuffle(random);
    List<int> prefilledLinearIndices = linearIndices.sublist(0, 10);

    for (int i = 0; i < prefilledLinearIndices.length; i++) {
      int position = prefilledLinearIndices[i];
      _userLinearOrder[position] = _correctLinearOrder[position];
    }

    List<int> remainingLinearIndices = linearIndices.sublist(10);
    _availableLinearLines = remainingLinearIndices.map((index) => _correctLinearOrder[index]).toList()
      ..shuffle(random);

    // Para búsqueda binaria: Seleccionar 15 índices aleatorios de 0 a 19
    List<int> binaryIndices = List.generate(20, (index) => index);
    binaryIndices.shuffle(random);
    List<int> prefilledBinaryIndices = binaryIndices.sublist(0, 15);

    for (int i = 0; i < prefilledBinaryIndices.length; i++) {
      int position = prefilledBinaryIndices[i];
      _userBinaryOrder[position] = _correctBinaryOrder[position];
    }

    List<int> remainingBinaryIndices = binaryIndices.sublist(15);
    _availableBinaryLines = remainingBinaryIndices.map((index) => _correctBinaryOrder[index]).toList()
      ..shuffle(random);
  }

  // Función para manejar el desplazamiento automático mientras se arrastra
  void _handleDragScroll(PointerEvent event) {
    const double edgeThreshold = 50.0; // Distancia desde el borde para activar el scroll
    const double scrollSpeed = 10.0; // Velocidad del desplazamiento
    final screenHeight = MediaQuery.of(context).size.height;
    final pointerY = event.position.dy;

    // Si está cerca del borde superior
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
    }
    // Si está cerca del borde inferior
    else if (pointerY > screenHeight - edgeThreshold) {
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
    }
    // Si no está cerca de los bordes, detener el desplazamiento
    else {
      _scrollTimer?.cancel();
    }
  }

  // Detener el desplazamiento cuando termina el arrastre
  void _stopDragScroll() {
    _scrollTimer?.cancel();
  }

  void _verifyLinearOrder() {
    bool isCorrect = _userLinearOrder.toString() == _correctLinearOrder.toString();

    setState(() {
      _linearCompleted = isCorrect;
      _linearStatusMessage = isCorrect ? '¡Correcto!' : 'Incorrecto';
      _linearLocked = true;
    });

    if (!_binaryCompleted) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _selectedSearchType = 'binaria';
            _linearStatusMessage = null;
          });
        }
      });
    }
  }

  void _verifyBinaryOrder() {
    bool isCorrect = _userBinaryOrder.toString() == _correctBinaryOrder.toString();

    setState(() {
      _binaryCompleted = isCorrect;
      _binaryStatusMessage = isCorrect ? '¡Correcto!' : 'Incorrecto';
      _binaryLocked = true;
    });

    if (!_linearCompleted) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _selectedSearchType = 'lineal';
            _binaryStatusMessage = null;
          });
        }
      });
    }
  }

  void _completeActivity() {
    _isCorrect = _linearCompleted && _binaryCompleted;
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
                    'Ejercicio 1: Búsqueda Lineal y Binaria',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lista ordenada: ${_sortedList.join(', ')}',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  // Botones rediseñados
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSearchType = 'lineal';
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _selectedSearchType == 'lineal'
                                ? const Color(0xFF003459).withOpacity(0.8)
                                : const Color(0xFF003459).withOpacity(0.5),
                            _selectedSearchType == 'lineal'
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
                          'Búsqueda Lineal',
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
                        _selectedSearchType = 'binaria';
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _selectedSearchType == 'binaria'
                                ? const Color(0xFF003459).withOpacity(0.8)
                                : const Color(0xFF003459).withOpacity(0.5),
                            _selectedSearchType == 'binaria'
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
                          'Búsqueda Binaria',
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
                  if (_selectedSearchType == 'lineal') ...[
                    Text(
                      'Búsqueda Lineal:',
                      style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(_userLinearOrder.length, (index) {
                        return DragTarget<String>(
                          onAccept: !_linearLocked
                              ? (data) {
                                  setState(() {
                                    if (_userLinearOrder[index].isNotEmpty) {
                                      _availableLinearLines.add(_userLinearOrder[index]);
                                    }
                                    _userLinearOrder[index] = data;
                                    _availableLinearLines.remove(data);
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
                                _userLinearOrder[index].isEmpty ? 'Arrastra una línea aquí' : _userLinearOrder[index],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: _userLinearOrder[index].isEmpty ? Colors.white30 : Colors.white70,
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
                      'Líneas disponibles para búsqueda lineal:',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: _availableLinearLines.asMap().entries.map((entry) {
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
                          child: _linearLocked
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
                    if (_linearStatusMessage != null)
                      Text(
                        _linearStatusMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _linearCompleted ? Colors.green : Colors.red,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _linearLocked ? null : _verifyLinearOrder,
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
                      'Búsqueda Binaria:',
                      style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(_userBinaryOrder.length, (index) {
                        return DragTarget<String>(
                          onAccept: !_binaryLocked
                              ? (data) {
                                  setState(() {
                                    if (_userBinaryOrder[index].isNotEmpty) {
                                      _availableBinaryLines.add(_userBinaryOrder[index]);
                                    }
                                    _userBinaryOrder[index] = data;
                                    _availableBinaryLines.remove(data);
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
                                _userBinaryOrder[index].isEmpty ? 'Arrastra una línea aquí' : _userBinaryOrder[index],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: _userBinaryOrder[index].isEmpty ? Colors.white30 : Colors.white70,
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
                      'Líneas disponibles para búsqueda binaria:',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: _availableBinaryLines.asMap().entries.map((entry) {
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
                          child: _binaryLocked
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
                    if (_binaryStatusMessage != null)
                      Text(
                        _binaryStatusMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _binaryCompleted ? Colors.green : Colors.red,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _binaryLocked ? null : _verifyBinaryOrder,
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