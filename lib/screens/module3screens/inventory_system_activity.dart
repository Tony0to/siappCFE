import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math'; // Para usar Random
import 'dart:async'; // Para usar Timer

class InventorySystemActivityScreen extends StatefulWidget {
  const InventorySystemActivityScreen({Key? key}) : super(key: key);

  @override
  _InventorySystemActivityScreenState createState() => _InventorySystemActivityScreenState();
}

class _InventorySystemActivityScreenState extends State<InventorySystemActivityScreen> {
  String? _inventoryStatusMessage;
  bool _isCorrect = false;
  bool _inventoryCompleted = false;
  bool _inventoryLocked = false;

  // ScrollController para controlar el desplazamiento
  final ScrollController _scrollController = ScrollController();

  // Timer para el desplazamiento automático
  Timer? _scrollTimer;

  // Líneas de código desordenadas para sistema de inventario
  List<String> _inventoryCodeLines = [
    'INICIO',
    'inventario ← diccionario vacío',
    'FUNCIÓN agregarProducto(nombre, precio)',
    'inventario[nombre] ← precio',
    'FUNCIÓN mostrarProductos()',
    'PARA cada producto en inventario HACER',
    'IMPRIMIR producto, ":", inventario[producto]',
    'FIN PARA',
    'FUNCIÓN calcularTotal()',
    'total ← 0',
    'PARA cada precio en inventario HACER',
    'total ← total + inventario[producto]',
    'FIN PARA',
    'IMPRIMIR "Valor total del inventario:", total',
    'agregarProducto("Manzana", 12)',
    'agregarProducto("Pan", 20)',
    'mostrarProductos()',
    'calcularTotal()',
    'FIN',
  ];

  // Líneas ordenadas correctamente para sistema de inventario
  final List<String> _correctInventoryOrder = [
    'INICIO',
    'inventario ← diccionario vacío',
    'FUNCIÓN agregarProducto(nombre, precio)',
    'inventario[nombre] ← precio',
    'FUNCIÓN mostrarProductos()',
    'PARA cada producto en inventario HACER',
    'IMPRIMIR producto, ":", inventario[producto]',
    'FIN PARA',
    'FUNCIÓN calcularTotal()',
    'total ← 0',
    'PARA cada precio en inventario HACER',
    'total ← total + inventario[producto]',
    'FIN PARA',
    'IMPRIMIR "Valor total del inventario:", total',
    'agregarProducto("Manzana", 12)',
    'agregarProducto("Pan", 20)',
    'mostrarProductos()',
    'calcularTotal()',
    'FIN',
  ];

  // Líneas que el usuario ordenará (75% prellenado de forma no continua)
  List<String> _userInventoryOrder = List.filled(19, '');

  // Lista para rastrear líneas disponibles
  List<String> _availableInventoryLines = [];

  @override
  void initState() {
    super.initState();

    // Prellenar el 75% del código de forma no continua
    final random = Random();

    // Seleccionar 14 índices aleatorios de 0 a 18 (19 líneas, 75% ≈ 14 prellenadas)
    List<int> inventoryIndices = List.generate(19, (index) => index);
    inventoryIndices.shuffle(random);
    List<int> prefilledInventoryIndices = inventoryIndices.sublist(0, 14);

    for (int i = 0; i < prefilledInventoryIndices.length; i++) {
      int position = prefilledInventoryIndices[i];
      _userInventoryOrder[position] = _correctInventoryOrder[position];
    }

    List<int> remainingInventoryIndices = inventoryIndices.sublist(14);
    _availableInventoryLines = remainingInventoryIndices.map((index) => _correctInventoryOrder[index]).toList()
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

  void _verifyInventoryOrder() {
    bool isCorrect = _userInventoryOrder.toString() == _correctInventoryOrder.toString();

    setState(() {
      _inventoryCompleted = isCorrect;
      _inventoryStatusMessage = isCorrect ? '¡Correcto!' : 'Incorrecto';
      _inventoryLocked = true;
    });
  }

  void _completeActivity() {
    _isCorrect = _inventoryCompleted;
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
                    'Ejercicio: Sistema de Inventario',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ordena las líneas de código para completar el sistema de inventario:',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sistema de Inventario:',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(_userInventoryOrder.length, (index) {
                      return DragTarget<String>(
                        onAccept: !_inventoryLocked
                            ? (data) {
                                setState(() {
                                  if (_userInventoryOrder[index].isNotEmpty) {
                                    _availableInventoryLines.add(_userInventoryOrder[index]);
                                  }
                                  _userInventoryOrder[index] = data;
                                  _availableInventoryLines.remove(data);
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
                              _userInventoryOrder[index].isEmpty ? 'Arrastra una línea aquí' : _userInventoryOrder[index],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _userInventoryOrder[index].isEmpty ? Colors.white30 : Colors.white70,
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
                    children: _availableInventoryLines.asMap().entries.map((entry) {
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
                        child: _inventoryLocked
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
                  if (_inventoryStatusMessage != null)
                    Text(
                      _inventoryStatusMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: _inventoryCompleted ? Colors.green : Colors.red,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _inventoryLocked ? null : _verifyInventoryOrder,
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