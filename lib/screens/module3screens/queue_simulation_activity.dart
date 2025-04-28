import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math'; // Para usar Random
import 'dart:async'; // Para usar Timer

class QueueSimulationActivityScreen extends StatefulWidget {
  const QueueSimulationActivityScreen({Key? key}) : super(key: key);

  @override
  _QueueSimulationActivityScreenState createState() => _QueueSimulationActivityScreenState();
}

class _QueueSimulationActivityScreenState extends State<QueueSimulationActivityScreen> {
  String? _queueStatusMessage;
  bool _isCorrect = false;
  bool _queueCompleted = false;
  bool _queueLocked = false;

  // ScrollController para controlar el desplazamiento
  final ScrollController _scrollController = ScrollController();

  // Timer para el desplazamiento automático
  Timer? _scrollTimer;

  // Líneas de código desordenadas para simulación de cola
  List<String> _queueCodeLines = [
    'INICIO',
    'cola ← lista vacía',
    'FUNCIÓN agregar(persona)',
    'agregar persona al final de cola',
    'FUNCIÓN atender()',
    'SI cola no está vacía ENTONCES',
    'eliminar primer elemento de cola',
    'SINO',
    'IMPRIMIR "La cola está vacía"',
    'FIN SI',
    'FUNCIÓN mostrar()',
    'IMPRIMIR "Estado de la cola:", cola',
    'agregar("Ana")',
    'agregar("Luis")',
    'mostrar()',
    'atender()',
    'mostrar()',
    'FIN',
  ];

  // Líneas ordenadas correctamente para simulación de cola
  final List<String> _correctQueueOrder = [
    'INICIO',
    'cola ← lista vacía',
    'FUNCIÓN agregar(persona)',
    'agregar persona al final de cola',
    'FUNCIÓN atender()',
    'SI cola no está vacía ENTONCES',
    'eliminar primer elemento de cola',
    'SINO',
    'IMPRIMIR "La cola está vacía"',
    'FIN SI',
    'FUNCIÓN mostrar()',
    'IMPRIMIR "Estado de la cola:", cola',
    'agregar("Ana")',
    'agregar("Luis")',
    'mostrar()',
    'atender()',
    'mostrar()',
    'FIN',
  ];

  // Líneas que el usuario ordenará (75% prellenado de forma no continua)
  List<String> _userQueueOrder = List.filled(18, '');

  // Lista para rastrear líneas disponibles
  List<String> _availableQueueLines = [];

  @override
  void initState() {
    super.initState();

    // Prellenar el 75% del código de forma no continua
    final random = Random();

    // Seleccionar 14 índices aleatorios de 0 a 17 (18 líneas, 75% ≈ 14 prellenadas)
    List<int> queueIndices = List.generate(18, (index) => index);
    queueIndices.shuffle(random);
    List<int> prefilledQueueIndices = queueIndices.sublist(0, 14);

    for (int i = 0; i < prefilledQueueIndices.length; i++) {
      int position = prefilledQueueIndices[i];
      _userQueueOrder[position] = _correctQueueOrder[position];
    }

    List<int> remainingQueueIndices = queueIndices.sublist(14);
    _availableQueueLines = remainingQueueIndices.map((index) => _correctQueueOrder[index]).toList()
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

  void _verifyQueueOrder() {
    bool isCorrect = _userQueueOrder.toString() == _correctQueueOrder.toString();

    setState(() {
      _queueCompleted = isCorrect;
      _queueStatusMessage = isCorrect ? '¡Correcto!' : 'Incorrecto';
      _queueLocked = true;
    });
  }

  void _completeActivity() {
    _isCorrect = _queueCompleted;
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
                    'Ejercicio: Simulación de Cola (FIFO)',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ordena las líneas de código para completar la simulación de una cola:',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Simulación de Cola:',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(_userQueueOrder.length, (index) {
                      return DragTarget<String>(
                        onAccept: !_queueLocked
                            ? (data) {
                                setState(() {
                                  if (_userQueueOrder[index].isNotEmpty) {
                                    _availableQueueLines.add(_userQueueOrder[index]);
                                  }
                                  _userQueueOrder[index] = data;
                                  _availableQueueLines.remove(data);
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
                              _userQueueOrder[index].isEmpty ? 'Arrastra una línea aquí' : _userQueueOrder[index],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _userQueueOrder[index].isEmpty ? Colors.white30 : Colors.white70,
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
                    children: _availableQueueLines.asMap().entries.map((entry) {
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
                        child: _queueLocked
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
                  if (_queueStatusMessage != null)
                    Text(
                      _queueStatusMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: _queueCompleted ? Colors.green : Colors.red,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _queueLocked ? null : _verifyQueueOrder,
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