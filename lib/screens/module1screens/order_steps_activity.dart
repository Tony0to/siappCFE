import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class OrderStepsActivityScreen extends StatefulWidget {
  final Map<String, dynamic>? moduleData;

  const OrderStepsActivityScreen({Key? key, this.moduleData}) : super(key: key);

  @override
  _OrderStepsActivityScreenState createState() => _OrderStepsActivityScreenState();
}

class _OrderStepsActivityScreenState extends State<OrderStepsActivityScreen> with TickerProviderStateMixin {
  int _currentActivityIndex = 0;
  bool _answersChecked = false;
  final Map<int, List<String>> _userOrderedSteps = {};
  final Map<int, List<bool>> _correctOrders = {};
  bool _isAttemptsLoading = true;
  int _remainingAttempts = 3;
  bool _isAttemptsExhausted = false;
  String? _errorMessage;
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _activities = [
    {
      'title': 'Hacer una reserva en un restaurante',
      'steps': [
        'Elegir el restaurante donde deseas hacer la reserva.',
        'Verificar disponibilidad de mesas en la fecha y hora deseadas.',
        'Contactar al restaurante (por teléfono, en persona o a través de su plataforma en línea).',
        'Proporcionar la información necesaria (nombre, número de personas, fecha y hora).',
        'Confirmar los detalles de la reserva y cualquier requerimiento especial.',
        'Guardar o anotar la confirmación de la reserva.',
        'Asistir al restaurante en la fecha y hora establecidas.',
      ],
    },
    {
      'title': 'Enviar un paquete por correo',
      'steps': [
        'Preparar el paquete asegurándose de que esté bien embalado.',
        'Escribir la dirección del destinatario correctamente en la caja o etiqueta.',
        'Elegir un servicio de mensajería o empresa de correos.',
        'Ir a la oficina de correos o solicitar una recogida a domicilio.',
        'Pagar el costo del envío y obtener el comprobante.',
        'Guardar el número de rastreo para dar seguimiento al paquete.',
        'Confirmar la entrega con el destinatario.',
      ],
    },
    {
      'title': 'Registrarse en una plataforma en línea',
      'steps': [
        'Ingresar al sitio web o aplicación de la plataforma.',
        'Hacer clic en el botón de "Registro" o "Crear cuenta".',
        'Completar el formulario con la información requerida (nombre, correo electrónico, contraseña).',
        'Aceptar los términos y condiciones de uso.',
        'Verificar la cuenta a través de un código enviado por correo electrónico o SMS.',
        'Iniciar sesión con las credenciales creadas.',
        'Configurar el perfil agregando información adicional si es necesario.',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Desordenar los pasos de cada actividad al inicio
    for (int i = 0; i < _activities.length; i++) {
      final steps = List<String>.from(_activities[i]['steps']);
      steps.shuffle(Random());
      _userOrderedSteps[i] = steps;
    }

    _loadAttemptsFromFirestore();
  }

  @override
  void dispose() {
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
          _isAttemptsExhausted = attempts <= 0 || (completed['order_steps'] ?? false);
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
        'completed_activities': {'order_steps': true},
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

  void _checkAnswers() {
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
    for (int i = 0; i < _activities.length; i++) {
      final correctSteps = _activities[i]['steps'] as List<String>;
      final userSteps = _userOrderedSteps[i]!;
      _correctOrders[i] = List<bool>.generate(userSteps.length, (index) => userSteps[index] == correctSteps[index]);
      if (_correctOrders[i]!.contains(false)) {
        allCorrect = false;
      }
    }
    setState(() {
      _answersChecked = true;
    });

    if (allCorrect) {
      _markActivityCompleted();
      Navigator.pop(context, true); // Retorna true para indicar que la actividad fue completada
    } else {
      _decrementAttempts();
    }
  }

  void _resetActivity() {
    if (_isAttemptsExhausted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes más intentos o la actividad ya está completada.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _currentActivityIndex = 0;
      _answersChecked = false;
      _correctOrders.clear();
      for (int i = 0; i < _activities.length; i++) {
        final steps = List<String>.from(_activities[i]['steps']);
        steps.shuffle(Random());
        _userOrderedSteps[i] = steps;
      }
    });
  }

  void _nextActivity() {
    if (_currentActivityIndex < _activities.length - 1) {
      setState(() {
        _currentActivityIndex++;
      });
    } else {
      _checkAnswers();
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
                          'Ordenar Pasos de Actividades',
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
                const SizedBox(height: 16), // Reducido de 20 a 16
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
                const SizedBox(height: 16), // Reducido de 20 a 16
                GlassmorphicCard(
                  child: Text(
                    'Instrucciones: Ordena los pasos en el orden correcto para completar cada actividad.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFFFFFFFF).withOpacity(0.9),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 16), // Reducido de 20 a 16
                if (!_answersChecked) ...[
                  GlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actividad ${_currentActivityIndex + 1} de ${_activities.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFFFFFFFF).withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8), // Reducido de 10 a 8
                        Text(
                          _activities[_currentActivityIndex]['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4FC3F7),
                          ),
                        ),
                        const SizedBox(height: 12), // Reducido de 20 a 12
                        Container(
                          height: 600, // Reducido de 600 a 300
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.2)),
                          ),
                          child: ReorderableListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(2), // Padding reducido
                            physics: const AlwaysScrollableScrollPhysics(),
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final step = _userOrderedSteps[_currentActivityIndex]!.removeAt(oldIndex);
                                _userOrderedSteps[_currentActivityIndex]!.insert(newIndex, step);
                              });
                            },
                            children: _userOrderedSteps[_currentActivityIndex]!
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final step = entry.value;
                                  return GlassmorphicCard(
                                    key: ValueKey('$index-$step-${_currentActivityIndex}'),
                                    child: ListTile(
                                      dense: true, // Hace el ListTile más compacto
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Padding reducido
                                      visualDensity: VisualDensity.compact, // Compacta aún más
                                      leading: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12, // Reducido de 20 a 12
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFFFFFFF),
                                        ),
                                      ),
                                      title: Text(
                                        step,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12, // Reducido de 16 a 12
                                          color: const Color(0xFFFFFFFF).withOpacity(0.9),
                                        ),
                                      ),
                                      trailing: ReorderableDragStartListener(
                                        index: index,
                                        child: const Icon(
                                          Icons.drag_handle,
                                          color: Color(0xFFFFFFFF),
                                          size: 18, // Reducido de 20 a 18 para mantener proporciones
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  const SizedBox(height: 16), // Reducido de 30 a 16
                  Center(
                    child: _buildAnimatedButton(
                      text: _currentActivityIndex < _activities.length - 1 ? 'Siguiente Actividad' : 'Verificar Orden',
                      onPressed: _isAttemptsExhausted ? null : _nextActivity,
                      gradient: LinearGradient(
                        colors: _isAttemptsExhausted
                            ? [Colors.grey.shade600, Colors.grey.shade400]
                            : [const Color(0xFF007EA7), const Color(0xFF00A8E8)],
                      ),
                    ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  ),
                ],
                if (_answersChecked) ...[
                  GlassmorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resultados',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4FC3F7),
                          ),
                        ),
                        const SizedBox(height: 12), // Reducido de 20 a 12
                        ..._activities.asMap().entries.map((entry) {
                          final index = entry.key;
                          final activity = entry.value;
                          return GlassmorphicCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity['title'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                ),
                                const SizedBox(height: 8), // Reducido de 10 a 8
                                ..._userOrderedSteps[index]!.asMap().entries.map((stepEntry) {
                                  final stepIndex = stepEntry.key;
                                  final step = stepEntry.value;
                                  final isCorrect = _correctOrders[index]![stepIndex];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCorrect ? Icons.check_circle : Icons.cancel,
                                          color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                          size: 18, // Reducido para mantener proporciones
                                        ),
                                        const SizedBox(width: 6), // Reducido de 8 a 6
                                        Expanded(
                                          child: Text(
                                            step,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12, // Reducido de 16 a 12
                                              color: isCorrect
                                                  ? const Color(0xFFFFFFFF).withOpacity(0.9)
                                                  : const Color(0xFFEF4444),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  const SizedBox(height: 16), // Reducido de 30 a 16
                  Center(
                    child: Column(
                      children: [
                        _buildAnimatedButton(
                          text: 'Reiniciar Actividad',
                          onPressed: _isAttemptsExhausted ? null : _resetActivity,
                          gradient: LinearGradient(
                            colors: _isAttemptsExhausted
                                ? [Colors.grey.shade600, Colors.grey.shade400]
                                : [const Color(0xFF007EA7), Color(0xFF00A8E8)],
                          ),
                        ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 12), // Reducido de 16 a 12
                        _buildAnimatedButton(
                          text: 'Volver a Actividades',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          gradient: const LinearGradient(
                            colors: [Color(0xFF007EA7), Color(0xFF00A8E8)],
                          ),
                        ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16), // Reducido de 30 a 16
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), // Reducido vertical de 12 a 10
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
            fontSize: 15, // Reducido de 16 a 15
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
  final Key? key;

  const GlassmorphicCard({this.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 2), // Reducido de 8 a 2
      padding: const EdgeInsets.all(8), // Reducido de 16 a 8
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