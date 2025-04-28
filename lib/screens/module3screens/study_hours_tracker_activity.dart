import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math'; // Para usar Random
import 'dart:async'; // Para usar Timer

class StudyHoursTrackerActivityScreen extends StatefulWidget {
  const StudyHoursTrackerActivityScreen({Key? key}) : super(key: key);

  @override
  _StudyHoursTrackerActivityScreenState createState() => _StudyHoursTrackerActivityScreenState();
}

class _StudyHoursTrackerActivityScreenState extends State<StudyHoursTrackerActivityScreen> {
  String? _studyHoursStatusMessage;
  bool _isCorrect = false;
  bool _studyHoursCompleted = false;
  bool _studyHoursLocked = false;

  // ScrollController para controlar el desplazamiento
  final ScrollController _scrollController = ScrollController();

  // Timer para el desplazamiento automático
  Timer? _scrollTimer;

  // Líneas de código desordenadas para registro de horas de estudio
  List<String> _studyHoursCodeLines = [
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

  // Líneas ordenadas correctamente para registro de horas de estudio
  final List<String> _correctStudyHoursOrder = [
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

  // Líneas que el usuario ordenará (75% prellenado de forma no continua)
  List<String> _userStudyHoursOrder = List.filled(18, '');

  // Lista para rastrear líneas disponibles
  List<String> _availableStudyHoursLines = [];

  @override
  void initState() {
    super.initState();

    // Prellenar el 75% del código de forma no continua
    final random = Random();

    // Seleccionar 14 índices aleatorios de 0 a 17 (18 líneas, 75% ≈ 14 prellenadas)
    List<int> studyHoursIndices = List.generate(18, (index) => index);
    studyHoursIndices.shuffle(random);
    List<int> prefilledStudyHoursIndices = studyHoursIndices.sublist(0, 14);

    for (int i = 0; i < prefilledStudyHoursIndices.length; i++) {
      int position = prefilledStudyHoursIndices[i];
      _userStudyHoursOrder[position] = _correctStudyHoursOrder[position];
    }

    List<int> remainingStudyHoursIndices = studyHoursIndices.sublist(14);
    _availableStudyHoursLines = remainingStudyHoursIndices.map((index) => _correctStudyHoursOrder[index]).toList()
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

  void _verifyStudyHoursOrder() {
    bool isCorrect = _userStudyHoursOrder.toString() == _correctStudyHoursOrder.toString();

    setState(() {
      _studyHoursCompleted = isCorrect;
      _studyHoursStatusMessage = isCorrect ? '¡Correcto!' : 'Incorrecto';
      _studyHoursLocked = true;
    });
  }

  void _completeActivity() {
    _isCorrect = _studyHoursCompleted;
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
                    'Ejercicio: Registro de Horas de Estudio',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ordena las líneas de código para completar el registro de horas de estudio:',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Registro de Horas:',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(_userStudyHoursOrder.length, (index) {
                      return DragTarget<String>(
                        onAccept: !_studyHoursLocked
                            ? (data) {
                                setState(() {
                                  if (_userStudyHoursOrder[index].isNotEmpty) {
                                    _availableStudyHoursLines.add(_userStudyHoursOrder[index]);
                                  }
                                  _userStudyHoursOrder[index] = data;
                                  _availableStudyHoursLines.remove(data);
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
                              _userStudyHoursOrder[index].isEmpty ? 'Arrastra una línea aquí' : _userStudyHoursOrder[index],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _userStudyHoursOrder[index].isEmpty ? Colors.white30 : Colors.white70,
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
                    children: _availableStudyHoursLines.asMap().entries.map((entry) {
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
                        child: _studyHoursLocked
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
                  if (_studyHoursStatusMessage != null)
                    Text(
                      _studyHoursStatusMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: _studyHoursCompleted ? Colors.green : Colors.red,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _studyHoursLocked ? null : _verifyStudyHoursOrder,
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