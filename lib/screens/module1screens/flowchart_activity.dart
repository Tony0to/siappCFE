import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // Para Random y shuffle

class FlowchartActivityScreen extends StatefulWidget {
  final Map<String, dynamic>? moduleData;

  const FlowchartActivityScreen({Key? key, this.moduleData}) : super(key: key);

  @override
  _FlowchartActivityScreenState createState() => _FlowchartActivityScreenState();
}

class _FlowchartActivityScreenState extends State<FlowchartActivityScreen> with TickerProviderStateMixin {
  // Lista de pasos que se pueden arrastrar
  List<String> _steps = [
    'ingresar x',
    'ingresar y',
    'z=x+y',
    'z>10',
    'El resultado es mayor',
    'el resultado es menor',
  ];

  // Mapa para rastrear las posiciones de los pasos arrastrados
  final Map<String, Offset> _stepPositions = {};
  final Map<String, bool> _isPlaced = {};
  // Mapa para rastrear qué paso está ocupando qué DragTarget
  final Map<String, String?> _dragTargetOccupancy = {};

  // Posiciones correctas para cada elemento del diagrama (usadas para verificación y drop zones)
  final Map<String, Offset> _correctPositions = {
    'ingresar x': const Offset(110, 90),      // Primer rectángulo
    'ingresar y': const Offset(110, 160),     // Segundo rectángulo
    'z=x+y': const Offset(110, 230),          // Tercer rectángulo
    'z>10': const Offset(110, 300),           // Diamante
    'El resultado es mayor': const Offset(210, 360), // Paralelogramo derecho
    'el resultado es menor': const Offset(10, 360),  // Paralelogramo izquierdo
  };

  bool _isVerified = false;
  bool _isCorrect = false;
  bool _isAttemptsLoading = true;
  int _remainingAttempts = 3;
  bool _isAttemptsExhausted = false;
  String? _errorMessage;
  late AnimationController _animationController;

  // ScrollController para manejar el desplazamiento del SingleChildScrollView principal
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    
    // Mezclar los pasos de forma aleatoria
    _steps.shuffle(Random());
    // Inicializar posiciones y estado de colocación
    for (var step in _steps) {
      _stepPositions[step] = Offset.zero;
      _isPlaced[step] = false;
    }
    // Inicializar el mapa de ocupación de DragTargets
    for (var step in _correctPositions.keys) {
      _dragTargetOccupancy[step] = null;
    }
    // Cargar intentos desde Firestore
    _loadAttemptsFromFirestore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAttemptsFromFirestore() async {
    setState(() {
      _isAttemptsLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Usuario no autenticado.';
          _isAttemptsLoading = false;
        });
        return;
      }

      final progressDoc = await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.moduleData?['id'] ?? 'module1')
          .get();

      if (progressDoc.exists) {
        final data = progressDoc.data();
        final attempts = (data?['intentos'] as num?)?.toInt() ?? 3;
        final completed = data?['completed_activities'] as Map<String, dynamic>? ?? {};
        setState(() {
          _remainingAttempts = attempts;
          _isAttemptsExhausted = attempts <= 0 || (completed['flowchart'] ?? false);
          _isAttemptsLoading = false;
        });
      } else {
        setState(() {
          _remainingAttempts = 3;
          _isAttemptsExhausted = false;
          _isAttemptsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los intentos: $e';
        _isAttemptsLoading = false;
      });
    }
  }

  Future<void> _decrementAttempts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final newAttempts = _remainingAttempts - 1;

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.moduleData?['id'] ?? 'module1')
          .set({
        'intentos': newAttempts,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _remainingAttempts = newAttempts;
        _isAttemptsExhausted = newAttempts <= 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar los intentos: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _markActivityCompleted() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .collection('modules')
          .doc(widget.moduleData?['id'] ?? 'module1')
          .set({
        'completed_activities': {'flowchart': true},
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _isAttemptsExhausted = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar la actividad: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  void _resetPositions() {
    setState(() {
      for (var step in _steps) {
        _stepPositions[step] = Offset.zero;
        _isPlaced[step] = false;
      }
      for (var step in _correctPositions.keys) {
        _dragTargetOccupancy[step] = null;
      }
      _isVerified = false;
      _isCorrect = false;
      // Mezclar de nuevo al reiniciar
      _steps.shuffle(Random());
    });
  }

  bool _isStepOverDragTarget(String step, Offset position) {
    final correctPos = _correctPositions[step]!;
    const double width = 100.0;
    const double height = 40.0;
    return position.dx >= correctPos.dx &&
           position.dx <= correctPos.dx + width &&
           position.dy >= correctPos.dy &&
           position.dy <= correctPos.dy + height;
  }

  void _verifyPositions() {
    if (_isAttemptsExhausted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes más intentos o la actividad ya está completada.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    bool allCorrect = true;
    const double tolerance = 20.0; // Tolerancia en píxeles

    for (var step in _steps) {
      if (!_isPlaced[step]!) {
        allCorrect = false;
        break;
      }
      final correctPos = _correctPositions[step]!;
      final currentPos = _stepPositions[step]!;
      // Verificar si la posición actual está dentro de la tolerancia
      if ((currentPos.dx - correctPos.dx).abs() > tolerance ||
          (currentPos.dy - correctPos.dy).abs() > tolerance) {
        allCorrect = false;
        break;
      }
    }

    setState(() {
      _isVerified = true;
      _isCorrect = allCorrect;
    });

    if (allCorrect) {
      _markActivityCompleted();
      Navigator.pop(context, true); // Retorna true para indicar que la actividad fue completada
    } else {
      _decrementAttempts();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAttemptsLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF003459), Color(0xFF00A8E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFFFFFFFF)),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Cargando progreso...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 500.ms),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildAnimatedButton(
                    text: 'Reintentar',
                    onPressed: _loadAttemptsFromFirestore,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007EA7), Color(0xFF00A8E8)],
                    ),
                  ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                ],
              ],
            ),
          ),
        ),
      );
    }

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
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassmorphicCard(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Diseñar Diagrama de Flujo',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFFFFF),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Intentos restantes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFFFFFFFF).withOpacity(0.9),
                        ),
                      ),
                      Text(
                        '$_remainingAttempts',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _remainingAttempts > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                GlassmorphicCard(
                  child: Text(
                    'Instrucciones: Arrastra los pasos y colócalos en el lugar correcto sobre el diagrama de flujo.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFFFFFFFF).withOpacity(0.9),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                // Área del diagrama de flujo con pasos arrastrables
                GlassmorphicCard(
                  child: Stack(
                    children: [
                      // Imagen del diagrama de flujo (reemplaza con tu asset)
                      Container(
                        height: 500,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.2), width: 2),
                          image: const DecorationImage(
                            image: AssetImage('assets/flowchart.png'), // Reemplaza con la ruta de tu imagen
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Capa para los pasos arrastrables y zonas de soltar
                      SizedBox(
                        height: 500,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            // Zonas de soltar (DragTargets) como guías visuales
                            ..._correctPositions.entries.map((entry) {
                              final step = entry.key;
                              return Positioned(
                                left: entry.value.dx,
                                top: entry.value.dy,
                                child: DragTarget<String>(
                                  builder: (context, candidateData, rejectedData) {
                                    return Container(
                                      width: 100,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _dragTargetOccupancy[step] == null
                                            ? const Color(0xFFFFFFFF).withOpacity(0.3)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    );
                                  },
                                  onAcceptWithDetails: (details) {
                                    setState(() {
                                      final droppedStep = details.data;
                                      // Ajustar la posición para centrar en el DragTarget
                                      final targetPos = _correctPositions[step]!;
                                      final adjustedOffset = Offset(
                                        targetPos.dx,
                                        targetPos.dy,
                                      );

                                      // Si el DragTarget ya está ocupado, devolver el paso anterior a la lista
                                      final currentOccupant = _dragTargetOccupancy[step];
                                      if (currentOccupant != null) {
                                        _stepPositions[currentOccupant] = Offset.zero;
                                        _isPlaced[currentOccupant] = false;
                                      }

                                      // Actualizar la posición y ocupación del paso soltado
                                      _stepPositions[droppedStep] = adjustedOffset;
                                      _isPlaced[droppedStep] = true;
                                      _dragTargetOccupancy[step] = droppedStep;

                                      // Limpiar otros DragTargets que pudieran tener este paso
                                      for (var target in _dragTargetOccupancy.keys) {
                                        if (target != step && _dragTargetOccupancy[target] == droppedStep) {
                                          _dragTargetOccupancy[target] = null;
                                        }
                                      }
                                    });
                                  },
                                ),
                              );
                            }),
                            // Pasos arrastrables
                            ..._steps.map((step) {
                              return Positioned(
                                left: _stepPositions[step]!.dx,
                                top: _stepPositions[step]!.dy,
                                child: Draggable<String>(
                                  data: step,
                                  feedback: Material(
                                    elevation: 4.0,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 100,
                                      padding: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF).withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        step,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: const Color(0xFF003459),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Container(),
                                  child: _isPlaced[step]!
                                      ? Container(
                                          width: 100,
                                          padding: const EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFFFF).withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            step,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: const Color(0xFF003459),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        )
                                      : Container(),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                const SizedBox(height: 20),
                // Lista de pasos disponibles para arrastrar
                GlassmorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pasos disponibles:',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4FC3F7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.2), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _steps.map((step) {
                                return !_isPlaced[step]!
                                    ? Draggable<String>(
                                        data: step,
                                        feedback: Material(
                                          elevation: 4.0,
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            width: 100,
                                            padding: const EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFFFFF).withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              step,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: const Color(0xFF003459),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        childWhenDragging: Container(),
                                        child: Container(
                                          width: 100,
                                          padding: const EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFFFFF).withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            step,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: const Color(0xFF003459),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      _buildAnimatedButton(
                        text: 'Revisar',
                        onPressed: _isAttemptsExhausted ? null : _verifyPositions,
                        gradient: LinearGradient(
                          colors: _isAttemptsExhausted
                              ? [Colors.grey.shade600, Colors.grey.shade400]
                              : [const Color(0xFF007EA7), const Color(0xFF00A8E8)],
                        ),
                      ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 16),
                      if (_isVerified)
                        Text(
                          _isCorrect ? '¡Correcto!' : 'Incorrecto, revisa las posiciones',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ).animate().fadeIn(delay: 500.ms),
                      const SizedBox(height: 16),
                      _buildAnimatedButton(
                        text: 'Reiniciar Actividad',
                        onPressed: _isAttemptsExhausted ? null : _resetPositions,
                        gradient: LinearGradient(
                          colors: _isAttemptsExhausted
                              ? [Colors.grey.shade600, Colors.grey.shade400]
                              : [const Color(0xFF007EA7), const Color(0xFF00A8E8)],
                        ),
                      ).animate().fadeIn(delay: 600.ms).scale(delay: 600.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 16),
                      _buildAnimatedButton(
                        text: 'Volver a Actividades',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        gradient: const LinearGradient(
                          colors: [Color(0xFF007EA7), Color(0xFF00A8E8)],
                        ),
                      ).animate().fadeIn(delay: 700.ms).scale(delay: 700.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
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
              color: Colors.black.withOpacity(0.2),
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
            color: const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}

class GlassmorphicCard extends StatelessWidget {
  final Widget child;

  const GlassmorphicCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}