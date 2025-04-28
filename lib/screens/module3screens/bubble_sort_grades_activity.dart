import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math'; // Para usar Random
import 'dart:async'; // Para usar Timer

class BubbleSortGradesActivityScreen extends StatefulWidget {
  const BubbleSortGradesActivityScreen({Key? key}) : super(key: key);

  @override
  _BubbleSortGradesActivityScreenState createState() => _BubbleSortGradesActivityScreenState();
}

class _BubbleSortGradesActivityScreenState extends State<BubbleSortGradesActivityScreen> {
  String? _bubbleSortStatusMessage;
  bool _isCorrect = false;
  bool _bubbleSortCompleted = false;
  bool _bubbleSortLocked = false;

  // ScrollController para controlar el desplazamiento
  final ScrollController _scrollController = ScrollController();

  // Timer para el desplazamiento automático
  Timer? _scrollTimer;

  // Líneas de código desordenadas para ordenamiento burbuja
  List<String> _bubbleSortCodeLines = [
    'INICIO',
    'calificaciones ← [85, 70, 95, 60, 90]',
    'n ← longitud(calificaciones)',
    'PARA i desde 0 hasta n-1 HACER',
    'PARA j desde 0 hasta n-i-2 HACER',
    'SI calificaciones[j] > calificaciones[j+1] ENTONCES',
    'intercambiar calificaciones[j] y calificaciones[j+1]',
    'FIN SI',
    'FIN PARA',
    'FIN PARA',
    'IMPRIMIR "Calificaciones ordenadas:", calificaciones',
    'FIN',
  ];

  // Líneas ordenadas correctamente para ordenamiento burbuja
  final List<String> _correctBubbleSortOrder = [
    'INICIO',
    'calificaciones ← [85, 70, 95, 60, 90]',
    'n ← longitud(calificaciones)',
    'PARA i desde 0 hasta n-1 HACER',
    'PARA j desde 0 hasta n-i-2 HACER',
    'SI calificaciones[j] > calificaciones[j+1] ENTONCES',
    'intercambiar calificaciones[j] y calificaciones[j+1]',
    'FIN SI',
    'FIN PARA',
    'FIN PARA',
    'IMPRIMIR "Calificaciones ordenadas:", calificaciones',
    'FIN',
  ];

  // Líneas que el usuario ordenará (75% prellenado de forma no continua)
  List<String> _userBubbleSortOrder = List.filled(12, '');

  // Lista para rastrear líneas disponibles
  List<String> _availableBubbleSortLines = [];

  @override
  void initState() {
    super.initState();

    // Prellenar el 75% del código de forma no continua
    final random = Random();

    // Seleccionar 9 índices aleatorios de 0 a 11 (12 líneas, 75% = 9 prellenadas)
    List<int> bubbleSortIndices = List.generate(12, (index) => index);
    bubbleSortIndices.shuffle(random);
    List<int> prefilledBubbleSortIndices = bubbleSortIndices.sublist(0, 9);

    for (int i = 0; i < prefilledBubbleSortIndices.length; i++) {
      int position = prefilledBubbleSortIndices[i];
      _userBubbleSortOrder[position] = _correctBubbleSortOrder[position];
    }

    List<int> remainingBubbleSortIndices = bubbleSortIndices.sublist(9);
    _availableBubbleSortLines = remainingBubbleSortIndices.map((index) => _correctBubbleSortOrder[index]).toList()
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

  void _verifyBubbleSortOrder() {
    bool isCorrect = _userBubbleSortOrder.toString() == _correctBubbleSortOrder.toString();

    setState(() {
      _bubbleSortCompleted = isCorrect;
      _bubbleSortStatusMessage = isCorrect ? '¡Correcto!' : 'Incorrecto';
      _bubbleSortLocked = true;
    });
  }

  void _completeActivity() {
    _isCorrect = _bubbleSortCompleted;
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
                    'Ejercicio: Ordenamiento Burbuja',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ordena las líneas de código para completar el algoritmo de ordenamiento burbuja:',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Algoritmo de Ordenamiento Burbuja:',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(_userBubbleSortOrder.length, (index) {
                      return DragTarget<String>(
                        onAccept: !_bubbleSortLocked
                            ? (data) {
                                setState(() {
                                  if (_userBubbleSortOrder[index].isNotEmpty) {
                                    _availableBubbleSortLines.add(_userBubbleSortOrder[index]);
                                  }
                                  _userBubbleSortOrder[index] = data;
                                  _availableBubbleSortLines.remove(data);
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
                              _userBubbleSortOrder[index].isEmpty ? 'Arrastra una línea aquí' : _userBubbleSortOrder[index],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _userBubbleSortOrder[index].isEmpty ? Colors.white30 : Colors.white70,
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
                    'Líneas disponibles:',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _availableBubbleSortLines.asMap().entries.map((entry) {
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
                        child: _bubbleSortLocked
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
                  if (_bubbleSortStatusMessage != null)
                    Text(
                      _bubbleSortStatusMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: _bubbleSortCompleted ? Colors.green : Colors.red,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _bubbleSortLocked ? null : _verifyBubbleSortOrder,
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