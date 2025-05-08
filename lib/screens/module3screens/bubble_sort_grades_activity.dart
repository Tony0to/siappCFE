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

  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

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

  late List<String> _initialUserBubbleSortOrder;
  List<String> _userBubbleSortOrder = List.filled(12, '');
  List<String> _availableBubbleSortLines = [];

  @override
  void initState() {
    super.initState();
    _initializeActivity();
  }

  void _initializeActivity() {
    final random = Random();
    List<int> indices = List.generate(12, (index) => index)..shuffle(random);
    List<int> prefilledIndices = indices.sublist(0, 9); // 75% prellenado

    _userBubbleSortOrder = List.filled(12, '');
    for (int index in prefilledIndices) {
      _userBubbleSortOrder[index] = _correctBubbleSortOrder[index];
    }

    _availableBubbleSortLines = indices.sublist(9).map((index) => _correctBubbleSortOrder[index]).toList();
    _initialUserBubbleSortOrder = List.from(_userBubbleSortOrder);

    setState(() {});
  }

  int _getIndentationLevel(String line) {
    if (line.contains('PARA j desde 0 hasta n-i-2 HACER') ||
        line.contains('SI calificaciones[j] > calificaciones[j+1] ENTONCES') ||
        line.contains('intercambiar calificaciones[j] y calificaciones[j+1]') ||
        line.contains('FIN SI')) {
      return 2;
    } else if (line.contains('PARA i desde 0 hasta n-1 HACER') ||
               line.contains('FIN PARA') && !line.contains('n-i-2')) {
      return 1;
    }
    return 0;
  }

  void _resetActivity() {
    setState(() {
      _userBubbleSortOrder = List.filled(12, '');
      // Iterar sobre los índices donde _initialUserBubbleSortOrder tiene valores no vacíos
      for (int index = 0; index < _initialUserBubbleSortOrder.length; index++) {
        if (_initialUserBubbleSortOrder[index].isNotEmpty) {
          _userBubbleSortOrder[index] = _initialUserBubbleSortOrder[index];
        }
      }
      _availableBubbleSortLines = _correctBubbleSortOrder.where((line) => !_initialUserBubbleSortOrder.contains(line)).toList();
      _bubbleSortStatusMessage = null;
      _bubbleSortCompleted = false;
      _bubbleSortLocked = false;
    });
  }

  void _handleDragScroll(PointerEvent event) {
    const double edgeThreshold = 50.0;
    const double scrollSpeed = 10.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final pointerY = event.position.dy;

    if (pointerY < edgeThreshold) {
      _scrollTimer ??= Timer.periodic(Duration(milliseconds: 16), (timer) {
        if (_scrollController.hasClients) {
          final newOffset = _scrollController.offset - scrollSpeed;
          _scrollController.jumpTo(newOffset.clamp(_scrollController.position.minScrollExtent, _scrollController.position.maxScrollExtent));
        }
      });
    } else if (pointerY > screenHeight - edgeThreshold) {
      _scrollTimer ??= Timer.periodic(Duration(milliseconds: 16), (timer) {
        if (_scrollController.hasClients) {
          final newOffset = _scrollController.offset + scrollSpeed;
          _scrollController.jumpTo(newOffset.clamp(_scrollController.position.minScrollExtent, _scrollController.position.maxScrollExtent));
        }
      });
    } else {
      _scrollTimer?.cancel();
    }
  }

  void _stopDragScroll() {
    _scrollTimer?.cancel();
  }

  void _verifyBubbleSortOrder() {
    bool isCorrect = _userBubbleSortOrder.join() == _correctBubbleSortOrder.join();
    setState(() {
      _bubbleSortCompleted = isCorrect;
      _bubbleSortStatusMessage = isCorrect ? '¡Correcto!' : 'Incorrecto';
      _bubbleSortLocked = true; // Bloquea ambos botones al verificar
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
                  Text('Ejercicio: Ordenamiento Burbuja', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 24),
                  Text('Ordena las líneas de código para completar el algoritmo de ordenamiento burbuja:', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 16),
                  Text('Algoritmo de Ordenamiento Burbuja:', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    color: Colors.black,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(_userBubbleSortOrder.length, (index) {
                        final indentationLevel = _userBubbleSortOrder[index].isEmpty ? 0 : _getIndentationLevel(_userBubbleSortOrder[index]);
                        final isFixed = _initialUserBubbleSortOrder[index].isNotEmpty;
                        return Padding(
                          padding: EdgeInsets.only(left: 16.0 * indentationLevel),
                          child: SizedBox(
                            width: double.infinity,
                            child: DragTarget<String>(
                              hitTestBehavior: HitTestBehavior.translucent,
                              onWillAccept: (data) => !_bubbleSortLocked,
                              onAccept: (data) {
                                setState(() {
                                  _userBubbleSortOrder[index] = data;
                                  _availableBubbleSortLines.remove(data);
                                });
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _userBubbleSortOrder[index].isEmpty ? Colors.white.withOpacity(0.2) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: _userBubbleSortOrder[index].isNotEmpty && !isFixed ? Border.all(color: Colors.white, width: 1) : null,
                                  ),
                                  child: _userBubbleSortOrder[index].isEmpty
                                      ? Text(
                                          'Arrastra una línea aquí',
                                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white30),
                                          textAlign: TextAlign.left,
                                        )
                                      : Text(
                                          _userBubbleSortOrder[index],
                                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
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
                  const SizedBox(height: 16),
                  Text('Líneas disponibles:', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Column(
                    children: _availableBubbleSortLines.map((line) {
                      return Draggable<String>(
                        data: line,
                        feedback: Material(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                            child: Text(line, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
                          ),
                        ),
                        childWhenDragging: Container(),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                          child: Text(line, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (_bubbleSortStatusMessage != null)
                    Text(_bubbleSortStatusMessage!, style: GoogleFonts.poppins(fontSize: 16, color: _bubbleSortCompleted ? Colors.green : Colors.red)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _bubbleSortLocked ? null : _verifyBubbleSortOrder,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF003459), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                        child: Text('Verificar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _bubbleSortLocked ? null : _resetActivity,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF003459), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                        child: Text('Reiniciar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _completeActivity,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF003459), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                      child: Text('Completar Actividad', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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