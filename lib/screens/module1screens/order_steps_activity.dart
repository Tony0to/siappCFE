import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:siapp/theme/app_colors.dart';
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
  String? _statusMessage;
  bool _isCompleted = false;
  bool _isLocked = false;
  double _score = 0.0;
  List<int> _wrongActivities = [];
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _verifyAnswers() {
    _wrongActivities.clear();
    int totalSteps = 0;
    int correctSteps = 0;

    for (int i = 0; i < _activities.length; i++) {
      final correctStepsList = _activities[i]['steps'] as List<String>;
      final userSteps = _userOrderedSteps[i]!;
      totalSteps += userSteps.length;

      // Initialize _correctOrders[i] to track correct/incorrect steps
      final List<bool> isCorrectList = List<bool>.generate(
        userSteps.length,
        (index) => userSteps[index] == correctStepsList[index],
      );
      _correctOrders[i] = isCorrectList;

      // Count correct steps
      for (bool isCorrect in isCorrectList) {
        if (isCorrect) {
          correctSteps++;
        }
      }

      // Mark activity as wrong if it contains any incorrect steps
      if (isCorrectList.contains(false)) {
        _wrongActivities.add(i);
      }
    }

    _score = (correctSteps / totalSteps) * 100;
    final passed = _score >= 70;

    setState(() {
      _answersChecked = true;
      _isCompleted = passed;
      _isLocked = passed;
      _statusMessage =
          'Calificación: ${_score.toStringAsFixed(1)}% ${passed ? "✅" : "❌"} Actividades con errores: ${_wrongActivities.length}';
    });

    _showResultDialog(passed);
  }

  void _resetActivity() {
    if (_isLocked) return;

    setState(() {
      _currentActivityIndex = 0;
      _answersChecked = false;
      _correctOrders.clear();
      _statusMessage = null;
      _isCompleted = false;
      _isLocked = false;
      _score = 0.0;
      _wrongActivities.clear();
      for (int i = 0; i < _activities.length; i++) {
        final steps = List<String>.from(_activities[i]['steps']);
        steps.shuffle(Random());
        _userOrderedSteps[i] = steps;
      }
    });
  }

  void _nextActivity() {
    if (_isLocked) return;

    if (_currentActivityIndex < _activities.length - 1) {
      setState(() {
        _currentActivityIndex++;
      });
    } else {
      _verifyAnswers();
    }
  }

  void _previousActivity() {
    if (_isLocked || _currentActivityIndex <= 0) return;

    setState(() {
      _currentActivityIndex--;
    });
  }

  void _completeActivity() {
    Navigator.pop(context, {'score': _score, 'passed': _isCompleted});
  }

  Future<void> _showResultDialog(bool passed) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              passed ? Icons.check_circle : Icons.error,
              color: passed ? AppColors.success : AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              passed ? '¡Actividad Completada!' : 'Actividad No Aprobada',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calificación: ${_score.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (_wrongActivities.isNotEmpty && !passed) ...[
                Text(
                  'Actividades con pasos incorrectos:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                ..._wrongActivities.map((index) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Text(
                        '• ${_activities[index]['title']}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )),
              ],
              if (passed)
                Text(
                  '¡Felicidades! Has completado la actividad.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (passed) _completeActivity();
            },
            child: Text(
              'Aceptar',
              style: GoogleFonts.poppins(color: AppColors.progressActive),
            ),
          ),
        ],
      ),
    );
  }

  void _showGradingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'Criterios de Evaluación',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para aprobar esta actividad, debes ordenar correctamente al menos el 70% de los pasos en todas las actividades.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• Cada actividad tiene una lista de pasos que deben ordenarse según el procedimiento correcto.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• La calificación se calcula como el porcentaje de pasos ordenados correctamente en todas las actividades.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Se aprueba con una calificación de 70% o más.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: GoogleFonts.poppins(color: AppColors.progressActive),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            heroTag: null,
            backgroundColor: AppColors.glassmorphicBackground,
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _showGradingInfo,
            heroTag: null,
            backgroundColor: AppColors.backgroundDark,
            child: const Icon(Icons.info, color: Colors.white),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassmorphicCard(
                child: Text(
                  'Ordenar Pasos de Actividades',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
              const SizedBox(height: 20),
              if (_statusMessage != null)
                GlassmorphicCard(
                  child: Text(
                    _statusMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: _isCompleted ? AppColors.success : AppColors.textPrimary,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              GlassmorphicCard(
                child: Text(
                  'Instrucciones: Ordena los pasos en el orden correcto para completar cada actividad.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              if (!_answersChecked) ...[
                GlassmorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actividad ${_currentActivityIndex + 1} de ${_activities.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _activities[_currentActivityIndex]['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.progressActive,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 600,
                        decoration: BoxDecoration(
                          color: AppColors.glassmorphicBackground.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassmorphicBorder),
                        ),
                        child: ReorderableListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          physics: const AlwaysScrollableScrollPhysics(),
                          onReorder: (oldIndex, newIndex) {
                            if (_isLocked) return;
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
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    leading: Text(
                                      '${index + 1}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    title: Text(
                                      step,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    trailing: ReorderableDragStartListener(
                                      index: index,
                                      child: const Icon(
                                        Icons.drag_handle,
                                        color: Colors.white,
                                        size: 24,
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
                const SizedBox(height: 30),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_currentActivityIndex > 0)
                        _buildAnimatedButton(
                          text: 'Anterior',
                          onPressed: _isLocked ? null : _previousActivity,
                          gradient: LinearGradient(
                            colors: _isLocked
                                ? [Colors.grey.shade600, Colors.grey.shade400]
                                : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                          ),
                        ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                      if (_currentActivityIndex > 0) const SizedBox(width: 16),
                      _buildAnimatedButton(
                        text: _currentActivityIndex < _activities.length - 1 ? 'Siguiente' : 'Verificar Orden',
                        onPressed: _isLocked ? null : _nextActivity,
                        gradient: LinearGradient(
                          colors: _isLocked
                              ? [Colors.grey.shade600, Colors.grey.shade400]
                              : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                        ),
                      ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    ],
                  ),
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
                          color: AppColors.progressActive,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._activities.asMap().entries.map((entry) {
                        final index = entry.key;
                        final activity = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GlassmorphicCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity['title'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ..._userOrderedSteps[index]!.asMap().entries.map((stepEntry) {
                                  final stepIndex = stepEntry.key;
                                  final step = stepEntry.value;
                                  final isCorrect = _correctOrders[index]![stepIndex];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      border: _wrongActivities.contains(index) && !isCorrect && !_isCompleted
                                          ? Border.all(color: AppColors.error, width: 2)
                                          : null,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isCorrect ? Icons.check_circle : Icons.cancel,
                                            color: isCorrect ? AppColors.success : AppColors.error,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              step,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: isCorrect ? AppColors.textPrimary : AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                const SizedBox(height: 30),
                Center(
                  child: _buildAnimatedButton(
                    text: 'Reiniciar Actividad',
                    onPressed: _isLocked ? null : _resetActivity,
                    gradient: LinearGradient(
                      colors: _isLocked
                          ? [Colors.grey.shade600, Colors.grey.shade400]
                          : [AppColors.progressActive, AppColors.progressActive.withOpacity(0.8)],
                    ),
                  ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                ),
              ],
              const SizedBox(height: 40),
            ],
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
            color: AppColors.textPrimary,
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassmorphicBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassmorphicBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}