import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math'; // Para usar Random
import 'dart:async'; // Para usar Timer

class CountVowelsRecursiveActivityScreen extends StatefulWidget {
  const CountVowelsRecursiveActivityScreen({Key? key}) : super(key: key);

  @override
  _CountVowelsRecursiveActivityScreenState createState() => _CountVowelsRecursiveActivityScreenState();
}

class _CountVowelsRecursiveActivityScreenState extends State<CountVowelsRecursiveActivityScreen> {
  String? _vowelStatusMessage;
  bool _isCorrect = false;
  bool _vowelCompleted = false;
  bool _vowelLocked = false;

  // ScrollController para controlar el desplazamiento
  final ScrollController _scrollController = ScrollController();

  // Timer para el desplazamiento automático
  Timer? _scrollTimer;

  // Líneas de código desordenadas para contar vocales recursivamente
  List<String> _vowelCodeLines = [
    'FUNCIÓN contarVocales(cadena)',
    'SI cadena está vacía ENTONCES',
    'RETORNAR 0',
    'FIN SI',
    'caracter ← primer carácter de cadena',
    'resto ← cadena sin el primer carácter',
    'caracter ← convertir a minúscula(caracter)',
    "SI caracter es 'a' o 'e' o 'i' o 'o' o 'u' ENTONCES",
    'RETORNAR 1 + contarVocales(resto)',
    'SINO',
    'RETORNAR contarVocales(resto)',
    'FIN FUNCIÓN',
  ];

  // Líneas ordenadas correctamente para contar vocales recursivamente
  final List<String> _correctVowelOrder = [
    'FUNCIÓN contarVocales(cadena)',
    'SI cadena está vacía ENTONCES',
    'RETORNAR 0',
    'FIN SI',
    'caracter ← primer carácter de cadena',
    'resto ← cadena sin el primer carácter',
    'caracter ← convertir a minúscula(caracter)',
    "SI caracter es 'a' o 'e' o 'i' o 'o' o 'u' ENTONCES",
    'RETORNAR 1 + contarVocales(resto)',
    'SINO',
    'RETORNAR contarVocales(resto)',
    'FIN FUNCIÓN',
  ];

  // Líneas que el usuario ordenará (75% prellenado de forma no continua)
  List<String> _userVowelOrder = List.filled(12, '');

  // Lista para rastrear líneas disponibles
  List<String> _availableVowelLines = [];

  @override
  void initState() {
    super.initState();

    // Prellenar el 75% del código de forma no continua
    final random = Random();

    // Seleccionar 9 índices aleatorios de 0 a 11 (12 líneas, 75% = 9 prellenadas)
    List<int> vowelIndices = List.generate(12, (index) => index);
    vowelIndices.shuffle(random);
    List<int> prefilledVowelIndices = vowelIndices.sublist(0, 9);

    for (int i = 0; i < prefilledVowelIndices.length; i++) {
      int position = prefilledVowelIndices[i];
      _userVowelOrder[position] = _correctVowelOrder[position];
    }

    List<int> remainingVowelIndices = vowelIndices.sublist(9);
    _availableVowelLines = remainingVowelIndices.map((index) => _correctVowelOrder[index]).toList()
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

  void _verifyVowelOrder() {
    bool isCorrect = _userVowelOrder.toString() == _correctVowelOrder.toString();

    setState(() {
      _vowelCompleted = isCorrect;
      _vowelStatusMessage = isCorrect ? '¡Correcto!' : 'Incorrecto';
      _vowelLocked = true;
    });
  }

  void _completeActivity() {
    _isCorrect = _vowelCompleted;
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
                    'Ejercicio: Contar Vocales Recursivamente',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ordena las líneas de código para completar el algoritmo recursivo que cuenta vocales:',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Función contarVocales:',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(_userVowelOrder.length, (index) {
                      return DragTarget<String>(
                        onAccept: !_vowelLocked
                            ? (data) {
                                setState(() {
                                  if (_userVowelOrder[index].isNotEmpty) {
                                    _availableVowelLines.add(_userVowelOrder[index]);
                                  }
                                  _userVowelOrder[index] = data;
                                  _availableVowelLines.remove(data);
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
                              _userVowelOrder[index].isEmpty ? 'Arrastra una línea aquí' : _userVowelOrder[index],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _userVowelOrder[index].isEmpty ? Colors.white30 : Colors.white70,
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
                    children: _availableVowelLines.asMap().entries.map((entry) {
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
                        child: _vowelLocked
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
                  if (_vowelStatusMessage != null)
                    Text(
                      _vowelStatusMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: _vowelCompleted ? Colors.green : Colors.red,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _vowelLocked ? null : _verifyVowelOrder,
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